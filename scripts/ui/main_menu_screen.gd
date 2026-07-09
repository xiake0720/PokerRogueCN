extends Control

@onready var start_button: Button = $Center/Panel/VBox/ButtonRow/StartButton
@onready var options_button: Button = $Center/Panel/VBox/ButtonRow/OptionsButton
@onready var quit_button: Button = $Center/Panel/VBox/ButtonRow/QuitButton
@onready var panel: PanelContainer = $Center/Panel

func _ready() -> void:
	panel.add_theme_stylebox_override("panel", _panel_style())
	start_button.pressed.connect(func(): Game.run.show_deck_select())
	options_button.pressed.connect(func(): Game.run.add_message("选项界面后续接入。"))
	quit_button.pressed.connect(func(): get_tree().quit())

func refresh() -> void:
	pass

func _panel_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.055, 0.10, 0.09, 0.92)
	style.border_color = Color(0.78, 0.32, 0.18, 1)
	style.set_border_width_all(4)
	style.set_corner_radius_all(12)
	style.content_margin_left = 28
	style.content_margin_top = 28
	style.content_margin_right = 28
	style.content_margin_bottom = 28
	return style
