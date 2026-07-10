class_name JokerCardView
extends PanelContainer

signal sell_requested(index: int)
signal inspect_requested(joker: Dictionary)

@onready var art_texture: TextureRect = %ArtTexture
@onready var rarity_frame: Panel = %RarityFrame
@onready var rarity_label: Label = %RarityLabel
@onready var name_label: Label = %NameLabel
@onready var edition_overlay: TextureRect = %EditionOverlay
@onready var seal_overlay: TextureRect = %SealOverlay
@onready var eternal_overlay: Label = %EternalOverlay
@onready var empty_slot_overlay: ColorRect = %EmptySlotOverlay
@onready var trigger_glow: Panel = %TriggerGlow
@onready var sell_button: Button = %SellButton

var joker_index: int = -1
var joker_data: Dictionary = {}
var _base_scale: Vector2 = Vector2.ONE

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)
	sell_button.pressed.connect(func() -> void: sell_requested.emit(joker_index))
	pivot_offset = custom_minimum_size * 0.5
	clear_slot()

func setup(joker: Dictionary, index: int, allow_sell: bool = true) -> void:
	joker_data = joker.duplicate(true)
	joker_index = index
	empty_slot_overlay.visible = false
	name_label.text = str(joker.get("name_cn", "小丑牌"))
	var rarity: String = str(joker.get("rarity", "common"))
	rarity_label.text = _rarity_text(rarity)
	rarity_frame.modulate = _rarity_color(rarity)
	art_texture.texture = ArtResolver.get_joker_art(str(joker.get("id", "unknown_joker")))
	edition_overlay.visible = str(joker.get("edition", "base")) != "base"
	seal_overlay.visible = not str(joker.get("seal", "")).is_empty()
	eternal_overlay.visible = bool(joker.get("eternal", false))
	tooltip_text = "%s\n%s" % [name_label.text, str(joker.get("description_cn", ""))]
	sell_button.visible = allow_sell
	sell_button.disabled = not allow_sell
	sell_button.text = "出售 $%d" % int(joker.get("sell_value", 1))
	_apply_compact_mode(custom_minimum_size.x <= 96.0)

func clear_slot() -> void:
	joker_index = -1
	joker_data.clear()
	art_texture.texture = null
	name_label.text = "空槽"
	rarity_label.text = ""
	empty_slot_overlay.visible = true
	edition_overlay.visible = false
	seal_overlay.visible = false
	eternal_overlay.visible = false
	trigger_glow.visible = false
	sell_button.visible = false
	tooltip_text = "空小丑槽"

func play_trigger() -> void:
	trigger_glow.visible = true
	trigger_glow.modulate = Color(1.35, 1.15, 0.55, 1)
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1.13, 1.13), 0.1)
	tween.parallel().tween_property(trigger_glow, "modulate:a", 0.2, 0.24)
	tween.tween_property(self, "scale", _base_scale, 0.12)
	tween.tween_callback(func() -> void: trigger_glow.visible = false)

func _apply_compact_mode(compact: bool) -> void:
	if compact:
		name_label.add_theme_font_size_override("font_size", 11)
		rarity_label.add_theme_font_size_override("font_size", 9)
		sell_button.add_theme_font_size_override("font_size", 10)
	else:
		name_label.add_theme_font_size_override("font_size", 16)
		rarity_label.add_theme_font_size_override("font_size", 13)
		sell_button.add_theme_font_size_override("font_size", 14)

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

func _rarity_color(rarity: String) -> Color:
	match rarity:
		"uncommon":
			return Color(0.55, 1.0, 0.62, 1)
		"rare":
			return Color(0.55, 0.72, 1.2, 1)
		"legendary":
			return Color(1.3, 0.72, 0.25, 1)
		_:
			return Color(1, 1, 1, 1)

func _on_mouse_entered() -> void:
	if joker_data.is_empty():
		return
	z_index = 20
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.12)

func _on_mouse_exited() -> void:
	z_index = 0
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", _base_scale, 0.1)

func _on_gui_input(event: InputEvent) -> void:
	if joker_data.is_empty():
		return
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			inspect_requested.emit(joker_data)
