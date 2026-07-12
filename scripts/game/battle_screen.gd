extends Control

const CardDetailPopupScene: PackedScene = preload("res://scenes/ui/card_detail_popup.tscn")
const FloatingScoreLabelScene: PackedScene = preload("res://scenes/ui/floating_score_label.tscn")
@onready var hud: GameHudPanel = %HUD
@onready var joker_header: Label = %JokerHeader
@onready var joker_slots: Array[JokerCardView] = [
	%JokerSlot1,
	%JokerSlot2,
	%JokerSlot3,
	%JokerSlot4,
	%JokerSlot5,
]
@onready var consumable_slots: Array[PanelContainer] = [%ConsumableSlot1, %ConsumableSlot2, %ConsumableSlot3]
@onready var consumable_count_label: Label = %ConsumableCountLabel
@onready var played_area: Control = %PlayedArea
@onready var deck_pile: Control = %DeckPile
@onready var deck_back: TextureRect = %DeckBack
@onready var deck_pile_label: Label = %DeckPileLabel
@onready var discard_count_label: Label = %DiscardCountLabel
@onready var hand_area: CardFanArea = %HandArea
@onready var chips_value: Label = %ChipsValue
@onready var mult_value: Label = %MultValue
@onready var play_button: Button = %PlayButton
@onready var sort_rank_button: Button = %SortRankButton
@onready var sort_suit_button: Button = %SortSuitButton
@onready var discard_button: Button = %DiscardButton

var selected_cards: Array = []
var is_animating: bool = false
var joker_views_by_id: Dictionary = {}
var detail_popup: CardDetailPopup

func _ready() -> void:
	play_button.pressed.connect(_play_selected)
	discard_button.pressed.connect(_discard_selected)
	sort_rank_button.pressed.connect(func() -> void: Game.run.set_hand_sort_mode("rank"))
	sort_suit_button.pressed.connect(func() -> void: Game.run.set_hand_sort_mode("suit"))
	hand_area.card_selection_changed.connect(_on_card_selection_changed)
	detail_popup = CardDetailPopupScene.instantiate() as CardDetailPopup
	add_child(detail_popup)
	for slot in joker_slots:
		slot.inspect_requested.connect(func(joker: Dictionary) -> void: detail_popup.show_joker(joker))
	for i in range(consumable_slots.size()):
		consumable_slots[i].gui_input.connect(_on_consumable_gui_input.bind(i))
	AudioManager.play_sfx("shuffle_cards", -2.0)
	modulate.a = 0.0
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.18)
	refresh()

func refresh() -> void:
	if is_animating:
		return
	selected_cards.clear()
	var run: RunState = Game.run
	hud.refresh_run(run, "battle")
	deck_pile_label.text = "%d/%d" % [run.deck.size(), run.full_deck.size()]
	discard_count_label.text = "弃牌堆\n%d" % run.discard_pile.size()
	var back_texture: Texture2D = ArtResolver.get_deck_back(run.deck_id)
	for child in deck_pile.get_children():
		if child is TextureRect:
			(child as TextureRect).texture = back_texture
	deck_back.texture = back_texture
	_rebuild_hand(run)
	_rebuild_jokers(run)
	_refresh_consumables(run)
	_update_selected_preview()
	_update_action_buttons()

func _rebuild_hand(run: RunState) -> void:
	hand_area.display_cards(run.sorted_hand_for_display(), selected_cards)

func _rebuild_jokers(run: RunState) -> void:
	joker_header.text = "小丑牌\n%d/%d" % [run.jokers.size(), run.joker_slots]
	joker_views_by_id.clear()
	for i in range(joker_slots.size()):
		var view: JokerCardView = joker_slots[i]
		if i < run.jokers.size():
			view.visible = true
			view.setup(run.jokers[i], i, false)
			joker_views_by_id[str(run.jokers[i].get("id", ""))] = view
		else:
			view.visible = true
			view.clear_slot()

func _refresh_consumables(run: RunState) -> void:
	consumable_count_label.text = "%d/%d" % [run.consumables.size(), run.consumable_slots]
	for i in range(consumable_slots.size()):
		var slot: PanelContainer = consumable_slots[i]
		var art: TextureRect = slot.get_node("Content/ArtTexture") as TextureRect
		var name_label: Label = slot.get_node("Content/NameLabel") as Label
		var empty_overlay: ColorRect = slot.get_node("Content/EmptySlotOverlay") as ColorRect
		if i < run.consumables.size():
			var item: Dictionary = run.consumables[i]
			var kind: String = str(item.get("kind", item.get("type", "tarot")))
			art.texture = ArtResolver.get_consumable_art(kind, str(item.get("id", "")))
			name_label.text = str(item.get("name_cn", "消耗牌"))
			empty_overlay.visible = false
			slot.tooltip_text = "%s\n%s" % [name_label.text, str(item.get("description_cn", ""))]
		else:
			art.texture = null
			name_label.text = "空槽"
			empty_overlay.visible = true
			slot.tooltip_text = "空消耗牌槽"

func _on_consumable_gui_input(event: InputEvent, index: int) -> void:
	if not (event is InputEventMouseButton):
		return
	var mouse_event: InputEventMouseButton = event as InputEventMouseButton
	if not mouse_event.pressed or mouse_event.button_index != MOUSE_BUTTON_LEFT:
		return
	if index >= Game.run.consumables.size():
		return
	var item: Dictionary = Game.run.consumables[index]
	if not Game.run.use_consumable(index, selected_cards.duplicate()):
		detail_popup.show_item(item)

func _on_card_selection_changed(card_id: String, selected: bool, view: PlayingCardView) -> void:
	if is_animating:
		view.set_selected_without_signal(false)
		return
	if selected:
		if selected_cards.size() >= 5:
			AudioManager.play_sfx("ui_error")
			view.set_selected_without_signal(false)
			hand_area.update_selection(selected_cards)
			return
		if not selected_cards.has(card_id):
			AudioManager.play_sfx("select_card")
			selected_cards.append(card_id)
	else:
		AudioManager.play_sfx("deselect_card")
		selected_cards.erase(card_id)
	hand_area.update_selection(selected_cards)
	_update_selected_preview()
	_update_action_buttons()

func _play_selected() -> void:
	if selected_cards.is_empty() or is_animating:
		return
	AudioManager.play_sfx("play_cards")
	_play_selected_with_animation()

func _discard_selected() -> void:
	if selected_cards.is_empty() or is_animating:
		return
	AudioManager.play_sfx("discard_cards")
	Game.run.discard_selected(selected_cards.duplicate())

func _update_action_buttons() -> void:
	var has_selection: bool = not selected_cards.is_empty()
	play_button.disabled = is_animating or not has_selection or Game.run.hands_left <= 0
	discard_button.disabled = is_animating or not has_selection or Game.run.discards_left <= 0

func _update_selected_preview() -> void:
	if selected_cards.is_empty():
		hud.set_hand_preview("选择手牌", "0 x 0", "最多选择 5 张牌")
		chips_value.text = "0"
		mult_value.text = "0"
		return
	var run: RunState = Game.run
	var cards: Array = _cards_by_ids(run.hand, selected_cards)
	var rules: Dictionary = ScoreEngine.build_rules(run)
	var hand_result: Dictionary = HandEvaluator.evaluate(cards, rules)
	var hand_id: String = str(hand_result.get("id", "high_card"))
	var hand_data: Dictionary = DataRegistry.find_by_id("poker_hands", hand_id)
	var level: int = int(run.hand_levels.get(hand_id, 1))
	var chips: int = int(hand_data.get("base_chips", 5)) + (level - 1) * int(hand_data.get("level_chips", 0))
	var mult: int = int(hand_data.get("base_mult", 1)) + (level - 1) * int(hand_data.get("level_mult", 0))
	var scoring_ids: Array = Array(hand_result.get("scoring_ids", []))
	for card in cards:
		if scoring_ids.has(card.get("instance_id", "")):
			chips += CardConstants.card_chip_value(card)
	hud.set_hand_preview("%s  等级%d" % [str(hand_result.get("name_cn", "高牌")), level], "%d x %d" % [chips, mult], "基础预览：%d分" % (chips * mult))
	chips_value.text = str(chips)
	mult_value.text = str(mult)

func _cards_by_ids(cards: Array, ids: Array) -> Array:
	var result: Array = []
	for card in cards:
		var card_id: String = str(card.get("instance_id", ""))
		if ids.has(card_id):
			result.append(card)
	return result

func _play_selected_with_animation() -> void:
	is_animating = true
	_update_action_buttons()
	var selected_copy: Array = _selected_in_hand_order()
	var played_views: Array[PlayingCardView] = hand_area.detach_card_views(selected_copy)
	var result: Dictionary = Game.run.play_selected(selected_copy, false)
	if result.is_empty():
		is_animating = false
		_update_action_buttons()
		return
	var scoring_ids: Array = result.get("scoring_ids", [])
	var score_result: Dictionary = result.get("score_result", {})
	await _animate_played_cards(played_views, scoring_ids, score_result)
	is_animating = false
	selected_cards.clear()
	Game.run.emit_signal("changed")

func _selected_in_hand_order() -> Array:
	var ordered: Array = []
	for card in Game.run.hand:
		var card_id: String = str(card.get("instance_id", ""))
		if selected_cards.has(card_id):
			ordered.append(card_id)
	return ordered

func _animate_played_cards(played_views: Array[PlayingCardView], scoring_ids: Array, score_result: Dictionary) -> void:
	for child in played_area.get_children():
		child.queue_free()
	await get_tree().process_frame
	var card_size: Vector2 = hand_area.card_size
	var count: int = played_views.size()
	var step: float = card_size.x + 22.0
	var total_width: float = card_size.x + step * float(max(count - 1, 0))
	var start_x: float = max(0.0, (played_area.size.x - total_width) * 0.5)
	var local_y: float = max(0.0, (played_area.size.y - card_size.y) * 0.5)
	for i in range(count):
		var view: PlayingCardView = played_views[i]
		var source_global: Vector2 = view.global_position
		view.reparent(played_area, true)
		view.top_level = true
		view.global_position = source_global
		view.size = card_size
		view.scale = Vector2.ONE
		view.toggle_mode = false
		view.set_selected_without_signal(false)
		var target_global: Vector2 = played_area.global_position + Vector2(start_x + step * float(i), local_y)
		var tween: Tween = create_tween()
		tween.set_trans(Tween.TRANS_BACK)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(view, "global_position", target_global, 0.24)
		await tween.finished
		view.top_level = false
		view.position = played_area.get_global_transform().affine_inverse() * target_global
	for view in played_views:
		var card_id: String = str(view.card_data.get("instance_id", ""))
		if scoring_ids.has(card_id):
			var chips: int = CardConstants.card_chip_value(view.card_data)
			AudioManager.play_sfx("chips_count", -4.0, 0.96 + randf() * 0.08)
			await _float_score("+%d" % chips, view.global_position + Vector2(48, -28), Color(0.25, 0.72, 1.0))
	await _animate_joker_effects(Array(score_result.get("joker_effects", [])))
	hud.set_hand_preview(hud.current_hand_label.text, "%d x %d" % [int(score_result.get("chips", 0)), int(score_result.get("mult", 0))], "本次得分：%d" % int(score_result.get("score", 0)))
	AudioManager.play_sfx("multiplier_up", -3.0)
	await _float_score("+%d" % int(score_result.get("score", 0)), hud.score_label.global_position + Vector2(110, -10), Color(1.0, 0.88, 0.32))
	if Game.run.current_score >= Game.run.target_score:
		AudioManager.play_sfx("score_target_reached")
	await get_tree().create_timer(0.18).timeout
	await _clear_played_area()
	hand_area.display_cards(Game.run.sorted_hand_for_display(), [])

func _clear_played_area() -> void:
	if played_area.get_child_count() == 0:
		return
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN)
	for child in played_area.get_children():
		var control: Control = child as Control
		if control == null:
			continue
		tween.parallel().tween_property(control, "modulate:a", 0.0, 0.14)
		tween.parallel().tween_property(control, "position:y", control.position.y - 18.0, 0.14)
	await tween.finished
	for child in played_area.get_children():
		child.queue_free()

func _animate_joker_effects(effects: Array) -> void:
	for effect in effects:
		var effect_data: Dictionary = effect
		var joker_id: String = str(effect_data.get("id", ""))
		if joker_views_by_id.has(joker_id):
			var view: JokerCardView = joker_views_by_id[joker_id]
			AudioManager.play_sfx("joker_trigger", -2.0)
			view.play_trigger()
			await _float_score(str(effect_data.get("text", "")), view.global_position + Vector2(16, view.size.y + 4), Color(1.0, 0.54, 0.28))

func _float_score(text: String, start_position: Vector2, color: Color) -> void:
	var label: Label = FloatingScoreLabelScene.instantiate() as Label
	add_child(label)
	label.text = text
	label.add_theme_color_override("font_color", color)
	label.global_position = start_position
	label.modulate.a = 0.0
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 1.0, 0.08)
	tween.parallel().tween_property(label, "global_position", start_position + Vector2(0, -40), 0.22)
	tween.tween_property(label, "modulate:a", 0.0, 0.16)
	await tween.finished
	label.queue_free()

func _pulse_node(node: Control) -> void:
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", Vector2(1.16, 1.16), 0.10)
	tween.tween_property(node, "scale", Vector2.ONE, 0.14)
