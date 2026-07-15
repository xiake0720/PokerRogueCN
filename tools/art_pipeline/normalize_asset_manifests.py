#!/usr/bin/env python3
"""Normalize legacy art-pipeline manifests to portable project paths."""

from __future__ import annotations

import json
import re
from pathlib import Path, PureWindowsPath
from typing import Any


ROOT = Path(__file__).resolve().parents[2]
MANIFESTS = (
    ROOT / "tools/art_pipeline/manifests/asset_manifest.json",
    ROOT / "tools/art_pipeline/manifests/extracted_asset_manifest.json",
)
DRIVE_PATH = re.compile(r"^[A-Za-z]:[\\/]")


def _portable_path(value: str, *, scene: str, target: bool) -> str:
    suffix = ""
    if "#" in value:
        value, suffix = value.split("#", 1)
        suffix = "#" + suffix
    normalized = value.replace("\\", "/")
    if normalized.startswith("res://"):
        return normalized + suffix
    marker = "/PokerRogueCN/"
    if marker in normalized:
        return "res://" + normalized.split(marker, 1)[1].lstrip("/") + suffix
    if normalized.startswith("assets/") or normalized.startswith("tools/"):
        return "res://" + normalized + suffix
    if normalized.startswith("ui/"):
        return "res://assets/" + normalized + suffix
    if DRIVE_PATH.match(normalized):
        name = PureWindowsPath(value).name
        return f"external_source/{scene or 'unsorted'}/{name}{suffix}"
    if target:
        return "res://assets/" + normalized.lstrip("/") + suffix
    return normalized + suffix


def normalize(path: Path) -> None:
    payload: Any = json.loads(path.read_text(encoding="utf-8-sig"))
    if not isinstance(payload, list):
        raise ValueError(f"expected a list manifest: {path}")
    for raw in payload:
        if not isinstance(raw, dict):
            continue
        scene = str(raw.get("scene", "unsorted"))
        if isinstance(raw.get("source"), str):
            raw["source"] = _portable_path(raw["source"], scene=scene, target=False)
        if isinstance(raw.get("target"), str):
            raw["target"] = _portable_path(raw["target"], scene=scene, target=True)
    text = json.dumps(payload, ensure_ascii=False, indent=2) + "\n"
    if re.search(r'"[A-Za-z]:[\\/]', text):
        raise ValueError(f"absolute drive path remains in {path}")
    path.write_text(text, encoding="utf-8")
    print(f"normalized {len(payload)} entries: {path.relative_to(ROOT).as_posix()}")


def main() -> None:
    for path in MANIFESTS:
        normalize(path)


if __name__ == "__main__":
    main()
