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
	run.start_new_run("red_deck", "settlement-flow")
	run.phase = RunState.Phase.ROUND
	run.money = 24
	run.hands_left = 2
	run.current_score = 500
	run.target_score = 300
	run.current_blind = {"id": "small_blind", "name_cn": "小盲注", "reward": 3}
	run.hand = [{"instance_id": "gold", "rank": "7", "suit": "clubs", "enhancement": "gold"}]
	run.pending_tags = [{"id": "money_tag", "effect": {"kind": "grant_money", "trigger": "settlement", "amount": 5}}]
	var before_settlement: int = run.money
	run._win_round()
	expect_equal(run.phase, RunState.Phase.SETTLEMENT, "won round should enter settlement")
	expect_equal(run.money, before_settlement, "settlement rewards must not be credited before claim")
	expect_equal(int(run.settlement.get("interest", -1)), 4, "interest should be one coin per five held, capped")
	expect_equal(int(run.settlement.get("gold_card_bonus", -1)), 3, "held gold cards should pay during settlement")
	expect_equal(int(run.settlement.get("tag_bonus", -1)), 5, "settlement tag should resolve in its declared later flow")
	var total: int = int(run.settlement.get("total", 0))
	expect_true(run.claim_settlement(), "first claim should credit settlement")
	expect_equal(run.money, before_settlement + total, "claim should credit the exact displayed total once")
	var after_claim: int = run.money
	expect_true(not run.claim_settlement(), "settlement cannot be claimed twice")
	expect_equal(run.money, after_claim, "second claim attempt must not change money")
	finish("test_settlement_flow")
