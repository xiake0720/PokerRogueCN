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
	style.bg_color = Color(0.12, 0.15, 0.18, 0.92)
	style.border_color = Color(0.44, 0.52, 0.62)
	style.set_border_width_all(3)
	style.set_corner_radius_all(18)
	style.content_margin_left = 42
	style.content_margin_top = 42
	style.content_margin_right = 42
	style.content_margin_bottom = 42
	return style
