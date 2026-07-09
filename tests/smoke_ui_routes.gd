extends Node

func _ready() -> void:
	Game.start_new_run("red_deck")
	await _check_scene("res://scenes/game/stage_select_screen.tscn")
	Game.run.start_round()
	await _check_scene("res://scenes/game/battle_screen.tscn")
	Game.run.phase = RunState.Phase.SHOP
	Game.run.generate_shop()
	await _check_scene("res://scenes/shop/joker_shop_screen.tscn")
	print("UI smoke passed: stage, battle, and shop screens instantiate successfully.")
	get_tree().quit(0)

func _check_scene(path: String) -> void:
	var resource: Resource = load(path)
	if resource == null or not resource is PackedScene:
		push_error("UI smoke failed: cannot load " + path)
		get_tree().quit(1)
		return
	var packed: PackedScene = resource as PackedScene
	var node: Node = packed.instantiate()
	add_child(node)
	await get_tree().process_frame
	remove_child(node)
	node.queue_free()
