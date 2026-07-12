#!/usr/bin/env python3
"""Generate the fixed, editor-visible Godot button style gallery scene."""

from __future__ import annotations

import json
from dataclasses import dataclass
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "scenes/debug/button_style_gallery.tscn"


@dataclass(frozen=True)
class GalleryRow:
    name: str
    variation: str
    style_folder: str
    asset_id: str
    minimum_size: tuple[int, int]


ROWS = (
    GalleryRow("超大红色主按钮", "PrimaryRedButton", "red", "common_primary_red", (220, 72)),
    GalleryRow("超大金色主按钮", "PrimaryGoldButton", "gold", "common_primary_gold", (220, 72)),
    GalleryRow("红色次级按钮", "SecondaryRedButton", "red", "common_secondary_red", (180, 62)),
    GalleryRow("金色次级按钮", "SecondaryGoldButton", "gold", "common_secondary_gold", (180, 62)),
    GalleryRow("小型红色按钮", "SmallRedButton", "danger", "common_small_red", (150, 52)),
    GalleryRow("小型金色按钮", "SmallGoldButton", "small", "common_small_gold", (150, 52)),
    GalleryRow("标签按钮", "TabButton", "tab", "deck_tab_center", (170, 58)),
    GalleryRow("图标按钮", "IconButton", "icon", "deck_arrow_right", (96, 52)),
    GalleryRow("危险按钮", "DangerButton", "danger", "common_small_red", (150, 52)),
    GalleryRow("首页开始专属", "", "home/start", "home_start", (220, 72)),
    GalleryRow("首页设置专属", "", "home/options", "home_options", (220, 62)),
    GalleryRow("战斗出牌专属", "", "battle/play", "battle_play", (220, 72)),
    GalleryRow("战斗弃牌专属", "", "battle/discard", "battle_discard", (180, 62)),
    GalleryRow("战斗点数排序", "", "battle/sort_rank", "battle_sort_rank", (180, 62)),
    GalleryRow("战斗花色排序", "", "battle/sort_suit", "battle_sort_suit", (180, 62)),
    GalleryRow("商店购买专属", "", "shop/buy", "shop_buy", (150, 52)),
    GalleryRow("结算继续专属", "", "settlement/continue", "settlement_continue", (220, 72)),
)


def main() -> None:
    assets_payload = json.loads((ROOT / "assets/ui/runtime/buttons/asset_normalization.json").read_text(encoding="utf-8"))
    assets = {item["id"]: item for item in assets_payload["assets"]}
    style_paths: dict[str, str] = {}
    for row in ROWS:
        for state in ("normal", "hover", "pressed", "disabled", "focus"):
            path = f"res://assets/ui/theme/styles/buttons/{row.style_folder}/{state}.tres"
            if (ROOT / path.removeprefix("res://")).is_file():
                style_paths[path] = ""
        for state in ("selected", "selected_hover"):
            path = f"res://assets/ui/theme/styles/buttons/{row.style_folder}/{state}.tres"
            if (ROOT / path.removeprefix("res://")).is_file():
                style_paths[path] = ""
    ext_lines = ['[ext_resource type="Script" path="res://scripts/ui/button_feedback.gd" id="1_feedback"]']
    for index, path in enumerate(sorted(style_paths), 2):
        ext_id = f"{index}_style"
        style_paths[path] = ext_id
        ext_lines.append(f'[ext_resource type="StyleBox" path="{path}" id="{ext_id}"]')
    lines = [f'[gd_scene load_steps={len(ext_lines) + 1} format=3]', "", *ext_lines, ""]
    lines.extend([
        '[node name="ButtonStyleGallery" type="Control"]',
        'layout_mode = 3',
        'anchors_preset = 15',
        'anchor_right = 1.0',
        'anchor_bottom = 1.0',
        'grow_horizontal = 2',
        'grow_vertical = 2',
        '',
        '[node name="Background" type="ColorRect" parent="."]',
        'layout_mode = 1',
        'anchors_preset = 15',
        'anchor_right = 1.0',
        'anchor_bottom = 1.0',
        'grow_horizontal = 2',
        'grow_vertical = 2',
        'color = Color(0.012, 0.045, 0.034, 1)',
        'mouse_filter = 2',
        '',
        '[node name="Margin" type="MarginContainer" parent="."]',
        'layout_mode = 1',
        'anchors_preset = 15',
        'anchor_right = 1.0',
        'anchor_bottom = 1.0',
        'offset_left = 28.0',
        'offset_top = 22.0',
        'offset_right = -28.0',
        'offset_bottom = -22.0',
        'grow_horizontal = 2',
        'grow_vertical = 2',
        '',
        '[node name="Scroll" type="ScrollContainer" parent="Margin"]',
        'layout_mode = 2',
        'horizontal_scroll_mode = 0',
        '',
        '[node name="Rows" type="VBoxContainer" parent="Margin/Scroll"]',
        'layout_mode = 2',
        'size_flags_horizontal = 3',
        'theme_override_constants/separation = 14',
        '',
        '[node name="Title" type="Label" parent="Margin/Scroll/Rows"]',
        'layout_mode = 2',
        'theme_override_colors/font_color = Color(1, 0.82, 0.3, 1)',
        'theme_override_font_sizes/font_size = 40',
        'text = "按钮样式画廊 · normal / hover / pressed / disabled / focus / selected"',
        'horizontal_alignment = 1',
        '',
        '[node name="ColumnLabels" type="Label" parent="Margin/Scroll/Rows"]',
        'layout_mode = 2',
        'theme_override_font_sizes/font_size = 20',
        'text = "每行依次展示：正常 ｜ 悬停预览 ｜ 按下 ｜ 禁用 ｜ 焦点 ｜ 选中"',
        'horizontal_alignment = 1',
        '',
    ])
    for row_index, row in enumerate(ROWS):
        asset = assets[row.asset_id]
        margins = asset["texture_margin"]
        detail = (
            f"{row.name} | 纹理 {asset['output_size'][0]}×{asset['output_size'][1]} | "
            f"Texture Margin L{margins['left']} T{margins['top']} R{margins['right']} B{margins['bottom']} | "
            f"Content Margin 见外部 .tres | 推荐最小 {asset['recommended_minimum_size'][0]}×{asset['recommended_minimum_size'][1]}"
        )
        parent = f"Margin/Scroll/Rows/Row{row_index}"
        lines.extend([
            f'[node name="Row{row_index}" type="VBoxContainer" parent="Margin/Scroll/Rows"]',
            'layout_mode = 2',
            'theme_override_constants/separation = 5',
            '',
            f'[node name="Description" type="Label" parent="{parent}"]',
            'layout_mode = 2',
            'theme_override_colors/font_color = Color(0.86, 0.78, 0.58, 1)',
            'theme_override_font_sizes/font_size = 17',
            f'text = "{detail}"',
            '',
            f'[node name="States" type="HBoxContainer" parent="{parent}"]',
            'layout_mode = 2',
            'theme_override_constants/separation = 12',
            '',
        ])
        state_names = ("正常", "悬停", "按下", "禁用", "焦点", "选中")
        for state_index, label in enumerate(state_names):
            button_parent = f"{parent}/States"
            lines.append(f'[node name="State{state_index}" type="Button" parent="{button_parent}"]')
            lines.append(f'custom_minimum_size = Vector2({row.minimum_size[0]}, {row.minimum_size[1]})')
            lines.append('layout_mode = 2')
            if row.variation:
                lines.append(f'theme_type_variation = &"{row.variation}"')
            style_state = ("normal", "hover", "pressed", "disabled", "focus", "selected")[state_index]
            if not row.variation or state_index in (1, 4):
                path = f"res://assets/ui/theme/styles/buttons/{row.style_folder}/{style_state}.tres"
                if path not in style_paths and style_state == "selected":
                    path = f"res://assets/ui/theme/styles/buttons/{row.style_folder}/pressed.tres"
                if path in style_paths:
                    lines.append(f'theme_override_styles/normal = ExtResource("{style_paths[path]}")')
            if state_index == 2 and row.variation:
                lines.append('toggle_mode = true')
                lines.append('button_pressed = true')
            elif state_index == 3 and row.variation:
                lines.append('disabled = true')
            elif state_index == 5:
                selected_path = f"res://assets/ui/theme/styles/buttons/{row.style_folder}/selected.tres"
                if selected_path in style_paths:
                    lines.append(f'theme_override_styles/normal = ExtResource("{style_paths[selected_path]}")')
                elif row.variation:
                    lines.append('toggle_mode = true')
                    lines.append('button_pressed = true')
            if state_index == 4:
                lines.append('theme_override_colors/font_color = Color(1, 0.84, 0.42, 1)')
            text = label if state_index < 5 else ("已选中" if "tab" in row.style_folder or "sort_" in row.style_folder else "价格 $12")
            lines.append(f'text = "{text}"')
            lines.append('text_overrun_behavior = 3')
            lines.append('script = ExtResource("1_feedback")')
            lines.append('play_hover_sound = false')
            lines.append('')
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT.write_text("\n".join(lines).rstrip() + "\n", encoding="utf-8")
    print(f"Generated {OUTPUT.relative_to(ROOT)} with {len(ROWS)} style rows")


if __name__ == "__main__":
    main()
