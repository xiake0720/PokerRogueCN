#!/usr/bin/env python3
"""Generate deterministic, text-free card art fallbacks and their manifest.

These assets are deliberately simple original vector-like drawings made with
Pillow.  They are category fallbacks, not substitutes for future bespoke art.
"""

from __future__ import annotations

import hashlib
import io
import json
from pathlib import Path
from typing import Callable

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[1]
OUTPUT_DIR = ROOT / "assets" / "ui" / "runtime" / "generated"
MANIFEST_PATH = ROOT / "assets" / "cards" / "card_art_manifest.json"
SIZE = (320, 448)
GOLD = (232, 184, 74, 255)
PALE_GOLD = (255, 231, 155, 255)
INK = (15, 18, 24, 255)


def _encode(image: Image.Image) -> bytes:
    buffer = io.BytesIO()
    image.save(buffer, format="PNG", optimize=False, compress_level=9)
    return buffer.getvalue()


def _write_if_changed(path: Path, data: bytes) -> str:
    current = path.read_bytes() if path.exists() else None
    if current == data:
        return "unchanged"
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(data)
    return "created" if current is None else "updated"


def _gradient(base: tuple[int, int, int], top: tuple[int, int, int]) -> Image.Image:
    image = Image.new("RGBA", SIZE, (0, 0, 0, 0))
    pixels = image.load()
    for y in range(SIZE[1]):
        amount = y / float(SIZE[1] - 1)
        color = tuple(int(top[index] * (1.0 - amount) + base[index] * amount) for index in range(3)) + (255,)
        for x in range(SIZE[0]):
            pixels[x, y] = color
    return image


def _card_base(base: tuple[int, int, int], top: tuple[int, int, int], accent: tuple[int, int, int]) -> tuple[Image.Image, ImageDraw.ImageDraw]:
    canvas = Image.new("RGBA", SIZE, (0, 0, 0, 0))
    draw = ImageDraw.Draw(canvas, "RGBA")
    draw.rounded_rectangle((15, 19, 307, 437), radius=30, fill=(0, 0, 0, 105))

    fill = _gradient(base, top)
    mask = Image.new("L", SIZE, 0)
    ImageDraw.Draw(mask).rounded_rectangle((12, 12, 300, 428), radius=28, fill=255)
    canvas.alpha_composite(Image.composite(fill, Image.new("RGBA", SIZE), mask))

    pattern = Image.new("RGBA", SIZE, (0, 0, 0, 0))
    pattern_draw = ImageDraw.Draw(pattern, "RGBA")
    for offset in range(-280, 340, 44):
        pattern_draw.line((offset, 405, offset + 330, 34), fill=(*accent, 30), width=8)
    pattern_mask = Image.new("L", SIZE, 0)
    ImageDraw.Draw(pattern_mask).rounded_rectangle((29, 29, 283, 411), radius=16, fill=255)
    canvas.alpha_composite(Image.composite(pattern, Image.new("RGBA", SIZE), pattern_mask))

    draw = ImageDraw.Draw(canvas, "RGBA")
    draw.rounded_rectangle((12, 12, 300, 428), radius=28, outline=(82, 45, 15, 255), width=8)
    draw.rounded_rectangle((19, 19, 293, 421), radius=22, outline=GOLD, width=5)
    draw.rounded_rectangle((28, 28, 284, 412), radius=17, outline=(*accent, 210), width=2)
    for x, y in ((36, 38), (276, 38), (36, 402), (276, 402)):
        draw.polygon(((x, y - 8), (x + 8, y), (x, y + 8), (x - 8, y)), fill=PALE_GOLD)
    draw.rounded_rectangle((50, 326, 262, 377), radius=14, fill=(5, 10, 12, 110), outline=(*accent, 180), width=3)
    for x in range(74, 245, 28):
        draw.ellipse((x, 345, x + 8, 353), fill=(*accent, 155))
    return canvas, draw


def _joker(draw: ImageDraw.ImageDraw) -> None:
    draw.ellipse((101, 139, 211, 249), fill=(244, 219, 174, 255), outline=GOLD, width=5)
    draw.polygon(((98, 157), (73, 100), (134, 134), (156, 82), (181, 134), (239, 99), (213, 161)), fill=(112, 38, 131, 255), outline=GOLD)
    for x, y in ((73, 100), (156, 82), (239, 99)):
        draw.ellipse((x - 9, y - 9, x + 9, y + 9), fill=PALE_GOLD)
    draw.ellipse((126, 181, 139, 194), fill=INK)
    draw.ellipse((174, 181, 187, 194), fill=INK)
    draw.arc((129, 182, 183, 225), 18, 162, fill=(139, 35, 40, 255), width=6)


def _joker_variant(item: dict) -> Image.Image:
    """Create a deterministic, text-free card unique to one joker definition."""
    joker_id = str(item.get("id", "unknown_joker"))
    rarity = str(item.get("rarity", "common"))
    effect = item.get("effect", {}) if isinstance(item.get("effect", {}), dict) else {}
    effect_kind = str(effect.get("kind", "none"))
    digest = hashlib.sha256(f"{joker_id}|{effect_kind}|{rarity}".encode("utf-8")).digest()
    palettes = {
        "common": ((42, 28, 51), (100, 45, 82)),
        "uncommon": ((18, 52, 43), (38, 112, 72)),
        "rare": ((18, 39, 73), (42, 83, 151)),
        "legendary": ((74, 30, 20), (158, 72, 28)),
    }
    base, top = palettes.get(rarity, palettes["common"])
    accent = (110 + digest[0] % 130, 90 + digest[1] % 140, 100 + digest[2] % 130)
    image, draw = _card_base(base, top, accent)
    _joker(draw)

    # Effect-family glyphs make mechanically different jokers recognizable.
    family = effect_kind.split("_")[0]
    if "money" in effect_kind or "gold" in effect_kind or family in {"sell", "interest"}:
        for offset in (0, 18, 36):
            draw.ellipse((69 + offset, 278 - offset // 3, 105 + offset, 296 - offset // 3), fill=GOLD, outline=PALE_GOLD, width=2)
    elif "mult" in effect_kind:
        draw.polygon(((81, 288), (96, 263), (111, 288), (96, 313)), fill=(194, 48, 58, 255), outline=PALE_GOLD)
        draw.polygon(((201, 288), (216, 263), (231, 288), (216, 313)), fill=(194, 48, 58, 255), outline=PALE_GOLD)
    elif "chip" in effect_kind:
        for x, color in ((80, (40, 121, 205, 255)), (130, (210, 52, 54, 255)), (180, (44, 142, 83, 255))):
            draw.ellipse((x, 270, x + 42, 312), fill=color, outline=PALE_GOLD, width=3)
    elif "copy" in effect_kind:
        draw.ellipse((67, 267, 119, 319), outline=PALE_GOLD, width=5)
        draw.ellipse((193, 267, 245, 319), outline=PALE_GOLD, width=5)
        draw.line((121, 293, 191, 293), fill=GOLD, width=5)
    elif "suit" in effect_kind or "face" in effect_kind or "rank" in effect_kind:
        draw.polygon(((82, 293), (102, 266), (122, 293), (102, 320)), fill=(188, 36, 48, 255), outline=PALE_GOLD)
        draw.polygon(((190, 320), (174, 286), (206, 286)), fill=(20, 26, 35, 255), outline=PALE_GOLD)
    else:
        points = 3 + digest[3] % 4
        for index in range(points):
            x = 70 + (digest[4 + index] % 170)
            y = 274 + (digest[10 + index] % 48)
            radius = 6 + digest[16 + index] % 10
            draw.polygon(((x, y - radius), (x + radius, y), (x, y + radius), (x - radius, y)), fill=(*accent, 230), outline=PALE_GOLD)

    # A hashed corner constellation ensures same-family cards are still unique.
    for index in range(5):
        x = 48 + (digest[21 + index] % 218)
        y = 52 + (digest[26 + index] % 55)
        radius = 3 + digest[31 - index] % 5
        draw.ellipse((x - radius, y - radius, x + radius, y + radius), fill=(*accent, 210), outline=PALE_GOLD)
    return image


def _voucher(draw: ImageDraw.ImageDraw) -> None:
    ticket = [(65, 128), (247, 128), (247, 161), (264, 177), (247, 194), (247, 269), (65, 269), (65, 194), (48, 177), (65, 161)]
    draw.polygon(ticket, fill=(239, 222, 172, 255), outline=GOLD)
    draw.line((89, 128, 89, 269), fill=(132, 53, 44, 255), width=4)
    draw.line((223, 128, 223, 269), fill=(132, 53, 44, 255), width=4)
    draw.polygon(((156, 151), (200, 198), (156, 246), (112, 198)), fill=(127, 28, 37, 255), outline=GOLD)
    draw.polygon(((156, 169), (181, 198), (156, 227), (131, 198)), fill=PALE_GOLD)


def _pack(draw: ImageDraw.ImageDraw) -> None:
    draw.rounded_rectangle((74, 107, 238, 286), radius=18, fill=(90, 37, 112, 255), outline=GOLD, width=6)
    draw.rectangle((67, 107, 245, 143), fill=(127, 54, 146, 255), outline=PALE_GOLD, width=3)
    draw.rectangle((67, 250, 245, 286), fill=(127, 54, 146, 255), outline=PALE_GOLD, width=3)
    draw.polygon(((111, 235), (105, 157), (149, 148), (156, 230)), fill=(234, 221, 190, 255), outline=GOLD)
    draw.polygon(((158, 230), (168, 148), (211, 160), (199, 237)), fill=(228, 207, 169, 255), outline=GOLD)
    draw.ellipse((128, 166, 186, 226), fill=(36, 28, 62, 255), outline=PALE_GOLD, width=4)


def _tarot(draw: ImageDraw.ImageDraw) -> None:
    draw.ellipse((94, 122, 218, 246), fill=(245, 224, 164, 255), outline=GOLD, width=4)
    draw.ellipse((129, 102, 230, 224), fill=(83, 25, 76, 255))
    for x, y, r in ((83, 125, 7), (228, 119, 8), (226, 247, 6), (97, 262, 5)):
        draw.polygon(((x, y - r), (x + r, y), (x, y + r), (x - r, y)), fill=PALE_GOLD)


def _planet(draw: ImageDraw.ImageDraw) -> None:
    draw.ellipse((94, 124, 218, 248), fill=(52, 157, 202, 255), outline=PALE_GOLD, width=4)
    draw.arc((58, 157, 254, 232), 188, 350, fill=GOLD, width=12)
    draw.arc((58, 157, 254, 232), 8, 171, fill=PALE_GOLD, width=4)
    draw.arc((112, 148, 202, 207), 25, 150, fill=(151, 222, 230, 220), width=10)


def _spectral(draw: ImageDraw.ImageDraw) -> None:
    draw.polygon(((64, 199), (104, 155), (156, 135), (208, 155), (248, 199), (208, 243), (156, 263), (104, 243)), fill=(30, 43, 88, 255), outline=GOLD)
    draw.ellipse((104, 157, 208, 241), fill=(198, 231, 224, 255), outline=PALE_GOLD, width=4)
    draw.ellipse((132, 171, 180, 227), fill=(55, 137, 176, 255))
    draw.ellipse((146, 183, 170, 215), fill=INK)
    draw.ellipse((151, 188, 159, 198), fill=(255, 255, 255, 230))


def _deck(draw: ImageDraw.ImageDraw) -> None:
    draw.rounded_rectangle((78, 109, 216, 268), radius=15, fill=(29, 60, 61, 255), outline=GOLD, width=5)
    draw.rounded_rectangle((101, 128, 239, 287), radius=15, fill=(17, 39, 44, 255), outline=PALE_GOLD, width=5)
    draw.rounded_rectangle((116, 143, 224, 272), radius=10, outline=GOLD, width=3)
    draw.polygon(((170, 163), (205, 207), (170, 251), (135, 207)), fill=GOLD)
    draw.polygon(((170, 181), (190, 207), (170, 233), (150, 207)), fill=(31, 68, 64, 255))


def _blind(draw: ImageDraw.ImageDraw) -> None:
    draw.ellipse((75, 116, 237, 278), fill=(25, 75, 151, 255), outline=GOLD, width=8)
    draw.ellipse((94, 135, 218, 259), outline=PALE_GOLD, width=10)
    for angle_point in ((156, 125), (212, 152), (228, 207), (201, 259), (156, 270), (101, 250), (84, 199), (105, 145)):
        x, y = angle_point
        draw.ellipse((x - 7, y - 7, x + 7, y + 7), fill=PALE_GOLD)
    draw.polygon(((156, 158), (197, 199), (156, 240), (115, 199)), fill=(15, 37, 79, 255), outline=GOLD)


def _unknown(draw: ImageDraw.ImageDraw) -> None:
    draw.ellipse((91, 132, 221, 262), outline=GOLD, width=8)
    draw.line((156, 145, 156, 249), fill=PALE_GOLD, width=8)
    draw.line((104, 197, 208, 197), fill=PALE_GOLD, width=8)
    draw.polygon(((156, 119), (168, 144), (156, 169), (144, 144)), fill=GOLD)
    draw.polygon(((156, 225), (168, 250), (156, 275), (144, 250)), fill=GOLD)


def _make_card(
    base: tuple[int, int, int],
    top: tuple[int, int, int],
    accent: tuple[int, int, int],
    emblem: Callable[[ImageDraw.ImageDraw], None],
) -> Image.Image:
    image, draw = _card_base(base, top, accent)
    emblem(draw)
    return image


def _make_lock_icon() -> Image.Image:
    image = Image.new("RGBA", (200, 200), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image, "RGBA")
    draw.rounded_rectangle((45, 78, 163, 178), radius=18, fill=(0, 0, 0, 95))
    draw.arc((53, 20, 147, 122), 180, 360, fill=(71, 48, 23, 255), width=26)
    draw.arc((53, 20, 147, 122), 180, 360, fill=GOLD, width=14)
    draw.rounded_rectangle((35, 68, 153, 168), radius=18, fill=(220, 196, 142, 255), outline=(91, 59, 24, 255), width=7)
    draw.rounded_rectangle((45, 78, 143, 158), radius=12, outline=PALE_GOLD, width=3)
    draw.ellipse((85, 96, 105, 116), fill=INK)
    draw.polygon(((90, 108), (100, 108), (109, 143), (81, 143)), fill=INK)
    return image


def _ids(path: str) -> list[str]:
    payload = json.loads((ROOT / path).read_text(encoding="utf-8-sig"))
    return [str(item["id"]) for item in payload]


def _items(path: str) -> list[dict]:
    payload = json.loads((ROOT / path).read_text(encoding="utf-8-sig"))
    return [item for item in payload if isinstance(item, dict)]


def _res(path: str) -> str:
    return f"res://{path}"


def _build_manifest() -> dict:
    joker_items = _items("data/cards/jokers.json")
    joker_ids = [str(item["id"]) for item in joker_items]
    voucher_ids = _ids("data/cards/vouchers.json")
    pack_ids = _ids("data/game/booster_packs.json")
    tarot_ids = _ids("data/cards/tarot_cards.json")
    planet_ids = _ids("data/cards/planet_cards.json")
    spectral_ids = _ids("data/cards/spectral_cards.json")
    deck_ids = _ids("data/game/decks.json")
    blind_ids = sorted(set(_ids("data/game/blinds.json") + _ids("data/game/boss_blinds.json")))
    generated = "res://assets/ui/runtime/generated/"
    runtime = "res://assets/ui/runtime/"
    return {
        "schema_version": 1,
        "generator": "res://tools/generate_card_fallbacks.py",
        "kinds": {
            "joker": {
                "fallback": generated + "joker_fallback.png",
                "known_ids": joker_ids,
                "items": {
                    **{joker_id: generated + f"jokers/{joker_id}.png" for joker_id in joker_ids},
                    "joker": runtime + "icons/shop_joker_art.png",
                },
                "generated_items": [joker_id for joker_id in joker_ids if joker_id != "joker"],
            },
            "voucher": {
                "fallback": generated + "voucher_fallback.png",
                "known_ids": voucher_ids,
                "items": {},
            },
            "pack": {
                "fallback": generated + "pack_fallback.png",
                "known_ids": pack_ids,
                "items": {
                    "buffoon_pack": runtime + "icons/shop_pack_joker.png",
                    "spectral_pack": runtime + "icons/shop_pack_spectral.png",
                },
            },
            "consumable": {
                "fallback": generated + "consumable_tarot_fallback.png",
                "fallback_by_subtype": {
                    "tarot": generated + "consumable_tarot_fallback.png",
                    "planet": generated + "consumable_planet_fallback.png",
                    "spectral": generated + "consumable_spectral_fallback.png",
                },
                "known_ids": sorted(tarot_ids + planet_ids + spectral_ids),
                "subtype_ids": {
                    "tarot": tarot_ids,
                    "planet": planet_ids,
                    "spectral": spectral_ids,
                },
                "items": {"mercury": runtime + "icons/shop_consumable_mercury.png"},
            },
            "deck": {
                "fallback": generated + "deck_fallback.png",
                "known_ids": deck_ids,
                "items": {
                    "red_deck": generated + "deck_red_fallback.png",
                    "blue_deck": generated + "deck_blue_fallback.png",
                    "yellow_deck": generated + "deck_yellow_fallback.png",
                    "black_deck": generated + "deck_black_fallback.png",
                },
            },
            "blind": {
                "fallback": generated + "blind_fallback.png",
                "known_ids": blind_ids,
                "items": {
                    "small_blind": runtime + "tokens/stage_blind_small.png",
                    "big_blind": runtime + "tokens/stage_blind_big.png",
                    **{
                        blind_id: runtime + "tokens/stage_blind_boss_locked.png"
                        for blind_id in blind_ids
                        if blind_id.startswith("boss_")
                    },
                },
            },
        },
        "unknown_fallback": generated + "unknown_fallback.png",
        "coverage": {
            "joker": {"known": len(joker_ids), "dedicated": len(joker_ids), "generated": max(0, len(joker_ids) - 1)},
            "voucher": {"known": len(voucher_ids), "dedicated": 0},
            "pack": {"known": len(pack_ids), "dedicated": 2},
            "consumable": {"known": len(tarot_ids) + len(planet_ids) + len(spectral_ids), "dedicated": 1},
            "deck": {"known": len(deck_ids), "dedicated": 4},
            "blind": {"known": len(blind_ids), "dedicated": len(blind_ids)},
        },
    }


def main() -> int:
    definitions = {
        "joker_fallback.png": ((49, 19, 58), (126, 35, 83), (207, 111, 202), _joker),
        "voucher_fallback.png": ((72, 23, 24), (145, 44, 46), (233, 182, 91), _voucher),
        "pack_fallback.png": ((38, 21, 67), (104, 44, 126), (197, 116, 216), _pack),
        "consumable_tarot_fallback.png": ((48, 21, 61), (108, 35, 91), (224, 162, 211), _tarot),
        "consumable_planet_fallback.png": ((13, 45, 73), (20, 93, 135), (95, 207, 226), _planet),
        "consumable_spectral_fallback.png": ((17, 24, 60), (29, 52, 112), (97, 214, 227), _spectral),
        "deck_fallback.png": ((17, 51, 43), (25, 91, 70), (76, 178, 131), _deck),
        "deck_red_fallback.png": ((69, 18, 25), (151, 36, 45), (231, 89, 74), _deck),
        "deck_blue_fallback.png": ((14, 37, 72), (27, 82, 151), (72, 163, 232), _deck),
        "deck_yellow_fallback.png": ((84, 49, 16), (164, 113, 24), (252, 209, 75), _deck),
        "deck_black_fallback.png": ((13, 15, 18), (49, 51, 56), (164, 172, 172), _deck),
        "blind_fallback.png": ((12, 31, 68), (23, 78, 145), (88, 188, 235), _blind),
        "unknown_fallback.png": ((35, 38, 42), (70, 75, 80), (189, 192, 193), _unknown),
    }
    for filename, (base, top, accent, emblem) in definitions.items():
        state = _write_if_changed(OUTPUT_DIR / filename, _encode(_make_card(base, top, accent, emblem)))
        print(f"{state:9} {filename}")
    for joker in _items("data/cards/jokers.json"):
        joker_id = str(joker.get("id", "unknown_joker"))
        if joker_id == "joker":
            continue
        path = OUTPUT_DIR / "jokers" / f"{joker_id}.png"
        state = _write_if_changed(path, _encode(_joker_variant(joker)))
        print(f"{state:9} jokers/{joker_id}.png")
    state = _write_if_changed(OUTPUT_DIR / "blind_lock_icon.png", _encode(_make_lock_icon()))
    print(f"{state:9} blind_lock_icon.png")
    manifest_data = (json.dumps(_build_manifest(), ensure_ascii=False, indent=2) + "\n").encode("utf-8")
    state = _write_if_changed(MANIFEST_PATH, manifest_data)
    print(f"{state:9} {MANIFEST_PATH.relative_to(ROOT).as_posix()}")
    print("manifest sha256", hashlib.sha256(manifest_data).hexdigest())
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
