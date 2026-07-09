extends Control

const CardDetailPopupScene: PackedScene = preload("res://scenes/ui/card_detail_popup.tscn")

@onready var hud: GameHudPanel = $Root/HBox/HUD
@onready var shop_panel: PanelContainer = $Root/HBox/BoardPanel/BoardMargin/BoardVBox/ShopPanel
@onready var owned_joker_header: Label = $Root/HBox/BoardPanel/BoardMargin/BoardVBox/OwnedJokerHeader
@onready var owned_joker_slots: Array[JokerCardView] = [
	$Root/HBox/BoardPanel/BoardMargin/BoardVBox/OwnedShelf/OwnedJokerRow/OwnedJokerSlot1,
	$Root/HBox/BoardPanel/BoardMargin/BoardVBox/OwnedShelf/OwnedJokerRow/OwnedJokerSlot2,
	$Root/HBox/BoardPanel/BoardMargin/BoardVBox/OwnedShelf/OwnedJokerRow/OwnedJokerSlot3,
	$Root/HBox/BoardPanel/BoardMargin/BoardVBox/OwnedShelf/OwnedJokerRow/OwnedJokerSlot4,
	$Root/HBox/BoardPanel/BoardMargin/BoardVBox/OwnedShelf/OwnedJokerRow/OwnedJokerSlot5,
]
@onready var next_button: Button = $Root/HBox/BoardPanel/BoardMargin/BoardVBox/ShopPanel/ShopMargin/ShopVBox/TopSection/ActionColumn/NextButton
@onready var reroll_button: Button = $Root/HBox/BoardPanel/BoardMargin/BoardVBox/ShopPanel/ShopMargin/ShopVBox/TopSection/ActionColumn/RerollButton
@onready var joker_offer_slots: Array[ShopOfferCard] = [
	$Root/HBox/BoardPanel/BoardMargin/BoardVBox/ShopPanel/ShopMargin/ShopVBox/TopSection/JokerShelf/JokerShelfMargin/JokerShopRow/JokerOfferSlot1,
	$Root/HBox/BoardPanel/BoardMargin/BoardVBox/ShopPanel/ShopMargin/ShopVBox/TopSection/JokerShelf/JokerShelfMargin/JokerShopRow/JokerOfferSlot2,
]
@onready var voucher_offer_slots: Array[ShopOfferCard] = [
	$Root/HBox/BoardPanel/BoardMargin/BoardVBox/ShopPanel/ShopMargin/ShopVBox/BottomSection/VoucherShelf/VoucherVBox/VoucherRow/VoucherOfferSlot,
]
@onready var pack_offer_slots: Array[ShopOfferCard] = [
	$Root/HBox/BoardPanel/BoardMargin/BoardVBox/ShopPanel/ShopMargin/ShopVBox/BottomSection/PackShelf/PackVBox/PackRow/PackOfferSlot1,
	$Root/HBox/BoardPanel/BoardMargin/BoardVBox/ShopPanel/ShopMargin/ShopVBox/BottomSection/PackShelf/PackVBox/PackRow/PackOfferSlot2,
]

var detail_popup: CardDetailPopup

func _ready() -> void:
	detail_popup = CardDetailPopupScene.instantiate() as CardDetailPopup
	add_child(detail_popup)
	next_button.pressed.connect(_on_next_pressed)
	reroll_button.pressed.connect(_on_reroll_pressed)
	for slot in owned_joker_slots:
		slot.inspect_requested.connect(func(joker: Dictionary) -> void: detail_popup.show_joker(joker))
	for slot in joker_offer_slots:
		slot.inspect_requested.connect(_show_offer_detail)
		slot.buy_requested.connect(_on_joker_offer_buy_requested)
	for slot in voucher_offer_slots:
		slot.inspect_requested.connect(_show_offer_detail)
		slot.buy_requested.connect(_on_voucher_offer_buy_requested)
	for slot in pack_offer_slots:
		slot.inspect_requested.connect(_show_offer_detail)
		slot.buy_requested.connect(_on_pack_offer_buy_requested)
	AudioManager.play_sfx("modal_open")
	_play_intro()
	refresh()

func refresh() -> void:
	var run: RunState = Game.run
	hud.refresh_run(run, "shop")
	reroll_button.text = "刷新\n$%d" % (0 if run.has_joker("chaos_the_clown") else 5)
	_refresh_owned(run)
	_refresh_joker_shop(run)
	_refresh_vouchers(run)
	_refresh_packs(run)

func _refresh_owned(run: RunState) -> void:
	owned_joker_header.text = "已拥有小丑牌 %d/%d" % [run.jokers.size(), run.joker_slots]
	for i in range(owned_joker_slots.size()):
		var slot: JokerCardView = owned_joker_slots[i]
		if i < run.jokers.size():
			slot.visible = true
			slot.custom_minimum_size = Vector2(88, 116)
			slot.setup(run.jokers[i], i, false)
		else:
			slot.visible = false

func _refresh_joker_shop(run: RunState) -> void:
	for i in range(joker_offer_slots.size()):
		var slot: ShopOfferCard = joker_offer_slots[i]
		if i < run.shop_items.size():
			slot.visible = true
			slot.setup(run.shop_items[i], i, "joker")
			slot.set_can_afford(run.money >= int(run.shop_items[i].get("cost", 0)) and run.jokers.size() < run.joker_slots)
			_animate_offer_in(slot, i)
		else:
			slot.visible = false

func _refresh_vouchers(run: RunState) -> void:
	for i in range(voucher_offer_slots.size()):
		var slot: ShopOfferCard = voucher_offer_slots[i]
		if i < run.shop_voucher_items.size():
			slot.visible = true
			slot.setup(run.shop_voucher_items[i], i, "voucher")
			slot.set_can_afford(run.money >= int(run.shop_voucher_items[i].get("cost", 0)))
			_animate_offer_in(slot, i)
		else:
			slot.visible = false

func _refresh_packs(run: RunState) -> void:
	for i in range(pack_offer_slots.size()):
		var slot: ShopOfferCard = pack_offer_slots[i]
		if i < run.shop_pack_items.size():
			slot.visible = true
			slot.setup(run.shop_pack_items[i], i, "pack")
			slot.set_can_afford(run.money >= int(run.shop_pack_items[i].get("cost", 0)))
			_animate_offer_in(slot, i)
		else:
			slot.visible = false

func _on_next_pressed() -> void:
	AudioManager.play_sfx("ui_click")
	Game.run.leave_shop()

func _on_reroll_pressed() -> void:
	AudioManager.play_sfx("shop_reroll")
	Game.run.reroll_shop()

func _on_joker_offer_buy_requested(index: int) -> void:
	AudioManager.play_sfx("purchase_card")
	Game.run.buy_shop_item(index)

func _on_voucher_offer_buy_requested(index: int) -> void:
	AudioManager.play_sfx("purchase_card")
	Game.run.buy_shop_voucher(index)

func _on_pack_offer_buy_requested(index: int) -> void:
	AudioManager.play_sfx("booster_open")
	Game.run.buy_shop_pack(index)

func _show_offer_detail(item: Dictionary) -> void:
	detail_popup.show_item(item)

func _animate_offer_in(view: Control, index: int) -> void:
	view.modulate.a = 0.0
	var target_y: float = view.position.y
	view.position.y = target_y + 18.0
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_interval(float(index) * 0.035)
	tween.tween_property(view, "modulate:a", 1.0, 0.14)
	tween.parallel().tween_property(view, "position:y", target_y, 0.18)

func _play_intro() -> void:
	shop_panel.modulate.a = 0.0
	var target_y: float = shop_panel.position.y
	shop_panel.position.y = target_y + 28.0
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(shop_panel, "modulate:a", 1.0, 0.18)
	tween.parallel().tween_property(shop_panel, "position:y", target_y, 0.22)
