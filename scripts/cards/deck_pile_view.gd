class_name DeckPileView
extends PanelContainer

@onready var back_label: Label = $Margin/VBox/BackLabel
@onready var count_label: Label = $Margin/VBox/CountLabel

func _ready() -> void:
	add_theme_stylebox_override("panel", _panel_style())
	back_label.add_theme_font_size_override("font_size", 28)
	count_label.add_theme_font_size_override("font_size", 22)

func setup(current_count: int, total_count: int) -> void:
	back_label.text = "牌背"
	count_label.text = "%d/%d" % [current_count, total_count]

func _panel_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.92, 0.66, 0.12, 0.98)
	style.border_color = Color(0.96, 0.92, 0.78)
	style.set_border_width_all(5)
	style.set_corner_radius_all(12)
	style.content_margin_left = 10
	style.content_margin_top = 10
	style.content_margin_right = 10
	style.content_margin_bottom = 10
	return style
