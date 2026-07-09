class_name CardFanArea
extends Control

const PlayingCardViewScene: PackedScene = preload("res://scenes/cards/playing_card_view.tscn")

signal card_selection_changed(card_id: String, selected: bool, view: PlayingCardView)

@export var max_selected: int = 5
@export var card_size: Vector2 = Vector2(144, 204)
@export var selected_lift: float = 52.0
@export var side_padding: float = 24.0
@export var bottom_padding: float = 12.0
@export var preferred_overlap: float = 30.0
@export var minimum_step: float = 76.0

var selected_ids: Array = []
var card_views: Array[PlayingCardView] = []
var previous_card_ids: Array[String] = []
var deal_source_global_position: Vector2 = Vector2.ZERO
var _layout_tweens: Dictionary = {}
var _layout_generation: int = 0

func _ready() -> void:
	resized.connect(_on_resized)

func set_deal_source_global_position(global_position: Vector2) -> void:
	deal_source_global_position = global_position

func display_cards(cards: Array, new_selected_ids: Array) -> void:
	_layout_generation += 1
	selected_ids = new_selected_ids.duplicate()
	var current_ids: Array[String] = []
	for raw_card in cards:
		var card: Dictionary = raw_card
		current_ids.append(str(card.get("instance_id", "")))

	var old_views: Dictionary = {}
	for view in card_views:
		var old_id: String = str(view.card_data.get("instance_id", ""))
		old_views[old_id] = view

	for view in card_views:
		var view_id: String = str(view.card_data.get("instance_id", ""))
		if not current_ids.has(view_id):
			_kill_tween(view_id)
			view.queue_free()

	var new_views: Array[PlayingCardView] = []
	var entering_ids: Array[String] = []
	for i in range(cards.size()):
		var card_data: Dictionary = cards[i]
		var card_id: String = str(card_data.get("instance_id", ""))
		var view: PlayingCardView
		if old_views.has(card_id) and is_instance_valid(old_views[card_id]):
			view = old_views[card_id] as PlayingCardView
			view.setup(card_data)
		else:
			view = PlayingCardViewScene.instantiate() as PlayingCardView
			add_child(view)
			view.card_selection_changed.connect(_on_view_selection_changed.bind(view))
			entering_ids.append(card_id)
		_configure_card_view(view, card_data, selected_ids.has(card_id))
		new_views.append(view)
		move_child(view, i)

	card_views = new_views
	previous_card_ids.clear()
	for copied_id in current_ids:
		previous_card_ids.append(copied_id)
	call_deferred("_layout_after_container_ready", entering_ids, _layout_generation)

func update_selection(new_selected_ids: Array) -> void:
	selected_ids = new_selected_ids.duplicate()
	for view in card_views:
		var card_id: String = str(view.card_data.get("instance_id", ""))
		view.set_selected_without_signal(selected_ids.has(card_id))
	_layout_cards(true)

func compact_after_removal(removed_ids: Array) -> void:
	_layout_generation += 1
	var remaining: Array[PlayingCardView] = []
	previous_card_ids.clear()
	for view in card_views:
		var card_id: String = str(view.card_data.get("instance_id", ""))
		if removed_ids.has(card_id):
			_kill_tween(card_id)
			view.queue_free()
		else:
			remaining.append(view)
			previous_card_ids.append(card_id)
	card_views = remaining
	selected_ids.clear()
	_layout_cards(true)

func detach_views(card_ids: Array) -> Array[PlayingCardView]:
	_layout_generation += 1
	var detached: Array[PlayingCardView] = []
	var remaining: Array[PlayingCardView] = []
	previous_card_ids.clear()
	for view in card_views:
		var card_id: String = str(view.card_data.get("instance_id", ""))
		if card_ids.has(card_id):
			_kill_tween(card_id)
			view.set_selected_without_signal(false)
			view.set_interactive(false)
			detached.append(view)
		else:
			remaining.append(view)
			previous_card_ids.append(card_id)
	card_views = remaining
	selected_ids.clear()
	_layout_cards(true)
	return detached

func ordered_selected_ids(raw_selected_ids: Array) -> Array:
	var ordered: Array = []
	for view in card_views:
		var card_id: String = str(view.card_data.get("instance_id", ""))
		if raw_selected_ids.has(card_id):
			ordered.append(card_id)
	return ordered

func _on_resized() -> void:
	_layout_cards(false)

func _configure_card_view(view: PlayingCardView, card_data: Dictionary, selected: bool) -> void:
	view.custom_minimum_size = card_size
	view.size = card_size
	view.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	view.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	view.scale = Vector2.ONE
	view.pivot_offset = card_size * 0.5
	view.setup(card_data)
	view.set_interactive(true)
	view.set_selected_without_signal(selected)
	view.modulate.a = 1.0

func _on_view_selection_changed(card_id: String, selected: bool, view: PlayingCardView) -> void:
	card_selection_changed.emit(card_id, selected, view)

func _layout_after_container_ready(entering_ids: Array, generation: int) -> void:
	await get_tree().process_frame
	if generation != _layout_generation:
		return
	_layout_cards(true, entering_ids)
	_animate_cards_in(entering_ids, generation)

func _layout_cards(animated: bool = true, skip_ids: Array = []) -> void:
	if card_views.is_empty():
		return
	var targets: Dictionary = _calculate_targets()
	for i in range(card_views.size()):
		var view: PlayingCardView = card_views[i]
		var card_id: String = str(view.card_data.get("instance_id", ""))
		if not targets.has(card_id):
			continue
		view.z_index = i
		if skip_ids.has(card_id):
			continue
		_move_view_to(card_id, view, targets[card_id], animated, 0.14)

func _calculate_targets() -> Dictionary:
	var targets: Dictionary = {}
	var count: int = card_views.size()
	if count <= 0:
		return targets
	var measured_width: float = size.x
	if measured_width < card_size.x:
		measured_width = get_viewport_rect().size.x * 0.72
	var available_width: float = max(card_size.x, measured_width - side_padding * 2.0)
	var step: float = card_size.x - preferred_overlap
	if count > 1:
		var fitted_step: float = (available_width - card_size.x) / float(count - 1)
		step = min(card_size.x - preferred_overlap, max(minimum_step, fitted_step))
	var total_width: float = card_size.x + step * float(count - 1)
	var start_x: float = side_padding + max(0.0, (available_width - total_width) * 0.5)
	var base_y: float = max(0.0, size.y - card_size.y - bottom_padding)
	for i in range(count):
		var view: PlayingCardView = card_views[i]
		var card_id: String = str(view.card_data.get("instance_id", ""))
		var is_selected: bool = selected_ids.has(card_id)
		targets[card_id] = Vector2(start_x + step * float(i), base_y - (selected_lift if is_selected else 0.0))
	return targets

func _animate_cards_in(entering_ids: Array, generation: int) -> void:
	if entering_ids.is_empty():
		return
	var targets: Dictionary = _calculate_targets()
	var delay_index: int = 0
	for view in card_views:
		var card_id: String = str(view.card_data.get("instance_id", ""))
		if not entering_ids.has(card_id):
			continue
		if not targets.has(card_id):
			continue
		_kill_tween(card_id)
		var target: Vector2 = targets[card_id]
		var start_position: Vector2 = target + Vector2(0.0, 72.0)
		if deal_source_global_position != Vector2.ZERO:
			start_position = get_global_transform().affine_inverse() * deal_source_global_position - card_size * 0.5
		view.position = start_position
		view.scale = Vector2.ONE
		view.modulate.a = 0.0
		var tween: Tween = create_tween()
		_layout_tweens[card_id] = tween
		tween.set_trans(Tween.TRANS_QUAD)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_interval(float(delay_index) * 0.075)
		tween.tween_property(view, "position", target, 0.24)
		tween.parallel().tween_property(view, "modulate:a", 1.0, 0.14)
		tween.tween_callback(func() -> void:
			if generation == _layout_generation:
				view.position = target
				view.scale = Vector2.ONE
				view.modulate.a = 1.0
		)
		delay_index += 1

func _move_view_to(card_id: String, view: PlayingCardView, target: Vector2, animated: bool, duration: float) -> void:
	_kill_tween(card_id)
	if animated and view.is_inside_tree():
		var tween: Tween = create_tween()
		_layout_tweens[card_id] = tween
		tween.set_trans(Tween.TRANS_QUAD)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(view, "position", target, duration)
		tween.tween_callback(func() -> void:
			view.position = target
		)
	else:
		view.position = target

func _kill_tween(card_id: String) -> void:
	if _layout_tweens.has(card_id):
		var tween_value: Variant = _layout_tweens[card_id]
		if tween_value is Tween:
			var tween: Tween = tween_value
			if tween.is_valid():
				tween.kill()
		_layout_tweens.erase(card_id)
