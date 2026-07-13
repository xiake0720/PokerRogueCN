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
	var visible_slot_count: int = mini(slots.size(), maxi(0, run.consumable_slots))
	for i: int in range(slots.size()):
		var slot: PanelContainer = slots[i]
		slot.visible = i < visible_slot_count
		if not slot.visible:
			continue
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
