class_name GameHudPanel
extends PanelContainer

@onready var title_label: Label = %TitleLabel
@onready var blind_token: TextureRect = %BlindToken
@onready var desc_label: Label = %DescLabel
@onready var target_label: Label = %TargetLabel
@onready var round_value_label: Label = %RoundValueLabel
@onready var score_box: Control = %ScoreBox
@onready var score_label: Label = %ScoreLabel
@onready var hand_box: Control = %HandBox
@onready var current_hand_label: Label = %CurrentHandLabel
@onready var chips_value_label: Label = %ChipsValueLabel
@onready var mult_value_label: Label = %MultValueLabel
@onready var preview_score_label: Label = %PreviewScoreLabel
@onready var hands_label: Label = %HandsLabel
@onready var discards_label: Label = %DiscardsLabel
@onready var money_label: Label = %MoneyLabel
@onready var ante_label: Label = %AnteLabel
@onready var blind_step_label: Label = %BlindStepLabel
@onready var deck_label: Label = %DeckLabel
@onready var tag_label: Label = %TagLabel
@onready var consumables_label: Label = %ConsumablesLabel
@onready var hand_list_toggle: Button = %HandListToggle
@onready var hand_info_scroll: ScrollContainer = %HandInfoScroll
@onready var hand_info: RichTextLabel = %HandInfo

var hand_list_expanded: bool = false


func _ready() -> void:
	hand_list_toggle.pressed.connect(_toggle_hand_list)
	_reset_numeric_display()


func refresh_run(run: RunState, mode: String = "battle") -> void:
	var blind_id: String = str(run.current_blind.get("id", "small_blind"))
	title_label.text = _hud_title(run, mode)
	blind_token.texture = ArtResolver.resolve_texture("blind", blind_id)
	target_label.text = _format_score(run.target_preview_for_stage(run.blind_index)) if mode == "stage" else _format_score(run.target_score)
	round_value_label.text = "%d / 8" % run.ante
	desc_label.text = _blind_description(run, mode)
	score_label.text = _format_score(run.current_score)
	match mode:
		"battle":
			hands_label.text = str(run.hands_left)
			discards_label.text = str(run.discards_left)
		"settlement":
			hands_label.text = str(run.settlement.get("hand_bonus", 0))
			discards_label.text = "0"
		_:
			hands_label.text = str(run.base_hands)
			discards_label.text = str(run.base_discards)
	money_label.text = "$%s" % _format_score(run.money)
	ante_label.text = "%d / 8" % run.ante
	blind_step_label.text = "%d / 3" % (run.blind_index + 1)
	match mode:
		"battle":
			deck_label.text = "牌库 %d / 弃牌堆 %d" % [run.deck.size(), run.discard_pile.size()]
		"settlement":
			deck_label.text = "本回合 %s / %s" % [
				_format_score(int(run.settlement.get("score", run.current_score))),
				_format_score(int(run.settlement.get("target", run.target_score))),
			]
		"shop":
			deck_label.text = "小丑 %d/%d · 牌库 %d" % [run.jokers.size(), run.joker_slots, run.full_deck.size()]
		_:
			deck_label.text = "牌库 %d / %d" % [run.full_deck.size(), run.full_deck.size()]
	var tag: Dictionary = run.current_skip_tag() if mode == "stage" else _first_pending_tag(run)
	tag_label.text = "标签：%s" % str(tag.get("name_cn", "无"))
	consumables_label.text = "消耗牌 %d/%d" % [run.consumables.size(), run.consumable_slots]
	if mode != "battle":
		set_hand_preview(
			"高牌  等级%d" % int(run.hand_levels.get("high_card", 1)),
			"5 × 1",
			"默认基础牌型"
		)
	hand_info.text = _hand_info_text(run)
	if mode == "stage":
		set_hand_preview("选择盲注", "0 x 0", "等待选择盲注")


func _hud_title(run: RunState, mode: String) -> String:
	match mode:
		"stage":
			return "当前盲注"
		"shop":
			return "当前状态"
		"settlement":
			return "当前下注"
		_:
			return _blind_display_name(run)


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
	var normalized: String = equation_text.replace("×", "x")
	var parts: PackedStringArray = normalized.split("x", false, 1)
	chips_value_label.text = parts[0].strip_edges() if not parts.is_empty() else "0"
	mult_value_label.text = parts[1].strip_edges() if parts.size() > 1 else "0"


func _blind_display_name(run: RunState) -> String:
	match run.blind_index:
		0:
			return "小盲注"
		1:
			return "大盲注"
		_:
			var boss_name: String = str(run.current_boss_data().get("name_cn", "首领盲注"))
			return boss_name if not boss_name.is_empty() else "首领盲注"


func _blind_description(run: RunState, mode: String) -> String:
	if run.blind_index == 2:
		var boss: Dictionary = run.current_boss_rule()
		if not boss.is_empty() and str(boss.get("rule", "none")) != "none":
			return str(boss.get("description_cn", "首领特殊规则"))
	if mode == "shop":
		return "商店 · 底注%d" % run.ante
	return str(run.current_blind.get("description_cn", "基础规则"))


func _first_pending_tag(run: RunState) -> Dictionary:
	if run.pending_tags.is_empty():
		return {}
	return run.pending_tags[0] as Dictionary


func _format_score(value: int) -> String:
	var digits: String = str(abs(value))
	var grouped: String = ""
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
		var hand_id: String = str(hand.get("id", ""))
		lines.append(
			"%s Lv.%d  %d筹码 × %d倍率" % [
				str(hand.get("name_cn", "")),
				int(run.hand_levels.get(hand_id, 1)),
				int(hand.get("base_chips", 0)),
				int(hand.get("base_mult", 0)),
			]
		)
	return "\n".join(lines)
