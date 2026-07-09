class_name ShopOfferCard
extends PanelContainer

signal buy_requested(index: int)
signal inspect_requested(item: Dictionary)

@onready var price_label: Label = $VBox/PriceLabel
@onready var art_panel: PanelContainer = $VBox/ArtPanel
@onready var art_label: Label = $VBox/ArtPanel/ArtLabel
@onready var name_label: Label = $VBox/NameLabel
@onready var type_label: Label = $VBox/TypeLabel
@onready var buy_button: Button = $VBox/BuyButton

var item_index: int = -1
var item_data: Dictionary = {}

func _ready() -> void:
	add_theme_stylebox_override("panel", _panel_style())
	art_panel.add_theme_stylebox_override("panel", _art_style(Color(0.82, 0.2, 0.18)))
	buy_button.pressed.connect(func() -> void: buy_requested.emit(item_index))
	gui_input.connect(_on_gui_input)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	pivot_offset = custom_minimum_size * 0.5

func setup(item: Dictionary, index: int, kind: String) -> void:
	item_index = index
	item_data = item.duplicate(true)
	item_data["kind"] = kind
	var cost: int = int(item_data.get("cost", 0))
	price_label.text = "$%d" % cost
	name_label.text = str(item_data.get("name_cn", "商品"))
	type_label.text = _type_text(kind)
	art_label.text = _art_text(kind)
	tooltip_text = "%s\n%s" % [name_label.text, str(item_data.get("description_cn", ""))]
	art_panel.add_theme_stylebox_override("panel", _art_style(_kind_color(kind)))
	buy_button.text = "购买"

func set_can_afford(can_afford: bool) -> void:
	buy_button.disabled = not can_afford
	modulate = Color.WHITE if can_afford else Color(1, 1, 1, 0.56)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			inspect_requested.emit(item_data)

func _on_mouse_entered() -> void:
	z_index = 50
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1.06, 1.06), 0.12)

func _on_mouse_exited() -> void:
	z_index = 0
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE, 0.10)

func _type_text(kind: String) -> String:
	match kind:
		"joker":
			return "小丑牌"
		"voucher":
			return "优惠券"
		"pack":
			return "补充包"
		_:
			return "商品"

func _art_text(kind: String) -> String:
	match kind:
		"joker":
			return "JOKER"
		"voucher":
			return "VOUCHER"
		"pack":
			return "PACK"
		_:
			return "ITEM"

func _kind_color(kind: String) -> Color:
	match kind:
		"joker":
			return Color(0.82, 0.18, 0.16)
		"voucher":
			return Color(0.85, 0.38, 0.62)
		"pack":
			return Color(0.55, 0.32, 0.9)
		_:
			return Color(0.28, 0.38, 0.42)

func _panel_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.13, 0.19, 0.2, 0.98)
	style.border_color = Color(0.05, 0.09, 0.1)
	style.set_border_width_all(3)
	style.set_corner_radius_all(9)
	style.content_margin_left = 6
	style.content_margin_top = 6
	style.content_margin_right = 6
	style.content_margin_bottom = 6
	return style

func _art_style(color: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = Color(0.92, 0.92, 0.86)
	style.set_border_width_all(3)
	style.set_corner_radius_all(8)
	return style
