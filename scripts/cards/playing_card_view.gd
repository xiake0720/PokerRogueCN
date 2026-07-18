class_name PlayingCardView
extends Button

signal card_selection_changed(card_id: String, selected: bool)

const HOVER_SCALE: Vector2 = Vector2(1.08, 1.08)
const FOCUS_SCALE: Vector2 = Vector2(1.035, 1.035)

@onready var card_art: TextureRect = $CardArt
@onready var state_overlay: Panel = $StateOverlay

var card_data: Dictionary = {}
var _selected: bool = false
var _hovered: bool = false
var _selection_limited: bool = false
var _base_z_index: int = 0
var _scale_tween: Tween = null
var _normal_style: StyleBoxFlat
var _hover_style: StyleBoxFlat
var _selected_style: StyleBoxFlat
var _focus_style: StyleBoxFlat
var _selected_focus_style: StyleBoxFlat
var _disabled_style: StyleBoxFlat

func _ready() -> void:
	pressed.connect(_emit_selection)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	focus_entered.connect(_on_focus_changed)
	focus_exited.connect(_on_focus_changed)
	focus_mode = Control.FOCUS_ALL
	pivot_offset = custom_minimum_size * 0.5
	_build_state_styles()
	_apply_flat_style()
	_update_visual_state()

func setup(card: Dictionary) -> void:
	card_data = card
	text = ""
	tooltip_text = CardConstants.card_title(card)
	var texture_path: String = _face_texture_path(card)
	if ResourceLoader.exists(texture_path):
		card_art.texture = load(texture_path)
	else:
		card_art.texture = null
	_apply_flat_style()
	_update_visual_state()

func set_selected_without_signal(selected: bool) -> void:
	_selected = selected
	set_pressed_no_signal(selected)
	_update_visual_state()

func set_selection_limited(limited: bool) -> void:
	_selection_limited = limited
	disabled = limited and not _selected
	_update_visual_state()

func set_base_z_index(value: int) -> void:
	_base_z_index = value
	_update_z_index()

func _emit_selection() -> void:
	_selected = button_pressed
	_update_visual_state()
	card_selection_changed.emit(str(card_data.get("instance_id", "")), button_pressed)

func _face_texture_path(card: Dictionary) -> String:
	var rank: String = str(card.get("rank", "A")).to_lower()
	var suit: String = str(card.get("suit", "spades"))
	return "res://assets/cards/poker/faces/%s_%s.png" % [rank, suit]

func _apply_flat_style() -> void:
	var style: StyleBoxEmpty = StyleBoxEmpty.new()
	add_theme_stylebox_override("normal", style)
	add_theme_stylebox_override("hover", style)
	add_theme_stylebox_override("pressed", style)
	add_theme_stylebox_override("focus", style)
	add_theme_stylebox_override("disabled", style)

func _on_mouse_entered() -> void:
	_hovered = true
	_update_visual_state()
	if not disabled:
		_tween_scale(HOVER_SCALE)

func _on_mouse_exited() -> void:
	_hovered = false
	_update_visual_state()
	_tween_scale(FOCUS_SCALE if has_focus() else Vector2.ONE)

func _on_focus_changed() -> void:
	_update_visual_state()
	if not _hovered:
		_tween_scale(FOCUS_SCALE if has_focus() else Vector2.ONE)

func _tween_scale(target_scale: Vector2) -> void:
	if _scale_tween != null and _scale_tween.is_valid():
		_scale_tween.kill()
	_scale_tween = create_tween()
	_scale_tween.set_trans(Tween.TRANS_BACK)
	_scale_tween.set_ease(Tween.EASE_OUT)
	_scale_tween.tween_property(self, "scale", target_scale, 0.12)

func _build_state_styles() -> void:
	_normal_style = _state_style(Color(0, 0, 0, 0), Color(0, 0, 0, 0), 0, Color(0, 0, 0, 0), 0)
	_hover_style = _state_style(Color(0.95, 0.68, 0.24, 0.04), Color(1.0, 0.78, 0.32, 0.88), 2, Color(1.0, 0.58, 0.16, 0.22), 5)
	_selected_style = _state_style(Color(1.0, 0.68, 0.18, 0.055), Color(1.0, 0.76, 0.26, 0.96), 2, Color(1.0, 0.54, 0.12, 0.3), 7)
	_focus_style = _state_style(Color(0.48, 0.78, 1.0, 0.08), Color(0.78, 0.93, 1.0, 1.0), 3, Color(0.38, 0.72, 1.0, 0.48), 8)
	_selected_focus_style = _state_style(Color(1.0, 0.68, 0.18, 0.055), Color(0.78, 0.93, 1.0, 1.0), 3, Color(1.0, 0.54, 0.12, 0.3), 7)
	_disabled_style = _state_style(Color(0.02, 0.025, 0.02, 0.18), Color(0.48, 0.43, 0.31, 0.72), 2, Color(0, 0, 0, 0.2), 3)

func _state_style(
	background: Color,
	border: Color,
	border_width: int,
	shadow: Color,
	shadow_size: int
) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(8)
	style.shadow_color = shadow
	style.shadow_size = shadow_size
	style.expand_margin_left = 5.0
	style.expand_margin_top = 5.0
	style.expand_margin_right = 5.0
	style.expand_margin_bottom = 5.0
	return style

func _update_visual_state() -> void:
	if not is_node_ready():
		return
	var style := _normal_style
	if disabled or _selection_limited:
		style = _disabled_style
	elif has_focus() and _selected:
		style = _selected_focus_style
	elif has_focus():
		style = _focus_style
	elif _selected:
		style = _selected_style
	elif _hovered:
		style = _hover_style
	state_overlay.add_theme_stylebox_override("panel", style)
	card_art.modulate = Color(0.68, 0.66, 0.58, 0.86) if disabled else Color.WHITE
	_update_z_index()

func _update_z_index() -> void:
	var state_raise := 0
	if _hovered or has_focus():
		state_raise = 300
	elif _selected:
		state_raise = 200
	z_index = _base_z_index + state_raise
