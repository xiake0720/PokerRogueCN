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
	var royal: Array = [
		_card("10", "hearts", 1), _card("J", "hearts", 2), _card("Q", "hearts", 3),
		_card("K", "hearts", 4), _card("A", "hearts", 5)
	]
	var royal_result: Dictionary = HandEvaluator.evaluate(royal)
	expect_equal(royal_result.get("id", ""), "royal_flush", "royal flush should be recognized")
	expect_equal(Array(royal_result.get("scoring_ids", [])).size(), 5, "royal flush should score five cards")

	var wheel: Array = [
		_card("A", "spades", 6), _card("2", "hearts", 7), _card("3", "clubs", 8),
		_card("4", "diamonds", 9), _card("5", "hearts", 10)
	]
	expect_equal(HandEvaluator.evaluate(wheel).get("id", ""), "straight", "ace-low straight should be recognized")

	var four_flush: Array = [
		_card("2", "clubs", 11), _card("5", "clubs", 12), _card("8", "clubs", 13), _card("K", "clubs", 14)
	]
	expect_equal(HandEvaluator.evaluate(four_flush).get("id", ""), "high_card", "four-card flush should require Four Fingers")
	expect_equal(HandEvaluator.evaluate(four_flush, {"four_card_hands": true}).get("id", ""), "flush", "Four Fingers should enable four-card flush")
	var six_high: Array = [
		_card("2", "spades", 20), _card("3", "hearts", 21), _card("4", "clubs", 22),
		_card("5", "diamonds", 23), _card("6", "hearts", 24)
	]
	var four_finger_straight: Dictionary = HandEvaluator.evaluate(six_high, {"four_card_hands": true})
	expect_equal(Array(four_finger_straight.get("scoring_ids", [])).size(), 5, "Four Fingers must not discard the fifth card of a natural five-card straight")
	var smeared_flush: Array = [
		_card("2", "hearts", 30), _card("5", "diamonds", 31), _card("8", "hearts", 32),
		_card("J", "diamonds", 33), _card("K", "hearts", 34)
	]
	expect_true(HandEvaluator.evaluate(smeared_flush).get("id", "") != "flush", "mixed red suits should not normally be a flush")
	expect_equal(HandEvaluator.evaluate(smeared_flush, {"smeared_suits": true}).get("id", ""), "flush", "Smeared Joker should merge red suits for flush detection")

	var registry: Node = root.get_node("DataRegistry")
	var unknown: Array[String] = ScoreEngine.unknown_effect_kinds(registry.get_table("jokers"))
	expect_true(unknown.is_empty(), "every declared joker effect kind should be explicitly classified")
	var fake_unknown: Array[String] = ScoreEngine.unknown_effect_kinds([{"effect": {"kind": "definitely_unknown"}}])
	expect_equal(fake_unknown, ["definitely_unknown"], "unknown core effect kinds must be reported")

	var run: RunState = RunState.new()
	run.start_new_run("red_deck", "joker-copy-order")
	run.jokers = [
		{"id": "blueprint", "name_cn": "蓝图", "effect": {"kind": "copy_right"}},
		{"id": "joker", "name_cn": "小丑", "effect": {"kind": "add_mult", "value": 4}}
	]
	var high_card: Dictionary = HandEvaluator.evaluate([_card("A", "clubs", 99)])
	var copied_score: Dictionary = ScoreEngine.calculate([_card("A", "clubs", 99)], high_card, run)
	expect_equal(copied_score.get("mult", 0), 9, "Blueprint should copy the right joker before that joker triggers normally")
	run.jokers.clear()
	var steel_card: Dictionary = _card("K", "spades", 100)
	steel_card["enhancement"] = "steel"
	run.hand = [steel_card]
	var steel_score: Dictionary = ScoreEngine.calculate([_card("A", "clubs", 99)], high_card, run)
	expect_equal(float(steel_score.get("x_mult", 0.0)), 1.5, "held steel cards should apply their multiplier before jokers")
	run.jokers = [
		{"id": "blueprint", "name_cn": "蓝图", "effect": {"kind": "copy_right"}},
		{"id": "brainstorm", "name_cn": "头脑风暴", "effect": {"kind": "copy_leftmost"}}
	]
	var cyclic_score: Dictionary = ScoreEngine.calculate([_card("A", "clubs", 99)], high_card, run)
	expect_true(Array(cyclic_score.get("joker_effects", [])).size() > 0, "copy cycles should terminate with an explicit diagnostic")
	finish("test_hand_evaluator")


func _card(rank: String, suit: String, id: int) -> Dictionary:
	return {"instance_id": "t_%d" % id, "rank": rank, "suit": suit, "enhancement": "", "edition": "", "seal": "", "chip_bonus": 0}
