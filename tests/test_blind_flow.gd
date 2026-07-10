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
	run.start_new_run("red_deck", "blind-flow")
	var starting_money: int = run.money
	var first_tag: Dictionary = run.current_skip_tag()
	expect_true(not first_tag.is_empty(), "small blind should expose a seeded tag from tags.json")
	expect_true(run.skip_blind(), "small blind should be skippable")
	expect_equal(run.blind_index, 1, "skip should advance small blind to big blind")
	expect_equal(run.money, starting_money, "skip must not grant a hard-coded four coins")
	expect_equal(run.tag_history.size(), 1, "skip should record the awarded tag")
	expect_true(run.skip_blind(), "big blind should be skippable")
	expect_equal(run.blind_index, 2, "second skip should advance to boss blind")
	var before_boss_skip: int = run.blind_index
	expect_true(not run.skip_blind(), "boss blind must not be skippable")
	expect_equal(run.blind_index, before_boss_skip, "failed boss skip must not advance progression")

	run.current_blind = registry.find_by_id("blinds", "boss_no_discards").duplicate(true)
	run.phase = RunState.Phase.STAGE_SELECT
	run.start_round()
	expect_equal(run.discards_left, 0, "boss_no_discards restriction must execute at round start")

	var normal: RunState = RunState.new()
	normal.start_new_run("red_deck", "boss-score")
	normal.blind_index = 2
	normal.current_blind = registry.find_by_id("blinds", "boss_none").duplicate(true)
	normal.phase = RunState.Phase.ROUND
	var blocked: RunState = RunState.new()
	blocked.start_new_run("red_deck", "boss-score")
	blocked.blind_index = 2
	blocked.current_blind = registry.find_by_id("blinds", "boss_hearts_disabled").duplicate(true)
	blocked.phase = RunState.Phase.ROUND
	var card: Dictionary = {"instance_id": "heart", "rank": "A", "suit": "hearts", "enhancement": "bonus", "edition": "", "seal": "", "chip_bonus": 0}
	var result: Dictionary = HandEvaluator.evaluate([card])
	var normal_score: Dictionary = ScoreEngine.calculate([card], result, normal)
	var blocked_score: Dictionary = ScoreEngine.calculate([card], result, blocked)
	expect_true(int(blocked_score.get("score", 0)) < int(normal_score.get("score", 0)), "debuff_suit boss must suppress matching card scoring")
	expect_equal(Array(blocked_score.get("debuffed_ids", [])).size(), 1, "debuffed scoring cards should be exposed for UI feedback")
	finish("test_blind_flow")
