extends SceneTree

const TestSupport = preload("res://tests/gameplay_test_base.gd")
var test_support = TestSupport.new()


func _init() -> void:
	_run.call_deferred()

func expect_true(condition: bool, message: String) -> void:
	test_support.expect_true(condition, message)

func expect_equal(actual, expected, message: String) -> void:
	test_support.expect_equal(actual, expected, message)

func finish(test_name: String) -> void:
	test_support.finish(self, test_name)


func _run() -> void:
	var first: RunState = RunState.new()
	first.start_new_run("red_deck", "repeatable-seed")
	expect_equal(first.full_deck.size(), 52, "standard deck must contain 52 cards")
	var identities: Dictionary = {}
	for card in first.full_deck:
		identities["%s:%s" % [card.get("rank", ""), card.get("suit", "")]] = true
	expect_equal(identities.size(), 52, "standard deck must contain every rank/suit combination exactly once")
	expect_equal(first.base_hands, 4, "hands should come from red deck data")
	expect_equal(first.base_discards, 4, "discards should come from red deck data")
	expect_equal(first.hand_size, 8, "hand size should come from deck data")
	expect_equal(first.joker_slots, 5, "joker slots should come from deck data")
	expect_equal(first.max_play_cards, 5, "selection limit should come from deck data")

	first.start_round()
	var first_hand_signature: Array = _signature(first.hand)
	var before_hand_size: int = first.hand.size()
	var too_many: Array = []
	for i in range(6):
		too_many.append(first.hand[i].get("instance_id", ""))
	expect_true(first.play_selected(too_many).is_empty(), "RunState must reject playing more than five cards")
	expect_equal(first.hand.size(), before_hand_size, "rejected selection must not mutate the hand")
	var gameplay_order: Array = _signature(first.hand)
	first.set_hand_sort_mode("suit")
	var display_order: Array = _signature(first.sorted_hand_for_display())
	expect_equal(_signature(first.hand), gameplay_order, "sorting must not mutate gameplay hand order")
	expect_true(_is_suit_sorted(display_order), "display sort should return cards grouped by suit")

	var second: RunState = RunState.new()
	second.start_new_run("red_deck", "repeatable-seed")
	second.start_round()
	expect_equal(_signature(second.hand), first_hand_signature, "same seed must reproduce the shuffled opening hand")
	first.phase = RunState.Phase.SHOP
	second.phase = RunState.Phase.SHOP
	first.generate_shop(true)
	second.generate_shop(true)
	expect_equal(_ids(first.shop_items), _ids(second.shop_items), "same seed and action path must reproduce shop offers")
	expect_equal(_ids(first.shop_pack_items), _ids(second.shop_pack_items), "same seed must reproduce pack offers")
	var generated_seed_run: RunState = RunState.new()
	generated_seed_run.start_new_run("red_deck")
	var generated_seed: String = generated_seed_run.seed_text
	generated_seed_run.start_round()
	var replay_run: RunState = RunState.new()
	replay_run.start_new_run("red_deck", generated_seed)
	replay_run.start_round()
	expect_equal(_signature(replay_run.hand), _signature(generated_seed_run.hand), "an automatically generated seed_text must replay the original run")
	finish("test_round_flow")


func _signature(cards: Array) -> Array:
	var result: Array = []
	for card in cards:
		result.append("%s:%s" % [card.get("rank", ""), card.get("suit", "")])
	return result


func _ids(items: Array) -> Array:
	var result: Array = []
	for item in items:
		result.append(item.get("id", ""))
	return result


func _is_suit_sorted(signatures: Array) -> bool:
	var order: Dictionary = {"spades": 0, "hearts": 1, "diamonds": 2, "clubs": 3}
	var previous: int = -1
	for signature in signatures:
		var suit: String = str(signature).get_slice(":", 1)
		var current: int = int(order.get(suit, -1))
		if current < previous:
			return false
		previous = current
	return true
