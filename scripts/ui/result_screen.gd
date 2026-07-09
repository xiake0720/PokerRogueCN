extends Control

@onready var title_label: Label = $Center/Panel/VBox/TitleLabel
@onready var desc_label: Label = $Center/Panel/VBox/DescLabel
@onready var home_button: Button = $Center/Panel/VBox/ButtonRow/HomeButton
@onready var endless_button: Button = $Center/Panel/VBox/ButtonRow/EndlessButton

func _ready() -> void:
	home_button.pressed.connect(func(): Game.run.show_home())
	endless_button.pressed.connect(func(): Game.run.continue_endless())
	refresh()

func refresh() -> void:
	if Game.run.phase == RunState.Phase.VICTORY:
		title_label.text = "通关成功"
		desc_label.text = "第8底注已经通过，可以进入无尽模式继续挑战。"
		endless_button.visible = true
	else:
		title_label.text = "本局失败"
		desc_label.text = "出牌次数已经用完，未达到目标分。"
		endless_button.visible = false
