extends Control

@onready var hud: GameHudPanel = $Root/HBox/HUD
@onready var stage_cards: Array[StageCardView] = [
	$Root/HBox/BoardPanel/BoardMargin/BoardVBox/StageRow/SmallBlindCard,
	$Root/HBox/BoardPanel/BoardMargin/BoardVBox/StageRow/BigBlindCard,
	$Root/HBox/BoardPanel/BoardMargin/BoardVBox/StageRow/BossBlindCard,
]
@onready var deck_pile_label: Label = $Root/HBox/BoardPanel/BoardMargin/BoardVBox/DeckPileLabel

func _ready() -> void:
	for i in range(stage_cards.size()):
		stage_cards[i].select_requested.connect(_on_stage_select_requested.bind(i))
		stage_cards[i].skip_requested.connect(_on_stage_skip_requested.bind(i))
	refresh()

func refresh() -> void:
	var run: RunState = Game.run
	hud.refresh_run(run, "stage")
	deck_pile_label.text = "牌库 %d/%d" % [run.full_deck.size(), run.full_deck.size()]
	_refresh_stages(run)

func _refresh_stages(run: RunState) -> void:
	var names: Array[String] = ["小关卡", "中关卡", "首领关卡"]
	for i in range(stage_cards.size()):
		stage_cards[i].setup(names[i], run.target_preview_for_stage(i), 3 + i, i == run.blind_index, i < run.blind_index, i < 2)

func _on_stage_select_requested(index: int) -> void:
	if index == Game.run.blind_index:
		Game.run.start_round()

func _on_stage_skip_requested(index: int) -> void:
	if index == Game.run.blind_index and index < 2:
		Game.run.skip_blind()
