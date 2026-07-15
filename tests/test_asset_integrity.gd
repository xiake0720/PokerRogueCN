extends SceneTree

var failures: Array[String] = []

func _init() -> void:
	_run.call_deferred()

func _run() -> void:
	var json_paths: Array[String] = [
		"res://tools/art_pipeline/manifests/asset_manifest.json",
		"res://tools/art_pipeline/manifests/extracted_asset_manifest.json",
		"res://tools/reports/buttons/button_manifest.json",
		"res://tools/reports/buttons/asset_normalization.json",
		"res://assets/ui/runtime/ui_asset_catalog.json",
		"res://assets/cards/card_art_manifest.json",
		"res://data/cards/jokers.json",
		"res://data/cards/planet_cards.json",
		"res://data/cards/spectral_cards.json",
		"res://data/cards/tarot_cards.json",
		"res://data/cards/vouchers.json",
		"res://data/game/blinds.json",
		"res://data/game/booster_packs.json",
		"res://data/game/boss_blinds.json",
		"res://data/game/decks.json",
		"res://data/game/poker_hands.json",
		"res://data/game/tags.json",
		"res://data/localization/zh_cn.json",
	]
	for path in json_paths:
		_expect(FileAccess.file_exists(path), "missing JSON: %s" % path)
		if FileAccess.file_exists(path):
			var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
			_expect(parsed != null, "invalid JSON: %s" % path)
			if parsed != null and path.contains("manifest"):
				_check_manifest_resource_paths(path, parsed)

	var ranks: Array[String] = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "j", "q", "k", "a"]
	var suits: Array[String] = ["clubs", "diamonds", "hearts", "spades"]
	var face_count: int = 0
	for rank in ranks:
		for suit in suits:
			var face_path: String = "res://assets/cards/poker/faces/%s_%s.png" % [rank, suit]
			_expect(FileAccess.file_exists(face_path), "missing poker face: %s" % face_path)
			if ResourceLoader.load(face_path, "Texture2D") is Texture2D:
				face_count += 1
	_expect(face_count == 52, "expected 52 importable poker faces, got %d" % face_count)

	var required_textures: Array[String] = [
		"res://assets/ui/runtime/backgrounds/home_table.png",
		"res://assets/ui/runtime/backgrounds/game_table_base.png",
		"res://assets/ui/runtime/frames/battle_hud_title_plate.png",
		"res://assets/ui/runtime/panels/battle_hud_chips_panel.png",
		"res://assets/ui/runtime/panels/battle_hud_mult_panel.png",
		"res://assets/ui/runtime/panels/settlement_detail_panel.png",
		"res://assets/ui/runtime/panels/shop_title_panel.png",
		"res://assets/ui/runtime/generated/joker_fallback.png",
		"res://assets/ui/runtime/generated/voucher_fallback.png",
		"res://assets/ui/runtime/generated/pack_fallback.png",
	]
	for path in required_textures:
		_expect(ResourceLoader.load(path, "Texture2D") is Texture2D, "texture failed to import: %s" % path)
	_finish("test_asset_integrity")

func _check_manifest_resource_paths(manifest_path: String, value: Variant) -> void:
	var paths: Array[String] = []
	_collect_res_paths(value, paths)
	var checked: Dictionary = {}
	for path in paths:
		if checked.has(path):
			continue
		checked[path] = true
		_expect(FileAccess.file_exists(path) or ResourceLoader.exists(path), "%s references missing resource: %s" % [manifest_path, path])
		if path.get_extension().to_lower() in ["png", "jpg", "jpeg", "webp", "svg"]:
			_expect(ResourceLoader.load(path, "Texture2D") is Texture2D, "%s texture is not loadable: %s" % [manifest_path, path])

func _collect_res_paths(value: Variant, output: Array[String]) -> void:
	if value is String:
		var text := str(value)
		if text.begins_with("res://") and not text.contains("#") and not text.get_extension().is_empty():
			output.append(text)
		return
	if value is Dictionary:
		for child: Variant in (value as Dictionary).values():
			_collect_res_paths(child, output)
		return
	if value is Array:
		for child: Variant in value:
			_collect_res_paths(child, output)

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _finish(test_name: String) -> void:
	if failures.is_empty():
		print("PASS %s" % test_name)
		quit(0)
		return
	for failure in failures:
		push_error("%s: %s" % [test_name, failure])
	quit(1)
