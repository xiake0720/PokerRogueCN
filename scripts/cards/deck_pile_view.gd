class_name DeckPileView
extends PanelContainer

@onready var back_texture: TextureRect = $Margin/VBox/BackTexture
@onready var count_label: Label = $Margin/VBox/CountLabel

func setup(deck_id: String, remaining: int, total: int) -> void:
	back_texture.texture = ArtResolver.get_deck_back(deck_id)
	count_label.text = "%d/%d" % [remaining, total]

func set_count(remaining: int, total: int) -> void:
	count_label.text = "%d/%d" % [remaining, total]
