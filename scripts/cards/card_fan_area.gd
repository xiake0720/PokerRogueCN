class_name CardFanArea
extends Control

const PlayingCardViewScene: PackedScene = preload("res://scenes/cards/playing_card_view.tscn")

signal card_selection_changed(card_id: String, selected: bool, view: PlayingCardView)

@export var max_selected: int = 5
@export var card_size: Vector2 = Vector2(144, 204)
@export var selected_lift: float = 46.0
@export var side_padding: float = 24.0
@export var bottom_padding: float = 12.0
@export var preferred_overlap: float = 54.0

var selected_ids: Array = []
var card_views: Array[PlayingCardView] = []
var _known_card_ids: Array[String] = []
var _layout_tweens: Dictionary = {}

func _ready() -> void:
	resized.connect(_layout_cards)

func display_cards(cards: Array, new_selected_ids: Array) -> void:
	var previous_ids: Array[String] = []
	for known_id in _known_card_ids:
		previous_ids.append(known_id)
	selected_ids = new_selected_ids.duplicate()
	for child in get_children():
		remove_child(child)
		child.queue_free()
	card_views.clear()
	_known_card_ids.clear()
	_layout_tweens.clear()
	var new_card_ids: Array[String] = []
	for raw_card in cards:
		var card: Dictionary = raw_card
		var card_id: String = str(card.get("instance_id", ""))
		var view: PlayingCardView = PlayingCardViewScene.instantiate() as PlayingCardView
		add_child(view)
		view.custom_minimum_size = card_size
		view.size = card_size
		view.setup(card)
		view.set_selected_without_signal(selected_ids.has(card_id))
		view.card_selection_changed.connect(_on_view_selection_changed.bind(view))
		card_views.append(view)
		_known_card_ids.append(card_id)
		if not previous_ids.has(card_id):
			new_card_ids.append(card_id)
	call_deferred("_layout_after_container_ready", new_card_ids)

func update_selection(new_selected_ids: Array) -> void:
	selected_ids = new_selected_ids.duplicate()
	for view in card_views:
		var card_id: String = str(view.card_data.get("instance_id", ""))
		view.set_selected_without_signal(selected_ids.has(card_id))
	_layout_cards()

func detach_card_views(card_ids: Array) -> Array[PlayingCardView]:
	var detached: Array[PlayingCardView] = []
	for i in range(card_views.size() - 1, -1, -1):
		var view: PlayingCardView = card_views[i]
		var card_id: String = str(view.card_data.get("instance_id", ""))
		if card_ids.has(card_id):
			detached.append(view)
			card_views.remove_at(i)
			_known_card_ids.erase(card_id)
			selected_ids.erase(card_id)
	detached.reverse()
	_layout_cards()
	return detached

func _on_view_selection_changed(card_id: String, selected: bool, view: PlayingCardView) -> void:
	card_selection_changed.emit(card_id, selected, view)

func _layout_after_container_ready(new_card_ids: Array[String]) -> void:
	await get_tree().process_frame
	_layout_cards(false)
	_animate_cards_in(new_card_ids)

func _layout_cards(animated: bool = true) -> void:
	if card_views.is_empty():
		return
	var count: int = card_views.size()
	var measured_width: float = size.x
	if measured_width < card_size.x:
		measured_width = get_viewport_rect().size.x * 0.72
	var available_width: float = max(card_size.x, measured_width - side_padding * 2.0)
	var step: float = card_size.x - preferred_overlap
	if count > 1:
		step = min(step, max(58.0, (available_width - card_size.x) / float(count - 1)))
	var total_width: float = card_size.x + step * float(count - 1)
	var start_x: float = side_padding + max(0.0, (available_width - total_width) * 0.5)
	var base_y: float = max(0.0, size.y - card_size.y - bottom_padding)
	for i in range(count):
		var view: PlayingCardView = card_views[i]
		var card_id: String = str(view.card_data.get("instance_id", ""))
		var is_selected: bool = selected_ids.has(card_id)
		var target: Vector2 = Vector2(start_x + step * float(i), base_y - (selected_lift if is_selected else 0.0))
		view.z_index = i
		view.size = card_size
		view.custom_minimum_size = card_size
		if _layout_tweens.has(view) and _layout_tweens[view] != null and _layout_tweens[view].is_valid():
			_layout_tweens[view].kill()
		if animated and view.is_inside_tree():
			var tween: Tween = create_tween()
			tween.set_trans(Tween.TRANS_BACK)
			tween.set_ease(Tween.EASE_OUT)
			tween.tween_property(view, "position", target, 0.16)
			_layout_tweens[view] = tween
		else:
			view.position = target

func _animate_cards_in(new_card_ids: Array[String]) -> void:
	for i in range(card_views.size()):
		var view: PlayingCardView = card_views[i]
		var card_id: String = str(view.card_data.get("instance_id", ""))
		if not new_card_ids.has(card_id):
			view.modulate.a = 1.0
			continue
		var target: Vector2 = view.position
		view.position = target + Vector2(0.0, 70.0)
		view.modulate.a = 0.0
		var tween: Tween = create_tween()
		tween.set_trans(Tween.TRANS_QUAD)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_interval(float(new_card_ids.find(card_id)) * 0.045)
		tween.tween_property(view, "position", target, 0.20)
		tween.parallel().tween_property(view, "modulate:a", 1.0, 0.16)
