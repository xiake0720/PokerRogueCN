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
	for button: Button in [start_button, options_button, quit_button, language_button]:
		button.mouse_entered.connect(_animate_button.bind(button, true))
		button.mouse_exited.connect(_animate_button.bind(button, false))
		button.focus_entered.connect(_animate_button.bind(button, true))
		button.focus_exited.connect(_animate_button.bind(button, false))
		button.pressed.connect(func(): AudioManager.play_sfx("ui_click"))
	call_deferred("_initialize_button_pivots")
	_animate_sparkles()

func refresh() -> void:
	pass

func _initialize_button_pivots() -> void:
	for button: Button in [start_button, options_button, quit_button, language_button]:
		button.pivot_offset = button.size * 0.5

func _animate_button(button: Button, highlighted: bool) -> void:
	var tween: Tween = create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_BACK if highlighted else Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", Vector2(1.025, 1.025) if highlighted else Vector2.ONE, 0.12)
	tween.tween_property(button, "modulate", Color(1.08, 1.08, 1.04, 1.0) if highlighted else Color.WHITE, 0.12)

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
