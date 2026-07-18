class_name ShopOfferCard
extends PanelContainer

signal buy_requested(index: int)
signal inspect_requested(item: Dictionary)

@onready var product_art: TextureRect = %ProductArt
@onready var product_content: Control = $ProductContent
@onready var price_label: Label = %PriceLabel
@onready var name_label: Label = %NameLabel
@onready var type_label: Label = %TypeLabel
@onready var buy_button: Button = %BuyButton
@onready var sold_overlay: Control = %SoldOverlay
@onready var sold_stamp: PanelContainer = %SoldStamp

var item_index: int = -1
var item_data: Dictionary = {}
var item_kind: String = ""
var _hover_tween: Tween = null
var _rest_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	buy_button.pressed.connect(func() -> void: buy_requested.emit(item_index))
	gui_input.connect(_on_gui_input)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	resized.connect(_sync_pivot)
	product_content.resized.connect(_fit_state_overlays)
	_sync_pivot()
	_fit_state_overlays.call_deferred()

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
	tooltip_text = "%s  ·  $%d" % [name_label.text, cost]
	sold_overlay.visible = false
	buy_button.visible = true
	product_art.modulate = Color.WHITE
	name_label.modulate = Color.WHITE
	price_label.modulate = Color.WHITE
	buy_button.text = "购买"
	_fit_state_overlays.call_deferred()

func set_can_afford(can_afford: bool, disabled_reason: String = "funds") -> void:
	buy_button.disabled = not can_afford
	product_art.modulate = Color.WHITE
	name_label.modulate = Color.WHITE
	price_label.modulate = Color.WHITE if can_afford or disabled_reason == "slots" else Color(1.0, 0.42, 0.24, 1.0)
	if not can_afford:
		buy_button.text = "槽位已满" if disabled_reason == "slots" else "金币不足"
	_fit_state_overlays.call_deferred()

func mark_sold() -> void:
	sold_overlay.visible = true
	buy_button.visible = false
	product_art.modulate = Color(0.62, 0.59, 0.52, 1)
	name_label.modulate = Color(0.72, 0.68, 0.58, 1)
	price_label.modulate = Color(0.72, 0.56, 0.34, 1)

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
	sold_overlay.visible = false
	product_art.modulate = Color.WHITE
	name_label.modulate = Color.WHITE
	price_label.modulate = Color.WHITE

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
	if _hover_tween != null and _hover_tween.is_valid():
		_hover_tween.kill()
	_rest_position = position
	_hover_tween = create_tween().set_parallel(true)
	_hover_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_hover_tween.tween_property(self, "position", _rest_position + Vector2(0.0, -8.0), 0.12)
	_hover_tween.tween_property(self, "scale", Vector2(1.025, 1.025), 0.12)
	_hover_tween.tween_property(self, "modulate", Color(1.06, 1.06, 1.04, 1.0), 0.12)

func _on_mouse_exited() -> void:
	if _hover_tween != null and _hover_tween.is_valid():
		_hover_tween.kill()
	_hover_tween = create_tween().set_parallel(true)
	_hover_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_hover_tween.tween_property(self, "position", _rest_position, 0.1)
	_hover_tween.tween_property(self, "scale", Vector2.ONE, 0.1)
	_hover_tween.tween_property(self, "modulate", Color.WHITE, 0.1)
	_hover_tween.chain().tween_callback(func() -> void:
		_hover_tween = null
	)

func _sync_pivot() -> void:
	pivot_offset = size * 0.5

func _fit_state_overlays() -> void:
	sold_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	sold_stamp.pivot_offset = sold_stamp.size * 0.5

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
