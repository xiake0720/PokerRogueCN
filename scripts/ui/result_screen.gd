extends Control

@onready var panel: PanelContainer = $Center/Panel
@onready var title_label: Label = $Center/Panel/VBox/TitleLabel
@onready var desc_label: Label = $Center/Panel/VBox/DescLabel
@onready var home_button: Button = $Center/Panel/VBox/ButtonRow/HomeButton
@onready var endless_button: Button = $Center/Panel/VBox/ButtonRow/EndlessButton

func _ready() -> void:
	panel.add_theme_stylebox_override("panel", _panel_style())
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

func _panel_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.15, 0.18, 0.96)
	style.border_color = Color(0.48, 0.56, 0.68)
	style.set_border_width_all(3)
	style.set_corner_radius_all(18)
	style.content_margin_left = 42
	style.content_margin_top = 36
	style.content_margin_right = 42
	style.content_margin_bottom = 36
	return style
