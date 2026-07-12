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
	var run: RunState = RunState.new()
	run.start_new_run("red_deck", "shop-flow")
	run.phase = RunState.Phase.SHOP
	run.money = 100
	run.jokers.append({"id": "chaos_the_clown", "name_cn": "混沌小丑", "effect": {"kind": "shop_rule"}})
	run.generate_shop(true)
	expect_equal(run.reroll_cost, 0, "Chaos the Clown should grant one free reroll per shop")
	var before_free: int = run.money
	expect_true(run.reroll_shop(), "free reroll should succeed")
	expect_equal(run.money, before_free, "free reroll should not charge money")
	expect_equal(run.reroll_cost, 5, "free reroll must be consumed, not remain free forever")
	expect_true(run.reroll_shop(), "first paid reroll should succeed")
	expect_equal(run.money, before_free - 5, "first paid reroll should cost base price")
	expect_equal(run.reroll_cost, 6, "paid reroll cost should increase")
	expect_true(run.reroll_shop(), "second paid reroll should succeed")
	expect_equal(run.money, before_free - 11, "second paid reroll should use increased price")
	expect_equal(run.reroll_cost, 7, "reroll cost should keep increasing")

	var order_run: RunState = RunState.new()
	order_run.start_new_run("red_deck", "joker-order")
	order_run.jokers = [
		{"id": "first", "name_cn": "第一张", "effect": {"kind": "add_mult", "value": 1}},
		{"id": "second", "name_cn": "第二张", "effect": {"kind": "add_mult", "value": 2}}
	]
	var card: Dictionary = {"instance_id": "one", "rank": "2", "suit": "clubs", "enhancement": "", "edition": "", "seal": "", "chip_bonus": 0}
	var score: Dictionary = ScoreEngine.calculate([card], HandEvaluator.evaluate([card]), order_run)
	var effects: Array = score.get("joker_effects", [])
	expect_equal(effects[0].get("id", ""), "first", "jokers should trigger left to right")
	expect_equal(effects[1].get("id", ""), "second", "joker order should be preserved")
	finish("test_shop_flow")
