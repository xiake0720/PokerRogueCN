extends Control

const StageCardViewScene: PackedScene = preload("res://scenes/game/stage_card_view.tscn")
const CardDetailPopupScene: PackedScene = preload("res://scenes/ui/card_detail_popup.tscn")

@onready var hud: GameHudPanel = $Root/HBox/HudPanel
@onready var board_panel: PanelContainer = $Root/HBox/BoardPanel
@onready var stage_row: HBoxContainer = $Root/HBox/BoardPanel/BoardVBox/StageRow
@onready var deck_pile_label: Label = $Root/HBox/BoardPanel/BoardVBox/DeckPileLabel

var detail_popup: CardDetailPopup

func _ready() -> void:
	board_panel.add_theme_stylebox_override("panel", _table_style())
	hud.hand_detail_requested.connect(_show_hand_detail)
	detail_popup = CardDetailPopupScene.instantiate() as CardDetailPopup
	add_child(detail_popup)
	refresh()

func refresh() -> void:
	var run: RunState = Game.run
	hud.refresh_run(run, "stage")
	deck_pile_label.text = "牌库 %d/%d" % [run.full_deck.size(), run.full_deck.size()]
	_rebuild_stages(run)

func _rebuild_stages(run: RunState) -> void:
	for child in stage_row.get_children():
		child.queue_free()
	var names: Array[String] = ["小关卡", "中关卡", "首领关卡"]
	for i in range(3):
		var view: StageCardView = StageCardViewScene.instantiate() as StageCardView
		stage_row.add_child(view)
		view.setup(names[i], run.target_preview_for_stage(i), 3 + i, i == run.blind_index, i < run.blind_index, i < 2)
		if i == run.blind_index:
			view.select_requested.connect(func() -> void: Game.run.start_round())
			view.skip_requested.connect(func() -> void: Game.run.skip_blind())

func _show_hand_detail(hand_id: String) -> void:
	var hand_data: Dictionary = DataRegistry.find_by_id("poker_hands", hand_id)
	if hand_data.is_empty():
		return
	detail_popup.show_hand(hand_data, int(Game.run.hand_levels.get(hand_id, 1)))

func _table_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.28, 0.2, 0.86)
	style.border_color = Color(0.12, 0.52, 0.38)
	style.set_border_width_all(5)
	style.set_corner_radius_all(15)
	style.content_margin_left = 27
	style.content_margin_top = 21
	style.content_margin_right = 27
	style.content_margin_bottom = 21
	return style
