extends Node

var failures: Array[String] = []


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var game: Node = get_node("/root/Game")
	game.start_new_run("red_deck", "PHASE-PANEL-FLOW")
	var table := (load("res://scenes/game/game_table_screen.tscn") as PackedScene).instantiate() as GameTableScreen
	add_child(table)
	await get_tree().process_frame
	await get_tree().process_frame
	table.set_phase(game.run.phase, true)
	var panel_ids := {
		"blind": table.blind_select_panel.get_instance_id(),
		"settlement": table.settlement_panel.get_instance_id(),
		"shop": table.shop_panel.get_instance_id(),
	}
	_expect(table.current_popup == table.blind_select_panel, "blind panel not selected for STAGE_SELECT")
	_expect(table.blind_select_panel.visible, "blind panel not visible")
	table.set_phase(RunState.Phase.ROUND, true)
	_expect(table.current_popup == null, "ROUND must not have a popup")
	_expect(table.battle_content.visible, "BattleContent hidden in ROUND")
	_expect(table.battle_content.mouse_filter != Control.MOUSE_FILTER_IGNORE, "BattleContent input disabled in ROUND")
	_expect(not table.modal_dim.visible, "ModalDim visible in ROUND")
	game.run.phase = RunState.Phase.SETTLEMENT
	game.run.settlement = {"total": 5, "reward": 3, "score": 100, "target": 90, "claimed": false}
	table.set_phase(RunState.Phase.SETTLEMENT, true)
	_expect(table.current_popup == table.settlement_panel, "settlement panel not selected")
	_expect(not table.battle_content.visible, "BattleContent visible during settlement")
	game.run.phase = RunState.Phase.SHOP
	game.run.jokers = [DataRegistry.find_by_id("jokers", "joker")]
	game.run.generate_shop(true)
	table.set_phase(RunState.Phase.SHOP, true)
	_expect(table.current_popup == table.shop_panel, "shop panel not selected")
	_expect(table.joker_shelf.slots[0].sell_button.visible, "shared JokerShelf is not sell-enabled in SHOP")
	_expect(table.blind_select_panel.get_instance_id() == panel_ids.blind, "blind panel was reinstantiated")
	_expect(table.settlement_panel.get_instance_id() == panel_ids.settlement, "settlement panel was reinstantiated")
	_expect(table.shop_panel.get_instance_id() == panel_ids.shop, "shop panel was reinstantiated")
	var transition_count: Array[int] = [0]
	table.popup_host.transition_started.connect(func() -> void: transition_count[0] += 1)
	game.run.phase = RunState.Phase.STAGE_SELECT
	table.set_phase(RunState.Phase.STAGE_SELECT, true)
	game.run.phase = RunState.Phase.ROUND
	table.set_phase(RunState.Phase.ROUND)
	_expect(table.blind_select_panel.visible, "replace/hide removed the outgoing panel instantly")
	game.run.phase = RunState.Phase.SETTLEMENT
	game.run.settlement = {"total": 7, "reward": 4, "score": 110, "target": 100, "claimed": false}
	table.set_phase(RunState.Phase.SETTLEMENT)
	game.run.phase = RunState.Phase.SHOP
	game.run.generate_shop(true)
	table.set_phase(RunState.Phase.SHOP)
	_expect(table.pending_phase == RunState.Phase.SHOP, "rapid phase requests did not retain the latest phase")
	await get_tree().create_timer(0.8).timeout
	_expect(table.current_phase == RunState.Phase.SHOP, "latest queued phase was not applied")
	_expect(table.pending_phase == -1, "pending phase was not consumed")
	_expect(table.current_popup == table.shop_panel, "queued SHOP did not finish on the shop panel")
	_expect(table.shop_panel.visible, "queued shop panel is hidden")
	_expect(not table.blind_select_panel.visible, "outgoing blind panel remained visible")
	_expect(table.blind_select_panel.mouse_filter == Control.MOUSE_FILTER_IGNORE, "hidden blind panel still accepts input")
	_expect(table.settlement_panel.mouse_filter == Control.MOUSE_FILTER_IGNORE, "hidden settlement panel still accepts input")
	var transitions_before_refresh := transition_count[0]
	table.set_phase(RunState.Phase.SHOP)
	_expect(transition_count[0] == transitions_before_refresh, "same phase reopened the current panel")
	table.popup_host.replace_panel(table.blind_select_panel)
	table.popup_host.hide_current_panel()
	await get_tree().create_timer(0.65).timeout
	_expect(table.popup_host.current_panel == null, "hide queued during replacement was lost")
	_expect(not table.modal_dim.visible, "queued hide left ModalDim visible")
	table.queue_free()
	await get_tree().process_frame
	_finish()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _finish() -> void:
	if failures.is_empty():
		print("PASS test_phase_panel_flow")
		get_tree().quit(0)
		return
	for failure: String in failures:
		push_error("test_phase_panel_flow: %s" % failure)
	get_tree().quit(1)
