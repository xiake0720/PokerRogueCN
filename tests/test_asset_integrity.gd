extends SceneTree

var failures: Array[String] = []

func _init() -> void:
	_run.call_deferred()

func _run() -> void:
	var json_paths: Array[String] = [
		"res://assets/ASSET_MANIFEST.json",
		"res://assets/ui/extracted/asset_manifest.json",
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
			_expect(JSON.parse_string(FileAccess.get_file_as_string(path)) != null, "invalid JSON: %s" % path)

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
		"res://assets/ui/runtime/backgrounds/stage_select.png",
		"res://assets/ui/runtime/backgrounds/battle_frame.png",
		"res://assets/ui/runtime/backgrounds/shop.png",
		"res://assets/ui/runtime/panels/battle_hud_full.png",
		"res://assets/ui/runtime/panels/deck_main_panel.png",
		"res://assets/ui/runtime/panels/settlement_detail_panel.png",
		"res://assets/ui/runtime/panels/shop_offers_panel.png",
		"res://assets/ui/runtime/generated/joker_fallback.png",
		"res://assets/ui/runtime/generated/voucher_fallback.png",
		"res://assets/ui/runtime/generated/pack_fallback.png",
	]
	for path in required_textures:
		_expect(ResourceLoader.load(path, "Texture2D") is Texture2D, "texture failed to import: %s" % path)
	_finish("test_asset_integrity")

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

