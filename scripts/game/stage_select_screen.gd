extends Control

const StageCardViewScene: PackedScene = preload("res://scenes/game/stage_card_view.tscn")

@onready var hud: GameHudPanel = $Root/HBox/HUD
@onready var board_panel: PanelContainer = $Root/HBox/BoardPanel
@onready var stage_row: HBoxContainer = $Root/HBox/BoardPanel/BoardMargin/BoardVBox/StageRow
@onready var deck_pile_label: Label = $Root/HBox/BoardPanel/BoardMargin/BoardVBox/DeckPileLabel

func _ready() -> void:
	board_panel.add_theme_stylebox_override("panel", _table_style())
	refresh()

func refresh() -> void:
	var run: RunState = Game.run
	hud.refresh_run(run, "stage")
	deck_pile_label.text = "牌库 %d/%d" % [run.full_deck.size(), run.full_deck.size()]
	_rebuild_stages(run)

func _rebuild_stages(run: RunState) -> void:
	for child in stage_row.get_children():
		child.queue_free()
	var names: Array[String] = ["小盲注", "大盲注", "首领盲注"]
	for i in range(3):
		var view: StageCardView = StageCardViewScene.instantiate() as StageCardView
		stage_row.add_child(view)
		view.setup(names[i], run.target_preview_for_stage(i), 3 + i, i == run.blind_index, i < run.blind_index, i < 2)
		if i == run.blind_index:
			view.select_requested.connect(func() -> void: Game.run.start_round())
			view.skip_requested.connect(func() -> void: Game.run.skip_blind())

func _table_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.055, 0.24, 0.16, 0.82)
	style.border_color = Color(0.61, 0.24, 0.16, 1)
	style.set_border_width_all(4)
	style.set_corner_radius_all(8)
	return style
