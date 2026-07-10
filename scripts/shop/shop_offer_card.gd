class_name ShopOfferCard
extends PanelContainer

signal buy_requested(index: int)
signal inspect_requested(item: Dictionary)

@onready var product_art: TextureRect = %ProductArt
@onready var product_frame: Panel = %ProductFrame
@onready var price_label: Label = %PriceLabel
@onready var name_label: Label = %NameLabel
@onready var type_label: Label = %TypeLabel
@onready var buy_button: Button = %BuyButton
@onready var sold_overlay: ColorRect = %SoldOverlay
@onready var disabled_overlay: ColorRect = %DisabledOverlay
@onready var hover_glow: Panel = %HoverGlow

var item_index: int = -1
var item_data: Dictionary = {}
var item_kind: String = ""

func _ready() -> void:
	buy_button.pressed.connect(func() -> void: buy_requested.emit(item_index))
	gui_input.connect(_on_gui_input)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	pivot_offset = custom_minimum_size * 0.5

func setup(item: Dictionary, index: int, kind: String) -> void:
	item_index = index
	item_kind = kind
	item_data = item.duplicate(true)
	item_data["kind"] = kind
	var cost: int = int(item_data.get("cost", 0))
	price_label.text = "$%d" % cost
	name_label.text = str(item_data.get("name_cn", "商品"))
	type_label.text = _type_text(kind)
	product_art.texture = _resolve_art(kind, str(item_data.get("id", "unknown")))
	product_frame.modulate = _kind_color(kind)
	tooltip_text = "%s\n%s" % [name_label.text, str(item_data.get("description_cn", ""))]
	sold_overlay.visible = false
	buy_button.visible = true
	buy_button.text = "购买"

func set_can_afford(can_afford: bool) -> void:
	buy_button.disabled = not can_afford
	disabled_overlay.visible = not can_afford
	product_art.modulate = Color.WHITE if can_afford else Color(0.48, 0.48, 0.48, 1)
	name_label.modulate = Color.WHITE
	price_label.modulate = Color.WHITE

func mark_sold() -> void:
	sold_overlay.visible = true
	disabled_overlay.visible = false
	buy_button.visible = false
	product_art.modulate = Color(0.55, 0.55, 0.55, 1)

func set_action_text(action_text: String) -> void:
	buy_button.text = action_text

func clear_offer() -> void:
	item_index = -1
	item_data.clear()
	product_art.texture = null
	name_label.text = "待补货"
	type_label.text = ""
	price_label.text = "—"
	buy_button.visible = false
	disabled_overlay.visible = true
	sold_overlay.visible = false

func _resolve_art(kind: String, id: String) -> Texture2D:
	match kind:
		"joker":
			return ArtResolver.get_joker_art(id)
		"voucher":
			return ArtResolver.get_voucher_art(id)
		"pack":
			return ArtResolver.get_pack_art(id)
		_:
			return ArtResolver.get_consumable_art(kind, id)

func _on_gui_input(event: InputEvent) -> void:
	if item_data.is_empty():
		return
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			inspect_requested.emit(item_data)

func _on_mouse_entered() -> void:
	if item_data.is_empty():
		return
	z_index = 50
	hover_glow.visible = true
	hover_glow.modulate = Color(1.25, 1.1, 0.72, 1)
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1.06, 1.06), 0.12)

func _on_mouse_exited() -> void:
	z_index = 0
	hover_glow.visible = false
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE, 0.1)

func _type_text(kind: String) -> String:
	match kind:
		"joker":
			return "小丑牌"
		"voucher":
			return "优惠券"
		"pack":
			return "补充包"
		"tarot":
			return "塔罗牌"
		"planet":
			return "星球牌"
		"spectral":
			return "幻灵牌"
		_:
			return "商品"

func _kind_color(kind: String) -> Color:
	match kind:
		"joker":
			return Color(1.08, 0.62, 0.56, 1)
		"voucher":
			return Color(1.05, 0.68, 0.88, 1)
		"pack":
			return Color(0.76, 0.66, 1.12, 1)
		_:
			return Color(0.72, 0.86, 0.82, 1)
