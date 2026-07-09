extends Control

@onready var dimmer: ColorRect = $Dimmer
@onready var dialog: PanelContainer = $Center/Dialog
@onready var deck_card: PanelContainer = $Center/Dialog/Margin/VBox/DeckRow/DeckCard
@onready var deck_back: PanelContainer = $Center/Dialog/Margin/VBox/DeckRow/DeckCard/DeckCardMargin/DeckInfoRow/DeckBack
@onready var deck_name_label: Label = $Center/Dialog/Margin/VBox/DeckRow/DeckCard/DeckCardMargin/DeckInfoRow/DeckText/DeckNameLabel
@onready var deck_desc_label: Label = $Center/Dialog/Margin/VBox/DeckRow/DeckCard/DeckCardMargin/DeckInfoRow/DeckText/DeckDescLabel
@onready var deck_stats_label: Label = $Center/Dialog/Margin/VBox/DeckRow/DeckCard/DeckCardMargin/DeckInfoRow/DeckText/DeckStatsLabel
@onready var stake_label: Label = $Center/Dialog/Margin/VBox/DifficultyRow/DifficultyPanel/DifficultyVBox/StakeLabel
@onready var stake_desc_label: Label = $Center/Dialog/Margin/VBox/DifficultyRow/DifficultyPanel/DifficultyVBox/StakeDescLabel
@onready var prev_deck_button: Button = $Center/Dialog/Margin/VBox/DeckRow/PrevDeckButton
@onready var next_deck_button: Button = $Center/Dialog/Margin/VBox/DeckRow/NextDeckButton
@onready var prev_stake_button: Button = $Center/Dialog/Margin/VBox/DifficultyRow/PrevStakeButton
@onready var next_stake_button: Button = $Center/Dialog/Margin/VBox/DifficultyRow/NextStakeButton
@onready var start_button: Button = $Center/Dialog/Margin/VBox/StartButton
@onready var back_button: Button = $Center/Dialog/Margin/VBox/BackButton

var decks: Array = []
var deck_index: int = 0
var stake_index: int = 0
var stakes: Array[Dictionary] = [
	{"name": "白注", "desc": "基础难度，适合完整测试流程。"},
	{"name": "红注", "desc": "目标分略高，奖励节奏更紧。"},
	{"name": "绿注", "desc": "进阶难度，适合熟悉规则后挑战。"}
]

func _ready() -> void:
	dialog.add_theme_stylebox_override("panel", _panel_style())
	deck_card.add_theme_stylebox_override("panel", _inner_panel_style())
	deck_back.add_theme_stylebox_override("panel", _deck_back_style(Color(0.75, 0.18, 0.12)))
	prev_deck_button.pressed.connect(func() -> void: _change_deck(-1))
	next_deck_button.pressed.connect(func() -> void: _change_deck(1))
	prev_stake_button.pressed.connect(func() -> void: _change_stake(-1))
	next_stake_button.pressed.connect(func() -> void: _change_stake(1))
	start_button.pressed.connect(_start_game)
	back_button.pressed.connect(func() -> void: Game.run.show_home())
	decks = DataRegistry.get_table("decks")
	_play_intro()
	refresh()

func refresh() -> void:
	if decks.is_empty():
		return
	var deck: Dictionary = decks[deck_index]
	deck_name_label.text = str(deck.get("name_cn", "牌组"))
	deck_desc_label.text = str(deck.get("description_cn", ""))
	deck_stats_label.text = "回合 %d  弃牌 %d  资金 $%d  小丑槽 %d" % [
		int(deck.get("hands", 4)),
		int(deck.get("discards", 3)),
		int(deck.get("start_money", 4)),
		int(deck.get("joker_slots", 5))
	]
	var colors: Array[Color] = [Color(0.72, 0.12, 0.08), Color(0.08, 0.34, 0.72), Color(0.9, 0.58, 0.08), Color(0.1, 0.1, 0.12)]
	deck_back.add_theme_stylebox_override("panel", _deck_back_style(colors[deck_index % colors.size()]))
	var stake: Dictionary = stakes[stake_index]
	stake_label.text = str(stake.get("name", "白注"))
	stake_desc_label.text = str(stake.get("desc", ""))

func _change_deck(direction: int) -> void:
	if decks.is_empty():
		return
	deck_index = int(posmod(deck_index + direction, decks.size()))
	_pulse(deck_card)
	refresh()

func _change_stake(direction: int) -> void:
	stake_index = int(posmod(stake_index + direction, stakes.size()))
	_pulse(stake_label)
	refresh()

func _start_game() -> void:
	if decks.is_empty():
		return
	var deck: Dictionary = decks[deck_index]
	Game.start_new_run(str(deck.get("id", "red_deck")))

func _play_intro() -> void:
	dimmer.modulate.a = 0.0
	dialog.position.y += 80.0
	dialog.modulate.a = 0.0
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(dimmer, "modulate:a", 1.0, 0.18)
	tween.parallel().tween_property(dialog, "position:y", dialog.position.y - 80.0, 0.22)
	tween.parallel().tween_property(dialog, "modulate:a", 1.0, 0.18)

func _pulse(node: Control) -> void:
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", Vector2(1.04, 1.04), 0.08)
	tween.tween_property(node, "scale", Vector2.ONE, 0.12)

func _panel_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.16, 0.26, 0.28, 0.98)
	style.border_color = Color(0.72, 0.8, 0.86)
	style.set_border_width_all(5)
	style.set_corner_radius_all(12)
	return style

func _inner_panel_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.14, 0.16, 0.94)
	style.border_color = Color(0.05, 0.09, 0.1)
	style.set_border_width_all(6)
	style.set_corner_radius_all(12)
	return style

func _deck_back_style(color: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = Color(0.95, 0.94, 0.86)
	style.set_border_width_all(6)
	style.set_corner_radius_all(12)
	style.content_margin_left = 12
	style.content_margin_top = 12
	style.content_margin_right = 12
	style.content_margin_bottom = 12
	return style
