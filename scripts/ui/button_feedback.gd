class_name ButtonFeedback
extends Button

@export_range(1.0, 1.08, 0.005) var hover_scale: float = 1.025
@export_range(0.9, 1.0, 0.005) var pressed_scale: float = 0.98
@export_range(0.03, 0.2, 0.01) var hover_duration: float = 0.1
@export_range(0.03, 0.15, 0.01) var press_duration: float = 0.06
@export var play_hover_sound: bool = true

var _rest_scale: Vector2
var _feedback_tween: Tween


func _ready() -> void:
	_rest_scale = scale
	_update_pivot.call_deferred()
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)
	resized.connect(_update_pivot)
	tree_exiting.connect(_stop_feedback)


func _update_pivot() -> void:
	pivot_offset = size * 0.5


func _on_mouse_entered() -> void:
	if disabled:
		return
	_animate_scale(_rest_scale * hover_scale, hover_duration)
	if play_hover_sound and AudioManager.SFX.has("ui_hover_tick"):
		AudioManager.play_sfx("ui_hover_tick", -5.0, 1.02)


func _on_mouse_exited() -> void:
	_animate_scale(_rest_scale, hover_duration)


func _on_button_down() -> void:
	if disabled:
		return
	_animate_scale(_rest_scale * pressed_scale, press_duration)


func _on_button_up() -> void:
	if disabled:
		_animate_scale(_rest_scale, hover_duration)
		return
	var target := _rest_scale * hover_scale if is_hovered() else _rest_scale
	_animate_scale(target, hover_duration)


func _on_focus_entered() -> void:
	if not disabled:
		_animate_scale(_rest_scale * hover_scale, hover_duration)


func _on_focus_exited() -> void:
	if not is_hovered():
		_animate_scale(_rest_scale, hover_duration)


func _animate_scale(target: Vector2, duration: float) -> void:
	_stop_feedback()
	if not is_inside_tree():
		scale = target
		return
	_feedback_tween = create_tween()
	_feedback_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_feedback_tween.tween_property(self, "scale", target, duration)


func _stop_feedback() -> void:
	if _feedback_tween != null and _feedback_tween.is_valid():
		_feedback_tween.kill()
	_feedback_tween = null
