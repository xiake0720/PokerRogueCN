#!/usr/bin/env python3
"""Deterministically slice transparent UI sprite sheets for Godot.

The tool is intentionally offline: it never touches ``.godot`` and it refuses
to write into ``art_source/ui``.  Slice definitions live in
``tools/ui_asset_slices.json`` so every runtime PNG can be reproduced and
audited without doing image work at game runtime.
"""

from __future__ import annotations

import argparse
from collections import deque
import hashlib
import io
import json
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterable

try:
    from PIL import Image, ImageChops, UnidentifiedImageError
except ImportError as exc:  # pragma: no cover - actionable CLI failure
    raise SystemExit("Pillow is required: python -m pip install Pillow") from exc


REPO_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_CONFIG = REPO_ROOT / "tools" / "ui_asset_slices.json"
ART_SOURCE_ROOT = (REPO_ROOT / "art_source" / "ui").resolve()
GENERATOR_PATH = "res://tools/ui_asset_slicer.py"


class SliceError(RuntimeError):
    """Raised when an input or output would violate the asset contract."""


@dataclass(frozen=True)
class EncodedPng:
    data: bytes
    size: tuple[int, int]
    alpha_bbox: tuple[int, int, int, int]
    alpha_min: int
    alpha_max: int
    edge_alpha_max: int


def _sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def _project_path(raw_path: str, *, label: str) -> Path:
    if not raw_path or raw_path.startswith("res://"):
        raw_path = raw_path.removeprefix("res://")
    candidate = (REPO_ROOT / raw_path).resolve()
    try:
        candidate.relative_to(REPO_ROOT)
    except ValueError as exc:
        raise SliceError(f"{label} escapes the project root: {raw_path}") from exc
    return candidate


def _resource_path(path: Path) -> str:
    relative = path.resolve().relative_to(REPO_ROOT).as_posix()
    return f"res://{relative}"


def _source_reference(path: Path) -> str:
    relative = path.resolve().relative_to(REPO_ROOT).as_posix()
    if path.resolve().is_relative_to(ART_SOURCE_ROOT):
        return relative
    return f"res://{relative}"


def _rect_xywh(value: Any, source_size: tuple[int, int], asset_id: str) -> tuple[int, int, int, int]:
    if value is None:
        return 0, 0, source_size[0], source_size[1]
    if not isinstance(value, list) or len(value) != 4 or not all(isinstance(item, int) for item in value):
        raise SliceError(f"{asset_id}: rect must be [x, y, width, height] integers")
    x, y, width, height = value
    if x < 0 or y < 0 or width <= 0 or height <= 0:
        raise SliceError(f"{asset_id}: rect has invalid values: {value}")
    if x + width > source_size[0] or y + height > source_size[1]:
        raise SliceError(f"{asset_id}: rect {value} exceeds source size {source_size}")
    return x, y, width, height


def _dimension_pair(value: Any, label: str, asset_id: str) -> tuple[int, int] | None:
    if value is None:
        return None
    if not isinstance(value, list) or len(value) != 2 or not all(isinstance(item, int) for item in value):
        raise SliceError(f"{asset_id}: {label} must be [width, height] integers")
    return int(value[0]), int(value[1])


def _edge_alpha_max(image: Image.Image) -> int:
    alpha = image.getchannel("A")
    width, height = image.size
    edge_values: list[int] = []
    edge_values.extend(alpha.crop((0, 0, width, 1)).getdata())
    edge_values.extend(alpha.crop((0, height - 1, width, height)).getdata())
    edge_values.extend(alpha.crop((0, 0, 1, height)).getdata())
    edge_values.extend(alpha.crop((width - 1, 0, width, height)).getdata())
    return max(edge_values, default=0)


def _encode_png(image: Image.Image) -> EncodedPng:
    rgba = image.convert("RGBA")
    alpha = rgba.getchannel("A")
    alpha_bbox = alpha.getbbox()
    if alpha_bbox is None:
        raise SliceError("output is fully transparent")
    extrema = alpha.getextrema()
    buffer = io.BytesIO()
    # Fixed parameters make repeated runs byte-for-byte stable.
    rgba.save(buffer, format="PNG", optimize=False, compress_level=9)
    return EncodedPng(
        data=buffer.getvalue(),
        size=rgba.size,
        alpha_bbox=tuple(int(item) for item in alpha_bbox),
        alpha_min=int(extrema[0]),
        alpha_max=int(extrema[1]),
        edge_alpha_max=_edge_alpha_max(rgba),
    )


def _validate_size(encoded: EncodedPng, definition: dict[str, Any], asset_id: str) -> None:
    exact = _dimension_pair(definition.get("expected_size"), "expected_size", asset_id)
    minimum = _dimension_pair(definition.get("min_size"), "min_size", asset_id)
    maximum = _dimension_pair(definition.get("max_size"), "max_size", asset_id)
    width, height = encoded.size
    if exact is not None and encoded.size != exact:
        raise SliceError(f"{asset_id}: output size {encoded.size} != expected {exact}")
    if minimum is not None and (width < minimum[0] or height < minimum[1]):
        raise SliceError(f"{asset_id}: output size {encoded.size} is below minimum {minimum}")
    if maximum is not None and (width > maximum[0] or height > maximum[1]):
        raise SliceError(f"{asset_id}: output size {encoded.size} exceeds maximum {maximum}")


def _write_if_changed(path: Path, data: bytes, *, validate_only: bool) -> str:
    current = path.read_bytes() if path.exists() else None
    if current == data:
        return "unchanged"
    if validate_only:
        if current is None:
            raise SliceError(f"missing generated output: {_resource_path(path)}")
        raise SliceError(f"stale generated output: {_resource_path(path)}")
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(data)
    return "created" if current is None else "updated"


def _load_source(path: Path, *, asset_id: str) -> tuple[Image.Image, bytes, bool]:
    if path.suffix.lower() != ".png":
        raise SliceError(f"{asset_id}: source must be a PNG: {_resource_path(path)}")
    if not path.is_file():
        raise SliceError(f"{asset_id}: source not found: {_resource_path(path)}")
    source_bytes = path.read_bytes()
    try:
        with Image.open(io.BytesIO(source_bytes)) as opened:
            opened.load()
            has_alpha = "A" in opened.getbands() or "transparency" in opened.info
            image = opened.convert("RGBA")
    except (UnidentifiedImageError, OSError) as exc:
        raise SliceError(f"{asset_id}: invalid PNG: {_resource_path(path)}") from exc
    return image, source_bytes, has_alpha


def _slice_image(source: Image.Image, definition: dict[str, Any], asset_id: str) -> tuple[Image.Image, list[int]]:
    x, y, width, height = _rect_xywh(definition.get("rect"), source.size, asset_id)
    result = source.crop((x, y, x + width, y + height))
    component_seed = definition.get("component_seed")
    if component_seed is not None:
        if (
            not isinstance(component_seed, list)
            or len(component_seed) != 2
            or not all(isinstance(item, int) for item in component_seed)
        ):
            raise SliceError(f"{asset_id}: component_seed must be [x, y] within the configured rectangle")
        seed_x, seed_y = int(component_seed[0]), int(component_seed[1])
        if seed_x < 0 or seed_y < 0 or seed_x >= result.width or seed_y >= result.height:
            raise SliceError(f"{asset_id}: component_seed {component_seed} is outside the configured rectangle")
        alpha = result.getchannel("A")
        alpha_bytes = alpha.tobytes()
        seed_index = seed_y * result.width + seed_x
        if alpha_bytes[seed_index] == 0:
            nearest: tuple[int, int] | None = None
            for radius in range(1, max(result.width, result.height)):
                left = max(0, seed_x - radius)
                right = min(result.width - 1, seed_x + radius)
                top = max(0, seed_y - radius)
                bottom = min(result.height - 1, seed_y + radius)
                candidates = (
                    ((scan_x, top) for scan_x in range(left, right + 1)),
                    ((scan_x, bottom) for scan_x in range(left, right + 1)),
                    ((left, scan_y) for scan_y in range(top + 1, bottom)),
                    ((right, scan_y) for scan_y in range(top + 1, bottom)),
                )
                for edge in candidates:
                    for scan_x, scan_y in edge:
                        if alpha_bytes[scan_y * result.width + scan_x] > 0:
                            nearest = (scan_x, scan_y)
                            break
                    if nearest is not None:
                        break
                if nearest is not None:
                    seed_x, seed_y = nearest
                    seed_index = seed_y * result.width + seed_x
                    break
            if nearest is None:
                raise SliceError(f"{asset_id}: component_seed rectangle contains no visible pixels")

        visited = bytearray(result.width * result.height)
        kept = bytearray(result.width * result.height)
        queue: deque[int] = deque([seed_index])
        visited[seed_index] = 1
        while queue:
            index = queue.popleft()
            if alpha_bytes[index] == 0:
                continue
            kept[index] = 255
            px = index % result.width
            py = index // result.width
            for neighbor_y in range(max(0, py - 1), min(result.height, py + 2)):
                row_offset = neighbor_y * result.width
                for neighbor_x in range(max(0, px - 1), min(result.width, px + 2)):
                    neighbor = row_offset + neighbor_x
                    if not visited[neighbor] and alpha_bytes[neighbor] > 0:
                        visited[neighbor] = 1
                        queue.append(neighbor)
        component_mask = Image.frombytes("L", result.size, bytes(kept))
        result.putalpha(ImageChops.multiply(alpha, component_mask))
    trim_alpha = bool(definition.get("trim_alpha", True))
    if trim_alpha:
        alpha_bbox = result.getchannel("A").getbbox()
        if alpha_bbox is None:
            raise SliceError(f"{asset_id}: configured rectangle contains no visible pixels")
        result = result.crop(alpha_bbox)
    if bool(definition.get("flip_x", False)):
        result = result.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
    if bool(definition.get("flip_y", False)):
        result = result.transpose(Image.Transpose.FLIP_TOP_BOTTOM)
    padding = int(definition.get("padding", 4))
    if padding < 0 or padding > 256:
        raise SliceError(f"{asset_id}: padding must be between 0 and 256")
    if padding:
        padded = Image.new("RGBA", (result.width + padding * 2, result.height + padding * 2), (0, 0, 0, 0))
        padded.alpha_composite(result, (padding, padding))
        result = padded
    return result, [x, y, width, height]


def _asset_record(
    definition: dict[str, Any],
    *,
    asset_id: str,
    source_path: Path,
    source_sha: str,
    source_size: tuple[int, int],
    source_has_alpha: bool,
    source_rect: list[int],
    output_path: Path,
    encoded: EncodedPng,
) -> dict[str, Any]:
    return {
        "id": asset_id,
        "scene": str(definition.get("scene", "shared")),
        "category": str(definition.get("category", "misc")),
        "path": _resource_path(output_path),
        "source": _source_reference(source_path),
        "source_sha256": source_sha,
        "source_size": list(source_size),
        "source_has_alpha": source_has_alpha,
        "source_rect_xywh": source_rect,
        "trim_alpha": bool(definition.get("trim_alpha", True)),
        "padding": int(definition.get("padding", 4)),
        "transform": {
            "flip_x": bool(definition.get("flip_x", False)),
            "flip_y": bool(definition.get("flip_y", False)),
        },
        "component_seed": definition.get("component_seed"),
        "output_size": list(encoded.size),
        "output_alpha_bbox": list(encoded.alpha_bbox),
        "alpha_range": [encoded.alpha_min, encoded.alpha_max],
        "edge_alpha_max": encoded.edge_alpha_max,
        "output_sha256": _sha256(encoded.data),
        "generated": False,
        "usage": str(definition.get("usage", "")),
        "tags": sorted(str(item) for item in definition.get("tags", [])),
        "validation": "passed",
    }


def _validate_external(definition: dict[str, Any], seen_ids: set[str]) -> dict[str, Any]:
    asset_id = str(definition.get("id", "")).strip()
    if not asset_id or asset_id in seen_ids:
        raise SliceError(f"external asset has missing or duplicate id: {asset_id!r}")
    seen_ids.add(asset_id)
    path = _project_path(str(definition.get("path", "")), label=f"{asset_id} path")
    image, source_bytes, has_alpha = _load_source(path, asset_id=asset_id)
    encoded = _encode_png(image)
    allow_opaque_edges = bool(definition.get("allow_opaque_edges", False))
    if encoded.edge_alpha_max > 0 and not allow_opaque_edges:
        raise SliceError(f"{asset_id}: external asset has visible pixels touching its edge")
    _validate_size(encoded, definition, asset_id)
    return {
        "id": asset_id,
        "scene": str(definition.get("scene", "shared")),
        "category": str(definition.get("category", "generated")),
        "path": _resource_path(path),
        "source": str(definition.get("source", "res://tools/generate_card_fallbacks.py")),
        "source_sha256": _sha256(source_bytes),
        "source_size": list(image.size),
        "source_has_alpha": has_alpha,
        "source_rect_xywh": [0, 0, image.width, image.height],
        "trim_alpha": False,
        "padding": 0,
        "transform": {"flip_x": False, "flip_y": False},
        "output_size": list(encoded.size),
        "output_alpha_bbox": list(encoded.alpha_bbox),
        "alpha_range": [encoded.alpha_min, encoded.alpha_max],
        "edge_alpha_max": encoded.edge_alpha_max,
        "output_sha256": _sha256(source_bytes),
        "generated": bool(definition.get("generated", True)),
        "usage": str(definition.get("usage", "")),
        "tags": sorted(str(item) for item in definition.get("tags", [])),
        "validation": "passed",
    }


def _manifest_bytes(config_path: Path, output_root: Path, records: Iterable[dict[str, Any]]) -> bytes:
    assets = sorted(records, key=lambda item: item["id"])
    sources = sorted({item["source"] for item in assets})
    payload = {
        "schema_version": 1,
        "generator": GENERATOR_PATH,
        "config": _resource_path(config_path),
        "output_root": _resource_path(output_root),
        "asset_count": len(assets),
        "source_count": len(sources),
        "sources": sources,
        "assets": assets,
    }
    return (json.dumps(payload, ensure_ascii=False, indent=2, sort_keys=False) + "\n").encode("utf-8")


def run(config_path: Path, *, validate_only: bool = False, quiet: bool = False) -> tuple[int, int]:
    if not config_path.is_file():
        raise SliceError(f"config not found: {config_path}")
    try:
        config = json.loads(config_path.read_text(encoding="utf-8-sig"))
    except (json.JSONDecodeError, OSError) as exc:
        raise SliceError(f"invalid config JSON: {config_path}") from exc
    if int(config.get("schema_version", 0)) != 1:
        raise SliceError("unsupported slice config schema_version")

    output_root = _project_path(str(config.get("output_root", "assets/ui/runtime")), label="output_root")
    try:
        output_root.relative_to(ART_SOURCE_ROOT)
    except ValueError:
        pass
    else:
        raise SliceError("output_root must not be inside art_source/ui")
    manifest_path = _project_path(
        str(config.get("manifest", "assets/ui/runtime/ui_asset_catalog.json")), label="manifest"
    )
    if manifest_path.suffix.lower() != ".json":
        raise SliceError("manifest must be a JSON file")

    records: list[dict[str, Any]] = []
    seen_ids: set[str] = set()
    changed = 0
    unchanged = 0
    for source_definition in config.get("sources", []):
        source_path = _project_path(str(source_definition.get("path", "")), label="source")
        source_image, source_bytes, source_has_alpha = _load_source(source_path, asset_id=str(source_path.name))
        source_sha = _sha256(source_bytes)
        for definition_raw in source_definition.get("slices", []):
            definition = dict(definition_raw)
            definition.setdefault("scene", source_definition.get("scene", "shared"))
            asset_id = str(definition.get("id", "")).strip()
            if not asset_id or asset_id in seen_ids:
                raise SliceError(f"slice has missing or duplicate id: {asset_id!r}")
            seen_ids.add(asset_id)
            output_relative = str(definition.get("output", ""))
            output_path = _project_path(str(Path(config["output_root"]) / output_relative), label=f"{asset_id} output")
            try:
                output_path.relative_to(output_root)
            except ValueError as exc:
                raise SliceError(f"{asset_id}: output escapes output_root") from exc
            if output_path.suffix.lower() != ".png":
                raise SliceError(f"{asset_id}: output must end in .png")
            if output_path == source_path:
                raise SliceError(f"{asset_id}: output would overwrite its source")

            output_image, source_rect = _slice_image(source_image, definition, asset_id)
            encoded = _encode_png(output_image)
            allow_opaque_edges = bool(definition.get("allow_opaque_edges", False))
            if encoded.edge_alpha_max > 0 and not allow_opaque_edges:
                raise SliceError(
                    f"{asset_id}: visible pixels touch the output edge (alpha={encoded.edge_alpha_max}); "
                    "increase padding or explicitly allow opaque edges"
                )
            _validate_size(encoded, definition, asset_id)
            state = _write_if_changed(output_path, encoded.data, validate_only=validate_only)
            changed += int(state != "unchanged")
            unchanged += int(state == "unchanged")
            records.append(
                _asset_record(
                    definition,
                    asset_id=asset_id,
                    source_path=source_path,
                    source_sha=source_sha,
                    source_size=source_image.size,
                    source_has_alpha=source_has_alpha,
                    source_rect=source_rect,
                    output_path=output_path,
                    encoded=encoded,
                )
            )
            if not quiet:
                print(f"{state:9} {asset_id:36} {_resource_path(output_path)} {encoded.size[0]}x{encoded.size[1]}")

    for definition in config.get("external_assets", []):
        records.append(_validate_external(definition, seen_ids))

    manifest_data = _manifest_bytes(config_path, output_root, records)
    manifest_state = _write_if_changed(manifest_path, manifest_data, validate_only=validate_only)
    changed += int(manifest_state != "unchanged")
    unchanged += int(manifest_state == "unchanged")
    if not quiet:
        print(f"{manifest_state:9} ui_asset_catalog                     {_resource_path(manifest_path)}")
        print(f"validated {len(records)} assets; changed={changed}, unchanged={unchanged}")
    return changed, unchanged


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--config", type=Path, default=DEFAULT_CONFIG, help="slice config JSON")
    parser.add_argument(
        "--validate-only",
        action="store_true",
        help="fail when an output is missing/stale; never write files",
    )
    parser.add_argument("--quiet", action="store_true", help="only print errors")
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(sys.argv[1:] if argv is None else argv)
    config_path = args.config if args.config.is_absolute() else (REPO_ROOT / args.config).resolve()
    try:
        run(config_path, validate_only=args.validate_only, quiet=args.quiet)
    except SliceError as exc:
        print(f"ui_asset_slicer: {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
