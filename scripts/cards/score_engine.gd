class_name ScoreEngine
extends RefCounted


static func calculate(played_cards: Array, hand_result: Dictionary, run: RunState) -> Dictionary:
	var hand_data: Dictionary = DataRegistry.find_by_id("poker_hands", str(hand_result.get("id", "high_card")))
	if hand_data.is_empty():
		hand_data = {"base_chips": 5, "base_mult": 1, "level_chips": 10, "level_mult": 1}
	var level: int = int(run.hand_levels.get(hand_result.get("id", "high_card"), 1))
	var chips: int = int(hand_data.get("base_chips", 5)) + (level - 1) * int(hand_data.get("level_chips", 0))
	var mult: int = int(hand_data.get("base_mult", 1)) + (level - 1) * int(hand_data.get("level_mult", 0))
	var x_mult: float = 1.0
	var money_gain: int = 0
	var log: Array = ["牌型：%s Lv.%d" % [hand_result.get("name_cn", "高牌"), level]]
	var scoring_ids: Array = hand_result.get("scoring_ids", [])

	for card in played_cards:
		if not scoring_ids.has(card.get("instance_id", "")):
			continue
		chips += CardConstants.card_chip_value(card)
		var enhancement: String = str(card.get("enhancement", ""))
		var edition: String = str(card.get("edition", ""))
		var seal: String = str(card.get("seal", ""))
		if enhancement == "bonus":
			chips += 30
		elif enhancement == "mult":
			mult += 4
		elif enhancement == "glass":
			x_mult *= 2.0
		elif enhancement == "lucky":
			if run.rng.randi_range(1, 5) == 1:
				mult += 20
			if run.rng.randi_range(1, 15) == 1:
				money_gain += 20
		if edition == "foil":
			chips += 50
		elif edition == "holographic":
			mult += 10
		elif edition == "polychrome":
			x_mult *= 1.5
		if seal == "gold":
			money_gain += 3

	var context: Dictionary = {
		"played_cards": played_cards,
		"scoring_ids": scoring_ids,
		"hand_result": hand_result,
		"chips": chips,
		"mult": mult,
		"x_mult": x_mult,
		"money_gain": money_gain,
		"log": log,
		"joker_effects": []
	}
	_apply_jokers(context, run)
	chips = int(context["chips"])
	mult = int(context["mult"])
	x_mult = float(context["x_mult"])
	money_gain = int(context["money_gain"])
	var total: int = int(round(float(chips) * float(mult) * x_mult))
	return {
		"chips": chips,
		"mult": mult,
		"x_mult": x_mult,
		"score": total,
		"money_gain": money_gain,
		"log": context["log"],
		"joker_effects": context["joker_effects"]
	}

static func build_rules(run: RunState) -> Dictionary:
	var rules: Dictionary = {
		"four_card_hands": false,
		"shortcut_straights": false,
		"all_cards_score": false
	}
	for joker in run.jokers:
		match str(joker.get("id", "")):
			"four_fingers":
				rules["four_card_hands"] = true
			"shortcut":
				rules["shortcut_straights"] = true
			"splash":
				rules["all_cards_score"] = true
	return rules

static func _apply_jokers(context: Dictionary, run: RunState) -> void:
	for joker in run.jokers:
		var effect: Dictionary = joker.get("effect", {})
		var kind: String = str(effect.get("kind", "none"))
		if kind == "none":
			continue
		if not _condition_matches(joker, context, run):
			continue
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
				var suit: String = str(effect.get("suit", ""))
				var per: int = int(effect.get("value", 0))
				var count: int = _count_scoring_cards(context, func(c): return c.get("suit", "") == suit)
				if count > 0:
					context["mult"] = int(context["mult"]) + count * per
					_record_joker_effect(context, joker, "+%d倍率" % (count * per))
			"scored_suit_chips":
				var suit: String = str(effect.get("suit", ""))
				var per: int = int(effect.get("value", 0))
				var count: int = _count_scoring_cards(context, func(c): return c.get("suit", "") == suit)
				if count > 0:
					context["chips"] = int(context["chips"]) + count * per
					_record_joker_effect(context, joker, "+%d筹码" % (count * per))
			"scored_rank_mult":
				var ranks: Array = effect.get("ranks", [])
				var per: int = int(effect.get("value", 0))
				var count: int = _count_scoring_cards(context, func(c): return ranks.has(str(c.get("rank", ""))))
				if count > 0:
					context["mult"] = int(context["mult"]) + count * per
					_record_joker_effect(context, joker, "+%d倍率" % (count * per))
			"scored_rank_chips":
				var ranks: Array = effect.get("ranks", [])
				var per: int = int(effect.get("value", 0))
				var count: int = _count_scoring_cards(context, func(c): return ranks.has(str(c.get("rank", ""))))
				if count > 0:
					context["chips"] = int(context["chips"]) + count * per
					_record_joker_effect(context, joker, "+%d筹码" % (count * per))
			"scored_face_mult":
				var per: int = int(effect.get("value", 0))
				var all_faces: bool = run.has_joker("pareidolia")
				var count: int = _count_scoring_cards(context, func(c): return CardConstants.is_face(c, all_faces))
				if count > 0:
					context["mult"] = int(context["mult"]) + count * per
					_record_joker_effect(context, joker, "+%d倍率" % (count * per))
			"scored_face_chips":
				var per: int = int(effect.get("value", 0))
				var all_faces: bool = run.has_joker("pareidolia")
				var count: int = _count_scoring_cards(context, func(c): return CardConstants.is_face(c, all_faces))
				if count > 0:
					context["chips"] = int(context["chips"]) + count * per
					_record_joker_effect(context, joker, "+%d筹码" % (count * per))
			"money":
				var value: int = _effect_value(effect, context, run)
				context["money_gain"] = int(context["money_gain"]) + value
				_record_joker_effect(context, joker, "+$%d" % value)
			"random_add_mult":
				var min_value: int = int(effect.get("min", 0))
				var max_value: int = int(effect.get("max", 0))
				var value: int = run.rng.randi_range(min_value, max_value)
				context["mult"] = int(context["mult"]) + value
				_record_joker_effect(context, joker, "+%d倍率" % value)
			"copy_right":
				var idx: int = run.jokers.find(joker)
				if idx >= 0 and idx + 1 < run.jokers.size():
					var source: Dictionary = run.jokers[idx + 1]
					var copied: Dictionary = source.duplicate(true)
					copied["name_cn"] = "%s复制" % joker.get("name_cn", "蓝图")
					_apply_single_copied(copied, context, run)
			"copy_leftmost":
				if not run.jokers.is_empty() and run.jokers[0] != joker:
					var source: Dictionary = run.jokers[0]
					var copied: Dictionary = source.duplicate(true)
					copied["name_cn"] = "%s复制" % joker.get("name_cn", "头脑风暴")
					_apply_single_copied(copied, context, run)

static func _apply_single_copied(joker: Dictionary, context: Dictionary, run: RunState) -> void:
	var temp: Array = run.jokers
	run.jokers = [joker]
	_apply_jokers(context, run)
	run.jokers = temp

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
	if condition.has("hand_contains"):
		if not Array(hand_result.get("contains", [])).has(condition["hand_contains"]):
			return false
	if condition.has("hand_is"):
		if str(hand_result.get("id", "")) != str(condition["hand_is"]):
			return false
	if condition.has("max_played_cards"):
		if Array(context.get("played_cards", [])).size() > int(condition["max_played_cards"]):
			return false
	if condition.has("remaining_discards"):
		if run.discards_left != int(condition["remaining_discards"]):
			return false
	if condition.has("already_played_this_round"):
		var hand_id: String = str(hand_result.get("id", ""))
		if int(run.round_hand_counts.get(hand_id, 0)) <= 0:
			return false
	if condition.has("final_hand"):
		if run.hands_left != 1:
			return false
	if condition.has("money_lte"):
		if run.money > int(condition["money_lte"]):
			return false
	if condition.has("enhanced_count_gte"):
		if run.count_enhanced_cards() < int(condition["enhanced_count_gte"]):
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
			return int(effect.get("per", 0)) * int(run.money / 5)
		"hand_play_count":
			var hand_result: Dictionary = context.get("hand_result", {})
			var hand_id: String = str(hand_result.get("id", ""))
			return int(run.total_hand_counts.get(hand_id, 0))
		"sell_value_other_jokers":
			var sum: int = 0
			for j in run.jokers:
				if j.get("id", "") != effect.get("owner_id", ""):
					sum += int(j.get("sell_value", 1))
			return sum
	return 0

static func _count_scoring_cards(context: Dictionary, predicate: Callable) -> int:
	var scoring_ids: Array = context.get("scoring_ids", [])
	var count: int = 0
	for card in context.get("played_cards", []):
		if scoring_ids.has(card.get("instance_id", "")) and predicate.call(card):
			count += 1
	return count
