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


func _ready() -> void:
	battle_content.configure_shared(hud, joker_shelf, consumable_tray, effects_host)
	battle_content.inspect_requested.connect(_show_item_detail)
	joker_shelf.inspect_requested.connect(_show_joker_detail)
	shop_panel.inspect_requested.connect(_show_item_detail)
	_detail_popup = CardDetailPopupScene.instantiate() as CardDetailPopup
	card_detail_host.add_child(_detail_popup)
	set_phase(Game.run.phase, true)


func refresh() -> void:
	if current_phase != Game.run.phase:
		set_phase(Game.run.phase)
		return
	refresh_permanent_ui()
	refresh_phase_content()


func set_phase(phase: int, immediate: bool = false) -> void:
	if is_transitioning:
		pending_phase = phase
	if current_phase == phase and not immediate:
		refresh()
		return
	is_transitioning = true
	current_phase = phase
	pending_phase = -1
	refresh_permanent_ui()
	battle_content.set_active(phase == RunState.Phase.ROUND)
	match phase:
		RunState.Phase.STAGE_SELECT:
			blind_select_panel.refresh_run(Game.run)
			popup_host.replace_panel(blind_select_panel, {"immediate": immediate})
			current_popup = blind_select_panel
		RunState.Phase.ROUND:
			popup_host.hide_current_panel(immediate)
			current_popup = null
			battle_content.refresh_run(Game.run)
		RunState.Phase.SETTLEMENT:
			settlement_panel.refresh_run(Game.run)
			popup_host.replace_panel(settlement_panel, {"immediate": immediate})
			current_popup = settlement_panel
		RunState.Phase.SHOP:
			shop_panel.refresh_run(Game.run)
			popup_host.replace_panel(shop_panel, {"immediate": immediate})
			shop_panel.play_intro()
			current_popup = shop_panel
		_:
			popup_host.hide_current_panel(true)
			current_popup = null
	is_transitioning = false


func refresh_permanent_ui() -> void:
	refresh_hud()
	refresh_jokers()
	refresh_consumables()
	refresh_deck()


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
	current_popup = null


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
