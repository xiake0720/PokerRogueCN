extends Node

var failures: Array[String] = []


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var main := (load("res://scenes/main.tscn") as PackedScene).instantiate()
	add_child(main)
	await get_tree().process_frame
	Game.start_new_run("red_deck", "GAME-TABLE-PERSISTENCE")
	await _settle()
	var screen_root: Control = main.get_node("ScreenRoot") as Control
	var table: GameTableScreen = screen_root.get_child(0) as GameTableScreen
	_expect(table != null, "STAGE_SELECT did not load GameTableScreen")
	if table == null:
		_finish()
		return
	var ids := {
		"table": table.get_instance_id(),
		"hud": table.hud.get_instance_id(),
		"jokers": table.joker_shelf.get_instance_id(),
		"consumables": table.consumable_tray.get_instance_id(),
		"deck": table.deck_area.get_instance_id(),
	}
	Game.run.start_round()
	await _settle()
	_check_ids(screen_root, ids, "ROUND")
	Game.run.phase = RunState.Phase.SETTLEMENT
	Game.run.settlement = {"total": 6, "reward": 4, "score": 120, "target": 100, "claimed": false}
	Game.run.emit_signal("changed")
	await _settle()
	_check_ids(screen_root, ids, "SETTLEMENT")
	Game.run.claim_settlement()
	await _settle()
	_check_ids(screen_root, ids, "SHOP")
	Game.run.leave_shop()
	await _settle()
	_check_ids(screen_root, ids, "STAGE_SELECT return")
	AudioManager.stop_all_sfx()
	AudioManager.stop_bgm()
	main.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
	_finish()


func _settle() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.34).timeout


func _check_ids(screen_root: Control, ids: Dictionary, label: String) -> void:
	_expect(screen_root.get_child_count() == 1, "%s created multiple page roots" % label)
	var table := screen_root.get_child(0) as GameTableScreen
	_expect(table != null, "%s replaced GameTableScreen with another type" % label)
	if table == null:
		return
	_expect(table.get_instance_id() == ids.table, "%s replaced GameTableScreen" % label)
	_expect(table.hud.get_instance_id() == ids.hud, "%s replaced HUD" % label)
	_expect(table.joker_shelf.get_instance_id() == ids.jokers, "%s replaced JokerShelf" % label)
	_expect(table.consumable_tray.get_instance_id() == ids.consumables, "%s replaced ConsumableTray" % label)
	_expect(table.deck_area.get_instance_id() == ids.deck, "%s replaced DeckArea" % label)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _finish() -> void:
	if failures.is_empty():
		print("PASS test_game_table_persistence")
		get_tree().quit(0)
		return
	for failure: String in failures:
		push_error("test_game_table_persistence: %s" % failure)
	get_tree().quit(1)
