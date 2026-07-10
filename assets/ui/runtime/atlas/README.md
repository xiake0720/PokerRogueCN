# Atlas resources

Runtime sprites are currently committed as independent PNG files because they
are edited and replaced individually in Godot. Put future `AtlasTexture` `.tres`
resources in this directory, and keep their source rectangles synchronized with
`tools/ui_asset_slices.json`. Do not point an atlas at a reference screenshot.
