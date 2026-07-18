class_name GameHudPanel
extends PanelContainer

@onready var title_label: Label = %TitleLabel
@onready var blind_token: TextureRect = %BlindToken
@onready var desc_label: Label = %DescLabel
@onready var round_caption: Label = %RoundCaption
@onready var round_value_label: Label = %RoundValueLabel
@onready var target_panel: Control = %TargetPanel
@onready var target_caption: Label = %TargetCaption
@onready var target_coin: TextureRect = %TargetCoin
@onready var target_label: Label = %TargetLabel
@onready var score_box: Control = %ScoreBox
@onready var score_caption: Label = %ScoreCaption
@onready var current_score_chip: TextureRect = %CurrentScoreChip
@onready var score_label: Label = %ScoreLabel
@onready var hand_box: Control = %HandBox
@onready var current_hand_label: Label = %CurrentHandLabel
@onready var equation_box: Control = %EquationBox
@onready var chips_value_label: Label = %ChipsValueLabel
@onready var times_label: Label = %TimesLabel
@onready var mult_value_label: Label = %MultValueLabel
@onready var preview_score_label: Label = %PreviewScoreLabel
@onready var counts_grid: Control = %CountsGrid
@onready var hands_title: Label = %HandsTitle
@onready var discards_title: Label = %DiscardsTitle
@onready var hands_label: Label = %HandsLabel
@onready var discards_label: Label = %DiscardsLabel
@onready var money_label: Label = %MoneyLabel
@onready var ante_box: Control = %AnteBox
@onready var ante_label: Label = %AnteLabel
@onready var blind_box: Control = %BlindBox
@onready var blind_caption: Label = %BlindCaption
@onready var blind_step_label: Label = %BlindStepLabel
@onready var deck_label: Label = %DeckLabel
@onready var tag_label: Label = %TagLabel
@onready var consumables_label: Label = %ConsumablesLabel
@onready var hand_list_toggle: Button = %HandListToggle
@onready var hand_info_scroll: ScrollContainer = %HandInfoScroll
@onready var hand_info: RichTextLabel = %HandInfo

var hand_list_expanded: bool = false
var current_mode: String = "battle"


func _ready() -> void:
	hand_list_toggle.pressed.connect(_toggle_hand_list)
	_reset_numeric_display()


func refresh_run(run: RunState, mode: String = "battle") -> void:
	current_mode = mode
	var blind_id := str(run.current_blind.get("id", "small_blind"))
	blind_token.texture = ArtResolver.resolve_texture("blind", blind_id)
	money_label.text = "$%s" % _format_score(run.money)
	ante_label.text = "%d / 8" % run.ante
	deck_label.text = _deck_summary(run, mode)
	var tag: Dictionary = run.current_skip_tag() if mode == "stage" else _first_pending_tag(run)
	tag_label.text = "标签：%s" % str(tag.get("name_cn", "无"))
	consumables_label.text = "消耗牌 %d/%d" % [run.consumables.size(), run.consumable_slots]
	hand_info.text = _hand_info_text(run)
	_apply_mode_visibility(mode)
	match mode:
		"stage":
			_refresh_stage_mode(run)
		"shop":
			_refresh_shop_mode(run)
		"settlement":
			_refresh_settlement_mode(run)
		_:
			_refresh_battle_mode(run)


func _apply_mode_visibility(mode: String) -> void:
	ante_box.visible = false
	blind_box.visible = true
	counts_grid.visible = true
	hand_box.visible = true
	# The ornamental HUD art contains fixed slots, so every mode fills those
	# slots with phase-relevant data instead of leaving battle-shaped holes.
	target_panel.visible = true
	score_box.visible = true
	equation_box.visible = true
	hand_list_toggle.disabled = mode != "battle"
	if mode != "battle" and hand_list_expanded:
		hand_list_expanded = false
		hand_list_toggle.set_pressed_no_signal(false)
		hand_info_scroll.visible = false


func _refresh_stage_mode(run: RunState) -> void:
	title_label.text = "选择盲注"
	round_caption.text = "底注"
	round_value_label.text = "%d / 8" % run.ante
	target_caption.text = "下一目标"
	target_label.text = _format_score(run.target_preview_for_stage(run.blind_index))
	set_hand_preview("当前进度", "0 x 0", _blind_display_name(run))
	hands_title.text = "出牌"
	discards_title.text = "弃牌"
	hands_label.text = str(run.base_hands)
	discards_label.text = str(run.base_discards)
	blind_caption.text = "盲注"
	blind_step_label.text = "%d / 3" % (run.blind_index + 1)
	target_coin.visible = true
	current_score_chip.visible = true
	score_caption.text = "当前\n分数"
	score_label.text = _format_score(run.current_score)
	_set_mode_equation(str(run.base_hands), "·", str(run.base_discards))
	desc_label.text = "依次选择盲注"


func _refresh_battle_mode(run: RunState) -> void:
	target_coin.visible = true
	current_score_chip.visible = true
	title_label.text = _blind_display_name(run)
	round_caption.text = "底注"
	round_value_label.text = "%d / 8" % run.ante
	target_caption.text = "目标\n分数"
	target_label.text = _format_score(run.target_score)
	score_caption.text = "当前\n分数"
	score_label.text = _format_score(run.current_score)
	hands_title.text = "出牌"
	discards_title.text = "弃牌"
	hands_label.text = str(run.hands_left)
	discards_label.text = str(run.discards_left)
	blind_caption.text = "盲注"
	blind_step_label.text = "%d / 3" % (run.blind_index + 1)
	desc_label.text = _blind_description(run)


func _refresh_shop_mode(run: RunState) -> void:
	title_label.text = "商店整备"
	round_caption.text = "下一盲注"
	round_value_label.text = "%d / 3" % mini(run.blind_index + 2, 3)
	set_hand_preview(
		"可出售小丑牌",
		"0 x 0",
		"槽位 %d / %d" % [run.jokers.size(), run.joker_slots]
	)
	hands_title.text = "小丑牌"
	discards_title.text = "消耗牌"
	hands_label.text = "%d/%d" % [run.jokers.size(), run.joker_slots]
	discards_label.text = "%d/%d" % [run.consumables.size(), run.consumable_slots]
	blind_caption.text = "刷新"
	blind_step_label.text = "$%d" % run.reroll_cost
	target_coin.visible = false
	current_score_chip.visible = false
	target_caption.text = "商店\n资金"
	target_label.text = "$%s" % _format_score(run.money)
	score_caption.text = "刷新\n费用"
	score_label.text = "$%d" % run.reroll_cost
	_set_mode_equation(str(run.shop_items.size()), "+", str(run.shop_pack_items.size()))
	desc_label.text = "购买、出售与整备"


func _refresh_settlement_mode(run: RunState) -> void:
	var settlement := run.settlement
	var claimed := bool(settlement.get("claimed", false))
	target_coin.visible = true
	current_score_chip.visible = true
	title_label.text = "回合结算"
	round_caption.text = "完成盲注"
	round_value_label.text = str(settlement.get("stage_name", _blind_display_name(run)))
	target_caption.text = "目标\n分数"
	target_label.text = _format_score(int(settlement.get("target", run.target_score)))
	score_caption.text = "最终\n分数"
	score_label.text = _format_score(int(settlement.get("score", run.current_score)))
	set_hand_preview(
		"本回合收入",
		"0 x 0",
		"+$%s" % _format_score(int(settlement.get("total", 0)))
	)
	hands_title.text = "出牌奖励"
	discards_title.text = "标签奖励"
	hands_label.text = "$%d" % int(settlement.get("hand_bonus", 0))
	discards_label.text = "$%d" % int(settlement.get("tag_bonus", 0))
	blind_caption.text = "结算"
	blind_step_label.text = "已领取" if claimed else "待领取"
	desc_label.text = "奖励已结算" if claimed else "奖励等待领取"
	_set_mode_equation(
		"$%d" % int(settlement.get("hand_bonus", 0)),
		"+",
		"$%d" % int(settlement.get("tag_bonus", 0))
	)


func _reset_numeric_display() -> void:
	round_value_label.text = "0 / 0"
	target_label.text = "0"
	score_label.text = "0"
	chips_value_label.text = "0"
	mult_value_label.text = "0"
	hands_label.text = "0"
	discards_label.text = "0"
	money_label.text = "$0"
	ante_label.text = "0 / 0"
	blind_step_label.text = "0 / 0"
	current_hand_label.text = "选择手牌"
	preview_score_label.text = "等待选择手牌"


func set_hand_preview(hand_text: String, equation_text: String, preview_text: String) -> void:
	current_hand_label.text = hand_text
	_set_equation_text(equation_text)
	preview_score_label.text = preview_text


func _set_equation_text(equation_text: String) -> void:
	var normalized := equation_text.replace("×", "x")
	var parts := normalized.split("x", false, 1)
	chips_value_label.text = parts[0].strip_edges() if not parts.is_empty() else "0"
	mult_value_label.text = parts[1].strip_edges() if parts.size() > 1 else "0"
	times_label.text = "×"


func _set_mode_equation(left: String, separator: String, right: String) -> void:
	chips_value_label.text = left
	times_label.text = separator
	mult_value_label.text = right


func _blind_display_name(run: RunState) -> String:
	match run.blind_index:
		0:
			return "小盲注"
		1:
			return "大盲注"
		_:
			var boss_name := str(run.current_boss_data().get("name_cn", "首领盲注"))
			return boss_name if not boss_name.is_empty() else "首领盲注"


func _blind_description(run: RunState) -> String:
	if run.blind_index == 2:
		var boss := run.current_boss_rule()
		if not boss.is_empty() and str(boss.get("rule", "none")) != "none":
			return str(boss.get("description_cn", "首领特殊规则"))
	return str(run.current_blind.get("description_cn", "基础规则"))


func _deck_summary(run: RunState, mode: String) -> String:
	match mode:
		"battle":
			return "牌库 %d / 弃牌堆 %d" % [run.deck.size(), run.discard_pile.size()]
		"settlement":
			return "本回合 %s / %s" % [
				_format_score(int(run.settlement.get("score", run.current_score))),
				_format_score(int(run.settlement.get("target", run.target_score))),
			]
		"shop":
			return "小丑 %d/%d · 牌库 %d" % [run.jokers.size(), run.joker_slots, run.full_deck.size()]
		_:
			return "牌库 %d" % run.full_deck.size()


func _first_pending_tag(run: RunState) -> Dictionary:
	if run.pending_tags.is_empty():
		return {}
	return run.pending_tags[0] as Dictionary


func _format_score(value: int) -> String:
	var digits := str(abs(value))
	var grouped := ""
	while digits.length() > 3:
		grouped = ",%s%s" % [digits.right(3), grouped]
		digits = digits.left(digits.length() - 3)
	grouped = digits + grouped
	return "-%s" % grouped if value < 0 else grouped


func _toggle_hand_list() -> void:
	hand_list_expanded = hand_list_toggle.button_pressed
	hand_info_scroll.visible = hand_list_expanded
	hand_list_toggle.text = "关闭\n信息" if hand_list_expanded else "比赛\n信息"


func _hand_info_text(run: RunState) -> String:
	var lines: Array[String] = ["[b]牌型等级[/b]"]
	for raw_hand in DataRegistry.get_table("poker_hands"):
		var hand: Dictionary = raw_hand
		var hand_id := str(hand.get("id", ""))
		lines.append(
			"%s Lv.%d  %d筹码 × %d倍率" % [
				str(hand.get("name_cn", "")),
				int(run.hand_levels.get(hand_id, 1)),
				int(hand.get("base_chips", 0)),
				int(hand.get("base_mult", 0)),
			]
		)
	return "\n".join(lines)
