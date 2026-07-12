extends Control

@onready var hud: GameHudPanel = %HUD
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

func _ready() -> void:
	claim_button.pressed.connect(_claim_and_continue)
	refresh()

func refresh() -> void:
	var run: RunState = Game.run
	var settlement: Dictionary = run.settlement
	hud.refresh_run(run, "settlement")
	var total: int = int(settlement.get("total", 0))
	var reward: int = int(settlement.get("reward", 0))
	var hand_bonus: int = int(settlement.get("hand_bonus", 0))
	var interest: int = int(settlement.get("interest", 0))
	var tag_bonus: int = int(settlement.get("tag_bonus", 0))
	var stage_name: String = str(settlement.get("stage_name", "盲注"))
	var score: int = int(settlement.get("score", 0))
	var target: int = int(settlement.get("target", 0))
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
	voucher_bonus_row.visible = int(settlement.get("voucher_bonus", 0)) > 0
	_set_row(voucher_bonus_row, "优惠券奖励", "+$%d" % int(settlement.get("voucher_bonus", 0)))
	other_bonus_row.visible = int(settlement.get("other_bonus", 0)) > 0
	_set_row(other_bonus_row, "其他奖励", "+$%d" % int(settlement.get("other_bonus", 0)))
	cashout_label.text = "+$%d" % total
	base_income_value.text = "$%d" % reward
	bonus_income_value.text = "$%d" % (total - reward)
	money_before_value.text = "$%d" % run.money
	money_after_value.text = "$%d" % (run.money + total)
	claim_button.disabled = bool(settlement.get("claimed", false))

func _set_row(row: HBoxContainer, title: String, value: String) -> void:
	var left_label: Label = row.get_node("LeftLabel") as Label
	var right_label: Label = row.get_node("RightLabel") as Label
	left_label.text = title
	right_label.text = value

func _claim_and_continue() -> void:
	if claim_button.disabled:
		return
	claim_button.disabled = true
	AudioManager.play_sfx("ui_click")
	Game.run.claim_settlement()
