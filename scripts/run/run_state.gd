class_name RunState
extends RefCounted


signal changed
signal message_added(message: String)

enum Phase { HOME, DECK_SELECT, STAGE_SELECT, ROUND, SETTLEMENT, SHOP, GAME_OVER, VICTORY }

const DEFAULT_HANDS: int = 4
const DEFAULT_DISCARDS: int = 3
const DEFAULT_HAND_SIZE: int = 8
const DEFAULT_JOKER_SLOTS: int = 5
const DEFAULT_CONSUMABLE_SLOTS: int = 2
const DEFAULT_MAX_PLAY_CARDS: int = 5
const DEFAULT_INTEREST_CAP: int = 5
const DEFAULT_REROLL_COST: int = 5
const REROLL_COST_STEP: int = 1

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
var hands_left: int = DEFAULT_HANDS
var discards_left: int = DEFAULT_DISCARDS
var base_hands: int = DEFAULT_HANDS
var base_discards: int = DEFAULT_DISCARDS
var hand_size: int = DEFAULT_HAND_SIZE
var joker_slots: int = DEFAULT_JOKER_SLOTS
var consumable_slots: int = DEFAULT_CONSUMABLE_SLOTS
var max_play_cards: int = DEFAULT_MAX_PLAY_CARDS
var interest_cap: int = DEFAULT_INTEREST_CAP

var full_deck: Array = []
var deck: Array = []
var hand: Array = []
var discard_pile: Array = []
var jokers: Array = []
var consumables: Array = []
var vouchers: Array = []
var pending_tags: Array = []
var tag_history: Array = []

var shop_items: Array = []
var shop_voucher_items: Array = []
var shop_pack_items: Array = []
var extra_shop_joker_slots: int = 0
var shop_discount: float = 1.0
var reroll_base_cost: int = DEFAULT_REROLL_COST
var reroll_cost: int = DEFAULT_REROLL_COST
var rerolls_this_shop: int = 0
var free_rerolls: int = 0

# A pack is a sub-flow of SHOP so the existing screen router remains compatible.
var current_pack: Dictionary = {}
var pack_options: Array = []
var pack_choices_left: int = 0

var settlement: Dictionary = {}
var settlement_claimed: bool = false
var hand_sort_mode: String = "rank"

var hand_levels: Dictionary = {}
var total_hand_counts: Dictionary = {}
var round_hand_counts: Dictionary = {}
var message_log: Array = []

var boss_disabled: bool = false
var boss_rerolls_left: int = 0
var last_used_consumable: Dictionary = {}

var _next_card_instance: int = 1
var _boss_schedule: Array = []
var _tag_schedule: Dictionary = {}
var _double_tag_copies: int = 0
var _free_jokers_this_shop: int = 0
var _edition_rate_bonus: float = 0.0


func _data_registry() -> Node:
	return Engine.get_main_loop().root.get_node("/root/DataRegistry")


func start_new_run(start_deck_id: String = "red_deck", requested_seed_text: String = "") -> void:
	_configure_seed(requested_seed_text)
	deck_id = start_deck_id
	ante = 1
	blind_index = 0
	endless = false
	current_score = 0
	var deck_data: Dictionary = _data_registry().find_by_id("decks", start_deck_id)
	money = int(deck_data.get("start_money", 4))
	base_hands = int(deck_data.get("hands", DEFAULT_HANDS))
	base_discards = int(deck_data.get("discards", DEFAULT_DISCARDS))
	hand_size = int(deck_data.get("hand_size", DEFAULT_HAND_SIZE))
	joker_slots = int(deck_data.get("joker_slots", DEFAULT_JOKER_SLOTS))
	consumable_slots = int(deck_data.get("consumable_slots", DEFAULT_CONSUMABLE_SLOTS))
	max_play_cards = int(deck_data.get("max_play_cards", DEFAULT_MAX_PLAY_CARDS))
	interest_cap = int(deck_data.get("interest_cap", DEFAULT_INTEREST_CAP))
	reroll_base_cost = int(deck_data.get("reroll_cost", DEFAULT_REROLL_COST))
	reroll_cost = reroll_base_cost
	extra_shop_joker_slots = 0
	shop_discount = 1.0
	_edition_rate_bonus = 0.0
	jokers.clear()
	consumables.clear()
	vouchers.clear()
	pending_tags.clear()
	tag_history.clear()
	shop_items.clear()
	shop_voucher_items.clear()
	shop_pack_items.clear()
	_close_pack()
	message_log.clear()
	settlement.clear()
	settlement_claimed = false
	last_used_consumable.clear()
	hand_levels.clear()
	total_hand_counts.clear()
	round_hand_counts.clear()
	for hand_data in _data_registry().get_table("poker_hands"):
		var hand_id: String = str(hand_data.get("id", ""))
		if hand_id != "":
			hand_levels[hand_id] = 1
			total_hand_counts[hand_id] = 0
	_create_standard_deck()
	_prepare_seeded_schedules()
	phase = Phase.STAGE_SELECT
	_set_current_blind()
	emit_signal("changed")


func _configure_seed(requested_seed_text: String) -> void:
	seed_text = requested_seed_text.strip_edges()
	if seed_text.is_empty():
		rng.randomize()
		seed_text = "%08x%08x" % [rng.randi(), rng.randi()]
	var stable_seed: int = seed_text.hash()
	if stable_seed == 0:
		stable_seed = 1
	rng.seed = stable_seed


func _prepare_seeded_schedules() -> void:
	_boss_schedule.clear()
	_tag_schedule.clear()
	_double_tag_copies = 0
	var bosses: Array = _data_registry().get_table("boss_blinds")
	var tags: Array = _data_registry().get_table("tags")
	for scheduled_ante in range(1, 65):
		if bosses.is_empty():
			_boss_schedule.append("boss_none")
		else:
			var boss: Dictionary = bosses[rng.randi_range(0, bosses.size() - 1)]
			_boss_schedule.append(str(boss.get("id", "boss_none")))
		for scheduled_blind in range(2):
			if not tags.is_empty():
				var tag: Dictionary = tags[rng.randi_range(0, tags.size() - 1)]
				_tag_schedule[_stage_key(scheduled_ante, scheduled_blind)] = str(tag.get("id", ""))


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
	current_blind = _data_registry().find_by_id("blinds", blind_ids[blind_index]).duplicate(true)
	if current_blind.is_empty():
		current_blind = {"id": "small_blind", "name_cn": "小盲注", "score_mult": 1.0, "reward": 3}
	target_score = _target_for_ante(ante, float(current_blind.get("score_mult", 1.0)))
	boss_disabled = false
	boss_rerolls_left = 1 if has_voucher("directors_cut") else 0


func _boss_for_ante() -> String:
	if ante > 0 and ante <= _boss_schedule.size():
		return str(_boss_schedule[ante - 1])
	var bosses: Array = _data_registry().get_table("boss_blinds")
	if bosses.is_empty():
		return "boss_none"
	return str(bosses[(ante - 1) % bosses.size()].get("id", "boss_none"))


func current_boss_data() -> Dictionary:
	if blind_index != 2:
		return {}
	return _data_registry().find_by_id("boss_blinds", str(current_blind.get("id", "")))


func current_boss_rule() -> Dictionary:
	if blind_index != 2 or boss_disabled or has_joker("chicot"):
		return {"rule": "none"}
	var boss: Dictionary = current_boss_data()
	if boss.is_empty():
		return {"rule": "none"}
	return boss


func reroll_boss() -> bool:
	if phase != Phase.STAGE_SELECT or blind_index != 2 or not has_voucher("directors_cut") or boss_rerolls_left <= 0:
		return false
	var cost: int = 10
	if money < cost:
		add_message("金币不足，无法重随首领盲注。")
		return false
	money -= cost
	boss_rerolls_left -= 1
	var old_id: String = str(current_blind.get("id", ""))
	var bosses: Array = _data_registry().get_table("boss_blinds").filter(func(item): return str(item.get("id", "")) != old_id)
	if bosses.is_empty():
		return false
	var replacement: Dictionary = bosses[rng.randi_range(0, bosses.size() - 1)]
	_boss_schedule[ante - 1] = str(replacement.get("id", "boss_none"))
	var remaining_rerolls: int = boss_rerolls_left
	_set_current_blind()
	boss_rerolls_left = remaining_rerolls
	add_message("已重随首领盲注。")
	emit_signal("changed")
	return true


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


func current_skip_tag() -> Dictionary:
	if blind_index >= 2:
		return {}
	var tag_id: String = str(_tag_schedule.get(_stage_key(ante, blind_index), ""))
	return _data_registry().find_by_id("tags", tag_id).duplicate(true)


func skip_blind() -> bool:
	if phase != Phase.STAGE_SELECT:
		return false
	if blind_index >= 2:
		add_message("首领盲注不能跳过。")
		return false
	var tag: Dictionary = current_skip_tag()
	if tag.is_empty():
		add_message("当前盲注没有可用跳过标签，无法跳过。")
		return false
	_queue_tag(tag)
	add_message("跳过盲注，获得标签：%s。" % tag.get("name_cn", tag.get("id", "标签")))
	_advance_blind()
	emit_signal("changed")
	return true


func _queue_tag(tag: Dictionary) -> void:
	var tag_copy: Dictionary = tag.duplicate(true)
	tag_history.append(tag_copy)
	if str(tag_copy.get("id", "")) == "double_tag":
		_double_tag_copies += 1
		return
	var copies: int = 1 + _double_tag_copies
	_double_tag_copies = 0
	for _copy_index in range(copies):
		pending_tags.append(tag_copy.duplicate(true))


func _stage_key(stage_ante: int, stage_blind: int) -> String:
	return "%d:%d" % [stage_ante, stage_blind]


func start_round() -> void:
	if phase != Phase.STAGE_SELECT:
		return
	phase = Phase.ROUND
	current_score = 0
	hands_left = base_hands
	discards_left = base_discards
	round_hand_counts.clear()
	settlement.clear()
	settlement_claimed = false
	var boss_rule: Dictionary = current_boss_rule()
	if str(boss_rule.get("rule", "none")) == "discourage_discards":
		discards_left = 0
		add_message("首领限制：本回合不能弃牌。")
	deck = full_deck.duplicate()
	hand.clear()
	discard_pile.clear()
	_shuffle_deck()
	_draw_to_hand()
	add_message("进入%s，目标分：%d。" % [current_blind.get("name_cn", "盲注"), target_score])
	emit_signal("changed")


func play_selected(card_ids: Array, emit_changed: bool = true) -> Dictionary:
	if phase != Phase.ROUND or card_ids.is_empty() or hands_left <= 0:
		return {}
	var unique_ids: Array = _unique_valid_ids(card_ids)
	if unique_ids.is_empty() or unique_ids.size() > max_play_cards:
		add_message("每次最多选择%d张牌。" % max_play_cards)
		return {}
	var played: Array = _take_from_hand(unique_ids)
	if played.size() != unique_ids.size():
		return {}
	var rules: Dictionary = ScoreEngine.build_rules(self)
	var hand_result: Dictionary = HandEvaluator.evaluate(played, rules)
	var score_result: Dictionary = ScoreEngine.calculate(played, hand_result, self)
	current_score += int(score_result.get("score", 0))
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
		score_result.get("chips", 0),
		score_result.get("mult", 0),
		score_result.get("x_mult", 1.0),
		score_result.get("score", 0)
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
		"scoring_ids": Array(score_result.get("scoring_ids", hand_result.get("scoring_ids", [])))
	}
	if emit_changed:
		emit_signal("changed")
	return result


func discard_selected(card_ids: Array) -> bool:
	if phase != Phase.ROUND or card_ids.is_empty() or discards_left <= 0:
		return false
	var unique_ids: Array = _unique_valid_ids(card_ids)
	if unique_ids.is_empty() or unique_ids.size() > max_play_cards:
		add_message("每次最多选择%d张牌弃掉。" % max_play_cards)
		return false
	var cards: Array = _take_from_hand(unique_ids)
	if cards.size() != unique_ids.size():
		return false
	for card in cards:
		discard_pile.append(card)
	discards_left -= 1
	_draw_to_hand()
	add_message("弃牌 %d 张。" % cards.size())
	emit_signal("changed")
	return true


func _unique_valid_ids(card_ids: Array) -> Array:
	var result: Array = []
	for card_id in card_ids:
		var normalized: String = str(card_id)
		if normalized != "" and not result.has(normalized):
			result.append(normalized)
	return result


func _take_from_hand(card_ids: Array) -> Array:
	var result: Array = []
	for card_id in card_ids:
		for i in range(hand.size() - 1, -1, -1):
			if str(hand[i].get("instance_id", "")) == str(card_id):
				result.append(hand[i])
				hand.remove_at(i)
				break
	return result


func _draw_to_hand() -> void:
	while hand.size() < hand_size and not deck.is_empty():
		hand.append(deck.pop_back())


func set_hand_sort_mode(mode: String) -> void:
	if mode != "rank" and mode != "suit":
		return
	hand_sort_mode = mode
	emit_signal("changed")


func sorted_hand_for_display() -> Array:
	var display_hand: Array = hand.duplicate()
	if hand_sort_mode == "suit":
		display_hand.sort_custom(func(a, b): return _card_suit_sort_value(a) < _card_suit_sort_value(b))
	else:
		display_hand.sort_custom(func(a, b): return _card_rank_sort_value(a) > _card_rank_sort_value(b))
	return display_hand


func _card_rank_sort_value(card: Dictionary) -> int:
	return CardConstants.rank_order(str(card.get("rank", ""))) * 10 + CardConstants.SUITS.find(str(card.get("suit", "")))


func _card_suit_sort_value(card: Dictionary) -> int:
	return CardConstants.SUITS.find(str(card.get("suit", ""))) * 100 - CardConstants.rank_order(str(card.get("rank", "")))


func _shuffle_deck() -> void:
	for i in range(deck.size() - 1, 0, -1):
		var j: int = rng.randi_range(0, i)
		var temporary = deck[i]
		deck[i] = deck[j]
		deck[j] = temporary


func _win_round() -> void:
	if phase != Phase.ROUND:
		return
	var reward: int = int(current_blind.get("reward", 3))
	var hand_bonus: int = int(max(hands_left, 0))
	var interest: int = int(min(int(max(money, 0) / 5), interest_cap))
	var gold_card_bonus: int = _held_gold_card_bonus()
	var tag_bonus: int = _consume_settlement_tags()
	var total: int = reward + hand_bonus + interest + gold_card_bonus + tag_bonus
	settlement = {
		"stage_name": current_blind.get("name_cn", "盲注"),
		"reward": reward,
		"hand_bonus": hand_bonus,
		"interest": interest,
		"interest_cap": interest_cap,
		"gold_card_bonus": gold_card_bonus,
		"tag_bonus": tag_bonus,
		"total": total,
		"score": current_score,
		"target": target_score,
		"claimed": false
	}
	settlement_claimed = false
	add_message("盲注通过：奖励%d + 剩余出牌%d + 利息%d + 黄金牌%d + 标签%d = +%d金币，等待领取。" % [reward, hand_bonus, interest, gold_card_bonus, tag_bonus, total])
	phase = Phase.SETTLEMENT


func _held_gold_card_bonus() -> int:
	var bonus: int = 0
	var boss_rule: Dictionary = current_boss_rule()
	var disabled_suit: String = str(boss_rule.get("suit", "")) if str(boss_rule.get("rule", "none")) == "debuff_suit" else ""
	for held_card in hand:
		if str(held_card.get("enhancement", "")) == "gold" and (disabled_suit == "" or str(held_card.get("suit", "")) != disabled_suit):
			bonus += 3
	return bonus


func _consume_settlement_tags() -> int:
	var bonus: int = 0
	var remaining: Array = []
	for tag in pending_tags:
		var effect: Dictionary = tag.get("effect", {})
		if str(effect.get("trigger", "")) == "settlement" and str(effect.get("kind", "")) == "grant_money":
			bonus += int(effect.get("amount", 0))
		else:
			remaining.append(tag)
	pending_tags = remaining
	return bonus


func claim_settlement() -> bool:
	if phase != Phase.SETTLEMENT or settlement_claimed:
		return false
	var total: int = int(settlement.get("total", 0))
	money += total
	settlement_claimed = true
	settlement["claimed"] = true
	phase = Phase.SHOP
	generate_shop(true)
	emit_signal("changed")
	return true


func generate_shop(reset_reroll_state: bool = true) -> void:
	if reset_reroll_state:
		rerolls_this_shop = 0
		free_rerolls = 1 if has_joker("chaos_the_clown") else 0
		_free_jokers_this_shop = 0
		_apply_shop_tags()
	_close_pack()
	shop_items.clear()
	shop_voucher_items.clear()
	shop_pack_items.clear()
	for _offer_index in range(2 + extra_shop_joker_slots):
		shop_items.append(_priced_offer(_random_joker(), 4))
	shop_voucher_items.append(_priced_offer(_random_voucher(), 10))
	for _pack_index in range(2):
		shop_pack_items.append(_priced_offer(_random_pack(), 4))
	for free_index in range(min(_free_jokers_this_shop, shop_items.size())):
		shop_items[free_index]["cost"] = 0
	_free_jokers_this_shop = 0
	_update_reroll_cost()


func _apply_shop_tags() -> void:
	var remaining: Array = []
	for tag in pending_tags:
		var effect: Dictionary = tag.get("effect", {})
		if str(effect.get("trigger", "")) != "shop":
			remaining.append(tag)
			continue
		match str(effect.get("kind", "")):
			"free_joker":
				_free_jokers_this_shop += int(effect.get("count", 1))
			"grant_consumable":
				if not _grant_random_consumable(str(effect.get("card_type", "planet"))):
					remaining.append(tag)
			_:
				push_error("Unknown tag effect kind: %s" % effect.get("kind", ""))
				remaining.append(tag)
	pending_tags = remaining


func _priced_offer(item: Dictionary, fallback_cost: int) -> Dictionary:
	var result: Dictionary = item.duplicate(true)
	var base_cost: int = int(result.get("cost", fallback_cost))
	result["base_cost"] = base_cost
	result["cost"] = int(max(0, floor(float(base_cost) * shop_discount)))
	return result


func _update_reroll_cost() -> void:
	if free_rerolls > 0:
		reroll_cost = 0
	else:
		reroll_cost = max(0, reroll_base_cost + rerolls_this_shop * REROLL_COST_STEP)


func reroll_shop() -> bool:
	if phase != Phase.SHOP or is_pack_open():
		return false
	_update_reroll_cost()
	var cost: int = reroll_cost
	if money < cost:
		add_message("金币不足，无法刷新商店。")
		return false
	if free_rerolls > 0:
		free_rerolls -= 1
	else:
		money -= cost
		rerolls_this_shop += 1
	generate_shop(false)
	_update_reroll_cost()
	add_message("商店已刷新，下次费用%d金币。" % reroll_cost)
	emit_signal("changed")
	return true


func buy_shop_item(index: int) -> bool:
	if phase != Phase.SHOP or is_pack_open() or index < 0 or index >= shop_items.size():
		return false
	if jokers.size() >= joker_slots:
		add_message("小丑槽已满。")
		return false
	var item: Dictionary = shop_items[index]
	var cost: int = int(item.get("cost", 4))
	if money < cost:
		add_message("金币不足。")
		return false
	money -= cost
	jokers.append(item.duplicate(true))
	shop_items.remove_at(index)
	add_message("购买：%s。" % item.get("name_cn", "小丑牌"))
	emit_signal("changed")
	return true


func buy_shop_voucher(index: int) -> bool:
	if phase != Phase.SHOP or is_pack_open() or index < 0 or index >= shop_voucher_items.size():
		return false
	var item: Dictionary = shop_voucher_items[index]
	var voucher_id: String = str(item.get("id", ""))
	if has_voucher(voucher_id):
		add_message("本局已经拥有该优惠券。")
		return false
	var cost: int = int(item.get("cost", 10))
	if money < cost:
		add_message("金币不足。")
		return false
	money -= cost
	vouchers.append(voucher_id)
	_apply_voucher(item)
	shop_voucher_items.remove_at(index)
	add_message("购买优惠券：%s，效果将在本局永久生效。" % item.get("name_cn", "优惠券"))
	emit_signal("changed")
	return true


func _apply_voucher(voucher: Dictionary) -> void:
	var effect: Dictionary = voucher.get("effect", {})
	match str(effect.get("kind", "none")):
		"extra_shop_joker_slot":
			extra_shop_joker_slots += int(effect.get("amount", 1))
		"shop_discount":
			shop_discount = min(shop_discount, float(effect.get("multiplier", 0.75)))
		"edition_rate":
			_edition_rate_bonus += float(effect.get("amount", 0.1))
		"reroll_discount":
			reroll_base_cost = max(0, reroll_base_cost - int(effect.get("amount", 2)))
			_update_reroll_cost()
		"consumable_slots":
			consumable_slots += int(effect.get("amount", 1))
		"hands":
			base_hands += int(effect.get("amount", 1))
		"discards":
			base_discards += int(effect.get("amount", 1))
		"interest_cap":
			interest_cap += int(effect.get("amount", 5))
		"ante_down_hands_down":
			ante = max(1, ante - int(effect.get("ante", 1)))
			base_hands = max(1, base_hands - int(effect.get("hands", 1)))
			_set_current_blind()
		"boss_reroll":
			boss_rerolls_left = max(boss_rerolls_left, int(effect.get("uses", 1)))
		"hand_size":
			hand_size += int(effect.get("amount", 1))
		"none", "pack_bias", "shop_card_type":
			pass
		_:
			push_error("Unknown voucher effect kind: %s" % effect.get("kind", ""))


func buy_shop_pack(index: int) -> bool:
	if phase != Phase.SHOP or is_pack_open() or index < 0 or index >= shop_pack_items.size():
		return false
	var item: Dictionary = shop_pack_items[index]
	var cost: int = int(item.get("cost", 4))
	if money < cost:
		add_message("金币不足。")
		return false
	money -= cost
	shop_pack_items.remove_at(index)
	_open_booster_pack(item)
	add_message("打开补充包：%s，请选择卡牌。" % item.get("name_cn", "补充包"))
	emit_signal("changed")
	return true


func _open_booster_pack(pack: Dictionary) -> void:
	current_pack = pack.duplicate(true)
	pack_choices_left = max(1, int(current_pack.get("choose", 1)))
	pack_options.clear()
	var pack_type: String = str(current_pack.get("type", "tarot"))
	var show_count: int = max(1, int(current_pack.get("show", 3)))
	for option_index in range(show_count):
		var option: Dictionary = _random_pack_option(pack_type, option_index)
		if not option.is_empty():
			pack_options.append(option)


func _random_pack_option(pack_type: String, option_index: int = 0) -> Dictionary:
	var table_name: String = "tarot_cards"
	match pack_type:
		"joker":
			return _random_joker()
		"planet":
			table_name = "planet_cards"
		"spectral":
			table_name = "spectral_cards"
		_:
			table_name = "tarot_cards"
	var pool: Array = _data_registry().get_table(table_name)
	if pool.is_empty():
		return {}
	var item: Dictionary
	if pack_type == "planet" and option_index == 0 and has_voucher("telescope"):
		item = _planet_for_most_played_hand(pool)
	else:
		item = pool[rng.randi_range(0, pool.size() - 1)]
	var result: Dictionary = item.duplicate(true)
	result["kind"] = pack_type
	return result


func _planet_for_most_played_hand(pool: Array) -> Dictionary:
	var best_hand: String = "high_card"
	var best_count: int = -1
	for hand_id in total_hand_counts:
		var count: int = int(total_hand_counts[hand_id])
		if count > best_count:
			best_count = count
			best_hand = str(hand_id)
	for planet in pool:
		if str(planet.get("target_hand", "")) == best_hand:
			return planet
	return pool[0]


func choose_pack_option(index: int) -> bool:
	if not is_pack_open() or index < 0 or index >= pack_options.size():
		return false
	var option: Dictionary = pack_options[index]
	var kind: String = str(option.get("kind", current_pack.get("type", "")))
	if kind == "joker":
		if jokers.size() >= joker_slots:
			add_message("小丑槽已满，无法选择该卡。")
			return false
		jokers.append(option.duplicate(true))
	else:
		if consumables.size() >= consumable_slots:
			add_message("消耗牌槽已满，无法选择该卡。")
			return false
		var consumable: Dictionary = option.duplicate(true)
		consumable["kind"] = kind
		consumables.append(consumable)
	pack_options.remove_at(index)
	pack_choices_left -= 1
	if pack_choices_left <= 0 or pack_options.is_empty():
		_close_pack()
	emit_signal("changed")
	return true


func skip_pack() -> bool:
	if not is_pack_open():
		return false
	_close_pack()
	add_message("已跳过补充包剩余选择。")
	emit_signal("changed")
	return true


func is_pack_open() -> bool:
	return not current_pack.is_empty()


func _close_pack() -> void:
	current_pack.clear()
	pack_options.clear()
	pack_choices_left = 0


func use_consumable(index: int, target_card_ids: Array = []) -> bool:
	if index < 0 or index >= consumables.size():
		return false
	var item: Dictionary = consumables[index]
	var previous_consumable: Dictionary = last_used_consumable.duplicate(true)
	if not _apply_consumable(item, target_card_ids):
		return false
	if str(item.get("id", "")) == "fool":
		last_used_consumable = previous_consumable
	else:
		last_used_consumable = item.duplicate(true)
	consumables.remove_at(index)
	add_message("使用消耗牌：%s。" % item.get("name_cn", item.get("id", "消耗牌")))
	emit_signal("changed")
	return true


func _apply_consumable(item: Dictionary, target_card_ids: Array) -> bool:
	var kind: String = str(item.get("kind", ""))
	var item_id: String = str(item.get("id", ""))
	if kind == "planet":
		return upgrade_hand(str(item.get("target_hand", "")))
	if kind == "tarot":
		return _apply_tarot(item_id, target_card_ids)
	if kind == "spectral":
		return _apply_spectral(item_id, target_card_ids)
	push_error("Unknown consumable kind: %s" % kind)
	return false


func upgrade_hand(hand_id: String, amount: int = 1) -> bool:
	if not hand_levels.has(hand_id) or amount <= 0:
		return false
	hand_levels[hand_id] = int(hand_levels[hand_id]) + amount
	return true


func _apply_tarot(item_id: String, target_card_ids: Array) -> bool:
	var targets: Array = _cards_from_hand(target_card_ids)
	match item_id:
		"fool":
			if last_used_consumable.is_empty() or str(last_used_consumable.get("id", "")) == "fool":
				return false
			return _apply_consumable(last_used_consumable, target_card_ids)
		"magician":
			return _set_card_field(targets, "enhancement", "lucky", 2)
		"empress":
			return _set_card_field(targets, "enhancement", "mult", 2)
		"hierophant":
			return _set_card_field(targets, "enhancement", "bonus", 2)
		"lovers":
			return _set_card_field(targets, "enhancement", "wild", 1)
		"chariot":
			return _set_card_field(targets, "enhancement", "steel", 1)
		"justice":
			return _set_card_field(targets, "enhancement", "glass", 1)
		"devil":
			return _set_card_field(targets, "enhancement", "gold", 1)
		"tower":
			return _set_card_field(targets, "enhancement", "stone", 1)
		"star":
			return _set_card_field(targets, "suit", "diamonds", 3)
		"moon":
			return _set_card_field(targets, "suit", "clubs", 3)
		"sun":
			return _set_card_field(targets, "suit", "hearts", 3)
		"world":
			return _set_card_field(targets, "suit", "spades", 3)
		"hermit":
			money += min(max(money, 0), 20)
			return true
		"wheel":
			if jokers.is_empty():
				return false
			if rng.randi_range(1, 4) == 1:
				var joker: Dictionary = jokers[rng.randi_range(0, jokers.size() - 1)]
				var editions: Array[String] = ["foil", "holographic", "polychrome"]
				joker["edition"] = editions[rng.randi_range(0, editions.size() - 1)]
			return true
		"strength":
			if targets.is_empty() or targets.size() > 2:
				return false
			for card in targets:
				var rank_index: int = CardConstants.RANKS.find(str(card.get("rank", "")))
				if rank_index >= 0:
					card["rank"] = CardConstants.RANKS[(rank_index + 1) % CardConstants.RANKS.size()]
			return true
		"temperance":
			var sell_total: int = 0
			for joker in jokers:
				sell_total += int(joker.get("sell_value", 0))
			money += min(sell_total, 50)
			return true
		"hanged_man":
			if targets.is_empty() or targets.size() > 2:
				return false
			for card in targets:
				_remove_card_everywhere(str(card.get("instance_id", "")))
			return true
		"death":
			if targets.size() != 2:
				return false
			var source: Dictionary = targets[1]
			var destination: Dictionary = targets[0]
			for field in ["rank", "suit", "enhancement", "edition", "seal", "chip_bonus"]:
				if field == "chip_bonus":
					destination[field] = source.get(field, 0)
				else:
					destination[field] = source.get(field, "")
			return true
		"judgement":
			return _grant_random_joker(false)
		"high_priestess":
			return _grant_random_consumable("planet")
		"emperor":
			return _grant_random_consumable("tarot")
		_:
			push_error("Unknown tarot card id: %s" % item_id)
			return false


func _apply_spectral(item_id: String, target_card_ids: Array) -> bool:
	var targets: Array = _cards_from_hand(target_card_ids)
	match item_id:
		"familiar":
			if not _destroy_one_for_spectral(targets):
				return false
			_generate_enhanced_cards(3, ["J", "Q", "K"])
			return true
		"grim":
			if not _destroy_one_for_spectral(targets):
				return false
			_generate_enhanced_cards(2, ["A"])
			return true
		"incantation":
			if not _destroy_one_for_spectral(targets):
				return false
			_generate_enhanced_cards(4, ["2", "3", "4", "5", "6", "7", "8", "9", "10"])
			return true
		"talisman":
			return _set_card_field(targets, "seal", "gold", 1)
		"deja_vu":
			return _set_card_field(targets, "seal", "red", 1)
		"trance":
			return _set_card_field(targets, "seal", "blue", 1)
		"medium":
			return _set_card_field(targets, "seal", "purple", 1)
		"aura":
			if targets.size() != 1:
				return false
			var editions: Array[String] = ["foil", "holographic", "polychrome"]
			targets[0]["edition"] = editions[rng.randi_range(0, editions.size() - 1)]
			return true
		"black_hole":
			for hand_id in hand_levels:
				hand_levels[hand_id] = int(hand_levels[hand_id]) + 1
			return true
		"wraith":
			if not _grant_random_joker(true):
				return false
			money = 0
			return true
		"sigil":
			if hand.is_empty():
				return false
			var suit: String = str(CardConstants.SUITS[rng.randi_range(0, CardConstants.SUITS.size() - 1)])
			for card in hand:
				card["suit"] = suit
			return true
		"ouija":
			if hand.is_empty():
				return false
			var rank: String = str(CardConstants.RANKS[rng.randi_range(0, CardConstants.RANKS.size() - 1)])
			for card in hand:
				card["rank"] = rank
			hand_size = max(1, hand_size - 1)
			return true
		"ectoplasm":
			if jokers.is_empty():
				return false
			var negative_joker: Dictionary = jokers[rng.randi_range(0, jokers.size() - 1)]
			negative_joker["edition"] = "negative"
			joker_slots += 1
			hand_size = max(1, hand_size - 1)
			return true
		"immolate":
			if hand.is_empty():
				return false
			var candidates: Array = hand.duplicate()
			_shuffle_array(candidates)
			for card in candidates.slice(0, min(5, candidates.size())):
				_remove_card_everywhere(str(card.get("instance_id", "")))
			money += 20
			return true
		"ankh":
			if jokers.is_empty() or joker_slots < 2:
				return false
			var chosen_joker: Dictionary = jokers[rng.randi_range(0, jokers.size() - 1)].duplicate(true)
			jokers.clear()
			jokers.append(chosen_joker)
			jokers.append(chosen_joker.duplicate(true))
			return true
		"soul":
			return _grant_legendary_joker()
		"hex":
			if jokers.is_empty():
				return false
			var polychrome_joker: Dictionary = jokers[rng.randi_range(0, jokers.size() - 1)].duplicate(true)
			polychrome_joker["edition"] = "polychrome"
			jokers.clear()
			jokers.append(polychrome_joker)
			return true
		"cryptid":
			if targets.size() != 1:
				return false
			for _copy_index in range(2):
				var copied_card: Dictionary = targets[0].duplicate(true)
				copied_card["instance_id"] = "c_%d" % _next_card_instance
				_next_card_instance += 1
				full_deck.append(copied_card)
				hand.append(copied_card)
			return true
		_:
			push_error("Unknown spectral card id: %s" % item_id)
			return false


func _destroy_one_for_spectral(targets: Array) -> bool:
	if targets.size() > 1 or hand.is_empty():
		return false
	var target: Dictionary = targets[0] if targets.size() == 1 else hand[rng.randi_range(0, hand.size() - 1)]
	_remove_card_everywhere(str(target.get("instance_id", "")))
	return true


func _generate_enhanced_cards(count: int, rank_pool: Array) -> void:
	var enhancements: Array[String] = ["bonus", "mult", "wild", "steel", "glass", "gold", "lucky"]
	for _card_index in range(count):
		var rank: String = str(rank_pool[rng.randi_range(0, rank_pool.size() - 1)])
		var suit: String = str(CardConstants.SUITS[rng.randi_range(0, CardConstants.SUITS.size() - 1)])
		var card: Dictionary = _new_playing_card(rank, suit)
		card["enhancement"] = enhancements[rng.randi_range(0, enhancements.size() - 1)]
		full_deck.append(card)
		if phase == Phase.ROUND:
			hand.append(card)


func _shuffle_array(items: Array) -> void:
	for i in range(items.size() - 1, 0, -1):
		var j: int = rng.randi_range(0, i)
		var temporary = items[i]
		items[i] = items[j]
		items[j] = temporary


func _cards_from_hand(card_ids: Array) -> Array:
	var unique_ids: Array = _unique_valid_ids(card_ids)
	var result: Array = []
	for card_id in unique_ids:
		var found: Dictionary = {}
		for card in hand:
			if str(card.get("instance_id", "")) == str(card_id):
				found = card
				break
		if found.is_empty():
			return []
		result.append(found)
	return result


func _set_card_field(cards: Array, field: String, value: String, max_cards: int) -> bool:
	if cards.is_empty() or cards.size() > max_cards:
		return false
	for card in cards:
		card[field] = value
	return true


func _remove_card_everywhere(instance_id: String) -> void:
	for collection in [full_deck, deck, hand, discard_pile]:
		for index in range(collection.size() - 1, -1, -1):
			if str(collection[index].get("instance_id", "")) == instance_id:
				collection.remove_at(index)


func _grant_random_consumable(kind: String) -> bool:
	if consumables.size() >= consumable_slots:
		return false
	var table_name: String = "%s_cards" % kind
	var pool: Array = _data_registry().get_table(table_name)
	if pool.is_empty():
		return false
	var item: Dictionary = pool[rng.randi_range(0, pool.size() - 1)].duplicate(true)
	item["kind"] = kind
	consumables.append(item)
	return true


func _grant_random_joker(rare_only: bool) -> bool:
	if jokers.size() >= joker_slots:
		return false
	var pool: Array = _data_registry().get_table("jokers")
	if rare_only:
		pool = pool.filter(func(joker): return str(joker.get("rarity", "")) == "rare")
	if pool.is_empty():
		return false
	jokers.append(pool[rng.randi_range(0, pool.size() - 1)].duplicate(true))
	return true


func _grant_legendary_joker() -> bool:
	if jokers.size() >= joker_slots:
		return false
	var pool: Array = _data_registry().get_table("jokers").filter(func(joker): return str(joker.get("rarity", "")) == "legendary")
	if pool.is_empty():
		return false
	jokers.append(pool[rng.randi_range(0, pool.size() - 1)].duplicate(true))
	return true


func sell_joker(index: int) -> bool:
	if index < 0 or index >= jokers.size():
		return false
	var item: Dictionary = jokers[index]
	var sell_value: int = int(item.get("sell_value", max(1, int(float(item.get("cost", 2)) / 2.0))))
	money += sell_value
	if str(item.get("id", "")) == "luchador" and phase == Phase.ROUND and blind_index == 2:
		boss_disabled = true
	jokers.remove_at(index)
	add_message("出售：%s，获得%d金币。" % [item.get("name_cn", "小丑牌"), sell_value])
	emit_signal("changed")
	return true


func leave_shop() -> bool:
	if phase != Phase.SHOP or is_pack_open():
		return false
	_advance_blind()
	if phase != Phase.VICTORY:
		phase = Phase.STAGE_SELECT
	emit_signal("changed")
	return true


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
	var list: Array = _data_registry().get_table("jokers")
	if list.is_empty():
		return {"id": "joker_placeholder", "name_cn": "小丑牌", "cost": 4, "rarity": "common", "effect": {"kind": "none"}}
	var roll: float = rng.randf()
	var rarity: String = "common"
	if roll > 0.95:
		rarity = "rare"
	elif roll > 0.70:
		rarity = "uncommon"
	var pool: Array = list.filter(func(candidate): return candidate.get("rarity", "common") == rarity and candidate.get("rarity", "") != "legendary")
	if pool.is_empty():
		pool = list.filter(func(candidate): return candidate.get("rarity", "common") == "common")
	var joker: Dictionary = pool[rng.randi_range(0, pool.size() - 1)]
	var result: Dictionary = joker.duplicate(true)
	if _edition_rate_bonus > 0.0 and rng.randf() < _edition_rate_bonus:
		var editions: Array[String] = ["foil", "holographic", "polychrome"]
		result["edition"] = editions[rng.randi_range(0, editions.size() - 1)]
	return result


func _random_voucher() -> Dictionary:
	var list: Array = _data_registry().get_table("vouchers").filter(func(voucher): return not has_voucher(str(voucher.get("id", ""))))
	if list.is_empty():
		return {"id": "voucher_placeholder", "name_cn": "优惠券", "description_cn": "本局优惠券已售罄。", "cost": 10, "kind": "voucher", "effect": {"kind": "none"}}
	var item: Dictionary = list[rng.randi_range(0, list.size() - 1)]
	var result: Dictionary = item.duplicate(true)
	result["cost"] = int(result.get("cost", 10))
	result["kind"] = "voucher"
	return result


func _random_pack() -> Dictionary:
	var list: Array = _data_registry().get_table("booster_packs")
	if list.is_empty():
		return {"id": "pack_placeholder", "name_cn": "补充包", "description_cn": "打开后选择卡牌。", "cost": 4, "kind": "pack", "type": "tarot", "show": 3, "choose": 1}
	var item: Dictionary = list[rng.randi_range(0, list.size() - 1)]
	var result: Dictionary = item.duplicate(true)
	result["cost"] = int(result.get("cost", _pack_cost(str(result.get("type", "")))))
	result["description_cn"] = "打开后展示%d张，选择%d张。" % [int(result.get("show", 3)), int(result.get("choose", 1))]
	result["kind"] = "pack"
	return result


func _pack_cost(pack_type: String) -> int:
	match pack_type:
		"joker", "spectral":
			return 6
		_:
			return 4


func has_joker(joker_id: String) -> bool:
	for joker in jokers:
		if str(joker.get("id", "")) == joker_id:
			return true
	return false


func has_voucher(voucher_id: String) -> bool:
	return vouchers.has(voucher_id)


func count_enhanced_cards() -> int:
	var count: int = 0
	for card in full_deck:
		if str(card.get("enhancement", "")) != "":
			count += 1
	return count


func add_message(text: String) -> void:
	message_log.append(text)
	if message_log.size() > 20:
		message_log.pop_front()
	emit_signal("message_added", text)
