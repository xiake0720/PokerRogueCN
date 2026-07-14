class_name BattleContent
extends Control

signal inspect_requested(item: Dictionary)

const FloatingScoreLabelScene: PackedScene = preload("res://scenes/ui/floating_score_label.tscn")

@onready var played_area: Control = %PlayedArea
@onready var hand_area: CardFanArea = %HandArea
@onready var play_button: Button = %PlayButton
@onready var sort_rank_button: Button = %SortRankButton
@onready var sort_suit_button: Button = %SortSuitButton
@onready var discard_button: Button = %DiscardButton

var selected_cards: Array = []
var is_animating: bool = false
var _hud: GameHudPanel = null
var _joker_shelf: JokerShelf = null
var _consumable_tray: ConsumableTray = null
var _effects_host: Control = null


func _ready() -> void:
	play_button.pressed.connect(_play_selected)
	discard_button.pressed.connect(_discard_selected)
	sort_rank_button.pressed.connect(func() -> void: Game.run.set_hand_sort_mode("rank"))
	sort_suit_button.pressed.connect(func() -> void: Game.run.set_hand_sort_mode("suit"))
	hand_area.card_selection_changed.connect(_on_card_selection_changed)


func configure_shared(
	hud: GameHudPanel,
	joker_shelf: JokerShelf,
	consumable_tray: ConsumableTray,
	effects_host: Control
) -> void:
	_hud = hud
	_joker_shelf = joker_shelf
	_consumable_tray = consumable_tray
	_effects_host = effects_host
	if not consumable_tray.item_requested.is_connected(_on_consumable_requested):
		consumable_tray.item_requested.connect(_on_consumable_requested)


func set_active(active: bool) -> void:
	visible = active
	mouse_filter = Control.MOUSE_FILTER_PASS if active else Control.MOUSE_FILTER_IGNORE
	set_process_input(active)
	if not active:
		selected_cards.clear()
		hand_area.update_selection([])
		for child: Node in played_area.get_children():
			child.queue_free()


func refresh_run(run: RunState) -> void:
	if is_animating or run.phase != RunState.Phase.ROUND:
		return
	selected_cards.clear()
	hand_area.display_cards(run.sorted_hand_for_display(), selected_cards)
	_update_selected_preview()
	_update_action_buttons()


func _on_consumable_requested(index: int, item: Dictionary) -> void:
	if Game.run.phase != RunState.Phase.ROUND:
		return
	if not Game.run.use_consumable(index, selected_cards.duplicate()):
		inspect_requested.emit(item)


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
	sort_rank_button.button_pressed = Game.run.hand_sort_mode == "rank"
	sort_suit_button.button_pressed = Game.run.hand_sort_mode == "suit"


func _update_selected_preview() -> void:
	if _hud == null:
		return
	if selected_cards.is_empty():
		_hud.set_hand_preview("选择手牌", "0 x 0", "最多选择 5 张牌")
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
	for card: Dictionary in cards:
		if scoring_ids.has(card.get("instance_id", "")):
			chips += CardConstants.card_chip_value(card)
	_hud.set_hand_preview(
		"%s  等级%d" % [str(hand_result.get("name_cn", "高牌")), level],
		"%d x %d" % [chips, mult],
		"基础预览：%d分" % (chips * mult)
	)


func _cards_by_ids(cards: Array, ids: Array) -> Array:
	var result: Array = []
	for card: Dictionary in cards:
		if ids.has(str(card.get("instance_id", ""))):
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
	await _animate_played_cards(
		played_views,
		Array(result.get("scoring_ids", [])),
		result.get("score_result", {}) as Dictionary
	)
	is_animating = false
	selected_cards.clear()
	Game.run.emit_signal("changed")


func _selected_in_hand_order() -> Array:
	var ordered: Array = []
	for card: Dictionary in Game.run.hand:
		var card_id: String = str(card.get("instance_id", ""))
		if selected_cards.has(card_id):
			ordered.append(card_id)
	return ordered


func _animate_played_cards(played_views: Array[PlayingCardView], scoring_ids: Array, score_result: Dictionary) -> void:
	for child: Node in played_area.get_children():
		child.queue_free()
	await get_tree().process_frame
	var card_size: Vector2 = hand_area.card_size
	var count: int = played_views.size()
	var step: float = card_size.x + 22.0
	var total_width: float = card_size.x + step * float(maxi(count - 1, 0))
	var start_x: float = maxf(0.0, (played_area.size.x - total_width) * 0.5)
	var local_y: float = maxf(0.0, (played_area.size.y - card_size.y) * 0.5)
	for i: int in range(count):
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
		var tween: Tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(view, "global_position", target_global, 0.24)
		await tween.finished
		view.top_level = false
		view.position = played_area.get_global_transform().affine_inverse() * target_global
	for view: PlayingCardView in played_views:
		var card_id: String = str(view.card_data.get("instance_id", ""))
		if scoring_ids.has(card_id):
			AudioManager.play_sfx("chips_count", -4.0, 0.96 + randf() * 0.08)
			await _float_score(
				"+%d" % CardConstants.card_chip_value(view.card_data),
				view.global_position + Vector2(48, -28),
				Color(0.25, 0.72, 1.0)
			)
	await _animate_joker_effects(Array(score_result.get("joker_effects", [])))
	if _hud != null:
		_hud.set_hand_preview(
			_hud.current_hand_label.text,
			"%d x %d" % [int(score_result.get("chips", 0)), int(score_result.get("mult", 0))],
			"本次得分：%d" % int(score_result.get("score", 0))
		)
		await _float_score(
			"+%d" % int(score_result.get("score", 0)),
			_hud.score_label.global_position + Vector2(110, -10),
			Color(1.0, 0.88, 0.32)
		)
	AudioManager.play_sfx("multiplier_up", -3.0)
	if Game.run.current_score >= Game.run.target_score:
		AudioManager.play_sfx("score_target_reached")
	await get_tree().create_timer(0.18).timeout
	await _clear_played_area()
	hand_area.display_cards(Game.run.sorted_hand_for_display(), [])


func _clear_played_area() -> void:
	if played_area.get_child_count() == 0:
		return
	var tween: Tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	for child: Node in played_area.get_children():
		var control: Control = child as Control
		if control != null:
			tween.parallel().tween_property(control, "modulate:a", 0.0, 0.14)
			tween.parallel().tween_property(control, "position:y", control.position.y - 18.0, 0.14)
	await tween.finished
	for child: Node in played_area.get_children():
		child.queue_free()


func _animate_joker_effects(effects: Array) -> void:
	if _joker_shelf == null:
		return
	for effect: Dictionary in effects:
		var view: JokerCardView = _joker_shelf.get_view_by_joker_id(str(effect.get("id", "")))
		if view != null:
			AudioManager.play_sfx("joker_trigger", -2.0)
			view.play_trigger()
			await _float_score(
				str(effect.get("text", "")),
				view.global_position + Vector2(16, view.size.y + 4),
				Color(1.0, 0.54, 0.28)
			)


func _float_score(text: String, start_position: Vector2, color: Color) -> void:
	var label: Label = FloatingScoreLabelScene.instantiate() as Label
	(_effects_host if _effects_host != null else self).add_child(label)
	label.text = text
	label.add_theme_color_override("font_color", color)
	label.global_position = start_position
	label.modulate.a = 0.0
	var tween: Tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 1.0, 0.08)
	tween.parallel().tween_property(label, "global_position", start_position + Vector2(0, -40), 0.22)
	tween.tween_property(label, "modulate:a", 0.0, 0.16)
	await tween.finished
	label.queue_free()
