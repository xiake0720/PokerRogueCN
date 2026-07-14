extends SceneTree

var failures: Array[String] = []


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	var path := "res://scenes/game/game_table_screen.tscn"
	var packed := load(path) as PackedScene
	_expect(packed != null, "GameTableScreen failed to load")
	if packed != null:
		var table := packed.instantiate()
		for node_name: String in [
			"BackgroundLayer", "GameTableBackground", "TableFrame", "SafeAspect", "Canvas",
			"PermanentLayout", "HUDArea", "GameHudPanel", "TableArea", "JokerShelf",
			"ConsumableTray", "DeckArea", "PhaseContentLayer",
			"BattleContent", "ModalLayer", "ModalDim", "BottomSheetHost",
			"BlindSelectPanel", "SettlementPanel", "ShopPanel", "EffectsLayer", "OverlayLayer",
		]:
			_expect(table.find_child(node_name, true, false) != null, "missing static node %s" % node_name)
		for removed_name: String in [
			"StaticDecorations", "CenterContentArea", "PopupAnchor", "ParticlesHost",
			"TransitionHost", "TooltipHost", "DebugOverlay",
		]:
			_expect(table.find_child(removed_name, true, false) == null, "unused placeholder remains: %s" % removed_name)
		table.free()
	var source := FileAccess.get_file_as_string(path)
	_expect(source.contains("game_table_base.png"), "table does not use game_table_base")
	_expect(not source.contains("home_table.png"), "table still uses home_table")
	_expect(not source.contains("OwnedJokerSlot"), "table contains a duplicate owned-joker shelf")
	var consumable_source := FileAccess.get_file_as_string("res://scripts/game/table/consumable_tray.gd")
	_expect(consumable_source.contains("run.consumable_slots"), "ConsumableTray hard-codes its slot count")
	var consumable_scene_source := FileAccess.get_file_as_string("res://scenes/game/table/consumable_tray.tscn")
	_expect(not consumable_scene_source.contains("battle_consumable_tray.png"), "ConsumableTray still has an outer decorative frame")
	_expect(consumable_scene_source.contains("ConsumableSlot1"), "ConsumableTray is missing slot 1")
	_expect(consumable_scene_source.contains("ConsumableSlot2"), "ConsumableTray is missing slot 2")
	var joker_scene_source := FileAccess.get_file_as_string("res://scenes/game/table/joker_shelf.tscn")
	_expect(not joker_scene_source.contains("battle_title_bar.png"), "JokerShelf still has an outer decorative frame")
	var detail_scene_source := FileAccess.get_file_as_string("res://scenes/ui/card_detail_popup.tscn")
	_expect(detail_scene_source.contains("DescriptionScroll"), "CardDetailPopup long text is not scrollable")
	_expect(detail_scene_source.contains("horizontal_scroll_mode = 0"), "CardDetailPopup allows unwanted horizontal scrolling")
	var router_source := FileAccess.get_file_as_string("res://scripts/ui/screen_router.gd")
	_expect(router_source.contains("GAME_TABLE_PATH"), "router has no shared gameplay path")
	_expect(router_source.contains("GAMEPLAY_PHASES"), "router has no gameplay phase group")
	for old_path: String in [
		"res://scenes/game/stage_select_screen.tscn",
		"res://scenes/game/battle_screen.tscn",
		"res://scenes/game/settlement_screen.tscn",
		"res://scenes/shop/joker_shop_screen.tscn",
	]:
		_expect(not FileAccess.file_exists(old_path), "legacy full-screen scene still exists: %s" % old_path)
	var main_source := FileAccess.get_file_as_string("res://scenes/main.tscn")
	_expect(not main_source.contains("game_table_base.png"), "main shell owns game table background")
	_finish()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _finish() -> void:
	if failures.is_empty():
		print("PASS test_game_table_scene")
		quit(0)
		return
	for failure: String in failures:
		push_error("test_game_table_scene: %s" % failure)
	quit(1)
