class_name OrnateTitleBanner
extends NinePatchRect

@export var title_text: String = "" :
	set(value):
		title_text = value
		_apply_text()
@export var subtitle_text: String = "" :
	set(value):
		subtitle_text = value
		_apply_text()
@export_range(24, 96, 1) var title_font_size: int = 52 :
	set(value):
		title_font_size = value
		_apply_text()
@export_range(14, 32, 1) var subtitle_font_size: int = 20 :
	set(value):
		subtitle_font_size = value
		_apply_text()


func _ready() -> void:
	_apply_text()


func _apply_text() -> void:
	var title_label := get_node_or_null("TitleLabel") as Label
	var subtitle_label := get_node_or_null("SubtitleLabel") as Label
	if title_label != null:
		title_label.text = title_text
		title_label.add_theme_font_size_override("font_size", title_font_size)
	if subtitle_label != null:
		subtitle_label.text = subtitle_text
		subtitle_label.visible = not subtitle_text.is_empty()
		subtitle_label.add_theme_font_size_override("font_size", subtitle_font_size)
