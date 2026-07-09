extends Control

const JokerCardViewScene: PackedScene = preload("res://scenes/cards/joker_card_view.tscn")
const PlayingCardViewScene: PackedScene = preload("res://scenes/cards/playing_card_view.tscn")
const CardDetailPopupScene: PackedScene = preload("res://scenes/ui/card_detail_popup.tscn")

@onready var hud: GameHudPanel = $Root/HBox/HudPanel
@onready var board_panel: PanelContainer = $Root/HBox/BoardPanel
@onready var joker_header: Label = $Root/HBox/BoardPanel/BoardVBox/JokerHeader
@onready var joker_row: HBoxContainer = $Root/HBox/BoardPanel/BoardVBox/JokerRow
@onready var played_area: Control = $Root/HBox/BoardPanel/BoardVBox/PlayArea/PlayedArea
@onready var deck_pile: DeckPileView = $Root/HBox/BoardPanel/BoardVBox/PlayArea/DeckPile
@onready var hand_area: CardFanArea = $Root/HBox/BoardPanel/BoardVBox/HandArea
@onready var play_button: Button = $Root/HBox/BoardPanel/BoardVBox/ActionRow/PlayButton
@onready var sort_rank_button: Button = $Root/HBox/BoardPanel/BoardVBox/ActionRow/SortRankButton
@onready var sort_suit_button: Button = $Root/HBox/BoardPanel/BoardVBox/ActionRow/SortSuitButton
@onready var discard_button: Button = $Root/HBox/BoardPanel/BoardVBox/ActionRow/DiscardButton

var selected_cards: Array = []
var is_animating: bool = false
var joker_views_by_id: Dictionary = {}
var detail_popup: CardDetailPopup

func _ready() -> void:
	board_panel.add_theme_stylebox_override("panel", _table_style())
	play_button.pressed.connect(_play_selected)
	discard_button.pressed.connect(_discard_selected)
	sort_rank_button.pressed.connect(func() -> void: Game.run.set_hand_sort_mode("rank"))
	sort_suit_button.pressed.connect(func() -> void: Game.run.set_hand_sort_mode("suit"))
	hand_area.card_selection_changed.connect(_on_card_selection_changed)
	hud.hand_detail_requested.connect(_show_hand_detail)
	detail_popup = CardDetailPopupScene.instantiate() as CardDetailPopup
	add_child(detail_popup)
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
	hud.set_deck_text(run.deck.size(), run.discard_pile.size())
	deck_pile.setup(run.deck.size(), run.full_deck.size())
	_rebuild_hand(run)
	_rebuild_jokers(run)
	_update_selected_preview()
	_update_action_buttons()

func _rebuild_hand(run: RunState) -> void:
	hand_area.set_deal_source_global_position(deck_pile.global_position + deck_pile.size * 0.5)
	hand_area.display_cards(run.hand, selected_cards)

func _rebuild_jokers(run: RunState) -> void:
	joker_header.text = "小丑牌 %d/%d" % [run.jokers.size(), run.joker_slots]
	joker_views_by_id.clear()
	for child in joker_row.get_children():
		child.queue_free()
	for i in range(run.jokers.size()):
		var view: JokerCardView = JokerCardViewScene.instantiate() as JokerCardView
		joker_row.add_child(view)
		view.setup(run.jokers[i], i, false)
		view.inspect_requested.connect(func(joker: Dictionary) -> void: detail_popup.show_joker(joker))
		joker_views_by_id[str(run.jokers[i].get("id", ""))] = view
		view.modulate.a = 0.0
		view.position.y += 16.0
		var tween: Tween = create_tween()
		tween.tween_interval(float(i) * 0.035)
		tween.tween_property(view, "modulate:a", 1.0, 0.16)

func _on_card_selection_changed(card_id: String, selected: bool, view: PlayingCardView) -> void:
	if is_animating:
		view.set_selected_without_signal(false)
		return
	if selected:
		if selected_cards.size() >= 5:
			view.set_selected_without_signal(false)
			hand_area.update_selection(selected_cards)
			return
		if not selected_cards.has(card_id):
			selected_cards.append(card_id)
	else:
		selected_cards.erase(card_id)
	hand_area.update_selection(selected_cards)
	_update_selected_preview()
	_update_action_buttons()

func _play_selected() -> void:
	if selected_cards.is_empty() or is_animating:
		return
	_play_selected_with_animation()

func _discard_selected() -> void:
	if selected_cards.is_empty() or is_animating:
		return
	Game.run.discard_selected(selected_cards.duplicate())

func _update_action_buttons() -> void:
	var has_selection: bool = not selected_cards.is_empty()
	play_button.disabled = is_animating or not has_selection or Game.run.hands_left <= 0
	discard_button.disabled = is_animating or not has_selection or Game.run.discards_left <= 0

func _update_selected_preview() -> void:
	if selected_cards.is_empty():
		hud.set_selected_preview("选择手牌", 0, 0, 0, "最多选择 5 张牌")
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
	var preview_score: int = chips * mult
	hud.set_selected_preview(str(hand_result.get("name_cn", "高牌")), level, chips, mult, "基础预览：%d分" % preview_score)

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
	var selected_copy: Array = hand_area.ordered_selected_ids(selected_cards)
	var source_positions: Dictionary = {}
	for view in hand_area.card_views:
		var card_id: String = str(view.card_data.get("instance_id", ""))
		if selected_copy.has(card_id):
			source_positions[card_id] = view.global_position

	# 出牌区复用手牌里的 PlayingCardView，不再创建第二套卡牌节点，确保手牌和出牌区尺寸完全一致。
	var detached_views: Array[PlayingCardView] = hand_area.detach_views(selected_copy)
	var result: Dictionary = Game.run.play_selected(selected_copy, false)
	if result.is_empty():
		is_animating = false
		selected_cards.clear()
		Game.run.emit_signal("changed")
		return

	var scoring_ids: Array = Array(result.get("scoring_ids", []))
	var score_result_value: Variant = result.get("score_result", {})
	var score_result: Dictionary = score_result_value if score_result_value is Dictionary else {}
	await _animate_played_cards(detached_views, scoring_ids, score_result, source_positions)
	is_animating = false
	selected_cards.clear()
	Game.run.emit_signal("changed")

func _animate_played_cards(played_views: Array[PlayingCardView], scoring_ids: Array, score_result: Dictionary, source_positions: Dictionary) -> void:
	_clear_played_area_immediately()
	await get_tree().process_frame
	var target_positions: Dictionary = _played_card_targets(played_views.size())

	for i in range(played_views.size()):
		var view: PlayingCardView = played_views[i]
		var card_id: String = str(view.card_data.get("instance_id", ""))
		var source_position: Vector2 = view.global_position
		var stored_source: Variant = source_positions.get(card_id, source_position)
		if stored_source is Vector2:
			source_position = stored_source
		var target_local: Vector2 = target_positions.get(i, Vector2.ZERO)
		var target_global: Vector2 = played_area.get_global_transform() * target_local

		var old_parent: Node = view.get_parent()
		if old_parent != null:
			old_parent.remove_child(view)
		played_area.add_child(view)
		view.reset_visual_state()
		view.toggle_mode = false
		view.custom_minimum_size = hand_area.card_size
		view.size = hand_area.card_size
		view.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		view.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		view.set_interactive(false)
		view.modulate.a = 1.0
		view.scale = Vector2.ONE
		view.pivot_offset = hand_area.card_size * 0.5
		view.top_level = true
		view.global_position = source_position

		var tween: Tween = create_tween()
		tween.set_trans(Tween.TRANS_QUAD)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(view, "global_position", target_global, 0.26)
		await tween.finished
		view.top_level = false
		view.position = target_local
		view.scale = Vector2.ONE
		view.modulate.a = 1.0
		await get_tree().create_timer(0.055).timeout

	await get_tree().create_timer(0.12).timeout

	for view in played_views:
		var card_id: String = str(view.card_data.get("instance_id", ""))
		if scoring_ids.has(card_id):
			var chips: int = CardConstants.card_chip_value(view.card_data)
			await _float_score("+%d" % chips, view.global_position + Vector2(42, -42), Color(0.25, 0.72, 1.0))
	await _animate_joker_effects(Array(score_result.get("joker_effects", [])))

	hud.set_selected_preview("本次得分", 1, int(score_result.get("chips", 0)), int(score_result.get("mult", 0)), "+%d分" % int(score_result.get("score", 0)))
	await _float_score("+%d" % int(score_result.get("score", 0)), hud.score_label.global_position + Vector2(130, -18), Color(1.0, 0.88, 0.32))
	await get_tree().create_timer(0.18).timeout
	await _clear_played_area()

func _played_card_targets(count: int) -> Dictionary:
	var targets: Dictionary = {}
	if count <= 0:
		return targets
	var card_size: Vector2 = hand_area.card_size
	var step: float = card_size.x + 24.0
	var max_width: float = max(card_size.x, played_area.size.x - 48.0)
	if count > 1:
		step = min(step, (max_width - card_size.x) / float(count - 1))
	step = max(card_size.x * 0.72, step)
	var total_width: float = card_size.x + step * float(count - 1)
	var start_x: float = max(0.0, (played_area.size.x - total_width) * 0.5)
	var y: float = max(0.0, (played_area.size.y - card_size.y) * 0.5)
	for i in range(count):
		targets[i] = Vector2(start_x + step * float(i), y)
	return targets

func _clear_played_area_immediately() -> void:
	for child in played_area.get_children():
		child.queue_free()

func _clear_played_area() -> void:
	var children: Array = played_area.get_children()
	if children.is_empty():
		return
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN)
	for child in children:
		if child is Control:
			var control: Control = child as Control
			tween.parallel().tween_property(control, "modulate:a", 0.0, 0.16)
			tween.parallel().tween_property(control, "position:y", control.position.y - 24.0, 0.16)
	await tween.finished
	for child in played_area.get_children():
		child.queue_free()

func _animate_joker_effects(effects: Array) -> void:
	for effect in effects:
		var effect_data: Dictionary = effect
		var joker_id: String = str(effect_data.get("id", ""))
		if joker_views_by_id.has(joker_id):
			var view: JokerCardView = joker_views_by_id[joker_id]
			_pulse_node(view)
			await _float_score(str(effect_data.get("text", "")), view.global_position + Vector2(24, view.size.y + 8), Color(1.0, 0.54, 0.28))

func _float_score(text: String, start_position: Vector2, color: Color) -> void:
	var label: Label = Label.new()
	add_child(label)
	label.text = text
	label.add_theme_font_size_override("font_size", 42)
	label.add_theme_color_override("font_color", color)
	label.global_position = start_position
	label.z_index = 500
	label.modulate.a = 0.0
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 1.0, 0.08)
	tween.parallel().tween_property(label, "global_position", start_position + Vector2(0, -52), 0.22)
	tween.tween_property(label, "modulate:a", 0.0, 0.16)
	await tween.finished
	label.queue_free()

func _pulse_node(node: Control) -> void:
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", Vector2(1.16, 1.16), 0.10)
	tween.tween_property(node, "scale", Vector2.ONE, 0.14)

func _show_hand_detail(hand_id: String) -> void:
	var hand_data: Dictionary = DataRegistry.find_by_id("poker_hands", hand_id)
	if hand_data.is_empty():
		return
	detail_popup.show_hand(hand_data, int(Game.run.hand_levels.get(hand_id, 1)))

func _table_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.32, 0.08, 0.035, 0.88)
	style.border_color = Color(0.48, 0.17, 0.08)
	style.set_border_width_all(5)
	style.set_corner_radius_all(15)
	style.content_margin_left = 27
	style.content_margin_top = 18
	style.content_margin_right = 27
	style.content_margin_bottom = 18
	return style
