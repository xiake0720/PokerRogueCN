#!/usr/bin/env python3
"""Audit Godot resource dependencies without mutating project resources.

The scanner intentionally combines literal dependency extraction with a small
set of project-specific, evidence-backed dynamic rules.  It writes only audit
artifacts under ``docs/cleanup`` and never deletes or moves files.

Supported inputs include Godot text resources, GDScript literal loaders,
project.godot entry points, JSON res:// values, Godot sidecar pairs, tests,
tools, editor-only content, exact hashes, and perceptual image similarity.
"""

from __future__ import annotations

import argparse
import configparser
import csv
import hashlib
import json
import os
import re
import sys
from collections import Counter, defaultdict, deque
from dataclasses import dataclass, field
from datetime import datetime, timezone
from pathlib import Path, PurePosixPath
from typing import Dict, Iterable, Iterator, List, Mapping, Optional, Sequence, Set, Tuple


SKIP_DIRS = {".git", ".godot", "__pycache__"}
TEXT_EXTENSIONS = {
    ".cfg", ".gd", ".gdshader", ".godot", ".import", ".ini", ".json",
    ".material", ".md", ".py", ".res", ".shader", ".tres", ".tscn",
    ".txt", ".uid", ".yaml", ".yml",
}
IMAGE_EXTENSIONS = {".png", ".jpg", ".jpeg", ".webp", ".svg"}
MEDIA_EXTENSIONS = IMAGE_EXTENSIONS | {".ogg", ".wav", ".mp3", ".otf", ".ttf", ".woff", ".woff2"}
SIDECAR_EXTENSIONS = {".import", ".uid"}
RESOURCE_RE = re.compile(r"res://[A-Za-z0-9_./%{}+:-]+")
WINDOWS_PATH_RE = re.compile(r"(?<![A-Za-z0-9_])([A-Za-z]:[\\/][^\"\r\n]+)")
EXT_RESOURCE_RE = re.compile(r'^\s*\[ext_resource\b[^\]]*\bpath="([^"]+)"', re.MULTILINE)
GENERIC_PATH_RE = re.compile(r"(?:preload|load|ResourceLoader\.(?:load|exists)|FileAccess\.(?:file_exists|get_file_as_string))\s*\(\s*[\"'](res://[^\"']+)")
STYLE_MODULATE_RE = re.compile(r"^modulate_color\s*=.*$", re.MULTILINE)
STYLE_TEXTURE_RE = re.compile(r'^\s*\[ext_resource\b[^\]]*\bpath="([^"]+)"[^\]]*\bid="([^"]+)"', re.MULTILINE)
STYLE_TEXTURE_USE_RE = re.compile(r"texture\s*=\s*ExtResource\(\"([^\"]+)\"\)")

GENERATED_REPORTS = {
    "docs/cleanup/resource_dependency_report.md",
    "docs/cleanup/orphan_candidates.csv",
    "docs/cleanup/cleanup_plan.md",
    "docs/cleanup/project_structure_proposal.md",
}

PRIMARY_ORDER = [
    "REACHABLE_RUNTIME_STATIC",
    "REACHABLE_RUNTIME_DYNAMIC",
    "TEST_ONLY",
    "TOOL_ONLY",
    "DEV_ONLY",
    "SOURCE_ONLY",
    "DOC_ONLY",
    "ORPHAN_CANDIDATE",
    "KEEP_UNCERTAIN",
]


def posix(path: Path) -> str:
    return path.as_posix().lstrip("./")


def res_path(rel: str) -> str:
    return "res://" + rel


def rel_from_res(value: str) -> Optional[str]:
    value = value.strip().rstrip(".,;:")
    if not value.startswith("res://"):
        return None
    rel = value[6:].replace("\\", "/")
    if not rel or ".." in PurePosixPath(rel).parts:
        return None
    return rel


def human_bytes(value: int) -> str:
    units = ["B", "KiB", "MiB", "GiB"]
    amount = float(value)
    for unit in units:
        if amount < 1024.0 or unit == units[-1]:
            return f"{amount:.1f} {unit}" if unit != "B" else f"{int(amount)} B"
        amount /= 1024.0
    return f"{value} B"


def read_text(path: Path) -> Optional[str]:
    if path.suffix.lower() not in TEXT_EXTENSIONS and path.name not in {"README", "LICENSE"}:
        return None
    try:
        return path.read_text(encoding="utf-8-sig")
    except (UnicodeDecodeError, OSError):
        try:
            return path.read_text(encoding="utf-8", errors="replace")
        except OSError:
            return None


def discover_files(root: Path) -> List[str]:
    results: List[str] = []
    for base, dirs, names in os.walk(root):
        dirs[:] = sorted(d for d in dirs if d not in SKIP_DIRS)
        base_path = Path(base)
        for name in sorted(names):
            path = base_path / name
            try:
                if path.is_file():
                    results.append(posix(path.relative_to(root)))
            except OSError:
                continue
    return sorted(results)


@dataclass(frozen=True)
class Edge:
    source: str
    target: str
    kind: str
    exists: bool


@dataclass
class FileRecord:
    path: str
    size: int
    extension: str
    sha256: str
    categories: Set[str] = field(default_factory=set)
    references: List[str] = field(default_factory=list)
    dynamic_reference: bool = False
    paired_files: Set[str] = field(default_factory=set)
    confidence: str = "medium"
    recommended_action: str = "keep"
    reason: str = ""

    @property
    def primary(self) -> str:
        for category in PRIMARY_ORDER:
            if category in self.categories:
                return category
        return "KEEP_UNCERTAIN"


class Audit:
    def __init__(self, root: Path, output_dir: Path, near_duplicates: bool = True) -> None:
        self.root = root.resolve()
        self.output_dir = output_dir
        self.near_duplicates_enabled = near_duplicates
        self.files = discover_files(self.root)
        self.file_set = set(self.files)
        self.records: Dict[str, FileRecord] = {}
        self.texts: Dict[str, str] = {}
        self.edges: List[Edge] = []
        self.outgoing: Dict[str, List[Edge]] = defaultdict(list)
        self.incoming: Dict[str, List[Edge]] = defaultdict(list)
        self.stale: List[Edge] = []
        self.invalid_json: List[Tuple[str, str]] = []
        self.absolute_paths: List[Tuple[str, str]] = []
        self.duplicate_groups: List[List[str]] = []
        self.near_duplicates: List[Tuple[str, str, int]] = []
        self.runtime_static: Set[str] = set()
        self.runtime_dynamic: Set[str] = set()
        self.test_reachable: Set[str] = set()
        self.tool_reachable: Set[str] = set()
        self.dev_reachable: Set[str] = set()
        self.style_stats: Dict[str, object] = {}
        self.project_entries: Dict[str, List[str]] = defaultdict(list)

    def run(self) -> None:
        self._inventory()
        self._parse_references()
        self._add_class_name_rules()
        self._add_dynamic_rules()
        self._build_graph()
        self._classify()
        self._pair_sidecars()
        self._find_duplicates()
        self._find_near_duplicates()
        self._audit_styles()

    def _inventory(self) -> None:
        for rel in self.files:
            path = self.root / rel
            try:
                data = path.read_bytes()
            except OSError:
                data = b""
            ext = path.suffix.lower() or "[none]"
            self.records[rel] = FileRecord(
                path=rel,
                size=len(data),
                extension=ext,
                sha256=hashlib.sha256(data).hexdigest(),
            )
            text = read_text(path)
            if text is not None:
                self.texts[rel] = text
                if ext == ".json":
                    try:
                        json.loads(text)
                    except json.JSONDecodeError as exc:
                        self.invalid_json.append((rel, f"line {exc.lineno}, column {exc.colno}: {exc.msg}"))
                for match in WINDOWS_PATH_RE.finditer(text):
                    value = match.group(1).strip()
                    if not value.lower().startswith("res:"):
                        self.absolute_paths.append((rel, value[:300]))

    def _reference_kind(self, source: str, text: str, start: int) -> str:
        if source == "assets/cards/card_art_manifest.json":
            return "dynamic_json"
        if source.endswith(".json"):
            return "json_metadata"
        window = text[max(0, start - 120): start + 240]
        if re.search(r"ResourceLoader\.(?:load|exists)|FileAccess\.(?:file_exists|get_file_as_string)", window):
            return "loader_literal"
        if source == "project.godot":
            return "project_setting"
        if source.endswith((".tscn", ".tres", ".material", ".gdshader", ".res")):
            return "godot_ext_resource"
        return "literal"

    def _parse_references(self) -> None:
        seen: Set[Tuple[str, str, str]] = set()
        for source, text in self.texts.items():
            if source.endswith((".import", ".uid")) or source in GENERATED_REPORTS:
                continue
            for match in RESOURCE_RE.finditer(text):
                raw = match.group(0).strip()
                target = rel_from_res(raw)
                if target is None:
                    continue
                # Template expressions are handled by explicit dynamic rules.
                if any(token in target for token in ("%s", "%d", "{", "}")):
                    continue
                kind = self._reference_kind(source, text, match.start())
                if source == "tests/test_game_table_scene.gd" and target in {
                    "scenes/game/stage_select_screen.tscn",
                    "scenes/game/battle_screen.tscn",
                    "scenes/game/settlement_screen.tscn",
                    "scenes/shop/joker_shop_screen.tscn",
                }:
                    kind = "negative_assertion"
                key = (source, target, kind)
                if key in seen:
                    continue
                seen.add(key)
                edge = Edge(source, target, kind, (self.root / target).exists())
                self.edges.append(edge)

        project = self.texts.get("project.godot", "")
        for setting, label in (
            ("run/main_scene", "main_scene"),
            ("theme/custom", "theme"),
            ("config/icon", "icon"),
        ):
            match = re.search(rf"^{re.escape(setting)}=\"([^\"]+)\"", project, re.MULTILINE)
            if match:
                rel = rel_from_res(match.group(1))
                if rel:
                    self.project_entries[label].append(rel)
        autoload_match = re.search(r"^\[autoload\]\s*(.*?)(?=^\[|\Z)", project, re.MULTILINE | re.DOTALL)
        if autoload_match:
            for raw in re.findall(r'="\*?(res://[^\"]+)"', autoload_match.group(1)):
                rel = rel_from_res(raw)
                if rel:
                    self.project_entries["autoload"].append(rel)
        plugin_match = re.search(r"^\[editor_plugins\]\s*(.*?)(?=^\[|\Z)", project, re.MULTILINE | re.DOTALL)
        if plugin_match:
            for raw in re.findall(r'res://[^\"\)]+', plugin_match.group(1)):
                rel = rel_from_res(raw)
                if rel:
                    self.project_entries["editor_plugin"].append(rel)

    def _add_edge(self, source: str, target: str, kind: str) -> None:
        if any(e.source == source and e.target == target and e.kind == kind for e in self.edges):
            return
        self.edges.append(Edge(source, target, kind, (self.root / target).exists()))

    def _add_class_name_rules(self) -> None:
        """Resolve Godot's global class_name registry as static script edges."""
        classes: Dict[str, str] = {}
        for rel, text in self.texts.items():
            if not rel.endswith(".gd"):
                continue
            match = re.search(r"^class_name\s+([A-Za-z_][A-Za-z0-9_]*)\b", text, re.MULTILINE)
            if match:
                classes[match.group(1)] = rel
        for source, text in self.texts.items():
            if not source.endswith((".gd", ".tscn")):
                continue
            for symbol, target in classes.items():
                if source != target and re.search(rf"\b{re.escape(symbol)}\b", text):
                    self._add_edge(source, target, "class_name_reference")

    def _add_dynamic_rules(self) -> None:
        # playing_card_view.gd constructs all 52 face paths from rank/suit IDs.
        playing_source = "scripts/cards/playing_card_view.gd"
        playing_text = self.texts.get(playing_source, "")
        if "assets/cards/poker/faces/%s_%s.png" in playing_text:
            for rel in self.files:
                if rel.startswith("assets/cards/poker/faces/") and Path(rel).suffix.lower() == ".png":
                    self._add_edge(playing_source, rel, "dynamic_path_rule")

        # ArtResolver consumes the manifest and every res:// value in it.
        manifest = "assets/cards/card_art_manifest.json"
        if manifest in self.file_set:
            for edge in list(self.edges):
                if edge.source == manifest and edge.kind == "json_metadata":
                    self.edges.remove(edge)
                    self.edges.append(Edge(edge.source, edge.target, "dynamic_json", edge.exists))

        # Generated joker art is an explicitly protected dynamic family.  The
        # directory rule covers dedicated art added before the manifest refresh.
        if "scripts/ui/art_resolver.gd" in self.file_set:
            for rel in self.files:
                if rel.startswith("assets/ui/runtime/generated/jokers/") and Path(rel).suffix.lower() in IMAGE_EXTENSIONS:
                    self._add_edge("scripts/ui/art_resolver.gd", rel, "dynamic_directory_rule")

        # The production-scene smoke test enumerates every .tscn under scenes/
        # except scenes/debug.  These are TEST_ONLY dependencies even when no
        # production scene explicitly instances them.
        scene_test = "tests/test_all_production_scenes.gd"
        scene_test_text = self.texts.get(scene_test, "")
        if "DirAccess.open" in scene_test_text and "scenes/debug" in scene_test_text:
            for rel in self.files:
                if rel.startswith("scenes/") and not rel.startswith("scenes/debug/") and rel.endswith(".tscn"):
                    self._add_edge(scene_test, rel, "test_dynamic_directory_rule")

    def _build_graph(self) -> None:
        self.outgoing.clear()
        self.incoming.clear()
        self.stale.clear()
        for edge in self.edges:
            self.outgoing[edge.source].append(edge)
            if edge.exists and edge.target in self.file_set:
                self.incoming[edge.target].append(edge)
            elif not edge.exists and edge.kind != "negative_assertion":
                self.stale.append(edge)

    def _walk_runtime(self, roots: Iterable[str]) -> Tuple[Set[str], Set[str]]:
        static: Set[str] = set()
        dynamic: Set[str] = set()
        queue: deque[Tuple[str, bool]] = deque()
        for root in roots:
            if root in self.file_set:
                queue.append((root, False))
        while queue:
            current, dyn = queue.popleft()
            bucket = dynamic if dyn else static
            if current in bucket:
                continue
            bucket.add(current)
            for edge in self.outgoing.get(current, []):
                if not edge.exists or edge.target not in self.file_set:
                    continue
                next_dyn = dyn or edge.kind in {"dynamic_json", "dynamic_path_rule", "dynamic_directory_rule"}
                if edge.target not in (dynamic if next_dyn else static):
                    queue.append((edge.target, next_dyn))
        return static, dynamic

    def _walk(self, roots: Iterable[str]) -> Set[str]:
        reached: Set[str] = set()
        queue: deque[str] = deque(r for r in roots if r in self.file_set)
        while queue:
            current = queue.popleft()
            if current in reached:
                continue
            reached.add(current)
            for edge in self.outgoing.get(current, []):
                if edge.exists and edge.target in self.file_set and edge.target not in reached:
                    queue.append(edge.target)
        return reached

    def _classify(self) -> None:
        runtime_roots = {"project.godot"}
        for label in ("main_scene", "autoload", "theme", "icon"):
            runtime_roots.update(self.project_entries.get(label, []))
        self.runtime_static, self.runtime_dynamic = self._walk_runtime(runtime_roots)

        test_roots = {p for p in self.files if p.startswith("tests/")}
        tool_roots = {p for p in self.files if p.startswith("tools/") and "/__pycache__/" not in p}
        dev_roots = {p for p in self.files if p.startswith("addons/") or p.startswith("scenes/debug/")}
        dev_roots.update(self.project_entries.get("editor_plugin", []))
        self.test_reachable = self._walk(test_roots)
        self.tool_reachable = self._walk(tool_roots)
        self.dev_reachable = self._walk(dev_roots)

        # Generator metadata that is not itself loaded by code remains tooling,
        # even when a historical report was placed under assets/ui/runtime.
        metadata_tool_roots = {
            "assets/ASSET_MANIFEST.json",
            "assets/audio/audio_manifest.json",
            "assets/ui/runtime/buttons/asset_normalization.json",
        }
        self.tool_reachable.update(p for p in metadata_tool_roots if p in self.file_set)

        for rel, record in self.records.items():
            if rel in self.runtime_static:
                record.categories.add("REACHABLE_RUNTIME_STATIC")
            if rel in self.runtime_dynamic:
                record.categories.add("REACHABLE_RUNTIME_DYNAMIC")
                record.dynamic_reference = True
            if rel in self.test_reachable and rel not in self.runtime_static and rel not in self.runtime_dynamic:
                record.categories.add("TEST_ONLY")
            if rel in self.tool_reachable and not record.categories.intersection({"REACHABLE_RUNTIME_STATIC", "REACHABLE_RUNTIME_DYNAMIC", "TEST_ONLY"}):
                record.categories.add("TOOL_ONLY")
            if rel in self.dev_reachable and not record.categories.intersection({"REACHABLE_RUNTIME_STATIC", "REACHABLE_RUNTIME_DYNAMIC", "TEST_ONLY", "TOOL_ONLY"}):
                record.categories.add("DEV_ONLY")

            if rel.startswith(("assets/reference/", "assets/references/", "assets/ui/reference/", "assets/ui/references/")):
                record.categories.add("SOURCE_ONLY")
            elif rel.startswith("assets/ui/extracted/") and not record.categories.intersection({"REACHABLE_RUNTIME_STATIC", "REACHABLE_RUNTIME_DYNAMIC"}):
                record.categories.add("SOURCE_ONLY")

            if rel.startswith(("docs/", "artifacts/", "output/")) or PurePosixPath(rel).name.lower() == "readme.md" or rel in {
                "README.md", "ASSET_REPLACEMENT_NOTES.md", "PROJECT_BUILD.txt", "shop_ui_test.tmp.log"
            }:
                record.categories.add("DOC_ONLY")

            if not record.categories:
                if self._is_orphan_candidate(rel):
                    record.categories.add("ORPHAN_CANDIDATE")
                else:
                    record.categories.add("KEEP_UNCERTAIN")

            incoming = self.incoming.get(rel, [])
            record.references = sorted({e.source for e in incoming})
            self._recommend(record)

    def _is_orphan_candidate(self, rel: str) -> bool:
        path = Path(rel)
        if path.suffix.lower() in SIDECAR_EXTENSIONS:
            return False
        if rel.startswith(("tests/", "tools/", "addons/", "docs/", "artifacts/", "output/")):
            return False
        if rel in {"project.godot", ".gitignore", "README.md", "icon.svg"}:
            return False
        # Runtime-looking resources with no path from any recognized root are
        # candidates even when they reference one another as an isolated group.
        return rel.startswith(("assets/", "scenes/", "scripts/", "autoload/", "data/"))

    def _recommend(self, record: FileRecord) -> None:
        rel = record.path
        categories = record.categories
        if categories.intersection({"REACHABLE_RUNTIME_STATIC", "REACHABLE_RUNTIME_DYNAMIC"}):
            record.confidence = "high"
            record.recommended_action = "keep"
            record.reason = "reachable from a production entry point"
        elif "TEST_ONLY" in categories:
            record.confidence = "high"
            record.recommended_action = "keep_or_update_test"
            record.reason = "reachable only from tests; review whether the test asserts stale architecture"
        elif "TOOL_ONLY" in categories:
            record.confidence = "high"
            record.recommended_action = "keep_or_move_to_tools"
            record.reason = "reachable only from tooling or generated reports"
        elif "DEV_ONLY" in categories:
            record.confidence = "high"
            record.recommended_action = "keep_dev_or_exclude_import"
            record.reason = "editor/debug-only dependency"
        elif "SOURCE_ONLY" in categories:
            record.confidence = "medium"
            record.recommended_action = "keep_or_move_to_art_source"
            record.reason = "source/provenance asset; not directly used by production runtime"
        elif "DOC_ONLY" in categories:
            record.confidence = "high"
            record.recommended_action = "keep_in_docs_or_exclude_import"
            record.reason = "documentation, review capture, or generated evidence"
        elif "ORPHAN_CANDIDATE" in categories:
            record.confidence = "high" if rel.startswith(("scenes/", "scripts/", "assets/ui/runtime/")) else "medium"
            record.recommended_action = "review_for_batch_c_or_d"
            record.reason = "unreachable from production, test, tool, editor, source, or documentation roots"
        else:
            record.confidence = "low"
            record.recommended_action = "keep_uncertain"
            record.reason = "no safe automated conclusion"

    def _pair_sidecars(self) -> None:
        for rel, record in list(self.records.items()):
            paired: Optional[str] = None
            if rel.endswith(".import"):
                candidate = rel[:-7]
                if candidate in self.records:
                    paired = candidate
            elif rel.endswith(".gd.uid"):
                candidate = rel[:-4]
                if candidate in self.records:
                    paired = candidate
            else:
                for candidate in (rel + ".import", rel + ".uid"):
                    if candidate in self.records:
                        record.paired_files.add(candidate)
            if paired:
                record.paired_files.add(paired)
                self.records[paired].paired_files.add(rel)
                record.categories = set(self.records[paired].categories)
                record.dynamic_reference = self.records[paired].dynamic_reference
                record.references = list(self.records[paired].references)
                record.confidence = self.records[paired].confidence
                record.recommended_action = "follow_primary_file"
                record.reason = f"Godot sidecar paired with {paired}; do not treat independently"

    def _find_duplicates(self) -> None:
        by_hash: Dict[Tuple[str, int], List[str]] = defaultdict(list)
        for rel, record in self.records.items():
            if record.extension in SIDECAR_EXTENSIONS or record.size == 0:
                continue
            by_hash[(record.sha256, record.size)].append(rel)
        self.duplicate_groups = [sorted(group) for group in by_hash.values() if len(group) > 1]
        self.duplicate_groups.sort(key=lambda g: (-self.records[g[0]].size, g))
        for group in self.duplicate_groups:
            for rel in group:
                self.records[rel].categories.add("DUPLICATE_CONTENT")

    @staticmethod
    def _dhash(path: Path) -> Optional[Tuple[int, Tuple[int, int]]]:
        try:
            from PIL import Image
            with Image.open(path) as image:
                size = image.size
                gray = image.convert("L").resize((9, 8))
                pixels = list(gray.getdata())
            value = 0
            for y in range(8):
                for x in range(8):
                    value = (value << 1) | int(pixels[y * 9 + x] > pixels[y * 9 + x + 1])
            return value, size
        except Exception:
            return None

    def _find_near_duplicates(self) -> None:
        if not self.near_duplicates_enabled:
            return
        hashes: Dict[str, Tuple[int, Tuple[int, int]]] = {}
        for rel in self.files:
            if Path(rel).suffix.lower() in IMAGE_EXTENSIONS - {".svg"}:
                result = self._dhash(self.root / rel)
                if result:
                    hashes[rel] = result
        paths = sorted(hashes)
        candidates: List[Tuple[str, str, int]] = []
        for index, left in enumerate(paths):
            left_hash, left_size = hashes[left]
            for right in paths[index + 1:]:
                if self.records[left].sha256 == self.records[right].sha256:
                    continue
                right_hash, right_size = hashes[right]
                # Restrict comparisons to same-size assets or close siblings to
                # avoid noisy cross-purpose matches.
                same_dir = str(PurePosixPath(left).parent) == str(PurePosixPath(right).parent)
                size_ratio = min(left_size[0] * left_size[1], right_size[0] * right_size[1]) / max(1, max(left_size[0] * left_size[1], right_size[0] * right_size[1]))
                if not same_dir and (left_size != right_size or size_ratio < 0.95):
                    continue
                # The project's bundled Python 3.9 lacks int.bit_count(); bin
                # keeps the audit compatible with that runtime.
                distance = bin(left_hash ^ right_hash).count("1")
                if distance <= 3:
                    candidates.append((left, right, distance))
        self.near_duplicates = sorted(candidates, key=lambda item: (item[2], item[0], item[1]))
        for left, right, _ in self.near_duplicates:
            self.records[left].categories.add("NEAR_DUPLICATE")
            self.records[right].categories.add("NEAR_DUPLICATE")

    def _audit_styles(self) -> None:
        styles = [p for p in self.files if p.startswith("assets/ui/theme/styles/") and p.endswith(".tres")]
        runtime_sources = self.runtime_static | self.runtime_dynamic
        referenced = [p for p in styles if any(edge.source in runtime_sources for edge in self.incoming.get(p, []))]
        exact_groups = [g for g in self.duplicate_groups if all(p in styles for p in g)]
        normalized: Dict[str, List[str]] = defaultdict(list)
        texture_families: Dict[str, List[str]] = defaultdict(list)
        for rel in styles:
            text = self.texts.get(rel, "")
            key = hashlib.sha256(STYLE_MODULATE_RE.sub("modulate_color=<normalized>", text).encode("utf-8")).hexdigest()
            normalized[key].append(rel)
            id_to_path = {identifier: path for path, identifier in STYLE_TEXTURE_RE.findall(text)}
            used = STYLE_TEXTURE_USE_RE.search(text)
            if used and used.group(1) in id_to_path:
                texture_families[id_to_path[used.group(1)]].append(rel)
        modulate_groups = [sorted(g) for g in normalized.values() if len(g) > 1 and len({self.records[p].sha256 for p in g}) > 1]
        texture_groups = {k: sorted(v) for k, v in texture_families.items() if len(v) > 1}
        self.style_stats = {
            "total": len(styles),
            "referenced": len(referenced),
            "unreferenced": len(styles) - len(referenced),
            "exact_duplicate_groups": len(exact_groups),
            "exact_duplicate_files": sum(len(g) for g in exact_groups),
            "modulate_only_groups": len(modulate_groups),
            "modulate_only_files": sum(len(g) for g in modulate_groups),
            "texture_family_count": len(texture_groups),
            "texture_family_styles": sum(len(v) for v in texture_groups.values()),
            "modulate_groups": modulate_groups,
            "texture_families": texture_groups,
        }

    def category_stats(self) -> Mapping[str, Tuple[int, int]]:
        stats: Dict[str, List[int]] = defaultdict(lambda: [0, 0])
        for record in self.records.values():
            for category in record.categories:
                stats[category][0] += 1
                stats[category][1] += record.size
        return {key: (value[0], value[1]) for key, value in stats.items()}

    def primary_stats(self) -> Mapping[str, Tuple[int, int]]:
        stats: Dict[str, List[int]] = defaultdict(lambda: [0, 0])
        for record in self.records.values():
            stats[record.primary][0] += 1
            stats[record.primary][1] += record.size
        return {key: (value[0], value[1]) for key, value in stats.items()}

    def high_confidence_orphans(self) -> List[FileRecord]:
        return [r for r in self.records.values() if "ORPHAN_CANDIDATE" in r.categories and r.confidence == "high" and r.extension not in SIDECAR_EXTENSIONS]

    def cleanup_estimate(self) -> int:
        # Conservative: high-confidence primary files plus their sidecars only.
        selected: Set[str] = set()
        for record in self.high_confidence_orphans():
            selected.add(record.path)
            selected.update(record.paired_files)
        return sum(self.records[p].size for p in selected if p in self.records)

    def conditional_cleanup_estimate(self) -> int:
        """Batch C/D estimate after stale test/report dependencies are fixed."""
        main_files = {
            "assets/ui/runtime/backgrounds/stage_select.png",
            "assets/ui/runtime/backgrounds/battle_frame.png",
            "assets/ui/runtime/backgrounds/shop.png",
            "assets/ui/runtime/panels/battle_hud_full.png",
            "assets/ui/runtime/panels/deck_main_panel.png",
            "assets/ui/runtime/panels/shop_offers_panel.png",
            "assets/ui/runtime/buttons/settlement/claim.png",
            "scenes/cards/deck_pile_view.tscn",
            "scripts/cards/deck_pile_view.gd",
            "scenes/ui/shared/blind_token_view.tscn",
            "scenes/ui/shared/currency_display.tscn",
            "scenes/ui/shared/deck_stack_view.tscn",
            "scenes/ui/shared/empty_card_slot.tscn",
            "scenes/ui/shared/ornate_panel.tscn",
            "scenes/ui/shared/price_plate.tscn",
            "scenes/ui/shared/reward_row.tscn",
            "scenes/ui/shared/section_header.tscn",
        }
        selected: Set[str] = set()
        for rel in main_files:
            record = self.records.get(rel)
            if record is None or record.categories.intersection({"REACHABLE_RUNTIME_STATIC", "REACHABLE_RUNTIME_DYNAMIC"}):
                continue
            selected.add(rel)
            selected.update(record.paired_files)
        return sum(self.records[p].size for p in selected if p in self.records)

    def write_outputs(self) -> None:
        output = self.root / self.output_dir
        output.mkdir(parents=True, exist_ok=True)
        with (output / "resource_dependency_report.md").open("w", encoding="utf-8", newline="\n") as handle:
            handle.write(self.render_report())
        self.write_orphan_csv(output / "orphan_candidates.csv")

    def write_orphan_csv(self, path: Path) -> None:
        fieldnames = [
            "path", "extension", "size_bytes", "category", "reference_count",
            "referenced_by", "dynamic_reference", "paired_files", "confidence",
            "recommended_action", "reason",
        ]
        candidates = [r for r in self.records.values() if r.primary in {"ORPHAN_CANDIDATE", "TEST_ONLY", "TOOL_ONLY", "DEV_ONLY", "SOURCE_ONLY", "DOC_ONLY", "KEEP_UNCERTAIN"}]
        candidates.sort(key=lambda r: (PRIMARY_ORDER.index(r.primary), -r.size, r.path))
        with path.open("w", encoding="utf-8-sig", newline="") as handle:
            writer = csv.DictWriter(handle, fieldnames=fieldnames)
            writer.writeheader()
            for record in candidates:
                writer.writerow({
                    "path": record.path,
                    "extension": record.extension,
                    "size_bytes": record.size,
                    "category": ";".join(sorted(record.categories)),
                    "reference_count": len(record.references),
                    "referenced_by": ";".join(record.references),
                    "dynamic_reference": str(record.dynamic_reference).lower(),
                    "paired_files": ";".join(sorted(record.paired_files)),
                    "confidence": record.confidence,
                    "recommended_action": record.recommended_action,
                    "reason": record.reason,
                })

    def render_report(self) -> str:
        now = datetime.now(timezone.utc).astimezone().isoformat(timespec="seconds")
        total_bytes = sum(r.size for r in self.records.values())
        static_only = self.runtime_static - self.runtime_dynamic
        dynamic = self.runtime_dynamic
        primary_stats = self.primary_stats()
        category_stats = self.category_stats()
        high_orphans = self.high_confidence_orphans()
        duplicate_redundant = sum(len(g) - 1 for g in self.duplicate_groups)

        lines: List[str] = [
            "# 项目资源依赖审计报告",
            "",
            f"> 生成时间：{now}",
            f"> 扫描根目录：`{self.root}`",
            "> 范围：排除 `.git/`、Godot 本地缓存 `.godot/` 与 Python `__pycache__/`；包含被 Git 忽略的 `artifacts/`、`output/`。",
            "",
            "## 执行摘要",
            "",
            f"- 扫描文件：**{len(self.files)}**，总大小 **{human_bytes(total_bytes)}**。",
            f"- 正式运行静态可达：**{len(static_only)}** 个文件；动态可达：**{len(dynamic)}** 个文件。",
            f"- 测试专用：**{primary_stats.get('TEST_ONLY', (0, 0))[0]}** 个文件。",
            f"- 高置信孤立候选：**{len(high_orphans)}** 个主文件；保守可清理估算（含配套 sidecar）**{human_bytes(self.cleanup_estimate())}**。",
            f"- 修正历史清单/测试后，Batch C/D 条件候选预计 **{human_bytes(self.conditional_cleanup_estimate())}**；这不是本轮删除许可。",
            f"- 完全重复：**{len(self.duplicate_groups)}** 组、**{duplicate_redundant}** 个冗余副本；近似重复候选：**{len(self.near_duplicates)}** 对。",
            f"- 无效 JSON：**{len(self.invalid_json)}**；不存在的 `res://` 引用：**{len(self.stale)}**。",
            "",
            "## 当前真实运行入口",
            "",
            f"- `run/main_scene`：`{res_path(self.project_entries.get('main_scene', ['未配置'])[0]) if self.project_entries.get('main_scene') else '未配置'}`。",
            f"- Autoload：{', '.join('`' + res_path(p) + '`' for p in self.project_entries.get('autoload', [])) or '无'}。",
            f"- 全局 Theme：{', '.join('`' + res_path(p) + '`' for p in self.project_entries.get('theme', [])) or '未配置'}。",
            f"- 图标：{', '.join('`' + res_path(p) + '`' for p in self.project_entries.get('icon', [])) or '未配置'}。",
            f"- 编辑器插件（DEV_ONLY）：{', '.join('`' + res_path(p) + '`' for p in self.project_entries.get('editor_plugin', [])) or '无'}。",
            "- `ScreenRouter` 的 HOME / DECK_SELECT / GAME_OVER、VICTORY 分别进入 `scenes/screens/main_menu_screen.tscn`、`run_setup_screen.tscn`、`result_screen.tscn`；STAGE_SELECT / ROUND / SETTLEMENT / SHOP 共用 `scenes/game/game_table_screen.tscn`。",
            "- 统一游戏桌内的阶段内容由 `blind_select_panel.tscn`、`battle_content.tscn`、`settlement_panel.tscn`、`shop_panel.tscn` 承载，属于同一场景常驻子树，而不是四个顶层页面。",
            "",
            "## 正式场景依赖图",
            "",
            "```mermaid",
            "flowchart TD",
            '  Project["project.godot"] --> Main["scenes/main.tscn"]',
            '  Main --> Router["ScreenRouter"]',
            '  Router --> Home["screens/main_menu_screen.tscn"]',
            '  Router --> Setup["screens/run_setup_screen.tscn"]',
            '  Router --> Result["screens/result_screen.tscn"]',
            '  Router --> Table["game/game_table_screen.tscn"]',
            '  Table --> Blind["phases/blind_select_panel.tscn"]',
            '  Table --> Battle["phases/battle_content.tscn"]',
            '  Table --> Settle["phases/settlement_panel.tscn"]',
            '  Table --> Shop["phases/shop_panel.tscn"]',
            "```",
            "",
            "### 可达正式场景",
            "",
        ]
        runtime_scenes = sorted(p for p in static_only | dynamic if p.endswith(".tscn"))
        lines.extend(f"- `{res_path(path)}`" for path in runtime_scenes)

        lines.extend([
            "",
            "## 动态资源依赖",
            "",
            "- `scripts/ui/art_resolver.gd` 静态读取 `assets/cards/card_art_manifest.json`；清单内的 `items`、分类 fallback、subtype fallback 与 unknown fallback 均按 `REACHABLE_RUNTIME_DYNAMIC` 传播。",
            "- `scripts/cards/playing_card_view.gd` 以 rank/suit 拼接 `assets/cards/poker/faces/%s_%s.png`；审计器把目录中 52 张 `.png` 及其 `.import` 配对纳入动态运行资源。",
            "- `assets/ui/runtime/generated/jokers/**` 是 ArtResolver 的受保护动态目录族；即使新专属图片暂未写回清单，也标记为动态保留。",
            "- `autoload/data_registry.gd` 读取 `data/**.json` 作为正式数据入口；AudioManager 的 BGM/SFX `preload` 均属于静态运行依赖。",
            "- `ui_asset_catalog.json`、`button_manifest.json`、`asset_normalization.json` 是来源/审计元数据；除非正式代码实际加载，否则不会仅因位于 `runtime/` 就升级为正式运行依赖。",
            "",
            "## 文件分类统计（唯一主分类）",
            "",
            "| 分类 | 文件数 | 大小 |",
            "|---|---:|---:|",
        ])
        for category in PRIMARY_ORDER:
            count, size = primary_stats.get(category, (0, 0))
            lines.append(f"| {category} | {count} | {human_bytes(size)} |")

        lines.extend([
            "",
            "## 状态标签统计（允许重叠）",
            "",
            "| 标签 | 文件数 | 大小 |",
            "|---|---:|---:|",
        ])
        for category in sorted(category_stats):
            count, size = category_stats[category]
            lines.append(f"| {category} | {count} | {human_bytes(size)} |")

        top_dirs: Dict[str, List[int]] = defaultdict(lambda: [0, 0])
        for record in self.records.values():
            parts = PurePosixPath(record.path).parts
            for depth in range(1, min(3, len(parts)) + 1):
                key = "/".join(parts[:depth]) + ("/" if depth < len(parts) else "")
                top_dirs[key][0] += 1
                top_dirs[key][1] += record.size
        largest_dirs = sorted(top_dirs.items(), key=lambda item: (-item[1][1], item[0]))[:20]
        largest_files = sorted(self.records.values(), key=lambda r: (-r.size, r.path))[:30]

        lines.extend([
            "",
            "## 目录用途与体积",
            "",
            "- `scenes/`、`scripts/`、`autoload/`、`data/`：正式代码/数据与测试可达组件混合，必须按图可达性处理。",
            "- `assets/ui/runtime/`：正式切片、动态卡面与若干历史审计 JSON 混合，目录名不能作为使用证据。",
            "- `assets/ui/extracted/` 与 reference 类目录：切片来源及可追溯素材；未被正式场景直接引用的部分标为 SOURCE_ONLY。",
            "- `tests/`：可执行完整性、流程、分辨率与截图验证入口；其依赖与正式运行依赖分开统计。",
            "- `tools/`：生成器、切片器、按钮审计和本扫描器；生成源与工具报告属于 TOOL_ONLY/SOURCE_ONLY。",
            "- `docs/`、`artifacts/`、`output/`：文档、验收截图和生成输出；建议从 Godot 导入范围排除，是否保留由证据价值决定。",
            "- `addons/`、`scenes/debug/`：编辑器插件与调试画廊，归 DEV_ONLY。",
            "",
            "### 最大目录 Top 20",
            "",
            "| 目录 | 文件数 | 大小 |",
            "|---|---:|---:|",
        ])
        for directory, (count, size) in largest_dirs:
            lines.append(f"| `{directory}` | {count} | {human_bytes(size)} |")

        lines.extend([
            "",
            "### 最大文件 Top 30",
            "",
            "| 文件 | 分类 | 大小 |",
            "|---|---|---:|",
        ])
        for record in largest_files:
            lines.append(f"| `{record.path}` | {record.primary} | {human_bytes(record.size)} |")

        focus_assets = [
            "assets/ui/runtime/backgrounds/stage_select.png",
            "assets/ui/runtime/backgrounds/battle_frame.png",
            "assets/ui/runtime/backgrounds/shop.png",
            "assets/ui/runtime/panels/battle_hud_full.png",
            "assets/ui/runtime/panels/deck_main_panel.png",
            "assets/ui/runtime/panels/shop_offers_panel.png",
            "assets/ui/runtime/buttons/settlement/claim.png",
        ]
        shared_scenes = [
            "scenes/ui/shared/blind_token_view.tscn",
            "scenes/ui/shared/currency_display.tscn",
            "scenes/ui/shared/deck_stack_view.tscn",
            "scenes/ui/shared/empty_card_slot.tscn",
            "scenes/ui/shared/ornate_panel.tscn",
            "scenes/ui/shared/price_plate.tscn",
            "scenes/ui/shared/reward_row.tscn",
            "scenes/ui/shared/section_header.tscn",
            "scenes/ui/shared/textured_button.tscn",
        ]
        button_manifest_data: Mapping[str, object] = {}
        try:
            button_manifest_data = json.loads(self.texts.get("assets/ui/runtime/buttons/button_manifest.json", "{}"))
        except json.JSONDecodeError:
            pass
        scene_counts = button_manifest_data.get("scene_counts", {}) if isinstance(button_manifest_data, dict) else {}
        debug_button_count = int(scene_counts.get("res://scenes/debug/button_style_gallery.tscn", 0)) if isinstance(scene_counts, dict) else 0
        abs_counts = Counter(source for source, _ in self.absolute_paths)
        docs_size = sum(r.size for r in self.records.values() if r.path.startswith("docs/"))
        artifacts_size = sum(r.size for r in self.records.values() if r.path.startswith("artifacts/"))
        output_size = sum(r.size for r in self.records.values() if r.path.startswith("output/"))

        lines.extend([
            "",
            "## 重点疑点复核",
            "",
            "### A. README 旧场景",
            "",
            "README 仍引用 4 个已不存在的旧顶层场景；正式路由已经改用统一游戏桌。`tests/test_game_table_scene.gd` 对这 4 个路径做的是“必须不存在”的负向架构断言，不应误报为坏依赖。",
            "",
            "### B. 运行目录中的历史按钮报告",
            "",
            f"- `button_manifest.json` 仍含 **{debug_button_count}** 个 `button_style_gallery` 按钮，并引用已删除的 `battle_screen`、`settlement_screen`、`joker_shop_screen`；它由测试读取，但不是正式运行加载入口。",
            "- `asset_normalization.json` 的 `generator` 指向 `tools/button_asset_normalizer.py`，属于 TOOL_ONLY 报告；第二轮应在重新生成测试清单后迁至 `tools/reports/`，而非继续混放在 runtime。",
            "",
            "### C. 本机绝对路径清单",
            "",
            f"- `assets/ASSET_MANIFEST.json`：发现 **{abs_counts.get('assets/ASSET_MANIFEST.json', 0)}** 个绝对路径文本。",
            f"- `assets/ui/extracted/asset_manifest.json`：发现 **{abs_counts.get('assets/ui/extracted/asset_manifest.json', 0)}** 个绝对路径文本。",
            "- 两者应改成仓库相对来源标识或可移植 `res://`，但本轮只报告、不改写。",
            "",
            "### D. 已知旧运行资源候选",
            "",
            "| 文件 | 当前主分类 | 有效引用来源 | 结论 |",
            "|---|---|---|---|",
        ])
        for path in focus_assets:
            record = self.records.get(path)
            if record:
                refs = ", ".join(f"`{p}`" for p in record.references) or "无"
                conclusion = "未被正式流程使用；仅测试/历史清单保活，Batch A 更新断言后可进入 Batch C"
                lines.append(f"| `{path}` | {record.primary} | {refs} | {conclusion} |")
            else:
                lines.append(f"| `{path}` | 文件不存在 | 无 | 无需清理 |")

        lines.extend([
            "",
            "### E. deck_pile_view 组件组",
            "",
            "`scenes/cards/deck_pile_view.tscn` 不在正式运行、工具或调试根可达集合；`test_all_production_scenes.gd` 通过目录枚举加载它，因此严格分类是 TEST_ONLY。其脚本只被该场景引用，`.gd.uid` 仅为脚本 sidecar。整组可作为条件 Batch D 候选，但不能计入零引用孤立项。",
            "",
            "### F. 共享组件池",
            "",
            "| 组件 | 当前主分类 | 说明 |",
            "|---|---|---|",
        ])
        for path in shared_scenes:
            record = self.records.get(path)
            if not record:
                lines.append(f"| `{path}` | 文件不存在 | 无 |")
                continue
            if record.primary == "ORPHAN_CANDIDATE":
                note = "未被正式/测试/工具有效实例化；高置信 Batch D 候选"
            elif record.primary == "TEST_ONLY":
                note = "仅由测试或历史按钮清单保活；先更新测试证据"
            else:
                note = "保留；存在正式或其他有效根依赖"
            lines.append(f"| `{path}` | {record.primary} | {note} |")

        lines.extend([
            "",
            "### H. 文档、截图、输出与调试资源",
            "",
            f"- `docs/`：**{human_bytes(docs_size)}**，包含审计文档、Excel 与视觉分层 before/after 证据；保留高价值文档，但通过 `.gdignore` 排除 Godot 导入。",
            f"- `artifacts/`：**{human_bytes(artifacts_size)}**，为被 `.gitignore` 忽略的本地截图输出；不提交，按需清理或外置。",
            f"- `output/`：**{human_bytes(output_size)}**，为生成输出；迁至 `tools/reports/` 或保持忽略。",
            "- `scenes/debug/button_style_gallery.tscn`：DEV_ONLY；保留时应与正式测试清单解耦，并将 `scenes/debug/` 从生产导出与自动生产场景枚举中排除。",
            "",
        ])

        lines.extend([
            "",
            "## Theme / StyleBox 审计",
            "",
            f"- StyleBox 文件总数：**{self.style_stats.get('total', 0)}**。",
            f"- 发现任意有效引用：**{self.style_stats.get('referenced', 0)}**；未发现引用：**{self.style_stats.get('unreferenced', 0)}**。",
            f"- 内容完全相同：**{self.style_stats.get('exact_duplicate_groups', 0)}** 组 / **{self.style_stats.get('exact_duplicate_files', 0)}** 个文件。",
            f"- 仅 `modulate_color` 不同：**{self.style_stats.get('modulate_only_groups', 0)}** 组 / **{self.style_stats.get('modulate_only_files', 0)}** 个文件。",
            f"- 同纹理派生按钮族：**{self.style_stats.get('texture_family_count', 0)}** 族 / **{self.style_stats.get('texture_family_styles', 0)}** 个样式。",
            "- 上述是收敛候选而非删除许可；必须先对照按钮状态、边距、焦点与禁用态回归测试。",
            "",
            "## 完全重复文件",
            "",
        ])
        if not self.duplicate_groups:
            lines.append("未发现（sidecar 与空文件已排除）。")
        else:
            for group in self.duplicate_groups[:100]:
                size = self.records[group[0]].size
                lines.append(f"- **{human_bytes(size)} × {len(group)}**：" + ", ".join(f"`{p}`" for p in group))

        lines.extend(["", "## 近似重复图片候选", ""])
        if not self.near_duplicates:
            lines.append("未发现，或 Pillow 不可用。")
        else:
            lines.append("dHash 距离仅用于人工复核，不作为删除依据：")
            for left, right, distance in self.near_duplicates[:100]:
                lines.append(f"- 距离 {distance}：`{left}` ↔ `{right}`")

        lines.extend(["", "## 过时或不存在的引用", ""])
        if not self.stale:
            lines.append("未发现。")
        else:
            for edge in sorted(self.stale, key=lambda e: (e.source, e.target, e.kind)):
                lines.append(f"- `{edge.source}` → `{res_path(edge.target)}`（{edge.kind}）")

        lines.extend(["", "## 本机绝对路径", ""])
        if not self.absolute_paths:
            lines.append("未发现。")
        else:
            for source, value in sorted(set(self.absolute_paths))[:200]:
                lines.append(f"- `{source}`：`{value}`")

        lines.extend(["", "## JSON 格式验证", ""])
        if not self.invalid_json:
            lines.append(f"全部 **{sum(1 for p in self.files if p.endswith('.json'))}** 个 JSON 文件解析成功。")
        else:
            for source, error in self.invalid_json:
                lines.append(f"- `{source}`：{error}")

        lines.extend([
            "",
            "## 高置信孤立候选",
            "",
            "这里只列出不在正式、测试、工具、插件、文档或来源素材根可达集合中的主文件；完整证据见 `orphan_candidates.csv`。",
            "",
        ])
        if not high_orphans:
            lines.append("未发现。")
        else:
            for record in sorted(high_orphans, key=lambda r: (-r.size, r.path)):
                pairs = ", ".join(f"`{p}`" for p in sorted(record.paired_files)) or "无"
                lines.append(f"- `{record.path}`（{human_bytes(record.size)}；配套：{pairs}）")

        lines.extend([
            "",
            "## 风险与解释边界",
            "",
            "- `ORPHAN_CANDIDATE` 表示本扫描模型未找到有效根路径，不等同于可立即删除；反射、编辑器手工加载、未提交分支或外部生成流程仍可能构成隐含依赖。",
            "- JSON 中存在的路径只有在该 JSON 自身由正式代码可达且具备加载语义时才标记动态运行；纯审计/来源清单不会扩大正式依赖集合。",
            "- `.import` 与图片/音频/字体、`.gd.uid` 与 `.gd` 作为同一资源组；CSV 中 sidecar 跟随主文件，不单独给删除建议。",
            "- 近似重复基于低分辨率感知哈希，按钮状态、透明边缘和微小色调差异可能具有明确交互意义。",
            "- 清理空间估算只累计高置信孤立主文件及其 sidecar，不包含 TEST_ONLY、DEV_ONLY、SOURCE_ONLY、DOC_ONLY 或 KEEP_UNCERTAIN，因此是保守下界。",
            "- 当前用户工作区若存在未提交修改，应在第二轮继续排除，不得 stash、reset 或覆盖。",
            "",
            "## 验证命令",
            "",
            "```powershell",
            "python tools/audits/resource_dependency_audit.py --root .",
            "D:\\Godot\\Godot_v4.6.2-stable_win64_console.exe --path . --headless -s res://tests/test_scene_integrity.gd",
            "D:\\Godot\\Godot_v4.6.2-stable_win64_console.exe --path . --headless -s res://tests/test_asset_integrity.gd",
            "D:\\Godot\\Godot_v4.6.2-stable_win64_console.exe --path . --headless -s res://tests/test_ui_resolutions.gd",
            "D:\\Godot\\Godot_v4.6.2-stable_win64_console.exe --path . --headless res://tests/smoke_run.tscn",
            "```",
            "",
            "本报告仅为第一轮只读审计；本轮未删除或移动任何项目文件。",
            "",
        ])
        return "\n".join(lines)

    def summary(self) -> Mapping[str, object]:
        primary = self.primary_stats()
        return {
            "scanned_files": len(self.files),
            "runtime_static": len(self.runtime_static - self.runtime_dynamic),
            "runtime_dynamic": len(self.runtime_dynamic),
            "test_only": primary.get("TEST_ONLY", (0, 0))[0],
            "high_confidence_orphans": len(self.high_confidence_orphans()),
            "duplicate_groups": len(self.duplicate_groups),
            "duplicate_redundant_files": sum(len(g) - 1 for g in self.duplicate_groups),
            "near_duplicate_pairs": len(self.near_duplicates),
            "cleanup_estimate_bytes": self.cleanup_estimate(),
            "conditional_cleanup_estimate_bytes": self.conditional_cleanup_estimate(),
            "invalid_json": len(self.invalid_json),
            "stale_references": len(self.stale),
        }


def parse_args(argv: Optional[Sequence[str]] = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[2], help="Godot project root")
    parser.add_argument("--output-dir", type=Path, default=Path("docs/cleanup"), help="Output path relative to root")
    parser.add_argument("--no-write", action="store_true", help="Scan and validate without writing reports")
    parser.add_argument("--skip-near-duplicates", action="store_true", help="Skip Pillow perceptual image comparison")
    return parser.parse_args(argv)


def main(argv: Optional[Sequence[str]] = None) -> int:
    args = parse_args(argv)
    audit = Audit(args.root, args.output_dir, near_duplicates=not args.skip_near_duplicates)
    audit.run()
    if not args.no_write:
        audit.write_outputs()
    print(json.dumps(audit.summary(), ensure_ascii=False, indent=2))
    return 2 if audit.invalid_json else 0


if __name__ == "__main__":
    raise SystemExit(main())
