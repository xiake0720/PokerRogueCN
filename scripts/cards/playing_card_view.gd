class_name PlayingCardView
extends Button


signal card_selection_changed(card_id: String, selected: bool)

const HOVER_SCALE: float = 1.08
const HOVER_DURATION: float = 0.10

var card_data: Dictionary = {}
var _selected: bool = false
var _is_interactive: bool = true
var _hovered: bool = false
var _hover_tween: Tween = null

func _ready() -> void:
	pressed.connect(_emit_selection)
	pivot_offset = custom_minimum_size * 0.5
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_apply_style()

func setup(card: Dictionary) -> void:
	card_data = card
	text = CardConstants.card_title(card)
	add_theme_font_size_override("font_size", 30)
	var text_color: Color = _text_color()
	add_theme_color_override("font_color", text_color)
	add_theme_color_override("font_hover_color", text_color)
	add_theme_color_override("font_pressed_color", text_color)
	add_theme_color_override("font_hover_pressed_color", text_color)
	add_theme_color_override("font_focus_color", text_color)
	add_theme_color_override("font_disabled_color", text_color)
	_apply_style()

func set_interactive(value: bool) -> void:
	_is_interactive = value
	disabled = false
	mouse_filter = Control.MOUSE_FILTER_STOP if value else Control.MOUSE_FILTER_IGNORE
	focus_mode = Control.FOCUS_ALL if value else Control.FOCUS_NONE
	if not value:
		_hovered = false
		_set_hover_scale(false, false)
	_apply_style()

func set_selected_without_signal(selected: bool) -> void:
	_selected = selected
	set_pressed_no_signal(selected)
	_apply_style()

func reset_visual_state() -> void:
	_hovered = false
	set_pressed_no_signal(false)
	_selected = false
	_set_hover_scale(false, false)
	_apply_style()

func _emit_selection() -> void:
	if not _is_interactive:
		set_pressed_no_signal(false)
		return
	_selected = button_pressed
	_apply_style()
	card_selection_changed.emit(str(card_data.get("instance_id", "")), button_pressed)

func _text_color() -> Color:
	var suit: String = str(card_data.get("suit", ""))
	if suit == "hearts" or suit == "diamonds":
		return Color(0.72, 0.08, 0.1)
	return Color(0.08, 0.09, 0.13)

func _apply_style() -> void:
	# 正式交互规范：扑克牌 hover / pressed / selected 不换色，只保留同一套牌面样式。
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.96, 0.93, 0.84)
	style.border_color = Color(0.08, 0.09, 0.12)
	style.set_border_width_all(3)
	style.set_corner_radius_all(12)
	style.content_margin_left = 12
	style.content_margin_top = 12
	style.content_margin_right = 12
	style.content_margin_bottom = 12
	add_theme_stylebox_override("normal", style)
	add_theme_stylebox_override("hover", style)
	add_theme_stylebox_override("pressed", style)
	add_theme_stylebox_override("focus", style)
	add_theme_stylebox_override("disabled", style)

func _on_mouse_entered() -> void:
	if not _is_interactive:
		return
	_hovered = true
	_set_hover_scale(true, true)

func _on_mouse_exited() -> void:
	_hovered = false
	_set_hover_scale(false, true)

func _set_hover_scale(active: bool, animated: bool) -> void:
	if _hover_tween != null and _hover_tween.is_valid():
		_hover_tween.kill()
	var target_scale: Vector2 = Vector2(HOVER_SCALE, HOVER_SCALE) if active else Vector2.ONE
	pivot_offset = size * 0.5
	if animated and is_inside_tree():
		_hover_tween = create_tween()
		_hover_tween.set_trans(Tween.TRANS_BACK)
		_hover_tween.set_ease(Tween.EASE_OUT)
		_hover_tween.tween_property(self, "scale", target_scale, HOVER_DURATION)
	else:
		scale = target_scale
