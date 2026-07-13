class_name DeckArea
extends Control

@onready var deck_pile: Control = %DeckPile
@onready var deck_count_label: Label = %DeckCountLabel
@onready var discard_count_label: Label = %DiscardCountLabel


func refresh_run(run: RunState, active_round: bool) -> void:
	var back_texture: Texture2D = ArtResolver.get_deck_back(run.deck_id)
	for child: Node in deck_pile.get_children():
		if child is TextureRect:
			(child as TextureRect).texture = back_texture
	var remaining: int = run.deck.size() if active_round else run.full_deck.size()
	deck_count_label.text = "%d/%d" % [remaining, run.full_deck.size()]
	discard_count_label.text = "弃牌堆\n%d" % run.discard_pile.size()
	modulate = Color.WHITE if active_round else Color(0.72, 0.78, 0.72, 1.0)
