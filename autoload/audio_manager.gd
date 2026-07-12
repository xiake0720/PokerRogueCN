extends Node

const BGM: Dictionary = {
	"menu_loop": preload("res://assets/audio/bgm/menu_loop.ogg"),
	"game_loop": preload("res://assets/audio/bgm/game_loop.ogg"),
	"shop_loop": preload("res://assets/audio/bgm/shop_loop.ogg")
}

const SFX: Dictionary = {
	"ui_click": preload("res://assets/audio/sfx/ui_click.wav"),
	"ui_hover_tick": preload("res://assets/audio/sfx/ui_hover_tick.wav"),
	"ui_error": preload("res://assets/audio/sfx/ui_error.wav"),
	"modal_open": preload("res://assets/audio/sfx/modal_open.wav"),
	"modal_close": preload("res://assets/audio/sfx/modal_close.wav"),
	"deck_switch": preload("res://assets/audio/sfx/deck_switch.wav"),
	"difficulty_toggle": preload("res://assets/audio/sfx/difficulty_toggle.wav"),
	"deal_card": preload("res://assets/audio/sfx/deal_card.wav"),
	"select_card": preload("res://assets/audio/sfx/select_card.wav"),
	"deselect_card": preload("res://assets/audio/sfx/deselect_card.wav"),
	"play_cards": preload("res://assets/audio/sfx/play_cards.wav"),
	"discard_cards": preload("res://assets/audio/sfx/discard_cards.wav"),
	"flip_card": preload("res://assets/audio/sfx/flip_card.wav"),
	"chips_count": preload("res://assets/audio/sfx/chips_count.wav"),
	"multiplier_up": preload("res://assets/audio/sfx/multiplier_up.wav"),
	"joker_trigger": preload("res://assets/audio/sfx/joker_trigger.wav"),
	"joker_rare_trigger": preload("res://assets/audio/sfx/joker_rare_trigger.wav"),
	"score_target_reached": preload("res://assets/audio/sfx/score_target_reached.wav"),
	"round_fail": preload("res://assets/audio/sfx/round_fail.wav"),
	"purchase_card": preload("res://assets/audio/sfx/purchase_card.wav"),
	"sell_card": preload("res://assets/audio/sfx/sell_card.wav"),
	"shop_reroll": preload("res://assets/audio/sfx/shop_reroll.wav"),
	"booster_open": preload("res://assets/audio/sfx/booster_open.wav"),
	"tarot_use": preload("res://assets/audio/sfx/tarot_use.wav"),
	"planet_use": preload("res://assets/audio/sfx/planet_use.wav"),
	"spectral_use": preload("res://assets/audio/sfx/spectral_use.wav"),
	"card_upgrade": preload("res://assets/audio/sfx/card_upgrade.wav"),
	"card_destroy": preload("res://assets/audio/sfx/card_destroy.wav"),
	"shuffle_cards": preload("res://assets/audio/sfx/shuffle_cards.wav")
}

var bgm_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []
var current_bgm: String = ""


func _ready() -> void:
	bgm_player = AudioStreamPlayer.new()
	bgm_player.volume_db = -10.0
	add_child(bgm_player)
	bgm_player.finished.connect(_on_bgm_finished)
	for i in range(12):
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		player.volume_db = -2.0
		add_child(player)
		sfx_players.append(player)


func play_bgm(audio_key: String) -> void:
	if audio_key == current_bgm:
		return
	if not BGM.has(audio_key):
		push_warning("Unknown BGM: " + audio_key)
		return
	current_bgm = audio_key
	bgm_player.stop()
	bgm_player.stream = BGM[audio_key]
	bgm_player.play()


func stop_bgm() -> void:
	current_bgm = ""
	bgm_player.stop()


func stop_all_sfx() -> void:
	for player: AudioStreamPlayer in sfx_players:
		player.stop()


func play_sfx(audio_key: String, volume_db: float = 0.0, pitch_scale: float = 1.0) -> void:
	if not SFX.has(audio_key):
		push_warning("Unknown SFX: " + audio_key)
		return
	var player: AudioStreamPlayer = _next_sfx_player()
	player.stop()
	player.stream = SFX[audio_key]
	player.volume_db = -2.0 + volume_db
	player.pitch_scale = pitch_scale
	player.play()


func _next_sfx_player() -> AudioStreamPlayer:
	for player in sfx_players:
		if not player.playing:
			return player
	return sfx_players[0]


func _on_bgm_finished() -> void:
	if current_bgm != "":
		bgm_player.play()
