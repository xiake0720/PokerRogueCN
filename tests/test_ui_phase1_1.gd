extends Node

var failures: Array[String] = []


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	Game.start_new_run("red_deck", "UI-PHASE-1-1-TEST")
	Game.run.start_round()
	var table := (load("res://scenes/game/game_table_screen.tscn") as PackedScene).instantiate() as GameTableScreen
	add_child(table)
	await get_tree().process_frame
	await get_tree().process_frame
	table.set_phase(RunState.Phase.ROUND, true)
	await get_tree().process_frame
	_test_card_reuse_and_states(table)
	_test_action_bar(table)
	_test_hud_modes(table)
	await _test_stage_intro(table)
	await _test_settlement_presentation(table)
	table.queue_free()
	await get_tree().process_frame
	_finish()


func _test_card_reuse_and_states(table: GameTableScreen) -> void:
	var fan := table.battle_content.hand_area
	var ids_before: Dictionary = {}
	for view: PlayingCardView in fan.card_views:
		var card_id := str(view.card_data.get("instance_id", ""))
		ids_before[card_id] = view.get_instance_id()
		_expect(view.focus_mode == Control.FOCUS_ALL, "PlayingCardView did not restore keyboard/gamepad focus")
	fan.display_cards(Game.run.sorted_hand_for_display(), [])
	for view: PlayingCardView in fan.card_views:
		var card_id := str(view.card_data.get("instance_id", ""))
		_expect(ids_before.get(card_id, 0) == view.get_instance_id(), "CardFanArea recreated card %s" % card_id)
	var selected: Array = []
	for i: int in range(mini(5, fan.card_views.size())):
		selected.append(str(fan.card_views[i].card_data.get("instance_id", "")))
	fan.update_selection(selected)
	for view: PlayingCardView in fan.card_views:
		var is_selected := selected.has(str(view.card_data.get("instance_id", "")))
		_expect(view.disabled != is_selected, "selection limit state is incorrect")
	if fan.card_views.size() > 5:
		_expect(fan.card_views[0].z_index > fan.card_views[5].z_index, "selected card was not raised above unselected cards")
		fan.card_views[5].emit_signal("mouse_entered")
		_expect(fan.card_views[5].z_index > fan.card_views[0].z_index, "hovered card was not raised to the top")


func _test_action_bar(table: GameTableScreen) -> void:
	var battle := table.battle_content
	_expect(battle.sort_rank_button.get_parent() == battle.sort_suit_button.get_parent(), "sort buttons are not one segmented control")
	_expect(battle.sort_rank_button.button_group == battle.sort_suit_button.button_group, "sort ButtonGroup changed")
	_expect(battle.sort_rank_button.custom_minimum_size.y >= 54.0 and battle.sort_rank_button.custom_minimum_size.y <= 60.0, "rank sort height is outside 54-60px")
	_expect(battle.sort_suit_button.custom_minimum_size.y >= 54.0 and battle.sort_suit_button.custom_minimum_size.y <= 60.0, "suit sort height is outside 54-60px")
	_expect(battle.play_button.custom_minimum_size.y > battle.discard_button.custom_minimum_size.y, "play button no longer has the highest priority")


func _test_hud_modes(table: GameTableScreen) -> void:
	var hud := table.hud
	Game.run.phase = RunState.Phase.STAGE_SELECT
	hud.refresh_run(Game.run, "stage")
	_expect(hud.equation_box.visible and hud.times_label.text == "·", "stage HUD did not populate its phase metrics")
	Game.run.phase = RunState.Phase.SHOP
	Game.run.generate_shop(true)
	hud.refresh_run(Game.run, "shop")
	_expect(hud.equation_box.visible and hud.target_panel.visible and hud.score_box.visible, "shop HUD left fixed content slots empty")
	_expect(hud.times_label.text == "+", "shop HUD retained the battle score equation")
	_expect(hud.title_label.text == "商店整备", "shop HUD title is not mode-specific")
	Game.run.phase = RunState.Phase.SETTLEMENT
	Game.run.settlement = {"stage_name": "大盲注", "total": 15, "score": 1240, "target": 900, "claimed": false}
	hud.refresh_run(Game.run, "settlement")
	_expect(hud.equation_box.visible and hud.times_label.text == "+", "settlement HUD did not populate reward metrics")
	_expect(hud.title_label.text == "回合结算", "settlement HUD title is incorrect")
	_expect(not hud.ante_box.visible, "HUD still displays duplicated Ante information")


func _test_stage_intro(table: GameTableScreen) -> void:
	Game.run.phase = RunState.Phase.STAGE_SELECT
	Game.run.blind_index = 0
	table.blind_select_panel.refresh_run(Game.run)
	var stage_card := table.blind_select_panel.stage_cards[0]
	var first_tween: Tween = stage_card.get("_intro_tween") as Tween
	table.blind_select_panel.refresh_run(Game.run)
	_expect(stage_card.get("_intro_tween") == first_tween, "StageCard intro restarted without a state change")
	Game.run.blind_index = 1
	table.blind_select_panel.refresh_run(Game.run)
	var changed_tween: Tween = stage_card.get("_intro_tween") as Tween
	_expect(changed_tween != first_tween, "StageCard intro did not react to a state change")
	_expect(first_tween == null or not first_tween.is_valid(), "StageCard left its previous intro tween running")
	await get_tree().process_frame


func _test_settlement_presentation(table: GameTableScreen) -> void:
	Game.run.phase = RunState.Phase.SETTLEMENT
	Game.run.money = 28
	Game.run.settlement_claimed = false
	Game.run.settlement = {
		"stage_name": "大盲注", "reward": 5, "hand_bonus": 2, "interest": 3,
		"tag_bonus": 4, "voucher_bonus": 1, "other_bonus": 0, "total": 15,
		"score": 1240, "target": 900, "claimed": false,
	}
	table.settlement_panel.refresh_run(Game.run)
	_expect(table.settlement_panel.claim_button.disabled, "claim button enabled before the settlement presentation")
	await get_tree().create_timer(1.8).timeout
	_expect(not table.settlement_panel.claim_button.disabled, "claim button did not enable after the presentation")
	_expect(table.settlement_panel.money_before_value.text == "$28", "settlement before-money display is incorrect")
	_expect(table.settlement_panel.money_after_value.text == "$43", "settlement after-money display is incorrect")
	Game.run.money = 43
	Game.run.settlement_claimed = true
	Game.run.settlement["claimed"] = true
	table.settlement_panel.refresh_run(Game.run)
	await get_tree().create_timer(1.8).timeout
	_expect(table.settlement_panel.claim_button.disabled, "claimed settlement button is enabled")
	_expect(table.settlement_panel.money_before_value.text == "$28", "claimed settlement lost the original balance")
	_expect(table.settlement_panel.money_after_value.text == "$43", "claimed settlement added the reward twice")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _finish() -> void:
	if failures.is_empty():
		print("PASS test_ui_phase1_1")
		get_tree().quit(0)
		return
	for failure: String in failures:
		push_error("test_ui_phase1_1: %s" % failure)
	get_tree().quit(1)
