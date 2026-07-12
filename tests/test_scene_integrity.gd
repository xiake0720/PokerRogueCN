extends SceneTree

var failures: Array[String] = []

func _init() -> void:
	_run.call_deferred()

func _run() -> void:
	var scenes: Array[String] = [
		"res://scenes/main.tscn",
		"res://scenes/ui/main_menu_screen.tscn",
		"res://scenes/ui/deck_select_screen.tscn",
		"res://scenes/game/stage_select_screen.tscn",
		"res://scenes/game/battle_screen.tscn",
		"res://scenes/game/settlement_screen.tscn",
		"res://scenes/shop/joker_shop_screen.tscn",
		"res://scenes/ui/result_screen.tscn",
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
