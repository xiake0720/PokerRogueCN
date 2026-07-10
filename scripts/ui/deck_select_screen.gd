extends Control

@onready var main_panel: NinePatchRect = %MainPanel
@onready var deck_stack: Control = %DeckStack
@onready var deck_back: TextureRect = %DeckBack
@onready var deck_name_label: Label = %DeckNameLabel
@onready var deck_desc_label: Label = %DeckDescLabel
@onready var hands_value: Label = %HandsValue
@onready var discards_value: Label = %DiscardsValue
@onready var money_value: Label = %MoneyValue
@onready var hand_size_value: Label = %HandSizeValue
@onready var joker_slots_value: Label = %JokerSlotsValue
@onready var stake_token_label: Label = %StakeTokenLabel
@onready var stake_label: Label = %StakeLabel
@onready var stake_desc_label: Label = %StakeDescLabel
@onready var new_run_button: Button = %NewRunButton
@onready var continue_button: Button = %ContinueButton
@onready var challenge_button: Button = %ChallengeButton
@onready var prev_deck_button: Button = %PrevDeckButton
@onready var next_deck_button: Button = %NextDeckButton
@onready var prev_stake_button: Button = %PrevStakeButton
@onready var next_stake_button: Button = %NextStakeButton
@onready var start_button: Button = %StartButton
@onready var back_button: Button = %BackButton

var decks: Array = []
var deck_index: int = 0
var stake_index: int = 0
var stakes: Array[Dictionary] = [
	{"name": "白注", "token": "白", "desc": "基础规则，适合完整体验。"},
	{"name": "红注", "token": "红", "desc": "目标分提高，资源节奏更紧。"},
	{"name": "绿注", "token": "绿", "desc": "进阶难度，要求更稳定的构筑。"}
]

func _ready() -> void:
	prev_deck_button.pressed.connect(func() -> void: _change_deck(-1))
	next_deck_button.pressed.connect(func() -> void: _change_deck(1))
	prev_stake_button.pressed.connect(func() -> void: _change_stake(-1))
	next_stake_button.pressed.connect(func() -> void: _change_stake(1))
	new_run_button.pressed.connect(func() -> void: stake_index = 0; refresh())
	challenge_button.pressed.connect(func() -> void: Game.run.add_message("挑战模式将在解锁后开放。"))
	start_button.pressed.connect(_start_game)
	back_button.pressed.connect(func() -> void:
		AudioManager.play_sfx("modal_close")
		Game.run.show_home()
	)
	decks = DataRegistry.get_table("decks")
	AudioManager.play_sfx("modal_open")
	_play_intro()
	refresh()

func refresh() -> void:
	if decks.is_empty():
		start_button.disabled = true
		return
	deck_index = clampi(deck_index, 0, decks.size() - 1)
	var deck: Dictionary = decks[deck_index]
	deck_name_label.text = str(deck.get("name_cn", "牌组"))
	deck_desc_label.text = str(deck.get("description_cn", ""))
	hands_value.text = str(int(deck.get("hands", 4)))
	discards_value.text = str(int(deck.get("discards", 3)))
	money_value.text = "$%d" % int(deck.get("start_money", 4))
	hand_size_value.text = str(int(deck.get("hand_size", 8)))
	joker_slots_value.text = str(int(deck.get("joker_slots", 5)))
	var texture: Texture2D = ArtResolver.get_deck_back(str(deck.get("id", "red_deck")))
	for child in deck_stack.get_children():
		if child is TextureRect:
			(child as TextureRect).texture = texture
	deck_back.texture = texture
	var stake: Dictionary = stakes[stake_index]
	stake_token_label.text = str(stake.get("token", "白"))
	stake_label.text = str(stake.get("name", "白注"))
	stake_desc_label.text = str(stake.get("desc", ""))
	start_button.disabled = false

func _change_deck(direction: int) -> void:
	if decks.is_empty():
		return
	AudioManager.play_sfx("deck_switch")
	deck_index = int(posmod(deck_index + direction, decks.size()))
	_pulse(deck_stack)
	refresh()

func _change_stake(direction: int) -> void:
	AudioManager.play_sfx("difficulty_toggle")
	stake_index = int(posmod(stake_index + direction, stakes.size()))
	_pulse(stake_label)
	refresh()

func _start_game() -> void:
	if decks.is_empty():
		return
	AudioManager.play_sfx("ui_click")
	var deck: Dictionary = decks[deck_index]
	Game.start_new_run(str(deck.get("id", "red_deck")))

func _play_intro() -> void:
	main_panel.position.y += 70.0
	main_panel.modulate.a = 0.0
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(main_panel, "position:y", main_panel.position.y - 70.0, 0.24)
	tween.parallel().tween_property(main_panel, "modulate:a", 1.0, 0.2)

func _pulse(node: Control) -> void:
	node.pivot_offset = node.size * 0.5
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", Vector2(1.04, 1.04), 0.08)
	tween.tween_property(node, "scale", Vector2.ONE, 0.12)
