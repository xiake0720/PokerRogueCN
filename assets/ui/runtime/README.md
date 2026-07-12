# Runtime UI assets

This directory contains editor-ready PNGs produced by offline tools. The files
under `assets/ui/extracted/` are the canonical source sheets and must not be
modified in place.

- Rebuild text-free art fallbacks: `python tools/generate_card_fallbacks.py`
- Rebuild all UI slices and the catalog: `python tools/ui_asset_slicer.py`
- Verify that committed outputs are current: `python tools/ui_asset_slicer.py --validate-only`

`ui_asset_catalog.json` records every source rectangle, output size, alpha-edge
check, SHA-256 hash, scene, category, and intended use. Generated category
fallbacks are explicitly marked with `generated: true`.
