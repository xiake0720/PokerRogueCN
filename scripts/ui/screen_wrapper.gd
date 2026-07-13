extends Control

@onready var content: Control = get_child(0) as Control


func refresh() -> void:
	if content != null and content.has_method("refresh"):
		content.refresh()
