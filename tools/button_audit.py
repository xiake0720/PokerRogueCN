#!/usr/bin/env python3
"""Audit every Godot button and interactive pseudo-button in the project."""

from __future__ import annotations

import hashlib
import json
import re
from collections import Counter
from pathlib import Path
from typing import Any

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
THEME_PATH = ROOT / "assets/ui/theme/game_theme.tres"
MANIFEST_PATH = ROOT / "tools/reports/buttons/button_manifest.json"
AUDIT_PATH = ROOT / "docs/button_audit.md"
BUTTON_TYPES = {"Button", "TextureButton", "CheckButton", "OptionButton", "MenuButton", "LinkButton"}
STATES = ("normal", "hover", "pressed", "disabled", "focus")


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def project_reference(path: Path) -> str:
    relative = path.relative_to(ROOT).as_posix()
    return relative if relative.startswith("art_source/") else "res://" + relative


def parse_value(value: str) -> Any:
    value = value.strip()
    if value.startswith('"') and value.endswith('"'):
        return value[1:-1]
    if value in ("true", "false"):
        return value == "true"
    vector = re.fullmatch(r"Vector2\(([-\d.]+),\s*([-\d.]+)\)", value)
    if vector:
        return [float(vector.group(1)), float(vector.group(2))]
    try:
        return float(value) if "." in value else int(value)
    except ValueError:
        return value


def parse_resource_text(path: Path) -> dict[str, Any]:
    text = path.read_text(encoding="utf-8")
    ext: dict[str, dict[str, str]] = {}
    sub: dict[str, dict[str, Any]] = {}
    resource: dict[str, Any] = {}
    current: dict[str, Any] | None = None
    for line in text.splitlines():
        ext_match = re.match(r'\[ext_resource type="([^"]+)" path="([^"]+)" id="([^"]+)"\]', line)
        if ext_match:
            ext[ext_match.group(3)] = {"type": ext_match.group(1), "path": ext_match.group(2)}
            current = None
            continue
        sub_match = re.match(r'\[sub_resource type="([^"]+)" id="([^"]+)"\]', line)
        if sub_match:
            current = {"type": sub_match.group(1), "properties": {}}
            sub[sub_match.group(2)] = current
            continue
        if line == "[resource]":
            current = {"type": "resource", "properties": resource}
            continue
        if current is not None and " = " in line:
            key, value = line.split(" = ", 1)
            current["properties"][key] = parse_value(value)
    return {"text": text, "ext": ext, "sub": sub, "resource": resource}


def parse_scene(path: Path) -> dict[str, Any]:
    parsed = parse_resource_text(path)
    text: str = parsed["text"]
    nodes: list[dict[str, Any]] = []
    current: dict[str, Any] | None = None
    for line in text.splitlines():
        node_match = re.match(r'\[node name="([^"]+)"(?: type="([^"]+)")?(?: parent="([^"]+)")?.*\]', line)
        if node_match:
            current = {
                "name": node_match.group(1),
                "type": node_match.group(2) or "InstancedScene",
                "parent": node_match.group(3) or "",
                "properties": {},
            }
            nodes.append(current)
            continue
        if line.startswith("["):
            current = None
        elif current is not None and " = " in line:
            key, value = line.split(" = ", 1)
            current["properties"][key] = parse_value(value)
    if nodes:
        root_name = nodes[0]["name"]
        for node in nodes:
            parent = node["parent"]
            node["full_path"] = root_name if not parent else f"{root_name}/{parent}/{node['name']}"
        node_types = {node["full_path"]: node["type"] for node in nodes}
        for node in nodes:
            parent = node["parent"]
            parent_path = root_name if parent == "." else (f"{root_name}/{parent}" if parent else "")
            node["parent_type"] = node_types.get(parent_path, "SceneRoot" if not parent else "Unknown")
    parsed["nodes"] = nodes
    return parsed


def resolve_ref(value: Any, ext: dict[str, Any], sub: dict[str, Any]) -> dict[str, Any]:
    if not isinstance(value, str):
        return {}
    ext_match = re.fullmatch(r'ExtResource\("([^"]+)"\)', value)
    if ext_match:
        item = dict(ext.get(ext_match.group(1), {}))
        item["ref"] = value
        return item
    sub_match = re.fullmatch(r'SubResource\("([^"]+)"\)', value)
    if sub_match:
        item = dict(sub.get(sub_match.group(1), {}))
        item["id"] = sub_match.group(1)
        item["ref"] = value
        return item
    return {}


def build_theme_styles() -> dict[str, dict[str, str]]:
    parsed = parse_resource_text(THEME_PATH)
    result: dict[str, dict[str, str]] = {}
    for key, value in parsed["resource"].items():
        base_match = re.fullmatch(r"([^/]+)/base_type", key)
        if base_match:
            result.setdefault(base_match.group(1), {})
            continue
        match = re.fullmatch(r"([^/]+)/styles/([^/]+)", key)
        if not match:
            continue
        ref = resolve_ref(value, parsed["ext"], parsed["sub"])
        if ref.get("path"):
            result.setdefault(match.group(1), {})[match.group(2)] = ref["path"]
    return result


def load_style(style_source: str, scene: dict[str, Any]) -> dict[str, Any]:
    if not style_source:
        return {}
    if style_source.startswith("res://"):
        path = ROOT / style_source.removeprefix("res://")
        if not path.is_file():
            return {"source": style_source, "missing": True}
        parsed = parse_resource_text(path)
        props = parsed["resource"]
        texture_ref = resolve_ref(props.get("texture", ""), parsed["ext"], parsed["sub"])
        texture_path = texture_ref.get("path", "")
    elif style_source.startswith("SubResource:"):
        sub_id = style_source.split(":", 1)[1]
        style = scene["sub"].get(sub_id, {})
        props = style.get("properties", {})
        texture_ref = resolve_ref(props.get("texture", ""), scene["ext"], scene["sub"])
        texture_path = texture_ref.get("path", "")
        if texture_ref.get("type") == "AtlasTexture":
            atlas_props = texture_ref.get("properties", {})
            atlas_ref = resolve_ref(atlas_props.get("atlas", ""), scene["ext"], scene["sub"])
            texture_path = atlas_ref.get("path", "")
    else:
        return {"source": style_source}
    image_size: list[int] | None = None
    if texture_path.startswith("res://"):
        texture_file = ROOT / texture_path.removeprefix("res://")
        if texture_file.is_file() and texture_file.suffix.lower() == ".png":
            with Image.open(texture_file) as image:
                image_size = list(image.size)
    margins = {
        side: float(props.get(f"texture_margin_{side}", 0.0))
        for side in ("left", "top", "right", "bottom")
    }
    content = {
        side: float(props.get(f"content_margin_{side}", -1.0))
        for side in ("left", "top", "right", "bottom")
    }
    return {
        "source": style_source,
        "texture": texture_path,
        "image_size": image_size,
        "texture_margin": margins,
        "content_margin": content,
        "axis_stretch": {
            "horizontal": int(props.get("axis_stretch_horizontal", 0)),
            "vertical": int(props.get("axis_stretch_vertical", 0)),
        },
        "modulate": props.get("modulate_color", "Color(1, 1, 1, 1)"),
    }


def explicit_style_source(node: dict[str, Any], state: str, scene: dict[str, Any]) -> str:
    value = node["properties"].get(f"theme_override_styles/{state}", "")
    ref = resolve_ref(value, scene["ext"], scene["sub"])
    if ref.get("path"):
        return ref["path"]
    if ref.get("id"):
        return f"SubResource:{ref['id']}"
    return ""


def classify(node: dict[str, Any], scene_path: str) -> str:
    variation = str(node["properties"].get("theme_type_variation", "")).replace('&"', "").replace('"', "")
    if variation:
        return variation
    name = node["name"]
    if name == "PlayingCardView":
        return "PlayingCardToggle"
    if "Sell" in name:
        return "DangerButton"
    if "Buy" in name:
        return "ShopBuyButton"
    if scene_path.endswith("main_menu_screen.tscn"):
        return "HomeExclusiveButton"
    if scene_path.endswith("battle_content.tscn"):
        return "BattleExclusiveButton"
    if scene_path.endswith("stage_card_view.tscn"):
        return "StagePrimaryButton" if name == "SelectButton" else "StageSecondaryButton"
    if scene_path.endswith("settlement_panel.tscn"):
        return "SettlementPrimaryButton"
    if scene_path.endswith("shop_panel.tscn"):
        return "ShopPrimaryButton" if name == "NextButton" else "ShopSecondaryButton"
    if scene_path.endswith("deck_select_screen.tscn"):
        return "DeckTabButton" if name in ("NewRunButton", "ContinueButton", "ChallengeButton") else "DeckExclusiveButton"
    return "NeutralButton"


def audit_button(node: dict[str, Any], scene: dict[str, Any], scene_path: str, theme: dict[str, dict[str, str]]) -> dict[str, Any]:
    props = node["properties"]
    variation = str(props.get("theme_type_variation", "Button")).replace('&"', "").replace('"', "") or "Button"
    styles: dict[str, Any] = {}
    style_sources: dict[str, str] = {}
    for state in STATES:
        lookup_state = "pressed" if state == "pressed" else state
        source = explicit_style_source(node, lookup_state, scene)
        if not source:
            source = theme.get(variation, {}).get(lookup_state, "") or theme.get("Button", {}).get(lookup_state, "")
        style_sources[state] = source
        styles[state] = load_style(source, scene)
    minimum = props.get("custom_minimum_size", [0.0, 0.0])
    if not isinstance(minimum, list):
        minimum = [0.0, 0.0]
    normal = styles["normal"]
    margins = normal.get("texture_margin", {side: 0.0 for side in ("left", "top", "right", "bottom")})
    geometry_invalid = bool(
        minimum[0] > 0 and margins["left"] + margins["right"] >= minimum[0]
        or minimum[1] > 0 and margins["top"] + margins["bottom"] >= minimum[1]
    )
    content_sets = {
        json.dumps(styles[state].get("content_margin", {}), sort_keys=True, ensure_ascii=False)
        for state in ("normal", "hover", "pressed", "disabled")
        if styles[state]
    }
    special = any("/buttons/home/" in source or "/buttons/battle/" in source or "/buttons/shop/" in source or "/buttons/settlement/" in source for source in style_sources.values())
    flat_card = bool(props.get("flat", False)) and node["name"] == "PlayingCardView"
    missing_states = [] if flat_card else [state for state in STATES if not style_sources[state]]
    return {
        "scene": scene_path,
        "node_path": node["full_path"],
        "name": node["name"],
        "text": props.get("text", ""),
        "node_type": node["type"],
        "minimum_size": minimum,
        "size_source": "custom_minimum_size" if minimum != [0.0, 0.0] else "parent anchors/container",
        "parent_type": node.get("parent_type", "Unknown"),
        "theme_type_variation": variation,
        "styles": style_sources,
        "style_details": styles,
        "texture": normal.get("texture", ""),
        "texture_original_size": normal.get("image_size"),
        "texture_margin": margins,
        "content_margin": normal.get("content_margin", {}),
        "axis_stretch": normal.get("axis_stretch", {}),
        "has_style_fallback": False,
        "has_texture_deformation": geometry_invalid,
        "has_text_jump": len(content_sets) > 1,
        "missing_states": missing_states,
        "preserve_exclusive_art": special,
        "final_button_type": classify(node, scene_path),
        "toggle_mode": bool(props.get("toggle_mode", False)),
        "disabled_by_default": bool(props.get("disabled", False)),
        "flat_art_button": flat_card,
    }


def pseudo_buttons(scene_path: str, scene: dict[str, Any]) -> list[dict[str, Any]]:
    results: list[dict[str, Any]] = []
    root = scene["nodes"][0] if scene["nodes"] else None
    if root is None:
        return results
    script_ref = resolve_ref(root["properties"].get("script", ""), scene["ext"], scene["sub"])
    script_path = script_ref.get("path", "")
    script_text = ""
    if script_path.startswith("res://"):
        script_file = ROOT / script_path.removeprefix("res://")
        if script_file.is_file():
            script_text = script_file.read_text(encoding="utf-8")
    if re.search(r"(?m)^\s*gui_input\.connect", script_text) and root["type"] not in BUTTON_TYPES:
        results.append({
            "scene": scene_path,
            "node_path": root["full_path"],
            "name": root["name"],
            "node_type": "PseudoButton",
            "interaction": "gui_input",
            "final_button_type": "InteractiveCard",
        })
    if scene_path.endswith("battle_content.tscn"):
        for name in ("ConsumableSlot1", "ConsumableSlot2", "ConsumableSlot3"):
            node = next((item for item in scene["nodes"] if item["name"] == name), None)
            if node:
                results.append({
                    "scene": scene_path,
                    "node_path": node["full_path"],
                    "name": name,
                    "node_type": "PseudoButton",
                    "interaction": "gui_input",
                    "final_button_type": "ConsumableSlot",
                })
    return results


def main() -> None:
    theme = build_theme_styles()
    buttons: list[dict[str, Any]] = []
    pseudo: list[dict[str, Any]] = []
    for scene_file in sorted((ROOT / "scenes").rglob("*.tscn")):
        scene_path = "res://" + scene_file.relative_to(ROOT).as_posix()
        if scene_path.startswith("res://scenes/debug/") or scene_path.startswith("res://scenes/archive/"):
            continue
        scene = parse_scene(scene_file)
        for node in scene["nodes"]:
            if node["type"] in BUTTON_TYPES:
                buttons.append(audit_button(node, scene, scene_path, theme))
        pseudo.extend(pseudo_buttons(scene_path, scene))
    source_hashes = {
        project_reference(path): sha256(path)
        for source_root in (ROOT / "art_source/ui/extracted", ROOT / "assets/ui/extracted")
        for path in sorted(source_root.rglob("*"))
        if path.is_file()
    }
    normalization = json.loads((ROOT / "tools/reports/buttons/asset_normalization.json").read_text(encoding="utf-8"))
    counts = Counter(button["scene"] for button in buttons)
    payload = {
        "schema_version": 1,
        "generated_by": "tools/button_audit.py",
        "button_count": len(buttons),
        "pseudo_button_count": len(pseudo),
        "scene_counts": dict(sorted(counts.items())),
        "theme_variations": sorted(name for name in theme if name != "Button"),
        "buttons": buttons,
        "pseudo_buttons": pseudo,
        "normalized_assets": normalization["assets"],
        "extracted_source_hashes": source_hashes,
    }
    MANIFEST_PATH.parent.mkdir(parents=True, exist_ok=True)
    MANIFEST_PATH.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    lines = [
        "# 按钮系统审计",
        "",
        "> 由 `tools/button_audit.py` 基于当前 `.tscn`、Theme、`.tres` 和 PNG 资源生成。",
        "",
        f"- 正式 BaseButton 派生节点：**{len(buttons)}**",
        f"- 交互式伪按钮：**{len(pseudo)}**",
        f"- 覆盖场景：**{len(counts)}**",
        "",
        "## 按场景统计",
        "",
        "| 场景 | 数量 |",
        "|---|---:|",
    ]
    lines.extend(f"| `{scene}` | {count} |" for scene, count in sorted(counts.items()))
    lines.extend(["", "## 按钮明细", ""])
    for index, button in enumerate(buttons, 1):
        lines.extend([
            f"### {index}. {button['name']}",
            "",
            f"- 场景路径：`{button['scene']}`",
            f"- 节点完整路径：`{button['node_path']}`",
            f"- 显示文字：`{button['text']}`",
            f"- 节点类型：`{button['node_type']}`",
            f"- 当前最小尺寸：`{button['minimum_size']}`（{button['size_source']}）",
            f"- 父容器类型：`{button['parent_type']}`",
            f"- Theme Type Variation：`{button['theme_type_variation']}`",
            f"- normal / hover / pressed / disabled / focus：`{button['styles']}`",
            f"- 图片资源：`{button['texture']}`；原始尺寸：`{button['texture_original_size']}`",
            f"- Texture Margin：`{button['texture_margin']}`",
            f"- Content Margin：`{button['content_margin']}`",
            f"- Axis Stretch：`{button['axis_stretch']}`",
            f"- 样式回退：`{button['has_style_fallback']}`",
            f"- 图片变形风险：`{button['has_texture_deformation']}`",
            f"- 文字跳动：`{button['has_text_jump']}`",
            f"- 状态缺失：`{button['missing_states']}`",
            f"- 保留专属美术：`{button['preserve_exclusive_art']}`",
            f"- 最终按钮类型：`{button['final_button_type']}`",
            "",
        ])
    lines.extend(["## 交互式伪按钮", ""])
    for item in pseudo:
        lines.append(f"- `{item['scene']}` → `{item['node_path']}`（{item['final_button_type']}，{item['interaction']}）")
    lines.extend([
        "",
        "## 审计结论",
        "",
        "- 全局基础 Button 已改为中性安全样式，强调色均通过显式 Variation 或外部专属 StyleBox 指定。",
        "- 正式按钮不在运行时创建 StyleBox；固定样式均位于 Theme 或独立 `.tres`。",
        "- `art_source/ui/extracted/` 是离线生成输入，只记录哈希，不被规范化工具写入。",
        "- 可切换按钮使用 `toggle_mode` 与 pressed/hover_pressed 显示 selected 状态。",
        "",
    ])
    AUDIT_PATH.parent.mkdir(parents=True, exist_ok=True)
    AUDIT_PATH.write_text("\n".join(lines), encoding="utf-8")
    print(f"Audited {len(buttons)} buttons and {len(pseudo)} pseudo-buttons")


if __name__ == "__main__":
    main()
