# Asset Replacement Notes

## Scope

- Project design size changed to 1920x1080.
- Global UI font uses ChillHuoGothic_F_ConBold.otf.
- Uploaded transparent assets are normalized under assets/ui, assets/cards, and assets/reference.
- Full reference images are kept as reference only and are not blindly overlaid as interactive UI.
- Poker card faces are generated as 52 PNG textures from the provided blank card and suit assets.
- Joker, tarot, spectral, voucher, and pack cards still use current object views because no final card art was provided.

## Shared UI

- Left score/HUD panel is centralized in scenes/game/game_hud_panel.tscn.
- Battle, stage select, and shop now instance the shared HUD scene.

## Validation

- Resource paths checked.
- JSON parsed.
- No := usage.
- No to_local() usage.
- No same-name CardConstants/HandEvaluator/ScoreEngine preload shadows.
