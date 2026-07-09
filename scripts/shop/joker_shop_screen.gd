extends Control

const ShopOfferCardScene: PackedScene = preload("res://scenes/shop/shop_offer_card.tscn")
const JokerCardViewScene: PackedScene = preload("res://scenes/cards/joker_card_view.tscn")
const CardDetailPopupScene: PackedScene = preload("res://scenes/ui/card_detail_popup.tscn")

@onready var hud: GameHudPanel = $Root/HBox/HudPanel
@onready var board_panel: PanelContainer = $Root/HBox/BoardPanel
@onready var owned_panel: PanelContainer = $Root/HBox/BoardPanel/BoardVBox/OwnedPanel
@onready var shop_panel: PanelContainer = $Root/HBox/BoardPanel/BoardVBox/ShopPanel
@onready var joker_shelf: PanelContainer = $Root/HBox/BoardPanel/BoardVBox/ShopPanel/ShopMargin/ShopVBox/TopSection/JokerShelf
@onready var voucher_shelf: PanelContainer = $Root/HBox/BoardPanel/BoardVBox/ShopPanel/ShopMargin/ShopVBox/BottomSection/VoucherShelf
@onready var pack_shelf: PanelContainer = $Root/HBox/BoardPanel/BoardVBox/ShopPanel/ShopMargin/ShopVBox/BottomSection/PackShelf
@onready var owned_joker_header: Label = $Root/HBox/BoardPanel/BoardVBox/OwnedPanel/OwnedMargin/OwnedVBox/OwnedJokerHeader
@onready var owned_joker_row: HBoxContainer = $Root/HBox/BoardPanel/BoardVBox/OwnedPanel/OwnedMargin/OwnedVBox/OwnedJokerRow
@onready var next_button: Button = $Root/HBox/BoardPanel/BoardVBox/ShopPanel/ShopMargin/ShopVBox/TopSection/ActionColumn/NextButton
@onready var reroll_button: Button = $Root/HBox/BoardPanel/BoardVBox/ShopPanel/ShopMargin/ShopVBox/TopSection/ActionColumn/RerollButton
@onready var joker_shop_row: HBoxContainer = $Root/HBox/BoardPanel/BoardVBox/ShopPanel/ShopMargin/ShopVBox/TopSection/JokerShelf/JokerShelfMargin/JokerShopRow
@onready var voucher_row: HBoxContainer = $Root/HBox/BoardPanel/BoardVBox/ShopPanel/ShopMargin/ShopVBox/BottomSection/VoucherShelf/VoucherVBox/VoucherRow
@onready var pack_row: HBoxContainer = $Root/HBox/BoardPanel/BoardVBox/ShopPanel/ShopMargin/ShopVBox/BottomSection/PackShelf/PackVBox/PackRow

var detail_popup: CardDetailPopup

func _ready() -> void:
	board_panel.add_theme_stylebox_override("panel", _board_style())
	owned_panel.add_theme_stylebox_override("panel", _owned_panel_style())
	shop_panel.add_theme_stylebox_override("panel", _shop_panel_style())
	joker_shelf.add_theme_stylebox_override("panel", _shelf_style())
	voucher_shelf.add_theme_stylebox_override("panel", _shelf_style())
	pack_shelf.add_theme_stylebox_override("panel", _shelf_style())
	detail_popup = CardDetailPopupScene.instantiate() as CardDetailPopup
	add_child(detail_popup)
	hud.hand_detail_requested.connect(_show_hand_detail)
	next_button.pressed.connect(func() -> void: Game.run.leave_shop())
	reroll_button.pressed.connect(func() -> void: Game.run.reroll_shop())
	_play_intro()
	refresh()

func refresh() -> void:
	var run: RunState = Game.run
	hud.refresh_run(run, "shop")
	reroll_button.text = "重掷\n$%d" % (0 if run.has_joker("chaos_the_clown") else 5)
	_rebuild_owned(run)
	_rebuild_joker_shop(run)
	_rebuild_vouchers(run)
	_rebuild_packs(run)

func _rebuild_owned(run: RunState) -> void:
	owned_joker_header.text = "已拥有小丑牌 %d/%d" % [run.jokers.size(), run.joker_slots]
	for child in owned_joker_row.get_children():
		child.queue_free()
	for i in range(run.jokers.size()):
		var view: JokerCardView = JokerCardViewScene.instantiate() as JokerCardView
		owned_joker_row.add_child(view)
		view.custom_minimum_size = Vector2(150, 210)
		view.setup(run.jokers[i], i, true)
		view.inspect_requested.connect(func(joker: Dictionary) -> void: detail_popup.show_joker(joker))
		view.sell_requested.connect(func(index: int) -> void: Game.run.sell_joker(index))
		_animate_offer_in(view, i)

func _rebuild_joker_shop(run: RunState) -> void:
	for child in joker_shop_row.get_children():
		child.queue_free()
	for i in range(run.shop_items.size()):
		var view: ShopOfferCard = ShopOfferCardScene.instantiate() as ShopOfferCard
		joker_shop_row.add_child(view)
		view.setup(run.shop_items[i], i, "joker")
		view.set_can_afford(run.money >= int(run.shop_items[i].get("cost", 0)) and run.jokers.size() < run.joker_slots)
		view.inspect_requested.connect(_show_offer_detail)
		view.buy_requested.connect(func(index: int) -> void: Game.run.buy_shop_item(index))
		_animate_offer_in(view, i)

func _rebuild_vouchers(run: RunState) -> void:
	for child in voucher_row.get_children():
		child.queue_free()
	for i in range(run.shop_voucher_items.size()):
		var view: ShopOfferCard = ShopOfferCardScene.instantiate() as ShopOfferCard
		voucher_row.add_child(view)
		view.setup(run.shop_voucher_items[i], i, "voucher")
		view.set_can_afford(run.money >= int(run.shop_voucher_items[i].get("cost", 0)))
		view.inspect_requested.connect(_show_offer_detail)
		view.buy_requested.connect(func(index: int) -> void: Game.run.buy_shop_voucher(index))
		_animate_offer_in(view, i)

func _rebuild_packs(run: RunState) -> void:
	for child in pack_row.get_children():
		child.queue_free()
	for i in range(run.shop_pack_items.size()):
		var view: ShopOfferCard = ShopOfferCardScene.instantiate() as ShopOfferCard
		pack_row.add_child(view)
		view.setup(run.shop_pack_items[i], i, "pack")
		view.set_can_afford(run.money >= int(run.shop_pack_items[i].get("cost", 0)))
		view.inspect_requested.connect(_show_offer_detail)
		view.buy_requested.connect(func(index: int) -> void: Game.run.buy_shop_pack(index))
		_animate_offer_in(view, i)

func _show_offer_detail(item: Dictionary) -> void:
	detail_popup.show_item(item)

func _show_hand_detail(hand_id: String) -> void:
	var hand_data: Dictionary = DataRegistry.find_by_id("poker_hands", hand_id)
	if hand_data.is_empty():
		return
	detail_popup.show_hand(hand_data, int(Game.run.hand_levels.get(hand_id, 1)))

func _animate_offer_in(view: Control, index: int) -> void:
	view.modulate.a = 0.0
	view.position.y += 18.0
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_interval(float(index) * 0.035)
	tween.tween_property(view, "modulate:a", 1.0, 0.14)
	tween.parallel().tween_property(view, "position:y", view.position.y - 18.0, 0.18)

func _play_intro() -> void:
	shop_panel.modulate.a = 0.0
	shop_panel.position.y += 40.0
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(shop_panel, "modulate:a", 1.0, 0.18)
	tween.parallel().tween_property(shop_panel, "position:y", shop_panel.position.y - 40.0, 0.22)

func _board_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.28, 0.2, 0.72)
	style.border_color = Color(0.08, 0.36, 0.27)
	style.set_border_width_all(6)
	style.set_corner_radius_all(15)
	style.content_margin_left = 27
	style.content_margin_top = 27
	style.content_margin_right = 27
	style.content_margin_bottom = 27
	return style

func _owned_panel_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.07, 0.12, 0.13, 0.68)
	style.border_color = Color(0.08, 0.2, 0.21)
	style.set_border_width_all(4)
	style.set_corner_radius_all(15)
	return style

func _shop_panel_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.12, 0.13, 0.96)
	style.border_color = Color(0.95, 0.22, 0.2)
	style.set_border_width_all(6)
	style.set_corner_radius_all(15)
	return style

func _shelf_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.18, 0.29, 0.31, 0.94)
	style.border_color = Color(0.05, 0.1, 0.11)
	style.set_border_width_all(5)
	style.set_corner_radius_all(15)
	style.content_margin_left = 18
	style.content_margin_top = 18
	style.content_margin_right = 18
	style.content_margin_bottom = 18
	return style
