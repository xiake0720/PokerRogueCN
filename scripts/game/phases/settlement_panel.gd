class_name SettlementPanel
extends Control

@onready var stage_name_label: Label = %StageNameLabel
@onready var score_label: Label = %ScoreLabel
@onready var total_row: HBoxContainer = %TotalRow
@onready var stage_name_row: HBoxContainer = %StageNameRow
@onready var score_row: HBoxContainer = %ScoreRow
@onready var reward_row: HBoxContainer = %RewardRow
@onready var hand_bonus_row: HBoxContainer = %HandBonusRow
@onready var interest_row: HBoxContainer = %InterestRow
@onready var tag_reward_row: HBoxContainer = %TagRewardRow
@onready var voucher_bonus_row: HBoxContainer = %VoucherBonusRow
@onready var other_bonus_row: HBoxContainer = %OtherBonusRow
@onready var cashout_label: Label = %CashoutLabel
@onready var base_income_value: Label = %BaseIncomeValue
@onready var bonus_income_value: Label = %BonusIncomeValue
@onready var money_before_value: Label = %MoneyBeforeValue
@onready var money_after_value: Label = %MoneyAfterValue
@onready var claim_button: Button = %ClaimButton

var _presentation_tween: Tween = null
var _presentation_signature: String = ""
var _presentation_complete: bool = false
var _presentation_claimed: bool = false


func _ready() -> void:
	claim_button.pressed.connect(_claim_and_continue)
	claim_button.disabled = true


func refresh_run(run: RunState) -> void:
	var settlement: Dictionary = run.settlement
	var total := int(settlement.get("total", 0))
	var reward := int(settlement.get("reward", 0))
	var hand_bonus := int(settlement.get("hand_bonus", 0))
	var interest := int(settlement.get("interest", 0))
	var tag_bonus := int(settlement.get("tag_bonus", 0))
	var stage_name := str(settlement.get("stage_name", "盲注"))
	var score := int(settlement.get("score", 0))
	var target := int(settlement.get("target", 0))
	var claimed := bool(settlement.get("claimed", false))
	var money_after := run.money if claimed else run.money + total
	var money_before := run.money - total if claimed else run.money
	stage_name_label.text = stage_name
	score_label.text = "%d / %d" % [score, target]
	_set_row(total_row, "总收入", "+$%d" % total)
	_set_row(stage_name_row, "完成盲注", stage_name)
	_set_row(score_row, "本关分数", "%d / %d" % [score, target])
	_set_row(reward_row, "基础奖励", "+$%d" % reward)
	_set_row(hand_bonus_row, "剩余出牌奖励", "+$%d" % hand_bonus)
	_set_row(interest_row, "利息奖励", "+$%d" % interest)
	tag_reward_row.visible = tag_bonus > 0
	_set_row(tag_reward_row, "标签奖励", "+$%d" % tag_bonus)
	var voucher_bonus := int(settlement.get("voucher_bonus", 0))
	voucher_bonus_row.visible = voucher_bonus > 0
	_set_row(voucher_bonus_row, "优惠券奖励", "+$%d" % voucher_bonus)
	var other_bonus := int(settlement.get("other_bonus", 0))
	other_bonus_row.visible = other_bonus > 0
	_set_row(other_bonus_row, "其他奖励", "+$%d" % other_bonus)
	var signature := "%s|%d|%d|%d|%d|%s" % [stage_name, total, reward, money_before, money_after, claimed]
	if signature != _presentation_signature:
		_presentation_signature = signature
		_play_presentation(total, reward, total - reward, money_before, money_after, claimed)
	else:
		claim_button.disabled = claimed or not _presentation_complete


func _play_presentation(
	total: int,
	reward: int,
	bonus: int,
	money_before: int,
	money_after: int,
	claimed: bool
) -> void:
	_kill_presentation_tween()
	_presentation_complete = false
	_presentation_claimed = claimed
	claim_button.disabled = true
	cashout_label.pivot_offset = cashout_label.size * 0.5
	money_after_value.pivot_offset = money_after_value.size * 0.5
	cashout_label.scale = Vector2(0.96, 0.96)
	money_after_value.scale = Vector2.ONE
	money_after_value.modulate = Color(0.82, 0.82, 0.72, 1.0)
	_set_cashout_display(0.0)
	_set_base_income_display(0.0)
	_set_bonus_income_display(0.0)
	money_before_value.text = "$%d" % money_before
	_set_money_after_display(float(money_before))
	_presentation_tween = create_tween()
	_presentation_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_presentation_tween.tween_interval(0.1)
	_presentation_tween.tween_method(_set_cashout_display, 0.0, float(total), 0.52)
	_presentation_tween.parallel().tween_property(cashout_label, "scale", Vector2(1.06, 1.06), 0.3)
	_presentation_tween.tween_property(cashout_label, "scale", Vector2.ONE, 0.14)
	_presentation_tween.tween_method(_set_base_income_display, 0.0, float(reward), 0.24)
	_presentation_tween.parallel().tween_method(_set_bonus_income_display, 0.0, float(bonus), 0.24)
	_presentation_tween.tween_method(_set_money_after_display, float(money_before), float(money_after), 0.46)
	_presentation_tween.parallel().tween_property(money_after_value, "modulate", Color(1.0, 0.82, 0.32, 1.0), 0.3)
	_presentation_tween.parallel().tween_property(money_after_value, "scale", Vector2(1.12, 1.12), 0.28)
	_presentation_tween.tween_property(money_after_value, "scale", Vector2.ONE, 0.14)
	_presentation_tween.finished.connect(_on_presentation_finished, CONNECT_ONE_SHOT)


func _set_cashout_display(value: float) -> void:
	cashout_label.text = "+$%d" % roundi(value)


func _set_base_income_display(value: float) -> void:
	base_income_value.text = "$%d" % roundi(value)


func _set_bonus_income_display(value: float) -> void:
	bonus_income_value.text = "$%d" % roundi(value)


func _set_money_after_display(value: float) -> void:
	money_after_value.text = "$%d" % roundi(value)


func _on_presentation_finished() -> void:
	_presentation_tween = null
	_presentation_complete = true
	claim_button.disabled = _presentation_claimed


func _set_row(row: HBoxContainer, title: String, value: String) -> void:
	(row.get_node("LeftLabel") as Label).text = title
	(row.get_node("RightLabel") as Label).text = value


func _claim_and_continue() -> void:
	if claim_button.disabled or not _presentation_complete:
		return
	claim_button.disabled = true
	AudioManager.play_sfx("ui_click")
	Game.run.claim_settlement()


func _kill_presentation_tween() -> void:
	if _presentation_tween != null and _presentation_tween.is_valid():
		_presentation_tween.kill()
	_presentation_tween = null


func _exit_tree() -> void:
	_kill_presentation_tween()
