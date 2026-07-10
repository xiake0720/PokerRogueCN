extends Control

@onready var start_button: Button = $MenuColumn/StartButton
@onready var options_button: Button = $MenuColumn/OptionsButton
@onready var quit_button: Button = $MenuColumn/QuitButton
@onready var language_button: Button = $MenuColumn/LanguageButton
@onready var sparkle_layer: Control = $TitleGroup/SparkleLayer

func _ready() -> void:
	start_button.pressed.connect(func(): Game.run.show_deck_select())
	options_button.pressed.connect(func(): Game.run.add_message("设置界面后续接入。"))
	quit_button.pressed.connect(func(): get_tree().quit())
	language_button.pressed.connect(func(): Game.run.add_message("语言切换后续接入。"))
	_animate_sparkles()

func refresh() -> void:
	pass

func _animate_sparkles() -> void:
	for i in range(sparkle_layer.get_child_count()):
		var sparkle: Control = sparkle_layer.get_child(i) as Control
		if sparkle == null:
			continue
		sparkle.pivot_offset = sparkle.size * 0.5
		sparkle.modulate.a = 0.25 + 0.12 * float(i % 3)
		var tween: Tween = create_tween()
		tween.set_loops()
		tween.tween_interval(float(i) * 0.18)
		tween.tween_property(sparkle, "modulate:a", 1.0, 0.42)
		tween.parallel().tween_property(sparkle, "scale", Vector2(1.32, 1.32), 0.42)
		tween.tween_property(sparkle, "modulate:a", 0.25, 0.58)
		tween.parallel().tween_property(sparkle, "scale", Vector2.ONE, 0.58)
