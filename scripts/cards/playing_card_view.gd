class_name PlayingCardView
extends Button

signal card_selection_changed(card_id: String, selected: bool)

const HOVER_SCALE: Vector2 = Vector2(1.08, 1.08)

@onready var card_art: TextureRect = $CardArt

var card_data: Dictionary = {}
var _selected: bool = false
var _scale_tween: Tween = null

func _ready() -> void:
	pressed.connect(_emit_selection)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	focus_mode = Control.FOCUS_NONE
	pivot_offset = custom_minimum_size * 0.5
	_apply_flat_style()

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

func set_selected_without_signal(selected: bool) -> void:
	_selected = selected
	set_pressed_no_signal(selected)
	_apply_flat_style()

func _emit_selection() -> void:
	_selected = button_pressed
	_apply_flat_style()
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
	_tween_scale(HOVER_SCALE)

func _on_mouse_exited() -> void:
	_tween_scale(Vector2.ONE)

func _tween_scale(target_scale: Vector2) -> void:
	if _scale_tween != null and _scale_tween.is_valid():
		_scale_tween.kill()
	_scale_tween = create_tween()
	_scale_tween.set_trans(Tween.TRANS_BACK)
	_scale_tween.set_ease(Tween.EASE_OUT)
	_scale_tween.tween_property(self, "scale", target_scale, 0.12)
