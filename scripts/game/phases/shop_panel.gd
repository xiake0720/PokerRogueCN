class_name ShopPanel
extends Control

signal inspect_requested(item: Dictionary)

@onready var title_panel: TextureRect = %TitlePanel
@onready var next_button: Button = %NextButton
@onready var reroll_button: Button = %RerollButton
@onready var joker_offer_slots: Array[ShopOfferCard] = [%JokerOfferSlot1, %JokerOfferSlot2]
@onready var voucher_offer_slots: Array[ShopOfferCard] = [%VoucherOfferSlot]
@onready var pack_offer_slots: Array[ShopOfferCard] = [%PackOfferSlot1, %PackOfferSlot2]
@onready var pack_overlay: Control = %PackOverlay
@onready var pack_open_title: Label = %PackOpenTitle
@onready var pack_choice_label: Label = %PackChoiceLabel
@onready var pack_option_slots: Array[ShopOfferCard] = [%PackOptionSlot1, %PackOptionSlot2, %PackOptionSlot3]
@onready var skip_pack_button: Button = %SkipPackButton


func _ready() -> void:
	next_button.pressed.connect(_on_next_pressed)
	reroll_button.pressed.connect(_on_reroll_pressed)
	skip_pack_button.pressed.connect(_on_skip_pack_pressed)
	for slot: ShopOfferCard in joker_offer_slots:
		slot.inspect_requested.connect(_show_offer_detail)
		slot.buy_requested.connect(_on_joker_offer_buy_requested)
	for slot: ShopOfferCard in voucher_offer_slots:
		slot.inspect_requested.connect(_show_offer_detail)
		slot.buy_requested.connect(_on_voucher_offer_buy_requested)
	for slot: ShopOfferCard in pack_offer_slots:
		slot.inspect_requested.connect(_show_offer_detail)
		slot.buy_requested.connect(_on_pack_offer_buy_requested)
	for slot: ShopOfferCard in pack_option_slots:
		slot.inspect_requested.connect(_show_offer_detail)
		slot.buy_requested.connect(_on_pack_option_requested)


func refresh_run(run: RunState) -> void:
	reroll_button.text = "刷新商店\n$%d" % run.reroll_cost
	reroll_button.disabled = run.money < run.reroll_cost or run.is_pack_open()
	next_button.disabled = run.is_pack_open()
	_refresh_joker_shop(run)
	_refresh_vouchers(run)
	_refresh_packs(run)
	_refresh_pack_open(run)


func play_intro() -> void:
	AudioManager.play_sfx("modal_open")
	title_panel.modulate.a = 0.0
	var target_y: float = title_panel.position.y
	title_panel.position.y = target_y + 24.0
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(title_panel, "modulate:a", 1.0, 0.18)
	tween.parallel().tween_property(title_panel, "position:y", target_y, 0.22)


func _refresh_joker_shop(run: RunState) -> void:
	for i: int in range(joker_offer_slots.size()):
		var slot: ShopOfferCard = joker_offer_slots[i]
		if i < run.shop_items.size():
			slot.setup(run.shop_items[i], i, "joker")
			var has_money: bool = run.money >= int(run.shop_items[i].get("cost", 0))
			var has_slot: bool = run.jokers.size() < run.joker_slots
			slot.set_can_afford(has_money and has_slot, "funds" if not has_money else "slots")
		else:
			slot.clear_offer()


func _refresh_vouchers(run: RunState) -> void:
	for i: int in range(voucher_offer_slots.size()):
		var slot: ShopOfferCard = voucher_offer_slots[i]
		if i < run.shop_voucher_items.size():
			slot.setup(run.shop_voucher_items[i], i, "voucher")
			slot.set_can_afford(run.money >= int(run.shop_voucher_items[i].get("cost", 0)))
		else:
			slot.clear_offer()


func _refresh_packs(run: RunState) -> void:
	for i: int in range(pack_offer_slots.size()):
		var slot: ShopOfferCard = pack_offer_slots[i]
		if i < run.shop_pack_items.size():
			slot.setup(run.shop_pack_items[i], i, "pack")
			slot.set_can_afford(run.money >= int(run.shop_pack_items[i].get("cost", 0)))
		else:
			slot.clear_offer()


func _refresh_pack_open(run: RunState) -> void:
	pack_overlay.visible = run.is_pack_open()
	if not pack_overlay.visible:
		return
	pack_open_title.text = str(run.current_pack.get("name_cn", "补充包"))
	pack_choice_label.text = "还可选择 %d 张" % run.pack_choices_left
	for i: int in range(pack_option_slots.size()):
		var slot: ShopOfferCard = pack_option_slots[i]
		if i < run.pack_options.size():
			var item: Dictionary = run.pack_options[i]
			var kind: String = str(item.get("kind", run.current_pack.get("type", "tarot")))
			slot.setup(item, i, kind)
			slot.set_action_text("选择")
			slot.set_can_afford(true)
		else:
			slot.clear_offer()


func _on_next_pressed() -> void:
	if next_button.disabled:
		return
	next_button.disabled = true
	AudioManager.play_sfx("ui_click")
	Game.run.leave_shop()


func _on_reroll_pressed() -> void:
	AudioManager.play_sfx("shop_reroll")
	Game.run.reroll_shop()


func _on_joker_offer_buy_requested(index: int) -> void:
	if index >= 0 and index < joker_offer_slots.size():
		joker_offer_slots[index].mark_sold()
	AudioManager.play_sfx("purchase_card")
	Game.run.buy_shop_item(index)


func _on_voucher_offer_buy_requested(index: int) -> void:
	if index >= 0 and index < voucher_offer_slots.size():
		voucher_offer_slots[index].mark_sold()
	AudioManager.play_sfx("purchase_card")
	Game.run.buy_shop_voucher(index)


func _on_pack_offer_buy_requested(index: int) -> void:
	if index >= 0 and index < pack_offer_slots.size():
		pack_offer_slots[index].mark_sold()
	AudioManager.play_sfx("booster_open")
	Game.run.buy_shop_pack(index)


func _on_pack_option_requested(index: int) -> void:
	AudioManager.play_sfx("card_upgrade")
	Game.run.choose_pack_option(index)


func _on_skip_pack_pressed() -> void:
	AudioManager.play_sfx("modal_close")
	Game.run.skip_pack()


func _show_offer_detail(item: Dictionary) -> void:
	inspect_requested.emit(item)
