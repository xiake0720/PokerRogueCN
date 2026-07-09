class_name JokerCardView
extends PanelContainer

signal sell_requested(index: int)
signal inspect_requested(joker: Dictionary)

@onready var name_label: Label = $VBox/NameLabel
@onready var art_frame: PanelContainer = $VBox/ArtFrame
@onready var art_label: Label = $VBox/ArtFrame/ArtLabel
@onready var rarity_label: Label = $VBox/RarityLabel
@onready var sell_button: Button = $VBox/SellButton

var joker_index: int = -1
var joker_data: Dictionary = {}
var _base_scale: Vector2 = Vector2.ONE

func _ready() -> void:
	add_theme_stylebox_override("panel", _panel_style())
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)
	sell_button.pressed.connect(func(): sell_requested.emit(joker_index))
	pivot_offset = custom_minimum_size * 0.5

func setup(joker: Dictionary, index: int, allow_sell: bool = true) -> void:
	joker_data = joker
	joker_index = index
	name_label.text = str(joker.get("name_cn", "小丑牌"))
	art_label.text = "JOKER"
	rarity_label.text = _rarity_text(str(joker.get("rarity", "common")))
	tooltip_text = "%s\n%s" % [name_label.text, str(joker.get("description_cn", ""))]
	sell_button.visible = allow_sell
	sell_button.text = "出售 $%d" % int(joker.get("sell_value", 1))
	_apply_compact_mode(custom_minimum_size.x <= 80.0)

func _apply_compact_mode(compact: bool) -> void:
	if compact:
		name_label.add_theme_font_size_override("font_size", 10)
		art_label.add_theme_font_size_override("font_size", 10)
		rarity_label.add_theme_font_size_override("font_size", 9)
		art_frame.custom_minimum_size = Vector2(0, 32)
		custom_minimum_size = Vector2(70, 70)
	else:
		name_label.add_theme_font_size_override("font_size", 18)
		art_label.add_theme_font_size_override("font_size", 20)
		rarity_label.add_theme_font_size_override("font_size", 16)
		art_frame.custom_minimum_size = Vector2(0, 88)

func _panel_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.88, 0.9, 0.84, 0.98)
	style.border_color = Color(0.08, 0.11, 0.13)
	style.set_border_width_all(3)
	style.set_corner_radius_all(8)
	style.content_margin_left = 8
	style.content_margin_top = 8
	style.content_margin_right = 8
	style.content_margin_bottom = 8
	return style

func _rarity_text(rarity: String) -> String:
	match rarity:
		"uncommon":
			return "罕见"
		"rare":
			return "稀有"
		"legendary":
			return "传奇"
		_:
			return "普通"

func _on_mouse_entered() -> void:
	z_index = 20
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1.12, 1.12), 0.12)

func _on_mouse_exited() -> void:
	z_index = 0
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", _base_scale, 0.10)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			inspect_requested.emit(joker_data)
