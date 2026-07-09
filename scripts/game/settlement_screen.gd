extends Control

@onready var total_left_label: Label = $Center/Panel/VBox/Lines/TotalRow/LeftLabel
@onready var total_right_label: Label = $Center/Panel/VBox/Lines/TotalRow/RightLabel
@onready var stage_name_right_label: Label = $Center/Panel/VBox/Lines/StageNameRow/RightLabel
@onready var score_right_label: Label = $Center/Panel/VBox/Lines/ScoreRow/RightLabel
@onready var reward_right_label: Label = $Center/Panel/VBox/Lines/RewardRow/RightLabel
@onready var hand_bonus_right_label: Label = $Center/Panel/VBox/Lines/HandBonusRow/RightLabel
@onready var interest_right_label: Label = $Center/Panel/VBox/Lines/InterestRow/RightLabel
@onready var claim_button: Button = $Center/Panel/VBox/ClaimButton

func _ready() -> void:
	claim_button.pressed.connect(func(): Game.run.claim_settlement())
	refresh()

func refresh() -> void:
	var settlement: Dictionary = Game.run.settlement
	total_left_label.text = "提现"
	total_right_label.text = "$%d" % settlement.get("total", 0)
	stage_name_right_label.text = str(settlement.get("stage_name", ""))
	score_right_label.text = "%d / %d" % [settlement.get("score", 0), settlement.get("target", 0)]
	reward_right_label.text = "$%d" % settlement.get("reward", 0)
	hand_bonus_right_label.text = "$%d" % settlement.get("hand_bonus", 0)
	interest_right_label.text = "$%d" % settlement.get("interest", 0)
