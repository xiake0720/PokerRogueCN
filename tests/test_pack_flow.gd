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
	run.start_new_run("red_deck", "pack-flow")
	run.phase = RunState.Phase.SHOP
	run.money = 20
	run.shop_pack_items = [{"id": "celestial_pack", "name_cn": "星球补充包", "type": "planet", "cost": 4, "choose": 1, "show": 3, "kind": "pack"}]
	expect_true(run.buy_shop_pack(0), "buying a pack should open its selection flow")
	expect_equal(run.money, 16, "pack purchase should charge exactly once")
	expect_true(run.is_pack_open(), "current_pack should remain populated while choosing")
	expect_equal(run.pack_options.size(), 3, "pack should generate its configured number of options")
	expect_true(not run.leave_shop(), "shop cannot be left while a pack is open")
	var chosen_hand: String = str(run.pack_options[0].get("target_hand", ""))
	expect_true(run.choose_pack_option(0), "choosing a pack option should succeed with a free consumable slot")
	expect_true(not run.is_pack_open(), "pack should close after all choices are used")
	expect_equal(run.consumables.size(), 1, "chosen planet should enter consumable inventory")
	var before_level: int = int(run.hand_levels.get(chosen_hand, 0))
	expect_true(run.use_consumable(0), "planet consumable should be usable")
	expect_equal(int(run.hand_levels.get(chosen_hand, 0)), before_level + 1, "planet must upgrade its target poker hand")
	expect_equal(run.consumables.size(), 0, "used consumable should leave inventory")
	var left: Dictionary = {"instance_id": "left", "rank": "2", "suit": "clubs", "enhancement": "", "edition": "", "seal": "", "chip_bonus": 0}
	var right: Dictionary = {"instance_id": "right", "rank": "K", "suit": "hearts", "enhancement": "bonus", "edition": "foil", "seal": "gold", "chip_bonus": 7}
	run.hand = [left, right]
	run.consumables = [{"id": "strength", "name_cn": "力量", "kind": "tarot"}]
	expect_true(run.use_consumable(0, ["left"]), "targeted tarot cards should be usable through stable card IDs")
	expect_equal(left.get("rank", ""), "3", "Strength should increase the selected rank")
	run.consumables = [{"id": "death", "name_cn": "死神", "kind": "tarot"}]
	expect_true(run.use_consumable(0, ["left", "right"]), "Death should accept exactly two ordered targets")
	expect_equal(left.get("rank", ""), right.get("rank", ""), "Death should copy the right target onto the left target")
	expect_equal(left.get("enhancement", ""), right.get("enhancement", ""), "Death should copy enhancements as well as rank/suit")
	run.consumables = [{"id": "cryptid", "name_cn": "隐生物", "kind": "spectral"}]
	var deck_size_before_cryptid: int = run.full_deck.size()
	expect_true(run.use_consumable(0, ["left"]), "Cryptid should copy one selected playing card")
	expect_equal(run.full_deck.size(), deck_size_before_cryptid + 2, "Cryptid should add two permanent deck copies")
	finish("test_pack_flow")
