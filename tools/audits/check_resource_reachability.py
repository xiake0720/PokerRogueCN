#!/usr/bin/env python3
"""CI-friendly checks for Godot resource reachability and repository hygiene."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
from collections import defaultdict
from datetime import datetime, timezone
from pathlib import Path, PurePosixPath
from typing import Any, Iterable, Iterator, Sequence


ROOT = Path(__file__).resolve().parents[2]
SKIP_DIRS = {".git", ".godot", "__pycache__", "artifacts", "output"}
IMAGE_EXTENSIONS = {".png", ".jpg", ".jpeg", ".webp", ".svg"}
RESOURCE_RE = re.compile(r"res://[A-Za-z0-9_./%{}+:-]+")
WINDOWS_PATH_RE = re.compile(r"(?<![A-Za-z0-9_])(?:[A-Za-z]:[\\/])")
NEGATIVE_RESOURCES = {
    "res://scenes/game/stage_select_screen.tscn",
    "res://scenes/game/battle_screen.tscn",
    "res://scenes/game/settlement_screen.tscn",
    "res://scenes/shop/joker_shop_screen.tscn",
}
INTENTIONAL_MISSING_RESOURCES = {
    ("tests/test_button_integrity.gd", "res://scenes/archive"),
}
MANIFESTS = (
    "assets/cards/card_art_manifest.json",
    "assets/ui/runtime/ui_asset_catalog.json",
    "tools/art_pipeline/manifests/asset_manifest.json",
    "tools/art_pipeline/manifests/extracted_asset_manifest.json",
    "tools/reports/buttons/button_manifest.json",
    "tools/reports/buttons/asset_normalization.json",
)
REPOSITORY_PREFIXES = (
    "art_source/",
    "assets/",
    "autoload/",
    "data/",
    "scenes/",
    "scripts/",
    "tests/",
    "tools/",
)


def relative(path: Path, root: Path) -> str:
    return path.relative_to(root).as_posix()


def iter_files(root: Path) -> Iterator[Path]:
    for base, dirs, names in os.walk(root):
        dirs[:] = sorted(name for name in dirs if name not in SKIP_DIRS)
        for name in sorted(names):
            path = Path(base) / name
            if path.is_file():
                yield path


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8-sig", errors="replace")


def iter_strings(value: Any) -> Iterator[str]:
    if isinstance(value, str):
        yield value
    elif isinstance(value, list):
        for child in value:
            yield from iter_strings(child)
    elif isinstance(value, dict):
        for key, child in value.items():
            if isinstance(key, str):
                yield key
            yield from iter_strings(child)


def resource_target(value: str) -> str | None:
    if not value.startswith("res://"):
        return None
    target = value.removeprefix("res://").split("#", 1)[0].rstrip(".,;:")
    if not target or ".." in PurePosixPath(target).parts:
        return None
    return target


def finding(code: str, path: str, message: str) -> dict[str, str]:
    return {"code": code, "path": path, "message": message}


class ReachabilityCheck:
    def __init__(self, root: Path) -> None:
        self.root = root.resolve()
        self.files = list(iter_files(self.root))
        self.errors: list[dict[str, str]] = []
        self.warnings: list[dict[str, str]] = []
        self.checks: dict[str, Any] = {}
        self.json_payloads: dict[str, Any] = {}

    def run(self) -> dict[str, Any]:
        self._check_json()
        self._check_literal_resources()
        self._check_manifests()
        self._check_production_scenes()
        self._check_runtime_images()
        self._check_runtime_hygiene()
        self._check_readme()
        self._check_dynamic_cards()
        self._check_docs_import_boundaries()
        self._check_duplicate_styles()
        status = "pass" if not self.errors else "fail"
        return {
            "schema_version": 1,
            "generated_at": datetime.now(timezone.utc).isoformat(),
            "status": status,
            "error_count": len(self.errors),
            "warning_count": len(self.warnings),
            "checks": self.checks,
            "errors": self.errors,
            "warnings": self.warnings,
        }

    def _check_json(self) -> None:
        invalid: list[str] = []
        checked = 0
        for path in self.files:
            if path.suffix.lower() != ".json":
                continue
            rel = relative(path, self.root)
            checked += 1
            try:
                self.json_payloads[rel] = json.loads(read_text(path))
            except json.JSONDecodeError as exc:
                invalid.append(rel)
                self.errors.append(finding("invalid_json", rel, f"line {exc.lineno}, column {exc.colno}: {exc.msg}"))
        self.checks["json"] = {"checked": checked, "invalid": invalid}

    def _check_literal_resources(self) -> None:
        allowed_extensions = {".cfg", ".gd", ".gdshader", ".godot", ".json", ".material", ".res", ".tres", ".tscn"}
        missing: list[dict[str, str]] = []
        checked = 0
        for path in self.files:
            rel = relative(path, self.root)
            # The vendored editor add-on contains example and negative-test paths that
            # are not project dependencies. Its own test suite is the authority there.
            if rel.startswith("addons/"):
                continue
            if rel.startswith(("docs/", "art_source/", "tools/reports/")) and rel != "README.md":
                continue
            if path.suffix.lower() not in allowed_extensions and rel != "README.md":
                continue
            text = read_text(path)
            for match in RESOURCE_RE.finditer(text):
                value = match.group(0).rstrip(".,;:")
                target = resource_target(value)
                if target is None or any(token in target for token in ("%s", "%d", "{", "}")):
                    continue
                if target.startswith((".godot/", "artifacts/", "output/")):
                    continue
                if rel == "tests/test_game_table_scene.gd" and value in NEGATIVE_RESOURCES:
                    continue
                if (rel, value) in INTENTIONAL_MISSING_RESOURCES:
                    continue
                checked += 1
                if not (self.root / target).exists():
                    item = {"source": rel, "target": value}
                    if item not in missing:
                        missing.append(item)
                        self.errors.append(finding("missing_res_path", rel, value))
        self.checks["literal_res_paths"] = {"checked": checked, "missing": missing}

    def _check_manifests(self) -> None:
        missing: list[dict[str, str]] = []
        checked = 0
        absolute_paths: list[dict[str, str]] = []
        for rel in MANIFESTS:
            path = self.root / rel
            if not path.is_file():
                self.errors.append(finding("missing_manifest", rel, "required manifest is absent"))
                continue
            payload = self.json_payloads.get(rel)
            if payload is None:
                continue
            for value in iter_strings(payload):
                if WINDOWS_PATH_RE.search(value):
                    absolute_paths.append({"manifest": rel, "value": value[:240]})
                    self.errors.append(finding("absolute_manifest_path", rel, value[:240]))
                target = resource_target(value)
                if target is not None:
                    if any(token in target for token in ("%s", "%d", "{", "}")):
                        continue
                    checked += 1
                    if not (self.root / target).exists():
                        missing.append({"manifest": rel, "target": value})
                        self.errors.append(finding("missing_manifest_resource", rel, value))
                    continue
                normalized = value.replace("\\", "/").split("#", 1)[0]
                if normalized.startswith("external_source/"):
                    continue
                if normalized.startswith(REPOSITORY_PREFIXES) and PurePosixPath(normalized).suffix:
                    checked += 1
                    if not (self.root / normalized).exists():
                        missing.append({"manifest": rel, "target": normalized})
                        self.errors.append(finding("missing_manifest_file", rel, normalized))
        self.checks["manifests"] = {
            "files": list(MANIFESTS),
            "checked_paths": checked,
            "missing": missing,
            "absolute_paths": absolute_paths,
        }

    def _production_scene_list(self) -> list[str]:
        source = read_text(self.root / "tests/test_all_production_scenes.gd")
        match = re.search(r"const\s+PRODUCTION_SCENES.*?=\s*\[(.*?)\]\s*\n", source, re.DOTALL)
        if not match:
            self.errors.append(finding("missing_production_inventory", "tests/test_all_production_scenes.gd", "PRODUCTION_SCENES not found"))
            return []
        return sorted(set(RESOURCE_RE.findall(match.group(1))))

    def _check_production_scenes(self) -> None:
        declared = self._production_scene_list()
        actual = sorted(
            "res://" + relative(path, self.root)
            for path in (self.root / "scenes").rglob("*.tscn")
            if "/debug/" not in path.as_posix() and "/archive/" not in path.as_posix()
        )
        missing = sorted(set(declared) - set(actual))
        undeclared = sorted(set(actual) - set(declared))
        for value in missing:
            self.errors.append(finding("missing_production_scene", "tests/test_all_production_scenes.gd", value))
        for value in undeclared:
            self.errors.append(finding("unlisted_production_scene", value, "scene is outside debug/archive but absent from the production inventory"))
        self.checks["production_scenes"] = {
            "declared_count": len(declared),
            "actual_count": len(actual),
            "missing": missing,
            "undeclared": undeclared,
        }

    def _collect_referenced_resources(self) -> set[str]:
        references: set[str] = set()
        prefixes = ("autoload/", "scripts/", "data/")
        for path in self.files:
            rel = relative(path, self.root)
            include = rel == "project.godot" or rel.startswith(prefixes)
            include = include or (rel.startswith("scenes/") and not rel.startswith(("scenes/debug/", "scenes/archive/")))
            include = include or rel.startswith("assets/ui/theme/") or rel == "assets/cards/card_art_manifest.json"
            if not include or path.suffix.lower() not in {".gd", ".godot", ".json", ".tres", ".tscn"}:
                continue
            for value in RESOURCE_RE.findall(read_text(path)):
                target = resource_target(value)
                if target and not any(token in target for token in ("%s", "%d", "{", "}")):
                    references.add(target)
        return references

    def _pipeline_outputs(self) -> set[str]:
        outputs: set[str] = set()
        for rel in ("assets/ui/runtime/ui_asset_catalog.json", "tools/reports/buttons/asset_normalization.json"):
            payload = self.json_payloads.get(rel)
            if payload is None:
                continue
            for value in iter_strings(payload):
                target = resource_target(value)
                if target and target.startswith("assets/ui/runtime/") and PurePosixPath(target).suffix.lower() in IMAGE_EXTENSIONS:
                    outputs.add(target)
        return outputs

    def _check_runtime_images(self) -> None:
        runtime_root = self.root / "assets/ui/runtime"
        images = sorted(relative(path, self.root) for path in runtime_root.rglob("*") if path.suffix.lower() in IMAGE_EXTENSIONS)
        referenced = self._collect_referenced_resources()
        pipeline = self._pipeline_outputs()
        unreferenced = [path for path in images if path not in referenced]
        pipeline_only = [path for path in unreferenced if path in pipeline]
        orphan = [path for path in unreferenced if path not in pipeline]
        if unreferenced:
            self.warnings.append(finding("unreferenced_runtime_images", "assets/ui/runtime", f"{len(unreferenced)} images are not directly reachable; {len(pipeline_only)} are reproducible pipeline outputs and {len(orphan)} require review"))
        self.checks["runtime_images"] = {
            "total": len(images),
            "direct_or_dynamic_references": len(images) - len(unreferenced),
            "unreferenced": unreferenced,
            "pipeline_owned": pipeline_only,
            "review_required": orphan,
        }

    def _check_runtime_hygiene(self) -> None:
        forbidden: list[str] = []
        allowed_json = {"assets/ui/runtime/ui_asset_catalog.json"}
        for path in self.files:
            rel = relative(path, self.root)
            if "/runtime/" not in "/" + rel:
                continue
            lower = rel.lower()
            bad = path.suffix.lower() in {".xlsx", ".xls", ".csv"}
            bad = bad or any(part in {"before", "after", "screenshots"} for part in PurePosixPath(lower).parts)
            bad = bad or (path.suffix.lower() == ".json" and rel not in allowed_json and any(token in lower for token in ("audit", "report", "normalization", "button_manifest")))
            if bad:
                forbidden.append(rel)
                self.errors.append(finding("forbidden_runtime_file", rel, "non-runtime artifact under a runtime directory"))
            if path.suffix.lower() in {".json", ".md", ".txt"} and WINDOWS_PATH_RE.search(read_text(path)):
                self.errors.append(finding("runtime_absolute_path", rel, "contains a local absolute path"))
        self.checks["runtime_hygiene"] = {"forbidden": forbidden}

    def _check_readme(self) -> None:
        readme = read_text(self.root / "README.md")
        missing: list[str] = []
        for value in sorted(set(RESOURCE_RE.findall(readme))):
            target = resource_target(value)
            if target and not (self.root / target).exists():
                missing.append(value)
                self.errors.append(finding("missing_readme_resource", "README.md", value))
        self.checks["readme"] = {"resource_links": len(set(RESOURCE_RE.findall(readme))), "missing": missing}

    def _check_dynamic_cards(self) -> None:
        manifest = self.json_payloads.get("assets/cards/card_art_manifest.json", {})
        paths = sorted({value for value in iter_strings(manifest) if value.startswith("res://")})
        missing = [value for value in paths if (resource_target(value) and not (self.root / resource_target(value)).exists())]
        faces = list((self.root / "assets/cards/poker/faces").glob("*.png"))
        if len(faces) != 52:
            self.errors.append(finding("poker_face_count", "assets/cards/poker/faces", f"expected 52 PNGs, found {len(faces)}"))
        for value in missing:
            self.errors.append(finding("missing_dynamic_card_resource", "assets/cards/card_art_manifest.json", value))
        self.checks["dynamic_cards"] = {"manifest_resource_count": len(paths), "missing": missing, "poker_face_count": len(faces)}

    def _check_docs_import_boundaries(self) -> None:
        docs_root = self.root / "docs"
        uncovered: list[str] = []
        images = [path for path in docs_root.rglob("*") if path.suffix.lower() in IMAGE_EXTENSIONS]
        for image in images:
            current = image.parent
            covered = False
            while current == docs_root or docs_root in current.parents:
                if (current / ".gdignore").is_file():
                    covered = True
                    break
                if current == docs_root:
                    break
                current = current.parent
            if not covered:
                rel = relative(image, self.root)
                uncovered.append(rel)
                self.errors.append(finding("docs_image_without_gdignore", rel, "no .gdignore in its docs ancestry"))
        self.checks["docs_images"] = {"count": len(images), "without_gdignore": uncovered}

    def _check_duplicate_styles(self) -> None:
        groups: dict[str, list[str]] = defaultdict(list)
        for path in (self.root / "assets/ui/theme/styles").rglob("*.tres"):
            groups[hashlib.sha256(path.read_bytes()).hexdigest()].append(relative(path, self.root))
        duplicates = [sorted(paths) for paths in groups.values() if len(paths) > 1]
        duplicates.sort()
        for paths in duplicates:
            self.errors.append(finding("duplicate_tres", paths[0], ", ".join(paths)))
        self.checks["theme_styles"] = {
            "count": sum(len(paths) for paths in groups.values()),
            "duplicate_groups": duplicates,
        }


def render_markdown(payload: dict[str, Any]) -> str:
    checks = payload["checks"]
    runtime = checks.get("runtime_images", {})
    scenes = checks.get("production_scenes", {})
    dynamic = checks.get("dynamic_cards", {})
    styles = checks.get("theme_styles", {})
    lines = [
        "# Resource reachability check",
        "",
        f"- Status: **{payload['status'].upper()}**",
        f"- Errors: **{payload['error_count']}**",
        f"- Warnings: **{payload['warning_count']}**",
        f"- Production scenes: **{scenes.get('declared_count', 0)}**",
        f"- Runtime images: **{runtime.get('total', 0)}**; direct/dynamic **{runtime.get('direct_or_dynamic_references', 0)}**; review **{len(runtime.get('review_required', []))}**",
        f"- Dynamic manifest resources: **{dynamic.get('manifest_resource_count', 0)}**; poker faces **{dynamic.get('poker_face_count', 0)}**",
        f"- Theme styles: **{styles.get('count', 0)}**; duplicate groups **{len(styles.get('duplicate_groups', []))}**",
        "",
        "## Errors",
        "",
    ]
    if payload["errors"]:
        lines.extend(f"- `{item['code']}` `{item['path']}` — {item['message']}" for item in payload["errors"])
    else:
        lines.append("None.")
    lines.extend(["", "## Warnings", ""])
    if payload["warnings"]:
        lines.extend(f"- `{item['code']}` `{item['path']}` — {item['message']}" for item in payload["warnings"])
    else:
        lines.append("None.")
    review = runtime.get("review_required", [])
    lines.extend(["", "## Runtime image review queue", ""])
    if review:
        lines.extend(f"- `{path}`" for path in review)
    else:
        lines.append("None.")
    lines.extend([
        "",
        "Run in CI:",
        "",
        "```powershell",
        "python tools/audits/check_resource_reachability.py",
        "```",
        "",
    ])
    return "\n".join(lines)


def parse_args(argv: Sequence[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=ROOT)
    parser.add_argument("--json-output", type=Path, default=Path("tools/reports/resource_reachability.json"))
    parser.add_argument("--markdown-output", type=Path, default=Path("docs/cleanup/resource_reachability_check.md"))
    parser.add_argument("--no-write", action="store_true")
    return parser.parse_args(argv)


def main(argv: Sequence[str] | None = None) -> int:
    args = parse_args(argv)
    root = args.root.resolve()
    payload = ReachabilityCheck(root).run()
    if not args.no_write:
        json_path = args.json_output if args.json_output.is_absolute() else root / args.json_output
        markdown_path = args.markdown_output if args.markdown_output.is_absolute() else root / args.markdown_output
        json_path.parent.mkdir(parents=True, exist_ok=True)
        markdown_path.parent.mkdir(parents=True, exist_ok=True)
        json_path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        markdown_path.write_text(render_markdown(payload), encoding="utf-8")
    print(json.dumps({"status": payload["status"], "errors": payload["error_count"], "warnings": payload["warning_count"]}, ensure_ascii=False))
    return 1 if payload["errors"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
