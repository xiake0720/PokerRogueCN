extends SceneTree

var failures: Array[String] = []
var panel: Control


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	root.size = Vector2i(1920, 1080)
	var game: Node = root.get_node("Game")
	game.start_new_run("red_deck", "SHOP-UI-STATES")
	game.run.phase = RunState.Phase.SHOP
	game.run.money = 100
	game.run.generate_shop(true)

	panel = (load("res://scenes/game/phases/shop_panel.tscn") as PackedScene).instantiate() as Control
	root.add_child(panel)
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	await process_frame
	await process_frame
	panel.call("refresh_run", game.run)
	await process_frame

	var next_button := panel.find_child("NextButton", true, false) as Button
	var reroll_button := panel.find_child("RerollButton", true, false) as Button
	var joker_offer := panel.find_child("JokerOfferSlot1", true, false) as Control
	var joker_buy_button := joker_offer.find_child("BuyButton", true, false) as Button
	var sold_overlay := joker_offer.find_child("SoldOverlay", true, false) as ColorRect
	_expect(not next_button.disabled, "next blind must be enabled in the default shop")
	_expect(not reroll_button.disabled, "reroll must be enabled when funds are sufficient")
	_expect(joker_buy_button.visible, "default offer must expose the buy action")

	var hovered := joker_offer
	var rest_position := hovered.position
	hovered.call("_on_mouse_entered")
	await create_timer(0.16).timeout
	_expect(hovered.scale.x <= 1.03, "hover scale must not exceed 1.03")
	_expect(absf((rest_position.y - hovered.position.y) - 8.0) <= 0.75, "hover must lift the offer by 8 pixels")
	hovered.call("_on_mouse_exited")
	await create_timer(0.14).timeout
	_expect(hovered.scale.is_equal_approx(Vector2.ONE), "hover exit must restore scale")
	_expect(hovered.position.is_equal_approx(rest_position), "hover exit must restore position")

	game.run.money = 0
	panel.call("refresh_run", game.run)
	await process_frame
	_expect(joker_buy_button.disabled, "insufficient funds must disable buying")
	_expect(joker_buy_button.text == "金币不足", "insufficient funds label must be preserved")
	_expect(reroll_button.disabled, "insufficient funds must disable reroll")

	game.run.money = 100
	var joker: Dictionary = root.get_node("DataRegistry").find_by_id("jokers", "joker")
	game.run.jokers.clear()
	for _index: int in range(game.run.joker_slots):
		game.run.jokers.append(joker.duplicate(true))
	panel.call("refresh_run", game.run)
	await process_frame
	_expect(joker_buy_button.disabled, "full joker slots must disable buying")
	_expect(joker_buy_button.text == "槽位已满", "full-slot label must be preserved")

	joker_offer.call("mark_sold")
	_expect(sold_overlay.visible, "sold offer must show its overlay")
	_expect(not joker_buy_button.visible, "sold offer must hide the buy action")

	game.run.current_pack = {"id": "test_pack", "name_cn": "测试补充包", "type": "tarot", "choose": 1}
	game.run.pack_choices_left = 1
	game.run.pack_options = [
		root.get_node("DataRegistry").find_by_id("tarot_cards", "fool"),
		root.get_node("DataRegistry").find_by_id("tarot_cards", "magician"),
		root.get_node("DataRegistry").find_by_id("tarot_cards", "high_priestess"),
	]
	panel.call("refresh_run", game.run)
	await process_frame
	var pack_overlay := panel.find_child("PackOverlay", true, false) as Control
	var pack_option := panel.find_child("PackOptionSlot1", true, false) as Control
	var pack_buy_button := pack_option.find_child("BuyButton", true, false) as Button
	_expect(pack_overlay.visible, "opening a pack must show the pack surface")
	_expect(next_button.disabled, "next blind must be disabled while a pack is open")
	_expect(reroll_button.disabled, "reroll must be disabled while a pack is open")
	_expect(pack_buy_button.text == "选择", "pack choice action must be preserved")

	game.start_new_run("red_deck", "SHOP-UI-ACTIONS")
	game.run.phase = RunState.Phase.SHOP
	game.run.money = 100
	game.run.generate_shop(true)
	panel.call("refresh_run", game.run)
	await process_frame
	var money_before_reroll: int = game.run.money
	var reroll_cost: int = game.run.reroll_cost
	reroll_button.pressed.emit()
	await process_frame
	_expect(game.run.money == money_before_reroll - reroll_cost, "reroll button must retain its purchase flow")
	_expect(game.run.reroll_cost > reroll_cost, "reroll button must retain cost progression")

	panel.call("refresh_run", game.run)
	next_button.pressed.emit()
	await process_frame
	_expect(game.run.phase == RunState.Phase.STAGE_SELECT, "next blind button must leave the shop")
	_expect(next_button.disabled, "next blind button must disable immediately after activation")

	root.get_node("AudioManager").stop_all_sfx()
	root.get_node("AudioManager").stop_bgm()
	panel.queue_free()
	await process_frame
	_finish()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _finish() -> void:
	if failures.is_empty():
		print("PASS test_shop_ui_states")
		quit(0)
		return
	for failure: String in failures:
		push_error("test_shop_ui_states: %s" % failure)
	quit(1)
