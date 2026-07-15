extends SceneTree

var failures: Array[String] = []

const EXPECTED_NODES: Dictionary = {
	"res://scenes/game/game_table_screen.tscn": [
		"GameTableBackground", "TableFrame", "GameHudPanel", "JokerShelf", "ConsumableTray", "DeckArea",
		"BattleContent", "BlindSelectPanel", "SettlementPanel", "ShopPanel", "ModalDim", "BottomSheetHost",
	],
	"res://scenes/game/phases/blind_select_panel.tscn": ["SmallBlindCard", "BigBlindCard", "BossBlindCard"],
	"res://scenes/game/phases/battle_content.tscn": [
		"PlayedFrame", "PlayedArea", "HandArea", "ActionRow",
		"PlayButton", "DiscardButton", "SortRankButton", "SortSuitButton",
	],
	"res://scenes/game/phases/shop_panel.tscn": [
		"JokerOfferSlot1", "JokerOfferSlot2", "VoucherOfferSlot", "PackOfferSlot1", "PackOfferSlot2",
		"PackOptionSlot1", "PackOptionSlot2", "PackOptionSlot3",
	],
	"res://scenes/game/phases/settlement_panel.tscn": [
		"TotalRow", "StageNameRow", "ScoreRow", "RewardRow", "HandBonusRow", "InterestRow", "TagRewardRow", "VoucherBonusRow", "OtherBonusRow",
	],
	"res://scenes/ui/result_screen.tscn": [
		"AnteRow", "BlindRow", "ScoreRow", "HandsRow", "BestHandRow", "JokersRow", "MoneyRow", "FailureReasonRow",
	],
}

func _init() -> void:
	_run.call_deferred()

func _run() -> void:
	for scene_path_value in EXPECTED_NODES:
		var scene_path: String = str(scene_path_value)
		var packed: PackedScene = load(scene_path) as PackedScene
		if packed == null:
			failures.append("cannot load UI scene: %s" % scene_path)
			continue
		var instance: Node = packed.instantiate()
		for node_name in EXPECTED_NODES[scene_path]:
			_expect(instance.find_child(str(node_name), true, false) != null, "%s missing static node %s" % [scene_path, node_name])
		instance.free()

	var deck_source: String = FileAccess.get_file_as_string("res://scenes/ui/deck_select_screen.tscn")
	_expect(not deck_source.contains("assets/ui/references"), "deck select must not use a reference image at runtime")
	_expect(not deck_source.contains("PartsDecor"), "deck select must not overlay the full component sheet")
	var runtime_scenes: Array[String] = [
		"res://scenes/game/game_table_screen.tscn", "res://scenes/game/phases/battle_content.tscn",
		"res://scenes/game/phases/blind_select_panel.tscn", "res://scenes/game/phases/settlement_panel.tscn",
		"res://scenes/game/phases/shop_panel.tscn",
	]
	for path in runtime_scenes:
		_expect(not FileAccess.get_file_as_string(path).contains("assets/ui/references"), "reference image used at runtime: %s" % path)

	var forbidden: Array[String] = ["PanelContainer.new()", "HBoxContainer.new()", "VBoxContainer.new()", "Label.new()", "Button.new()", "TextureRect.new()"]
	var ui_scripts: Array[String] = [
		"res://scripts/ui/deck_select_screen.gd", "res://scripts/game/game_table_screen.gd",
		"res://scripts/game/phases/blind_select_panel.gd", "res://scripts/game/phases/battle_content.gd",
		"res://scripts/game/phases/settlement_panel.gd", "res://scripts/game/phases/shop_panel.gd",
		"res://scripts/game/table/joker_shelf.gd", "res://scripts/game/table/consumable_tray.gd",
		"res://scripts/game/table/deck_area.gd", "res://scripts/ui/result_screen.gd",
	]
	for path in ui_scripts:
		var source: String = FileAccess.get_file_as_string(path)
		for expression in forbidden:
			_expect(not source.contains(expression), "%s creates fixed UI at runtime: %s" % [path, expression])
	var battle_source: String = FileAccess.get_file_as_string("res://scripts/game/phases/battle_content.gd")
	_expect(battle_source.contains("await _clear_played_area()"), "played cards must clear after scoring animation")
	_expect(battle_source.contains("hand_area.display_cards(Game.run.sorted_hand_for_display(), [])"), "hand must refresh after PlayedArea clears")
	var fan_source: String = FileAccess.get_file_as_string("res://scripts/cards/card_fan_area.gd")
	_expect(fan_source.contains("if not previous_ids.has(card_id)"), "card fan must identify only newly drawn cards")
	_expect(fan_source.contains("_animate_cards_in(new_card_ids)"), "card fan must animate only the new card id set")
	_finish("test_ui_static_structure")

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _finish(test_name: String) -> void:
	if failures.is_empty():
		print("PASS %s" % test_name)
		quit(0)
		return
	for failure in failures:
		push_error("%s: %s" % [test_name, failure])
	quit(1)
