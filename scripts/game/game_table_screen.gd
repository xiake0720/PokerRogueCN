class_name GameTableScreen
extends Control

const CardDetailPopupScene: PackedScene = preload("res://scenes/ui/card_detail_popup.tscn")

@onready var hud: GameHudPanel = %GameHudPanel
@onready var joker_shelf: JokerShelf = %JokerShelf
@onready var consumable_tray: ConsumableTray = %ConsumableTray
@onready var deck_area: DeckArea = %DeckArea
@onready var battle_content: BattleContent = %BattleContent
@onready var blind_select_panel: BlindSelectPanel = %BlindSelectPanel
@onready var settlement_panel: SettlementPanel = %SettlementPanel
@onready var shop_panel: ShopPanel = %ShopPanel
@onready var popup_host: BottomSheetHost = %BottomSheetHost
@onready var modal_dim: ColorRect = %ModalDim
@onready var effects_host: Control = %FloatingScoreHost
@onready var card_detail_host: Control = %CardDetailHost

var current_phase: int = -1
var pending_phase: int = -1
var is_transitioning: bool = false
var current_popup: Control = null
var _detail_popup: CardDetailPopup = null
var _pending_immediate: bool = false


func _ready() -> void:
	battle_content.configure_shared(hud, joker_shelf, consumable_tray, effects_host)
	battle_content.inspect_requested.connect(_show_item_detail)
	joker_shelf.inspect_requested.connect(_show_joker_detail)
	shop_panel.inspect_requested.connect(_show_item_detail)
	popup_host.transition_started.connect(_on_popup_transition_started)
	popup_host.transition_finished.connect(_on_popup_transition_finished)
	popup_host.panel_shown.connect(_on_popup_panel_shown)
	popup_host.panel_hidden.connect(_on_popup_panel_hidden)
	_detail_popup = CardDetailPopupScene.instantiate() as CardDetailPopup
	card_detail_host.add_child(_detail_popup)


func refresh() -> void:
	if current_phase != Game.run.phase:
		set_phase(Game.run.phase)
		return
	refresh_permanent_ui()
	refresh_phase_content()


func set_phase(phase: int, immediate: bool = false) -> void:
	if is_transitioning:
		pending_phase = phase
		_pending_immediate = immediate
		return
	if current_phase == phase and not immediate:
		refresh_permanent_ui()
		refresh_phase_content()
		return
	current_phase = phase
	refresh_permanent_ui()
	battle_content.set_active(phase == RunState.Phase.ROUND)
	match phase:
		RunState.Phase.STAGE_SELECT:
			blind_select_panel.refresh_run(Game.run)
			popup_host.replace_panel(blind_select_panel, {"immediate": immediate})
		RunState.Phase.ROUND:
			popup_host.hide_current_panel(immediate)
			battle_content.refresh_run(Game.run)
		RunState.Phase.SETTLEMENT:
			settlement_panel.refresh_run(Game.run)
			popup_host.replace_panel(settlement_panel, {"immediate": immediate})
		RunState.Phase.SHOP:
			shop_panel.refresh_run(Game.run)
			popup_host.replace_panel(shop_panel, {"immediate": immediate})
			shop_panel.play_intro()
		_:
			popup_host.hide_current_panel(true)
	if not popup_host.is_transitioning:
		_sync_current_popup()
		_consume_pending_phase()


func refresh_permanent_ui() -> void:
	_apply_phase_visibility()
	refresh_hud()
	refresh_jokers()
	refresh_consumables()
	refresh_deck()


func _apply_phase_visibility() -> void:
	var is_battle := current_phase == RunState.Phase.ROUND
	var is_shop := current_phase == RunState.Phase.SHOP
	var is_stage_select := current_phase == RunState.Phase.STAGE_SELECT
	joker_shelf.visible = is_battle or is_shop
	consumable_tray.visible = is_battle
	deck_area.visible = is_battle or is_stage_select
	popup_host.dim_blocks_input = not is_shop
	popup_host.dim_alpha = 0.08 if is_shop else 0.14
	var joker_area := joker_shelf.get_parent() as Control
	if joker_area != null:
		joker_area.anchor_left = 0.39 if is_shop else 0.01
		joker_area.anchor_top = 0.015
		joker_area.anchor_right = 0.995 if is_shop else 0.72
		joker_area.anchor_bottom = 0.285 if is_shop else 0.245
		joker_area.offset_left = 0.0
		joker_area.offset_top = 0.0
		joker_area.offset_right = 0.0
		joker_area.offset_bottom = 0.0


func refresh_hud() -> void:
	hud.refresh_run(Game.run, _hud_mode_for_phase(current_phase))


func refresh_jokers() -> void:
	joker_shelf.refresh_run(Game.run, current_phase == RunState.Phase.SHOP)


func refresh_consumables() -> void:
	consumable_tray.refresh_run(Game.run, current_phase == RunState.Phase.ROUND)


func refresh_deck() -> void:
	deck_area.refresh_run(Game.run, current_phase == RunState.Phase.ROUND)


func refresh_phase_content() -> void:
	match current_phase:
		RunState.Phase.STAGE_SELECT:
			blind_select_panel.refresh_run(Game.run)
		RunState.Phase.ROUND:
			battle_content.refresh_run(Game.run)
		RunState.Phase.SETTLEMENT:
			settlement_panel.refresh_run(Game.run)
		RunState.Phase.SHOP:
			shop_panel.refresh_run(Game.run)


func show_blind_select() -> void:
	set_phase(RunState.Phase.STAGE_SELECT)


func show_battle() -> void:
	set_phase(RunState.Phase.ROUND)


func show_settlement() -> void:
	set_phase(RunState.Phase.SETTLEMENT)


func show_shop() -> void:
	set_phase(RunState.Phase.SHOP)


func hide_popup() -> void:
	popup_host.hide_current_panel()


func _on_popup_transition_started() -> void:
	is_transitioning = true


func _on_popup_transition_finished() -> void:
	is_transitioning = false
	_sync_current_popup()
	_consume_pending_phase()


func _on_popup_panel_shown(panel: Control) -> void:
	current_popup = panel


func _on_popup_panel_hidden(panel: Control) -> void:
	if current_popup == panel:
		current_popup = null


func _sync_current_popup() -> void:
	current_popup = popup_host.current_panel


func _consume_pending_phase() -> void:
	if pending_phase < 0:
		return
	var next_phase := pending_phase
	var next_immediate := _pending_immediate
	pending_phase = -1
	_pending_immediate = false
	if next_phase == current_phase and not next_immediate:
		refresh_permanent_ui()
		refresh_phase_content()
		return
	set_phase(next_phase, next_immediate)


func _hud_mode_for_phase(phase: int) -> String:
	match phase:
		RunState.Phase.STAGE_SELECT:
			return "stage"
		RunState.Phase.ROUND:
			return "battle"
		RunState.Phase.SETTLEMENT:
			return "settlement"
		RunState.Phase.SHOP:
			return "shop"
		_:
			return "battle"


func _show_joker_detail(joker: Dictionary) -> void:
	if _detail_popup != null:
		_detail_popup.show_joker(joker)


func _show_item_detail(item: Dictionary) -> void:
	if _detail_popup != null:
		_detail_popup.show_item(item)
