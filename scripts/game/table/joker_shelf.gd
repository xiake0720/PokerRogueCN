class_name JokerShelf
extends Control

signal inspect_requested(joker: Dictionary)

@onready var count_label: Label = %JokerCountLabel
@onready var slots: Array[JokerCardView] = [
	%JokerSlot1, %JokerSlot2, %JokerSlot3, %JokerSlot4, %JokerSlot5,
	%JokerSlot6, %JokerSlot7,
]

var _allow_sell: bool = false
var _views_by_id: Dictionary = {}


func _ready() -> void:
	for slot: JokerCardView in slots:
		slot.inspect_requested.connect(_on_inspect_requested)
		slot.sell_requested.connect(_on_sell_requested)


func refresh_run(run: RunState, allow_sell: bool = false) -> void:
	_allow_sell = allow_sell
	count_label.text = "小丑牌\n%d/%d" % [run.jokers.size(), run.joker_slots]
	_views_by_id.clear()
	var visible_slot_count: int = mini(slots.size(), maxi(5, run.joker_slots))
	for i: int in range(slots.size()):
		var slot: JokerCardView = slots[i]
		slot.visible = i < visible_slot_count
		if not slot.visible:
			continue
		if i < run.jokers.size():
			var joker: Dictionary = run.jokers[i]
			slot.setup(joker, i, allow_sell)
			_views_by_id[str(joker.get("id", ""))] = slot
		else:
			slot.clear_slot()


func set_sell_enabled(enabled: bool) -> void:
	refresh_run(Game.run, enabled)


func get_view_by_joker_id(joker_id: String) -> JokerCardView:
	return _views_by_id.get(joker_id) as JokerCardView


func _on_inspect_requested(joker: Dictionary) -> void:
	inspect_requested.emit(joker)


func _on_sell_requested(index: int) -> void:
	if not _allow_sell or Game.run.phase != RunState.Phase.SHOP:
		return
	Game.run.sell_joker(index)
