extends Control

@onready var start_button: Button = $Center/Panel/VBox/ButtonRow/StartButton
@onready var options_button: Button = $Center/Panel/VBox/ButtonRow/OptionsButton
@onready var quit_button: Button = $Center/Panel/VBox/ButtonRow/QuitButton

func _ready() -> void:
	start_button.pressed.connect(func(): Game.run.show_deck_select())
	options_button.pressed.connect(func(): Game.run.add_message("选项界面后续接入。"))
	quit_button.pressed.connect(func(): get_tree().quit())

func refresh() -> void:
	pass
