class_name HandEvaluator
extends RefCounted


static func evaluate(played_cards: Array, rules: Dictionary = {}) -> Dictionary:
	var cards: Array = played_cards.duplicate(true)
	var stone_cards: Array = cards.filter(func(c: Dictionary) -> bool: return c.get("enhancement", "") == "stone")
	var normal_cards: Array = cards.filter(func(c: Dictionary) -> bool: return c.get("enhancement", "") != "stone")
	var allow_four: bool = bool(rules.get("four_card_hands", false))
	var allow_shortcut: bool = bool(rules.get("shortcut_straights", false))
	var splash: bool = bool(rules.get("all_cards_score", false))

	var best: Dictionary = _detect_best(normal_cards, allow_four, allow_shortcut)
	var scoring_ids: Array = best.get("scoring_ids", [])
	for stone in stone_cards:
		scoring_ids.append(stone.get("instance_id", ""))
	if splash:
		scoring_ids.clear()
		for card in cards:
			scoring_ids.append(card.get("instance_id", ""))
	best["scoring_ids"] = scoring_ids
	best["contains"] = _build_contains(best.get("id", "high_card"), normal_cards, allow_four, allow_shortcut)
	return best

static func _detect_best(cards: Array, allow_four: bool, allow_shortcut: bool) -> Dictionary:
	if cards.is_empty():
		return {"id": "high_card", "name_cn": "高牌", "scoring_ids": []}

	var rank_groups: Dictionary = _rank_groups(cards)
	var flush_groups: Dictionary = _flush_groups(cards)

	var flush_five: Array = _find_flush_five(rank_groups)
	if not flush_five.is_empty():
		return {"id": "flush_five", "name_cn": "同花五条", "scoring_ids": _ids(flush_five)}

	var flush_house: Array = _find_flush_house(flush_groups)
	if not flush_house.is_empty():
		return {"id": "flush_house", "name_cn": "同花葫芦", "scoring_ids": _ids(flush_house)}

	var five_kind: Array = _find_count(rank_groups, 5)
	if not five_kind.is_empty():
		return {"id": "five_kind", "name_cn": "五条", "scoring_ids": _ids(five_kind)}

	var straight_flush: Array = _find_straight_flush(flush_groups, allow_four, allow_shortcut)
	if not straight_flush.is_empty():
		var royal: bool = _is_royal(straight_flush)
		return {
			"id": "royal_flush" if royal else "straight_flush",
			"name_cn": "皇家同花顺" if royal else "同花顺",
			"scoring_ids": _ids(straight_flush)
		}

	var four_kind: Array = _find_count(rank_groups, 4)
	if not four_kind.is_empty():
		return {"id": "four_kind", "name_cn": "四条", "scoring_ids": _ids(four_kind)}

	var full_house: Array = _find_full_house(rank_groups)
	if not full_house.is_empty():
		return {"id": "full_house", "name_cn": "葫芦", "scoring_ids": _ids(full_house)}

	var flush: Array = _find_flush(flush_groups, allow_four)
	if not flush.is_empty():
		return {"id": "flush", "name_cn": "同花", "scoring_ids": _ids(flush)}

	var straight: Array = _find_straight(cards, allow_four, allow_shortcut)
	if not straight.is_empty():
		return {"id": "straight", "name_cn": "顺子", "scoring_ids": _ids(straight)}

	var three: Array = _find_count(rank_groups, 3)
	if not three.is_empty():
		return {"id": "three_kind", "name_cn": "三条", "scoring_ids": _ids(three)}

	var two_pair: Array = _find_two_pair(rank_groups)
	if not two_pair.is_empty():
		return {"id": "two_pair", "name_cn": "两对", "scoring_ids": _ids(two_pair)}

	var pair: Array = _find_count(rank_groups, 2)
	if not pair.is_empty():
		return {"id": "pair", "name_cn": "对子", "scoring_ids": _ids(pair)}

	var high: Array = _highest_cards(cards, 1)
	return {"id": "high_card", "name_cn": "高牌", "scoring_ids": _ids(high)}

static func _build_contains(hand_id: String, cards: Array, allow_four: bool, allow_shortcut: bool) -> Array:
	var contains: Array = [hand_id]
	var ranks: Dictionary = _rank_groups(cards)
	if not _find_count(ranks, 2).is_empty() and not contains.has("pair"):
		contains.append("pair")
	if not _find_two_pair(ranks).is_empty() and not contains.has("two_pair"):
		contains.append("two_pair")
	if not _find_count(ranks, 3).is_empty() and not contains.has("three_kind"):
		contains.append("three_kind")
	if not _find_straight(cards, allow_four, allow_shortcut).is_empty() and not contains.has("straight"):
		contains.append("straight")
	if not _find_flush(_flush_groups(cards), allow_four).is_empty() and not contains.has("flush"):
		contains.append("flush")
	return contains

static func _rank_groups(cards: Array) -> Dictionary:
	var groups: Dictionary = {}
	for card in cards:
		var rank: String = str(card.get("rank", ""))
		if rank == "":
			continue
		if not groups.has(rank):
			groups[rank] = []
		groups[rank].append(card)
	return groups

static func _flush_groups(cards: Array) -> Dictionary:
	var groups: Dictionary = {"spades": [], "hearts": [], "diamonds": [], "clubs": []}
	for card in cards:
		var suit: String = str(card.get("suit", ""))
		if groups.has(suit):
			groups[suit].append(card)
		if card.get("enhancement", "") == "wild":
			for s in groups.keys():
				if s != suit:
					groups[s].append(card)
	return groups

static func _find_flush_five(rank_groups: Dictionary) -> Array:
	for rank in rank_groups.keys():
		var by_suit: Dictionary = {}
		for card in rank_groups[rank]:
			var suit: String = str(card.get("suit", ""))
			by_suit[suit] = by_suit.get(suit, []) + [card]
		for suit in by_suit.keys():
			if by_suit[suit].size() >= 5:
				return by_suit[suit].slice(0, 5)
	return []

static func _find_flush_house(flush_groups: Dictionary) -> Array:
	for suit in flush_groups.keys():
		var cards: Array = flush_groups[suit]
		if cards.size() < 5:
			continue
		var full: Array = _find_full_house(_rank_groups(cards))
		if not full.is_empty():
			return full
	return []

static func _find_straight_flush(flush_groups: Dictionary, allow_four: bool, allow_shortcut: bool) -> Array:
	for suit in flush_groups.keys():
		var straight: Array = _find_straight(flush_groups[suit], allow_four, allow_shortcut)
		if not straight.is_empty():
			return straight
	return []

static func _find_count(rank_groups: Dictionary, count: int) -> Array:
	for rank in rank_groups.keys():
		if rank_groups[rank].size() >= count:
			return rank_groups[rank].slice(0, count)
	return []

static func _find_full_house(rank_groups: Dictionary) -> Array:
	var triples: Array = []
	var pairs: Array = []
	for rank in rank_groups.keys():
		if rank_groups[rank].size() >= 3:
			triples.append(rank)
		if rank_groups[rank].size() >= 2:
			pairs.append(rank)
	triples.sort_custom(func(a, b): return CardConstants.rank_order(a) > CardConstants.rank_order(b))
	pairs.sort_custom(func(a, b): return CardConstants.rank_order(a) > CardConstants.rank_order(b))
	for three_rank in triples:
		for pair_rank in pairs:
			if pair_rank != three_rank:
				return rank_groups[three_rank].slice(0, 3) + rank_groups[pair_rank].slice(0, 2)
	return []

static func _find_flush(flush_groups: Dictionary, allow_four: bool) -> Array:
	var needed: int = 4 if allow_four else 5
	for suit in flush_groups.keys():
		var cards: Array = flush_groups[suit]
		if cards.size() >= needed:
			return _highest_cards(cards, needed)
	return []

static func _find_straight(cards: Array, allow_four: bool, allow_shortcut: bool) -> Array:
	var needed: int = 4 if allow_four else 5
	var by_value: Dictionary = {}
	for card in cards:
		var rank: String = str(card.get("rank", ""))
		var value: int = CardConstants.rank_order(rank)
		if value <= 0:
			continue
		if not by_value.has(value):
			by_value[value] = card
		if rank == "A" and not by_value.has(1):
			by_value[1] = card
	var values: Array = by_value.keys()
	values.sort()
	for i in range(values.size()):
		var chosen: Array = [values[i]]
		var last: int = int(values[i])
		for j in range(i + 1, values.size()):
			var gap: int = int(values[j]) - last
			if gap == 1 or (allow_shortcut and gap <= 2):
				chosen.append(values[j])
				last = int(values[j])
				if chosen.size() == needed:
					var result: Array = []
					for v in chosen:
						result.append(by_value[v])
					return result
			elif gap > 2:
				break
	return []

static func _find_two_pair(rank_groups: Dictionary) -> Array:
	var pairs: Array = []
	for rank in rank_groups.keys():
		if rank_groups[rank].size() >= 2:
			pairs.append(rank)
	pairs.sort_custom(func(a, b): return CardConstants.rank_order(a) > CardConstants.rank_order(b))
	if pairs.size() >= 2:
		return rank_groups[pairs[0]].slice(0, 2) + rank_groups[pairs[1]].slice(0, 2)
	return []

static func _highest_cards(cards: Array, count: int) -> Array:
	var sorted: Array = cards.duplicate()
	sorted.sort_custom(func(a, b): return CardConstants.rank_order(str(a.get("rank", ""))) > CardConstants.rank_order(str(b.get("rank", ""))))
	return sorted.slice(0, min(count, sorted.size()))

static func _is_royal(cards: Array) -> bool:
	var ranks: Dictionary = {}
	for card in cards:
		ranks[str(card.get("rank", ""))] = true
	for rank in ["10", "J", "Q", "K", "A"]:
		if not ranks.has(rank):
			return false
	return true

static func _ids(cards: Array) -> Array:
	var result: Array = []
	for card in cards:
		result.append(card.get("instance_id", ""))
	return result
