extends SceneTree

var failures: Array[String] = []

func _init() -> void:
	_run.call_deferred()

func _run() -> void:
	var scenes: Array[String] = [
		"res://scenes/main.tscn",
		"res://scenes/screens/main_menu_screen.tscn",
		"res://scenes/screens/run_setup_screen.tscn",
		"res://scenes/screens/result_screen.tscn",
		"res://scenes/game/game_table_screen.tscn",
		"res://scenes/game/phases/battle_content.tscn",
		"res://scenes/game/phases/blind_select_panel.tscn",
		"res://scenes/game/phases/settlement_panel.tscn",
		"res://scenes/game/phases/shop_panel.tscn",
		"res://scenes/game/table/joker_shelf.tscn",
		"res://scenes/game/table/consumable_tray.tscn",
		"res://scenes/game/table/deck_area.tscn",
		"res://scenes/ui/shared/bottom_sheet_host.tscn",
		"res://scenes/cards/playing_card_view.tscn",
		"res://scenes/cards/joker_card_view.tscn",
		"res://scenes/game/game_hud_panel.tscn",
		"res://scenes/game/stage_card_view.tscn",
		"res://scenes/shop/shop_offer_card.tscn",
	]
	for path in scenes:
		var packed: PackedScene = ResourceLoader.load(path, "PackedScene") as PackedScene
		_expect(packed != null, "scene failed to load: %s" % path)
		if packed != null:
			var instance: Node = packed.instantiate()
			_expect(instance != null, "scene failed to instantiate: %s" % path)
			if instance != null:
				instance.free()
	_finish("test_scene_integrity")

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
