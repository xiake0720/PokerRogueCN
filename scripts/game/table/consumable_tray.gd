class_name ConsumableTray
extends Control

signal item_requested(index: int, item: Dictionary)

@onready var count_label: Label = %ConsumableCountLabel
@onready var slots: Array[PanelContainer] = [
	%ConsumableSlot1, %ConsumableSlot2, %ConsumableSlot3, %ConsumableSlot4,
]

var _interactive: bool = false


func _ready() -> void:
	for i: int in range(slots.size()):
		slots[i].gui_input.connect(_on_slot_gui_input.bind(i))


func refresh_run(run: RunState, interactive: bool = false) -> void:
	_interactive = interactive
	count_label.text = "%d/%d" % [run.consumables.size(), run.consumable_slots]
	var slot_size := Vector2(100, 145) * clampf(get_viewport_rect().size.x / 1920.0, 0.72, 1.08)
	var visible_item_count: int = mini(slots.size(), run.consumables.size())
	for i: int in range(slots.size()):
		var slot: PanelContainer = slots[i]
		slot.custom_minimum_size = slot_size
		slot.visible = i < visible_item_count
		if not slot.visible:
			continue
		var art: TextureRect = slot.get_node("Content/ArtTexture") as TextureRect
		var name_label: Label = slot.get_node("Content/NameLabel") as Label
		var item: Dictionary = run.consumables[i]
		var kind: String = str(item.get("kind", item.get("type", "tarot")))
		art.texture = ArtResolver.get_consumable_art(kind, str(item.get("id", "")))
		name_label.text = str(item.get("name_cn", "消耗牌"))
		slot.tooltip_text = "%s\n%s" % [name_label.text, str(item.get("description_cn", ""))]
		slot.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if interactive else Control.CURSOR_ARROW


func _on_slot_gui_input(event: InputEvent, index: int) -> void:
	if not _interactive or not (event is InputEventMouseButton):
		return
	var mouse_event: InputEventMouseButton = event as InputEventMouseButton
	if not mouse_event.pressed or mouse_event.button_index != MOUSE_BUTTON_LEFT:
		return
	if index < 0 or index >= Game.run.consumables.size():
		return
	item_requested.emit(index, Game.run.consumables[index])
