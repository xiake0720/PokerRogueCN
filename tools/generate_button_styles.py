#!/usr/bin/env python3
"""Generate editor-visible Button StyleBox resources from measured asset specs."""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
STYLE_ROOT = ROOT / "assets/ui/theme/styles/buttons"


@dataclass(frozen=True)
class Family:
    folder: str
    texture: str
    margins: tuple[int, int, int, int]
    content: tuple[int, int, int, int]
    states: tuple[str, ...] = ("normal", "hover", "pressed", "disabled", "focus")
    disabled_texture: str = ""


FAMILIES = (
    Family("red", "common/primary_red.png", (58, 24, 58, 24), (34, 12, 34, 12)),
    Family("gold", "common/primary_gold.png", (58, 24, 58, 24), (34, 12, 34, 12)),
    Family("tab", "deck_select/tab_center.png", (38, 20, 38, 20), (28, 10, 28, 10), ("normal", "hover", "pressed", "disabled", "focus", "selected", "selected_hover")),
    Family("small", "common/small_gold.png", (27, 14, 27, 14), (20, 7, 20, 7)),
    Family("danger", "common/small_red.png", (27, 14, 27, 14), (20, 7, 20, 7)),
)


SPECIAL = (
    Family("home/start", "home/start.png", (84, 26, 84, 26), (72, 12, 32, 12)),
    Family("home/options", "home/options.png", (72, 22, 72, 22), (62, 10, 26, 10)),
    Family("home/quit", "home/quit.png", (72, 23, 72, 23), (62, 10, 26, 10)),
    Family("home/language", "home/language.png", (72, 23, 72, 23), (62, 10, 26, 10)),
    Family("deck_select/tab_left", "deck_select/tab_left.png", (44, 20, 38, 20), (28, 10, 28, 10), ("normal", "hover", "pressed", "disabled", "focus", "selected", "selected_hover")),
    Family("deck_select/tab_center", "deck_select/tab_center.png", (38, 20, 38, 20), (28, 10, 28, 10), ("normal", "hover", "pressed", "disabled", "focus", "selected", "selected_hover")),
    Family("deck_select/tab_right", "deck_select/tab_right.png", (38, 20, 44, 20), (28, 10, 28, 10), ("normal", "hover", "pressed", "disabled", "focus", "selected", "selected_hover")),
    Family("deck_select/start", "deck_select/start.png", (58, 22, 58, 22), (34, 11, 34, 11)),
    Family("deck_select/back", "deck_select/back.png", (42, 18, 42, 18), (26, 9, 26, 9)),
    Family("stage/select", "stage/select.png", (40, 18, 40, 18), (24, 9, 24, 9), disabled_texture="stage/disabled.png"),
    Family("stage/skip", "stage/skip.png", (34, 16, 34, 16), (22, 8, 22, 8), disabled_texture="stage/disabled.png"),
    Family("battle/play", "battle/play.png", (44, 22, 44, 22), (28, 11, 28, 11)),
    Family("battle/discard", "battle/discard.png", (34, 18, 34, 18), (22, 9, 22, 9)),
    Family("battle/sort_rank", "battle/sort_rank.png", (34, 18, 34, 18), (24, 9, 24, 9), ("normal", "hover", "pressed", "disabled", "focus", "selected", "selected_hover")),
    Family("battle/sort_suit", "battle/sort_suit.png", (34, 18, 34, 18), (24, 9, 24, 9), ("normal", "hover", "pressed", "disabled", "focus", "selected", "selected_hover")),
    Family("shop/next", "shop/next.png", (42, 19, 42, 19), (26, 9, 26, 9)),
    Family("shop/reroll", "shop/reroll.png", (34, 17, 34, 17), (22, 8, 22, 8)),
    Family("shop/buy", "shop/buy.png", (27, 14, 27, 14), (18, 7, 18, 7)),
    Family("settlement/continue", "settlement/continue.png", (50, 21, 50, 21), (30, 10, 30, 10)),
    Family("result/primary", "result/primary.png", (48, 20, 48, 20), (28, 10, 28, 10)),
    Family("result/home", "result/home.png", (40, 17, 40, 17), (24, 8, 24, 8)),
    Family("popup/confirm", "popup/confirm.png", (31, 14, 31, 14), (20, 7, 20, 7)),
    Family("popup/cancel", "popup/cancel.png", (31, 14, 31, 14), (20, 7, 20, 7)),
)


MODULATE = {
    "normal": "Color(1, 1, 1, 1)",
    "hover": "Color(1.08, 1.06, 1.02, 1)",
    "pressed": "Color(0.88, 0.9, 0.92, 1)",
    "disabled": "Color(0.55, 0.56, 0.58, 0.92)",
    "selected": "Color(1.12, 1.08, 0.9, 1)",
    "selected_hover": "Color(1.16, 1.12, 0.94, 1)",
}


def texture_style(family: Family, state: str) -> str:
    left, top, right, bottom = family.margins
    c_left, c_top, c_right, c_bottom = family.content
    texture_name = family.disabled_texture if state == "disabled" and family.disabled_texture else family.texture
    texture = f"res://assets/ui/runtime/buttons/{texture_name}"
    return f'''[gd_resource type="StyleBoxTexture" load_steps=2 format=3]

[ext_resource type="Texture2D" path="{texture}" id="1_texture"]

[resource]
content_margin_left = {float(c_left):.1f}
content_margin_top = {float(c_top):.1f}
content_margin_right = {float(c_right):.1f}
content_margin_bottom = {float(c_bottom):.1f}
texture = ExtResource("1_texture")
texture_margin_left = {float(left):.1f}
texture_margin_top = {float(top):.1f}
texture_margin_right = {float(right):.1f}
texture_margin_bottom = {float(bottom):.1f}
axis_stretch_horizontal = 0
axis_stretch_vertical = 0
modulate_color = {MODULATE[state]}
'''


def focus_style() -> str:
    return '''[gd_resource type="StyleBoxFlat" format=3]

[resource]
content_margin_left = 4.0
content_margin_top = 4.0
content_margin_right = 4.0
content_margin_bottom = 4.0
bg_color = Color(0, 0, 0, 0)
border_width_left = 3
border_width_top = 3
border_width_right = 3
border_width_bottom = 3
border_color = Color(1, 0.83, 0.32, 0.95)
corner_radius_top_left = 8
corner_radius_top_right = 8
corner_radius_bottom_right = 8
corner_radius_bottom_left = 8
anti_aliasing = false
'''


def icon_style(state: str) -> str:
    colors = {
        "normal": "Color(0.035, 0.11, 0.085, 0.86)",
        "hover": "Color(0.08, 0.21, 0.15, 0.96)",
        "pressed": "Color(0.025, 0.075, 0.06, 0.98)",
        "disabled": "Color(0.035, 0.055, 0.05, 0.62)",
    }
    if state == "focus":
        return focus_style()
    return f'''[gd_resource type="StyleBoxFlat" format=3]

[resource]
content_margin_left = 8.0
content_margin_top = 8.0
content_margin_right = 8.0
content_margin_bottom = 8.0
bg_color = {colors[state]}
border_width_left = 2
border_width_top = 2
border_width_right = 2
border_width_bottom = 2
border_color = Color(0.82, 0.61, 0.2, 0.9)
corner_radius_top_left = 8
corner_radius_top_right = 8
corner_radius_bottom_right = 8
corner_radius_bottom_left = 8
anti_aliasing = false
'''


def write_family(family: Family) -> None:
    folder = STYLE_ROOT / family.folder
    folder.mkdir(parents=True, exist_ok=True)
    for state in family.states:
        content = focus_style() if state == "focus" else texture_style(family, state)
        (folder / f"{state}.tres").write_text(content, encoding="utf-8")


def main() -> None:
    for family in (*FAMILIES, *SPECIAL):
        write_family(family)
    icon_folder = STYLE_ROOT / "icon"
    icon_folder.mkdir(parents=True, exist_ok=True)
    for state in ("normal", "hover", "pressed", "disabled", "focus"):
        (icon_folder / f"{state}.tres").write_text(icon_style(state), encoding="utf-8")
    print(f"Generated button StyleBox resources under {STYLE_ROOT}")


if __name__ == "__main__":
    main()
