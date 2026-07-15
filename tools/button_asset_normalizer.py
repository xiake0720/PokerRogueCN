#!/usr/bin/env python3
"""Deterministically normalize source button art for Godot runtime use.

The source files are read-only inputs. Outputs use nearest-neighbour sampling and
are grouped by scene so every StyleBoxTexture can reference a small, explicit
runtime texture instead of a large extracted atlas.
"""

from __future__ import annotations

import hashlib
import json
from dataclasses import dataclass
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
OUTPUT_ROOT = ROOT / "assets/ui/runtime/buttons"
REPORT_PATH = ROOT / "tools/reports/buttons/asset_normalization.json"


@dataclass(frozen=True)
class ButtonAssetSpec:
    asset_id: str
    source: str
    output: str
    output_size: tuple[int, int]
    texture_margin: tuple[int, int, int, int]
    minimum_size: tuple[int, int]
    usage: str
    trim_alpha: bool = True
    padding: int = 0


SPECS = (
    ButtonAssetSpec("common_primary_red", "art_source/ui/extracted/battle/button_red_large.png", "common/primary_red.png", (420, 110), (58, 24, 58, 24), (280, 84), "Extra-large and primary red buttons", False),
    ButtonAssetSpec("common_primary_gold", "art_source/ui/extracted/battle/button_gold_large.png", "common/primary_gold.png", (420, 110), (58, 24, 58, 24), (280, 84), "Extra-large and primary gold buttons", False),
    ButtonAssetSpec("common_secondary_red", "assets/ui/extracted/battle/button_red_small.png", "common/secondary_red.png", (300, 88), (42, 19, 42, 19), (170, 58), "Secondary red buttons", False),
    ButtonAssetSpec("common_secondary_gold", "assets/ui/extracted/battle/button_gold_small.png", "common/secondary_gold.png", (300, 88), (42, 19, 42, 19), (170, 58), "Secondary gold buttons", False),
    ButtonAssetSpec("common_small_red", "assets/ui/extracted/battle/button_red_small.png", "common/small_red.png", (190, 64), (27, 14, 27, 14), (120, 46), "Compact red and danger buttons", False),
    ButtonAssetSpec("common_small_gold", "assets/ui/extracted/battle/button_gold_small.png", "common/small_gold.png", (190, 64), (27, 14, 27, 14), (120, 46), "Compact gold buttons", False),
    ButtonAssetSpec("home_start", "art_source/ui/extracted/home/menu_button_start.png", "home/start.png", (620, 136), (84, 26, 84, 26), (360, 96), "Home start button", False),
    ButtonAssetSpec("home_options", "art_source/ui/extracted/home/menu_button_settings.png", "home/options.png", (560, 105), (72, 22, 72, 22), (300, 72), "Home settings button", False),
    ButtonAssetSpec("home_quit", "art_source/ui/extracted/home/menu_button_quit.png", "home/quit.png", (560, 111), (72, 23, 72, 23), (300, 72), "Home quit button", False),
    ButtonAssetSpec("home_language", "art_source/ui/extracted/home/menu_button_language.png", "home/language.png", (560, 111), (72, 23, 72, 23), (300, 72), "Home language button", False),
    ButtonAssetSpec("deck_tab_left", "assets/ui/runtime/buttons/deck_tab_left.png", "deck_select/tab_left.png", (303, 88), (44, 20, 38, 20), (240, 72), "New-run tab"),
    ButtonAssetSpec("deck_tab_center", "assets/ui/runtime/buttons/deck_tab_center.png", "deck_select/tab_center.png", (280, 88), (38, 20, 38, 20), (240, 72), "Continue tab"),
    ButtonAssetSpec("deck_tab_right", "assets/ui/runtime/buttons/deck_tab_right.png", "deck_select/tab_right.png", (292, 88), (38, 20, 44, 20), (240, 72), "Challenge tab"),
    ButtonAssetSpec("deck_start", "assets/ui/runtime/buttons/deck_start_button.png", "deck_select/start.png", (420, 100), (58, 22, 58, 22), (300, 84), "Deck start button"),
    ButtonAssetSpec("deck_back", "assets/ui/runtime/buttons/deck_back_button.png", "deck_select/back.png", (300, 78), (42, 18, 42, 18), (220, 68), "Deck back button"),
    ButtonAssetSpec("deck_arrow_left", "assets/ui/runtime/icons/deck_arrow_left.png", "deck_select/arrow_left.png", (42, 34), (0, 0, 0, 0), (48, 48), "Previous selector icon"),
    ButtonAssetSpec("deck_arrow_right", "assets/ui/runtime/icons/deck_arrow_right.png", "deck_select/arrow_right.png", (42, 34), (0, 0, 0, 0), (48, 48), "Next selector icon"),
    ButtonAssetSpec("stage_select", "assets/ui/runtime/buttons/stage_select_button.png", "stage/select.png", (300, 78), (40, 18, 40, 18), (220, 68), "Blind select button"),
    ButtonAssetSpec("stage_skip", "assets/ui/runtime/buttons/stage_skip_button.png", "stage/skip.png", (240, 68), (34, 16, 34, 16), (170, 58), "Blind skip button"),
    ButtonAssetSpec("stage_disabled", "assets/ui/runtime/buttons/stage_disabled_button.png", "stage/disabled.png", (300, 78), (40, 18, 40, 18), (220, 68), "Blind disabled state"),
    ButtonAssetSpec("battle_play", "assets/ui/runtime/buttons/battle_play_button.png", "battle/play.png", (300, 92), (44, 22, 44, 22), (220, 84), "Battle play button"),
    ButtonAssetSpec("battle_discard", "assets/ui/runtime/buttons/battle_discard_button.png", "battle/discard.png", (230, 78), (34, 18, 34, 18), (170, 68), "Battle discard button"),
    ButtonAssetSpec("battle_sort_rank", "assets/ui/runtime/buttons/battle_sort_rank_button.png", "battle/sort_rank.png", (230, 78), (34, 18, 34, 18), (170, 68), "Sort by rank button"),
    ButtonAssetSpec("battle_sort_suit", "assets/ui/runtime/buttons/battle_sort_suit_button.png", "battle/sort_suit.png", (230, 78), (34, 18, 34, 18), (170, 68), "Sort by suit button"),
    ButtonAssetSpec("shop_next", "assets/ui/runtime/buttons/shop_button_red.png", "shop/next.png", (300, 82), (42, 19, 42, 19), (220, 68), "Leave shop button"),
    ButtonAssetSpec("shop_reroll", "assets/ui/runtime/buttons/shop_button_green.png", "shop/reroll.png", (240, 72), (34, 17, 34, 17), (170, 58), "Shop reroll button"),
    ButtonAssetSpec("shop_buy", "assets/ui/runtime/buttons/shop_button_green.png", "shop/buy.png", (190, 60), (27, 14, 27, 14), (120, 48), "Shop offer buy button"),
    ButtonAssetSpec("settlement_continue", "assets/ui/runtime/buttons/settlement_continue_button.png", "settlement/continue.png", (360, 92), (50, 21, 50, 21), (280, 84), "Settlement continue button"),
    ButtonAssetSpec("result_primary", "assets/ui/runtime/buttons/settlement_continue_button.png", "result/primary.png", (340, 88), (48, 20, 48, 20), (280, 80), "Result primary action"),
    ButtonAssetSpec("result_home", "assets/ui/runtime/buttons/deck_back_button.png", "result/home.png", (280, 76), (40, 17, 40, 17), (220, 68), "Result secondary action"),
    ButtonAssetSpec("popup_confirm", "assets/ui/extracted/battle/button_gold_small.png", "popup/confirm.png", (220, 64), (31, 14, 31, 14), (160, 54), "Popup confirmation", False),
    ButtonAssetSpec("popup_cancel", "assets/ui/extracted/battle/button_red_small.png", "popup/cancel.png", (220, 64), (31, 14, 31, 14), (160, 54), "Popup cancel", False),
)


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def normalize(spec: ButtonAssetSpec) -> dict[str, object]:
    source_path = ROOT / spec.source
    if not source_path.is_file():
        raise FileNotFoundError(source_path)
    image = Image.open(source_path).convert("RGBA")
    source_size = image.size
    alpha_bbox = image.getchannel("A").getbbox() or (0, 0, *source_size)
    crop_bbox = alpha_bbox if spec.trim_alpha else (0, 0, *source_size)
    cropped = image.crop(crop_bbox)
    if spec.padding:
        padded = Image.new("RGBA", (cropped.width + spec.padding * 2, cropped.height + spec.padding * 2))
        padded.alpha_composite(cropped, (spec.padding, spec.padding))
        cropped = padded
    normalized = cropped.resize(spec.output_size, Image.Resampling.NEAREST)
    output_path = OUTPUT_ROOT / spec.output
    output_path.parent.mkdir(parents=True, exist_ok=True)
    normalized.save(output_path, format="PNG", optimize=False, compress_level=9)
    left, top, right, bottom = spec.texture_margin
    if left + right >= spec.minimum_size[0] or top + bottom >= spec.minimum_size[1]:
        raise ValueError(f"Invalid nine-patch geometry for {spec.asset_id}")
    source_reference = spec.source.replace("\\", "/")
    if not source_reference.startswith("art_source/"):
        source_reference = "res://" + source_reference
    return {
        "id": spec.asset_id,
        "source": source_reference,
        "source_sha256": sha256(source_path),
        "source_size": list(source_size),
        "alpha_bbox": list(alpha_bbox),
        "crop_bbox": list(crop_bbox),
        "cropped_size": [crop_bbox[2] - crop_bbox[0], crop_bbox[3] - crop_bbox[1]],
        "output": "res://assets/ui/runtime/buttons/" + spec.output.replace("\\", "/"),
        "output_size": list(spec.output_size),
        "output_sha256": sha256(output_path),
        "texture_margin": {"left": left, "top": top, "right": right, "bottom": bottom},
        "recommended_minimum_size": list(spec.minimum_size),
        "axis_stretch": "stretch",
        "filter": "nearest",
        "usage": spec.usage,
    }


def main() -> None:
    records = [normalize(spec) for spec in SPECS]
    payload = {"schema_version": 1, "generator": "tools/button_asset_normalizer.py", "assets": records}
    REPORT_PATH.parent.mkdir(parents=True, exist_ok=True)
    REPORT_PATH.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Normalized {len(records)} button assets -> {OUTPUT_ROOT}")


if __name__ == "__main__":
    main()
