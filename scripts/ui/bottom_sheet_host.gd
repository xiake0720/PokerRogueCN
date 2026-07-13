class_name BottomSheetHost
extends Control

@export var modal_dim_path: NodePath
@export_range(0.12, 0.28, 0.01) var dim_alpha: float = 0.2
@export_range(0.22, 0.32, 0.01) var show_duration: float = 0.28
@export_range(0.18, 0.26, 0.01) var hide_duration: float = 0.22

var current_panel: Control = null
var pending_panel: Control = null
var is_transitioning: bool = false
var _active_tween: Tween = null
var _rest_positions: Dictionary = {}

@onready var modal_dim: ColorRect = get_node_or_null(modal_dim_path) as ColorRect


func _ready() -> void:
	for child: Node in get_children():
		if child is Control:
			var panel: Control = child as Control
			_rest_positions[panel] = panel.position
			panel.visible = false
			panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if modal_dim != null:
		modal_dim.visible = false
		modal_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE


func show_panel(panel: Control, options: Dictionary = {}) -> void:
	if panel == null:
		return
	if current_panel == panel and panel.visible and not is_transitioning:
		return
	_start_show(panel, bool(options.get("immediate", false)))


func hide_current_panel(immediate: bool = false) -> void:
	if current_panel == null:
		_set_dim_visible(false)
		return
	_kill_active_tween()
	var panel: Control = current_panel
	if immediate:
		_finish_hide(panel)
		return
	is_transitioning = true
	var rest: Vector2 = _rest_position(panel)
	_active_tween = create_tween()
	_active_tween.set_trans(Tween.TRANS_QUAD)
	_active_tween.set_ease(Tween.EASE_IN)
	_active_tween.tween_property(panel, "position:y", rest.y + _travel_distance(panel), hide_duration)
	_active_tween.parallel().tween_property(panel, "modulate:a", 0.85, hide_duration)
	_active_tween.finished.connect(_finish_hide.bind(panel), CONNECT_ONE_SHOT)


func replace_panel(panel: Control, options: Dictionary = {}) -> void:
	if current_panel != null and current_panel != panel:
		_hide_immediately(current_panel)
	_start_show(panel, bool(options.get("immediate", false)))


func _start_show(panel: Control, immediate: bool) -> void:
	_kill_active_tween()
	if current_panel != null and current_panel != panel:
		_hide_immediately(current_panel)
	current_panel = panel
	pending_panel = null
	var rest: Vector2 = _rest_position(panel)
	panel.visible = true
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_set_dim_visible(true)
	if immediate:
		panel.position = rest
		panel.modulate.a = 1.0
		is_transitioning = false
		return
	is_transitioning = true
	panel.position = Vector2(rest.x, rest.y + _travel_distance(panel))
	panel.modulate.a = 0.85
	_active_tween = create_tween()
	_active_tween.set_trans(Tween.TRANS_CUBIC)
	_active_tween.set_ease(Tween.EASE_OUT)
	_active_tween.tween_property(panel, "position", rest, show_duration)
	_active_tween.parallel().tween_property(panel, "modulate:a", 1.0, show_duration)
	_active_tween.finished.connect(_finish_show.bind(panel), CONNECT_ONE_SHOT)


func _finish_show(panel: Control) -> void:
	if not is_instance_valid(panel) or current_panel != panel:
		return
	panel.position = _rest_position(panel)
	panel.modulate.a = 1.0
	is_transitioning = false
	_active_tween = null


func _finish_hide(panel: Control) -> void:
	if is_instance_valid(panel):
		_hide_immediately(panel)
	if current_panel == panel:
		current_panel = null
	is_transitioning = false
	_active_tween = null
	_set_dim_visible(false)


func _hide_immediately(panel: Control) -> void:
	panel.visible = false
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.position = _rest_position(panel)
	panel.modulate.a = 1.0


func _rest_position(panel: Control) -> Vector2:
	if not _rest_positions.has(panel):
		_rest_positions[panel] = panel.position
	return _rest_positions[panel] as Vector2


func _travel_distance(panel: Control) -> float:
	return maxf(size.y, panel.size.y) + 64.0


func _set_dim_visible(show: bool) -> void:
	if modal_dim == null:
		return
	modal_dim.visible = show
	modal_dim.color.a = dim_alpha
	modal_dim.mouse_filter = Control.MOUSE_FILTER_STOP if show else Control.MOUSE_FILTER_IGNORE


func _kill_active_tween() -> void:
	if _active_tween != null and _active_tween.is_valid():
		_active_tween.kill()
	_active_tween = null
	is_transitioning = false


func _exit_tree() -> void:
	_kill_active_tween()
