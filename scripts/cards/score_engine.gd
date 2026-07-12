class_name ScoreEngine
extends RefCounted


const SCORING_EFFECT_KINDS: Array[String] = [
	"add_mult",
	"add_chips",
	"x_mult",
	"scored_suit_mult",
	"scored_suit_chips",
	"scored_rank_mult",
	"scored_rank_chips",
	"scored_face_mult",
	"scored_face_chips",
	"money",
	"random_add_mult",
	"copy_right",
	"copy_leftmost"
]
const EXTERNAL_EFFECT_KINDS: Array[String] = ["rule", "shop_rule"]
const EXPLICITLY_UNIMPLEMENTED_KIND: String = "none"
const EXTERNAL_NONE_JOKER_IDS: Array[String] = ["chicot", "luchador"]


static func calculate(played_cards: Array, hand_result: Dictionary, run: RunState) -> Dictionary:
	var hand_data: Dictionary = _data_registry().find_by_id("poker_hands", str(hand_result.get("id", "high_card")))
	if hand_data.is_empty():
		hand_data = {"base_chips": 5, "base_mult": 1, "level_chips": 10, "level_mult": 1}
	var level: int = int(run.hand_levels.get(hand_result.get("id", "high_card"), 1))
	var chips: int = int(hand_data.get("base_chips", 5)) + (level - 1) * int(hand_data.get("level_chips", 0))
	var mult: int = int(hand_data.get("base_mult", 1)) + (level - 1) * int(hand_data.get("level_mult", 0))
	var x_mult: float = 1.0
	var money_gain: int = 0
	var score_log: Array = ["牌型：%s Lv.%d" % [hand_result.get("name_cn", "高牌"), level]]
	var raw_scoring_ids: Array = Array(hand_result.get("scoring_ids", []))
	var scoring_ids: Array = raw_scoring_ids.duplicate()
	var debuffed_ids: Array = []
	var boss_rule: Dictionary = run.current_boss_rule()
	if str(boss_rule.get("rule", "none")) == "debuff_suit":
		var disabled_suit: String = str(boss_rule.get("suit", ""))
		for card in played_cards:
			var card_id: String = str(card.get("instance_id", ""))
			if scoring_ids.has(card_id) and str(card.get("suit", "")) == disabled_suit:
				debuffed_ids.append(card_id)
		for card_id in debuffed_ids:
			scoring_ids.erase(card_id)
		if not debuffed_ids.is_empty():
			score_log.append("首领限制：%d张%s牌不参与计分" % [debuffed_ids.size(), disabled_suit])

	for card in played_cards:
		if not scoring_ids.has(card.get("instance_id", "")):
			continue
		chips += CardConstants.card_chip_value(card)
		var enhancement: String = str(card.get("enhancement", ""))
		var edition: String = str(card.get("edition", ""))
		var seal: String = str(card.get("seal", ""))
		match enhancement:
			"bonus":
				chips += 30
			"mult":
				mult += 4
			"glass":
				x_mult *= 2.0
			"lucky":
				if run.rng.randi_range(1, 5) == 1:
					mult += 20
				if run.rng.randi_range(1, 15) == 1:
					money_gain += 20
		match edition:
			"foil":
				chips += 50
			"holographic":
				mult += 10
			"polychrome":
				x_mult *= 1.5
		if seal == "gold":
			money_gain += 3

	var held_steel_count: int = 0
	var disabled_held_suit: String = str(boss_rule.get("suit", "")) if str(boss_rule.get("rule", "none")) == "debuff_suit" else ""
	for held_card in run.hand:
		if str(held_card.get("enhancement", "")) != "steel":
			continue
		if disabled_held_suit != "" and str(held_card.get("suit", "")) == disabled_held_suit:
			continue
		x_mult *= 1.5
		held_steel_count += 1
	if held_steel_count > 0:
		score_log.append("手牌钢铁牌：%d张，X1.5^%d" % [held_steel_count, held_steel_count])

	var context: Dictionary = {
		"played_cards": played_cards,
		"raw_scoring_ids": raw_scoring_ids,
		"scoring_ids": scoring_ids,
		"debuffed_ids": debuffed_ids,
		"hand_result": hand_result,
		"chips": chips,
		"mult": mult,
		"x_mult": x_mult,
		"money_gain": money_gain,
		"log": score_log,
		"joker_effects": [],
		"unimplemented_jokers": [],
		"unknown_effect_kinds": []
	}
	_apply_jokers(context, run)
	chips = int(context["chips"])
	mult = int(context["mult"])
	x_mult = float(context["x_mult"])
	money_gain = int(context["money_gain"])

	var boss_score_multiplier: float = 1.0
	if str(boss_rule.get("rule", "none")) == "final_hand_pressure" and run.hands_left > 1:
		boss_score_multiplier = float(boss_rule.get("score_multiplier_before_final", 0.5))
		x_mult *= boss_score_multiplier
		context["log"].append("首领限制：最终一次出牌前得分X%.2f" % boss_score_multiplier)
	var total: int = int(round(float(chips) * float(mult) * x_mult))
	return {
		"chips": chips,
		"mult": mult,
		"x_mult": x_mult,
		"score": total,
		"money_gain": money_gain,
		"scoring_ids": scoring_ids,
		"debuffed_ids": debuffed_ids,
		"boss_score_multiplier": boss_score_multiplier,
		"log": context["log"],
		"joker_effects": context["joker_effects"],
		"unimplemented_jokers": context["unimplemented_jokers"],
		"unknown_effect_kinds": context["unknown_effect_kinds"]
	}


static func build_rules(run: RunState) -> Dictionary:
	var rules: Dictionary = {
		"four_card_hands": false,
		"shortcut_straights": false,
		"all_cards_score": false,
		"smeared_suits": false
	}
	for joker in run.jokers:
		match str(joker.get("id", "")):
			"four_fingers":
				rules["four_card_hands"] = true
			"shortcut":
				rules["shortcut_straights"] = true
			"splash":
				rules["all_cards_score"] = true
			"smeared_joker":
				rules["smeared_suits"] = true
	return rules


static func _data_registry() -> Node:
	return Engine.get_main_loop().root.get_node("/root/DataRegistry")


static func unknown_effect_kinds(joker_data: Array) -> Array[String]:
	var unknown: Array[String] = []
	for joker in joker_data:
		var kind: String = str(joker.get("effect", {}).get("kind", EXPLICITLY_UNIMPLEMENTED_KIND))
		if not is_known_effect_kind(kind) and not unknown.has(kind):
			unknown.append(kind)
	return unknown


static func is_known_effect_kind(kind: String) -> bool:
	return kind == EXPLICITLY_UNIMPLEMENTED_KIND or SCORING_EFFECT_KINDS.has(kind) or EXTERNAL_EFFECT_KINDS.has(kind)


static func _apply_jokers(context: Dictionary, run: RunState) -> void:
	# Array order is the authoritative trigger order. Every copied chain receives its
	# own visited-index set so Blueprint/Brainstorm cycles terminate deterministically.
	for joker_index in range(run.jokers.size()):
		_apply_joker_at(joker_index, context, run, [])
		_apply_joker_edition(run.jokers[joker_index], context)


static func _apply_joker_at(joker_index: int, context: Dictionary, run: RunState, visited: Array) -> void:
	if joker_index < 0 or joker_index >= run.jokers.size():
		return
	if visited.has(joker_index):
		var cycle_joker: Dictionary = run.jokers[joker_index]
		_record_joker_effect(context, cycle_joker, "复制链循环，已安全中止")
		return
	var next_visited: Array = visited.duplicate()
	next_visited.append(joker_index)
	var joker: Dictionary = run.jokers[joker_index]
	var effect: Dictionary = joker.get("effect", {})
	var kind: String = str(effect.get("kind", EXPLICITLY_UNIMPLEMENTED_KIND))
	if kind == EXPLICITLY_UNIMPLEMENTED_KIND:
		if EXTERNAL_NONE_JOKER_IDS.has(str(joker.get("id", ""))):
			return
		var unresolved: Array = context.get("unimplemented_jokers", [])
		unresolved.append(str(joker.get("id", "")))
		context["unimplemented_jokers"] = unresolved
		return
	if not is_known_effect_kind(kind):
		var unknown: Array = context.get("unknown_effect_kinds", [])
		unknown.append(kind)
		context["unknown_effect_kinds"] = unknown
		push_error("Unknown core joker effect kind '%s' on '%s'." % [kind, joker.get("id", "")])
		return
	if EXTERNAL_EFFECT_KINDS.has(kind):
		return
	if not _condition_matches(joker, context, run):
		return

	match kind:
		"add_mult":
			var value: int = _effect_value(effect, context, run)
			context["mult"] = int(context["mult"]) + value
			_record_joker_effect(context, joker, "+%d倍率" % value)
		"add_chips":
			var value: int = _effect_value(effect, context, run)
			context["chips"] = int(context["chips"]) + value
			_record_joker_effect(context, joker, "+%d筹码" % value)
		"x_mult":
			var value: float = float(effect.get("value", 1.0))
			context["x_mult"] = float(context["x_mult"]) * value
			_record_joker_effect(context, joker, "X%.2f倍率" % value)
		"scored_suit_mult":
			_apply_counted_addition(context, joker, effect, "mult", func(card): return card.get("suit", "") == effect.get("suit", ""))
		"scored_suit_chips":
			_apply_counted_addition(context, joker, effect, "chips", func(card): return card.get("suit", "") == effect.get("suit", ""))
		"scored_rank_mult":
			var ranks: Array = effect.get("ranks", [])
			_apply_counted_addition(context, joker, effect, "mult", func(card): return ranks.has(str(card.get("rank", ""))))
		"scored_rank_chips":
			var ranks: Array = effect.get("ranks", [])
			_apply_counted_addition(context, joker, effect, "chips", func(card): return ranks.has(str(card.get("rank", ""))))
		"scored_face_mult":
			var all_faces: bool = run.has_joker("pareidolia")
			_apply_counted_addition(context, joker, effect, "mult", func(card): return CardConstants.is_face(card, all_faces))
		"scored_face_chips":
			var all_faces: bool = run.has_joker("pareidolia")
			_apply_counted_addition(context, joker, effect, "chips", func(card): return CardConstants.is_face(card, all_faces))
		"money":
			var value: int = _effect_value(effect, context, run)
			context["money_gain"] = int(context["money_gain"]) + value
			_record_joker_effect(context, joker, "+$%d" % value)
		"random_add_mult":
			var value: int = run.rng.randi_range(int(effect.get("min", 0)), int(effect.get("max", 0)))
			context["mult"] = int(context["mult"]) + value
			_record_joker_effect(context, joker, "+%d倍率" % value)
		"copy_right":
			var target_index: int = joker_index + 1
			if target_index < run.jokers.size():
				_apply_joker_at(target_index, context, run, next_visited)
		"copy_leftmost":
			if not run.jokers.is_empty():
				_apply_joker_at(0, context, run, next_visited)


static func _apply_counted_addition(context: Dictionary, joker: Dictionary, effect: Dictionary, field: String, predicate: Callable) -> void:
	var per_card: int = int(effect.get("value", 0))
	var count: int = _count_scoring_cards(context, predicate)
	if count <= 0:
		return
	var amount: int = count * per_card
	context[field] = int(context[field]) + amount
	_record_joker_effect(context, joker, "+%d%s" % [amount, "筹码" if field == "chips" else "倍率"])


static func _apply_joker_edition(joker: Dictionary, context: Dictionary) -> void:
	match str(joker.get("edition", "")):
		"foil":
			context["chips"] = int(context["chips"]) + 50
			_record_joker_effect(context, joker, "闪箔+50筹码")
		"holographic":
			context["mult"] = int(context["mult"]) + 10
			_record_joker_effect(context, joker, "镭射+10倍率")
		"polychrome":
			context["x_mult"] = float(context["x_mult"]) * 1.5
			_record_joker_effect(context, joker, "多彩X1.5倍率")


static func _record_joker_effect(context: Dictionary, joker: Dictionary, text: String) -> void:
	context["log"].append("%s：%s" % [joker.get("name_cn", joker.get("name", "")), text])
	var effects: Array = context.get("joker_effects", [])
	effects.append({
		"id": str(joker.get("id", "")),
		"name_cn": str(joker.get("name_cn", joker.get("name", ""))),
		"text": text
	})
	context["joker_effects"] = effects


static func _condition_matches(joker: Dictionary, context: Dictionary, run: RunState) -> bool:
	var condition: Dictionary = joker.get("condition", {})
	if condition.is_empty():
		return true
	var hand_result: Dictionary = context.get("hand_result", {})
	if condition.has("hand_contains") and not Array(hand_result.get("contains", [])).has(condition["hand_contains"]):
		return false
	if condition.has("hand_is") and str(hand_result.get("id", "")) != str(condition["hand_is"]):
		return false
	if condition.has("max_played_cards") and Array(context.get("played_cards", [])).size() > int(condition["max_played_cards"]):
		return false
	if condition.has("remaining_discards") and run.discards_left != int(condition["remaining_discards"]):
		return false
	if condition.has("already_played_this_round"):
		var hand_id: String = str(hand_result.get("id", ""))
		if int(run.round_hand_counts.get(hand_id, 0)) <= 0:
			return false
	if condition.has("final_hand") and run.hands_left != 1:
		return false
	if condition.has("money_lte") and run.money > int(condition["money_lte"]):
		return false
	if condition.has("enhanced_count_gte") and run.count_enhanced_cards() < int(condition["enhanced_count_gte"]):
		return false
	return true


static func _effect_value(effect: Dictionary, context: Dictionary, run: RunState) -> int:
	if effect.has("value"):
		return int(effect["value"])
	match str(effect.get("scale", "")):
		"remaining_discards":
			return int(effect.get("per", 0)) * run.discards_left
		"joker_count":
			return int(effect.get("per", 0)) * run.jokers.size()
		"deck_remaining":
			return int(effect.get("per", 0)) * run.deck.size()
		"money":
			return int(effect.get("per", 0)) * run.money
		"money_div_5":
			return int(effect.get("per", 0)) * int(float(run.money) / 5.0)
		"hand_play_count":
			var hand_result: Dictionary = context.get("hand_result", {})
			return int(run.total_hand_counts.get(str(hand_result.get("id", "")), 0))
		"sell_value_other_jokers":
			var sum: int = 0
			for joker in run.jokers:
				if joker.get("id", "") != effect.get("owner_id", ""):
					sum += int(joker.get("sell_value", 1))
			return sum
	return 0


static func _count_scoring_cards(context: Dictionary, predicate: Callable) -> int:
	var scoring_ids: Array = context.get("scoring_ids", [])
	var count: int = 0
	for card in context.get("played_cards", []):
		if scoring_ids.has(card.get("instance_id", "")) and predicate.call(card):
			count += 1
	return count
