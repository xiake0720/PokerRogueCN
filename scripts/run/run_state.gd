class_name RunState
extends RefCounted


signal changed
signal message_added(message: String)

enum Phase { HOME, DECK_SELECT, STAGE_SELECT, ROUND, SETTLEMENT, SHOP, GAME_OVER, VICTORY }

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var phase: int = Phase.HOME
var seed_text: String = ""

var deck_id: String = "red_deck"
var ante: int = 1
var blind_index: int = 0
var endless: bool = false
var current_blind: Dictionary = {}
var current_score: int = 0
var target_score: int = 300

var money: int = 4
var hands_left: int = 4
var discards_left: int = 3
var base_hands: int = 4
var base_discards: int = 3
var hand_size: int = 8
var joker_slots: int = 5

var full_deck: Array = []
var deck: Array = []
var hand: Array = []
var discard_pile: Array = []
var jokers: Array = []
var shop_items: Array = []
var shop_voucher_items: Array = []
var shop_pack_items: Array = []
var settlement: Dictionary = {}
var hand_sort_mode: String = "rank"

var hand_levels: Dictionary = {}
var total_hand_counts: Dictionary = {}
var round_hand_counts: Dictionary = {}
var message_log: Array = []

var _next_card_instance: int = 1

func start_new_run(start_deck_id: String = "red_deck") -> void:
	rng.randomize()
	deck_id = start_deck_id
	ante = 1
	blind_index = 0
	endless = false
	var deck_data: Dictionary = DataRegistry.find_by_id("decks", start_deck_id)
	money = int(deck_data.get("start_money", 4))
	base_hands = int(deck_data.get("hands", 4))
	base_discards = int(deck_data.get("discards", 3))
	hand_size = int(deck_data.get("hand_size", 8))
	joker_slots = int(deck_data.get("joker_slots", 5))
	jokers.clear()
	message_log.clear()
	hand_levels.clear()
	total_hand_counts.clear()
	for h in DataRegistry.get_table("poker_hands"):
		hand_levels[h["id"]] = 1
		total_hand_counts[h["id"]] = 0
	_create_standard_deck()
	phase = Phase.STAGE_SELECT
	_set_current_blind()
	emit_signal("changed")

func show_home() -> void:
	phase = Phase.HOME
	emit_signal("changed")

func show_deck_select() -> void:
	phase = Phase.DECK_SELECT
	emit_signal("changed")

func select_deck(start_deck_id: String) -> void:
	start_new_run(start_deck_id)

func _create_standard_deck() -> void:
	full_deck.clear()
	_next_card_instance = 1
	for suit in CardConstants.SUITS:
		for rank in CardConstants.RANKS:
			full_deck.append(_new_playing_card(rank, suit))

func _new_playing_card(rank: String, suit: String) -> Dictionary:
	var card: Dictionary = {
		"instance_id": "c_%d" % _next_card_instance,
		"rank": rank,
		"suit": suit,
		"enhancement": "",
		"edition": "",
		"seal": "",
		"chip_bonus": 0
	}
	_next_card_instance += 1
	return card

func _set_current_blind() -> void:
	var blind_ids: Array[String] = ["small_blind", "big_blind", _boss_for_ante()]
	current_blind = DataRegistry.find_by_id("blinds", blind_ids[blind_index])
	if current_blind.is_empty():
		current_blind = {"id": "small_blind", "name_cn": "小关卡", "score_mult": 1.0, "reward": 3}
	target_score = _target_for_ante(ante, float(current_blind.get("score_mult", 1.0)))

func _boss_for_ante() -> String:
	var bosses: Array = DataRegistry.get_table("boss_blinds")
	if bosses.is_empty():
		return "boss_none"
	var boss: Dictionary = bosses[(ante - 1) % bosses.size()]
	return str(boss.get("id", "boss_none"))

func _target_for_ante(current_ante: int, mult: float) -> int:
	var base_scores: Array[int] = [300, 800, 2000, 5000, 11000, 20000, 35000, 50000]
	var base: int = base_scores[int(min(current_ante - 1, base_scores.size() - 1))]
	if current_ante > 8:
		base = int(50000 * pow(1.7, current_ante - 8))
	return int(round(float(base) * mult))

func target_preview_for_stage(stage_index: int) -> int:
	var mults: Array[float] = [1.0, 1.5, 2.0]
	var index: int = int(clamp(stage_index, 0, mults.size() - 1))
	return _target_for_ante(ante, mults[index])

func skip_blind() -> void:
	if phase != Phase.STAGE_SELECT:
		return
	if blind_index >= 2:
		add_message("首领关卡不能跳过。")
		return
	money += 4
	add_message("跳过关卡，获得临时奖励：+4金币。")
	_advance_blind()
	emit_signal("changed")

func start_round() -> void:
	if phase != Phase.STAGE_SELECT:
		return
	phase = Phase.ROUND
	current_score = 0
	hands_left = base_hands
	discards_left = base_discards
	round_hand_counts.clear()
	deck = full_deck.duplicate(true)
	hand.clear()
	discard_pile.clear()
	_shuffle_deck()
	_draw_to_hand()
	add_message("进入%s，目标分：%d。" % [current_blind.get("name_cn", "关卡"), target_score])
	emit_signal("changed")

func play_selected(card_ids: Array, emit_changed: bool = true) -> Dictionary:
	if phase != Phase.ROUND or card_ids.is_empty() or hands_left <= 0:
		return {}
	var played: Array = _take_from_hand(card_ids)
	var rules: Dictionary = ScoreEngine.build_rules(self)
	var hand_result: Dictionary = HandEvaluator.evaluate(played, rules)
	var score_result: Dictionary = ScoreEngine.calculate(played, hand_result, self)
	current_score += int(score_result["score"])
	money += int(score_result.get("money_gain", 0))
	hands_left -= 1
	var hand_id: String = str(hand_result.get("id", "high_card"))
	total_hand_counts[hand_id] = int(total_hand_counts.get(hand_id, 0)) + 1
	round_hand_counts[hand_id] = int(round_hand_counts.get(hand_id, 0)) + 1
	for card in played:
		discard_pile.append(card)
	_draw_to_hand()
	add_message("%s：%d筹码 × %d倍率 × %.2f = %d" % [
		hand_result.get("name_cn", "高牌"),
		score_result["chips"],
		score_result["mult"],
		score_result["x_mult"],
		score_result["score"]
	])
	if current_score >= target_score:
		_win_round()
	elif hands_left <= 0:
		phase = Phase.GAME_OVER
		add_message("出牌次数用完，本局失败。")
	var result: Dictionary = {
		"played_cards": played,
		"hand_result": hand_result,
		"score_result": score_result,
		"scoring_ids": Array(hand_result.get("scoring_ids", []))
	}
	if emit_changed:
		emit_signal("changed")
	return result

func discard_selected(card_ids: Array) -> void:
	if phase != Phase.ROUND or card_ids.is_empty() or discards_left <= 0:
		return
	var cards: Array = _take_from_hand(card_ids)
	for card in cards:
		discard_pile.append(card)
	discards_left -= 1
	_draw_to_hand()
	add_message("弃牌 %d 张。" % cards.size())
	emit_signal("changed")

func _take_from_hand(card_ids: Array) -> Array:
	var result: Array = []
	for id in card_ids:
		for i in range(hand.size() - 1, -1, -1):
			if hand[i].get("instance_id", "") == id:
				result.append(hand[i])
				hand.remove_at(i)
				break
	return result

func _draw_to_hand() -> void:
	while hand.size() < hand_size and not deck.is_empty():
		hand.append(deck.pop_back())
	_sort_hand()

func set_hand_sort_mode(mode: String) -> void:
	hand_sort_mode = mode
	_sort_hand()
	emit_signal("changed")

func _sort_hand() -> void:
	if hand_sort_mode == "suit":
		hand.sort_custom(func(a, b): return _card_suit_sort_value(a) < _card_suit_sort_value(b))
	else:
		hand.sort_custom(func(a, b): return _card_rank_sort_value(a) > _card_rank_sort_value(b))

func _card_rank_sort_value(card: Dictionary) -> int:
	return CardConstants.rank_order(str(card.get("rank", ""))) * 10 + CardConstants.SUITS.find(str(card.get("suit", "")))

func _card_suit_sort_value(card: Dictionary) -> int:
	return CardConstants.SUITS.find(str(card.get("suit", ""))) * 100 - CardConstants.rank_order(str(card.get("rank", "")))

func _shuffle_deck() -> void:
	for i in range(deck.size() - 1, 0, -1):
		var j: int = rng.randi_range(0, i)
		var tmp = deck[i]
		deck[i] = deck[j]
		deck[j] = tmp

func _win_round() -> void:
	var reward: int = int(current_blind.get("reward", 3))
	var hand_bonus: int = int(max(hands_left, 0))
	var interest: int = int(min(int(money / 5), 5))
	var total: int = reward + hand_bonus + interest
	settlement = {
		"stage_name": current_blind.get("name_cn", "关卡"),
		"reward": reward,
		"hand_bonus": hand_bonus,
		"interest": interest,
		"total": total,
		"score": current_score,
		"target": target_score
	}
	money += total
	add_message("关卡通过：奖励%d + 剩余出牌%d + 利息%d = +%d金币。" % [reward, hand_bonus, interest, total])
	phase = Phase.SETTLEMENT

func claim_settlement() -> void:
	if phase != Phase.SETTLEMENT:
		return
	phase = Phase.SHOP
	generate_shop()
	emit_signal("changed")

func generate_shop() -> void:
	shop_items.clear()
	shop_voucher_items.clear()
	shop_pack_items.clear()
	for i in range(2):
		shop_items.append(_random_joker())
	shop_voucher_items.append(_random_voucher())
	for i in range(2):
		shop_pack_items.append(_random_pack())

func reroll_shop() -> void:
	if phase != Phase.SHOP:
		return
	var cost: int = 5
	if has_joker("chaos_the_clown"):
		cost = 0
	if money < cost:
		add_message("金币不足，无法刷新商店。")
		return
	money -= cost
	generate_shop()
	add_message("商店已刷新。")
	emit_signal("changed")

func buy_shop_item(index: int) -> void:
	if phase != Phase.SHOP or index < 0 or index >= shop_items.size():
		return
	if jokers.size() >= joker_slots:
		add_message("小丑槽已满。")
		return
	var item: Dictionary = shop_items[index]
	var cost: int = int(item.get("cost", 4))
	if money < cost:
		add_message("金币不足。")
		return
	money -= cost
	jokers.append(item.duplicate(true))
	shop_items.remove_at(index)
	add_message("购买：%s。" % item.get("name_cn", "小丑牌"))
	emit_signal("changed")

func buy_shop_voucher(index: int) -> void:
	if phase != Phase.SHOP or index < 0 or index >= shop_voucher_items.size():
		return
	var item: Dictionary = shop_voucher_items[index]
	var cost: int = int(item.get("cost", 10))
	if money < cost:
		add_message("金币不足。")
		return
	money -= cost
	shop_voucher_items.remove_at(index)
	add_message("购买优惠券：%s。" % item.get("name_cn", "优惠券"))
	emit_signal("changed")

func buy_shop_pack(index: int) -> void:
	if phase != Phase.SHOP or index < 0 or index >= shop_pack_items.size():
		return
	var item: Dictionary = shop_pack_items[index]
	var cost: int = int(item.get("cost", 4))
	if money < cost:
		add_message("金币不足。")
		return
	money -= cost
	shop_pack_items.remove_at(index)
	add_message("购买补充包：%s。" % item.get("name_cn", "补充包"))
	emit_signal("changed")

func sell_joker(index: int) -> void:
	if index < 0 or index >= jokers.size():
		return
	var item: Dictionary = jokers[index]
	var sell_value: int = int(item.get("sell_value", max(1, int(item.get("cost", 2)) / 2)))
	money += sell_value
	jokers.remove_at(index)
	add_message("出售：%s，获得%d金币。" % [item.get("name_cn", "小丑牌"), sell_value])
	emit_signal("changed")

func leave_shop() -> void:
	if phase != Phase.SHOP:
		return
	_advance_blind()
	if phase != Phase.VICTORY:
		phase = Phase.STAGE_SELECT
	emit_signal("changed")

func _advance_blind() -> void:
	if blind_index < 2:
		blind_index += 1
	else:
		ante += 1
		blind_index = 0
		if ante > 8 and not endless:
			phase = Phase.VICTORY
			add_message("第8底注已通过，通关！可以继续无尽模式。")
			return
	_set_current_blind()

func continue_endless() -> void:
	endless = true
	phase = Phase.STAGE_SELECT
	_set_current_blind()
	emit_signal("changed")

func _random_joker() -> Dictionary:
	var list: Array = DataRegistry.get_table("jokers")
	var roll: float = rng.randf()
	var rarity: String = "common"
	if roll > 0.95:
		rarity = "rare"
	elif roll > 0.70:
		rarity = "uncommon"
	var pool: Array = list.filter(func(j): return j.get("rarity", "common") == rarity and j.get("rarity", "") != "legendary")
	if pool.is_empty():
		pool = list.filter(func(j): return j.get("rarity", "common") == "common")
	var joker: Dictionary = pool[rng.randi_range(0, pool.size() - 1)]
	return joker.duplicate(true)

func _random_voucher() -> Dictionary:
	var list: Array = DataRegistry.get_table("vouchers")
	if list.is_empty():
		return {"id": "voucher_placeholder", "name_cn": "优惠券", "description_cn": "商店优惠项目。", "cost": 10, "kind": "voucher"}
	var item: Dictionary = list[rng.randi_range(0, list.size() - 1)]
	var result: Dictionary = item.duplicate(true)
	result["cost"] = int(result.get("cost", 10))
	result["kind"] = "voucher"
	return result

func _random_pack() -> Dictionary:
	var list: Array = DataRegistry.get_table("booster_packs")
	if list.is_empty():
		return {"id": "pack_placeholder", "name_cn": "补充包", "description_cn": "打开后选择卡牌。", "cost": 4, "kind": "pack"}
	var item: Dictionary = list[rng.randi_range(0, list.size() - 1)]
	var result: Dictionary = item.duplicate(true)
	result["cost"] = _pack_cost(str(result.get("type", "")))
	result["description_cn"] = "打开后展示%d张，选择%d张。" % [int(result.get("show", 3)), int(result.get("choose", 1))]
	result["kind"] = "pack"
	return result

func _pack_cost(pack_type: String) -> int:
	match pack_type:
		"joker":
			return 6
		"spectral":
			return 6
		"planet":
			return 4
		_:
			return 4

func has_joker(joker_id: String) -> bool:
	for joker in jokers:
		if joker.get("id", "") == joker_id:
			return true
	return false

func count_enhanced_cards() -> int:
	var count: int = 0
	for card in full_deck:
		if str(card.get("enhancement", "")) != "":
			count += 1
	return count

func add_message(text: String) -> void:
	message_log.append(text)
	if message_log.size() > 10:
		message_log.pop_front()
	emit_signal("message_added", text)
