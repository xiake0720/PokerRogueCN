class_name BottomSheetHost
extends Control

signal transition_started
signal transition_finished
signal panel_shown(panel: Control)
signal panel_hidden(panel: Control)

@export var modal_dim_path: NodePath
@export_range(0.12, 0.28, 0.01) var dim_alpha: float = 0.2
@export_range(0.22, 0.32, 0.01) var show_duration: float = 0.28
@export_range(0.18, 0.26, 0.01) var hide_duration: float = 0.22

var current_panel: Control = null
var pending_panel: Control = null
var is_transitioning: bool = false
var _active_tween: Tween = null
var _rest_positions: Dictionary = {}
var _pending_immediate: bool = false
var _pending_hide: bool = false

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
	var immediate := bool(options.get("immediate", false))
	if is_transitioning:
		pending_panel = panel
		_pending_immediate = immediate
		_pending_hide = false
		return
	if current_panel == panel and panel.visible:
		_normalize_visible_panel(panel)
		return
	if current_panel != null and current_panel != panel:
		replace_panel(panel, options)
		return
	_begin_transition()
	_start_show(panel, immediate)


func hide_current_panel(immediate: bool = false) -> void:
	if is_transitioning:
		pending_panel = null
		_pending_immediate = immediate
		_pending_hide = true
		return
	if current_panel == null:
		_set_dim_visible(false)
		return
	var panel: Control = current_panel
	_begin_transition()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if immediate:
		_complete_hide(panel, false)
		_end_transition()
		return
	var rest: Vector2 = _rest_position(panel)
	_active_tween = create_tween()
	_active_tween.set_trans(Tween.TRANS_QUAD)
	_active_tween.set_ease(Tween.EASE_IN)
	_active_tween.tween_property(panel, "position:y", rest.y + _travel_distance(panel), hide_duration)
	_active_tween.parallel().tween_property(panel, "modulate:a", 0.85, hide_duration)
	_active_tween.finished.connect(_on_hide_finished.bind(panel), CONNECT_ONE_SHOT)


func replace_panel(panel: Control, options: Dictionary = {}) -> void:
	if panel == null:
		return
	var immediate := bool(options.get("immediate", false))
	if is_transitioning:
		pending_panel = panel
		_pending_immediate = immediate
		_pending_hide = false
		return
	if current_panel == panel and panel.visible:
		_normalize_visible_panel(panel)
		return
	_begin_transition()
	if current_panel == null:
		_start_show(panel, immediate)
		return
	pending_panel = panel
	_pending_immediate = immediate
	var outgoing := current_panel
	outgoing.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if immediate:
		_complete_hide(outgoing, true)
		_start_pending_panel()
		return
	var rest := _rest_position(outgoing)
	_active_tween = create_tween()
	_active_tween.set_trans(Tween.TRANS_QUAD)
	_active_tween.set_ease(Tween.EASE_IN)
	_active_tween.tween_property(outgoing, "position:y", rest.y + _travel_distance(outgoing), hide_duration)
	_active_tween.parallel().tween_property(outgoing, "modulate:a", 0.85, hide_duration)
	_active_tween.finished.connect(_on_replace_hide_finished.bind(outgoing), CONNECT_ONE_SHOT)


func _start_show(panel: Control, immediate: bool) -> void:
	current_panel = panel
	var rest: Vector2 = _rest_position(panel)
	panel.visible = true
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_set_dim_visible(true)
	if immediate:
		panel.position = rest
		panel.modulate.a = 1.0
		panel.mouse_filter = Control.MOUSE_FILTER_STOP
		panel_shown.emit(panel)
		_end_transition()
		return
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
	_normalize_visible_panel(panel)
	_active_tween = null
	panel_shown.emit(panel)
	_end_transition()


func _on_hide_finished(panel: Control) -> void:
	_active_tween = null
	_complete_hide(panel, false)
	_end_transition()


func _on_replace_hide_finished(panel: Control) -> void:
	_active_tween = null
	_complete_hide(panel, true)
	_start_pending_panel()


func _start_pending_panel() -> void:
	var next_panel := pending_panel
	var immediate := _pending_immediate
	var should_hide := _pending_hide
	pending_panel = null
	_pending_immediate = false
	_pending_hide = false
	if should_hide:
		_set_dim_visible(false)
		_end_transition()
		return
	if next_panel == null or not is_instance_valid(next_panel):
		_end_transition()
		return
	_start_show(next_panel, immediate)


func _complete_hide(panel: Control, keep_dim: bool) -> void:
	if is_instance_valid(panel):
		_hide_immediately(panel)
		panel_hidden.emit(panel)
	if current_panel == panel:
		current_panel = null
	if not keep_dim:
		_set_dim_visible(false)


func _hide_immediately(panel: Control) -> void:
	if not is_instance_valid(panel):
		return
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


func _set_dim_visible(should_show: bool) -> void:
	if modal_dim == null:
		return
	modal_dim.visible = should_show
	modal_dim.color.a = dim_alpha
	modal_dim.mouse_filter = Control.MOUSE_FILTER_STOP if should_show else Control.MOUSE_FILTER_IGNORE


func _begin_transition() -> void:
	is_transitioning = true
	transition_started.emit()


func _end_transition() -> void:
	var queued_panel := pending_panel
	var queued_immediate := _pending_immediate
	var queued_hide := _pending_hide
	pending_panel = null
	_pending_immediate = false
	_pending_hide = false
	is_transitioning = false
	_active_tween = null
	transition_finished.emit()
	if is_transitioning:
		return
	if queued_hide:
		hide_current_panel(queued_immediate)
		return
	if queued_panel == null or queued_panel == current_panel:
		return
	replace_panel(queued_panel, {"immediate": queued_immediate})


func _normalize_visible_panel(panel: Control) -> void:
	panel.visible = true
	panel.position = _rest_position(panel)
	panel.modulate.a = 1.0
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_set_dim_visible(true)


func _kill_active_tween() -> void:
	if _active_tween != null and _active_tween.is_valid():
		_active_tween.kill()
	_active_tween = null
	is_transitioning = false


func _exit_tree() -> void:
	_kill_active_tween()
	pending_panel = null
	_pending_hide = false
	for child: Node in get_children():
		if child is Control:
			_hide_immediately(child as Control)
