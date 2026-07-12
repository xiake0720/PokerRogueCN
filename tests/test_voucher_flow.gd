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
	var registry: Node = root.get_node("DataRegistry")
	var run: RunState = RunState.new()
	run.start_new_run("red_deck", "voucher-flow")
	run.phase = RunState.Phase.SHOP
	run.money = 100
	var grabber: Dictionary = registry.find_by_id("vouchers", "grabber").duplicate(true)
	grabber["cost"] = 10
	run.shop_voucher_items = [grabber]
	var base_hands: int = run.base_hands
	expect_true(run.buy_shop_voucher(0), "voucher purchase should succeed")
	expect_true(run.has_voucher("grabber"), "purchased voucher should be retained for the run")
	expect_equal(run.base_hands, base_hands + 1, "Grabber should permanently increase round hands")
	run.phase = RunState.Phase.STAGE_SELECT
	run.start_round()
	expect_equal(run.hands_left, base_hands + 1, "voucher effect should persist into later rounds")

	run.phase = RunState.Phase.SHOP
	var seed_money: Dictionary = registry.find_by_id("vouchers", "seed_money").duplicate(true)
	seed_money["cost"] = 10
	run.shop_voucher_items = [seed_money]
	expect_true(run.buy_shop_voucher(0), "second unique voucher should be purchasable")
	expect_equal(run.interest_cap, 10, "Seed Money should permanently raise the interest cap")
	var overstock: Dictionary = registry.find_by_id("vouchers", "overstock").duplicate(true)
	overstock["cost"] = 10
	run.shop_voucher_items = [overstock]
	expect_true(run.buy_shop_voucher(0), "Overstock should be purchasable")
	run.generate_shop(true)
	expect_equal(run.shop_items.size(), 3, "Overstock should add a persistent shop joker offer")
	finish("test_voucher_flow")
