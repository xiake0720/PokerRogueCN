extends Node

func _ready() -> void:
	Game.start_new_run("red_deck")
	if Game.run.phase != RunState.Phase.STAGE_SELECT:
		push_error("Smoke failed: run did not enter stage select.")
		get_tree().quit(1)
		return
	Game.run.start_round()
	if Game.run.phase != RunState.Phase.ROUND:
		push_error("Smoke failed: run did not enter round.")
		get_tree().quit(1)
		return
	if Game.run.hand.size() == 0:
		push_error("Smoke failed: starting hand is empty.")
		get_tree().quit(1)
		return
	var ids: Array = []
	for i in range(min(5, Game.run.hand.size())):
		ids.append(Game.run.hand[i].get("instance_id", ""))
	var result: Dictionary = Game.run.play_selected(ids)
	if result.is_empty():
		push_error("Smoke failed: play_selected returned empty result.")
		get_tree().quit(1)
		return
	var score_result_value: Variant = result.get("score_result", {})
	var score_result: Dictionary = score_result_value if score_result_value is Dictionary else {}
	if int(score_result.get("score", 0)) <= 0:
		push_error("Smoke failed: score result is invalid.")
		get_tree().quit(1)
		return
	Game.run.generate_shop()
	if Game.run.shop_items.is_empty() or Game.run.shop_voucher_items.is_empty() or Game.run.shop_pack_items.is_empty():
		push_error("Smoke failed: shop offers are incomplete.")
		get_tree().quit(1)
		return
	print("Smoke passed: run starts, round starts, hand draws, play resolves, shop generates.")
	get_tree().quit(0)
