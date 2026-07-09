class_name DeckOptionView
extends PanelContainer

signal deck_selected(deck_id: String)

@onready var name_label: Label = $Row/InfoBox/NameLabel
@onready var desc_label: Label = $Row/InfoBox/DescLabel
@onready var select_button: Button = $Row/SelectButton

var deck_id: String = ""

func _ready() -> void:
	add_theme_stylebox_override("panel", _panel_style())
	select_button.pressed.connect(func(): deck_selected.emit(deck_id))

func setup(deck: Dictionary) -> void:
	deck_id = str(deck.get("id", "red_deck"))
	name_label.text = deck.get("name_cn", "")
	desc_label.text = deck.get("description_cn", "")

func _panel_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.18, 0.22, 0.96)
	style.border_color = Color(0.36, 0.43, 0.52)
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.content_margin_left = 14
	style.content_margin_top = 12
	style.content_margin_right = 14
	style.content_margin_bottom = 12
	return style
