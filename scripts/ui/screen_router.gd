extends Control

const SCREEN_BY_PHASE = {
	RunState.Phase.HOME: "res://scenes/ui/main_menu_screen.tscn",
	RunState.Phase.DECK_SELECT: "res://scenes/ui/deck_select_screen.tscn",
	RunState.Phase.STAGE_SELECT: "res://scenes/game/stage_select_screen.tscn",
	RunState.Phase.ROUND: "res://scenes/game/battle_screen.tscn",
	RunState.Phase.SETTLEMENT: "res://scenes/game/settlement_screen.tscn",
	RunState.Phase.SHOP: "res://scenes/shop/joker_shop_screen.tscn",
	RunState.Phase.GAME_OVER: "res://scenes/ui/result_screen.tscn",
	RunState.Phase.VICTORY: "res://scenes/ui/result_screen.tscn"
}

@onready var screen_root: Control = $ScreenRoot

var current_phase: int = -1
var current_screen: Node = null

func _ready() -> void:
	Game.run_replaced.connect(_bind_run)
	_bind_run()

func _bind_run() -> void:
	if not Game.run.changed.is_connected(_on_run_changed):
		Game.run.changed.connect(_on_run_changed)
	current_phase = -1
	_on_run_changed()

func _on_run_changed() -> void:
	if current_phase == Game.run.phase and current_screen != null:
		if current_screen.has_method("refresh"):
			current_screen.refresh()
		return
	current_phase = Game.run.phase
	_load_screen(SCREEN_BY_PHASE.get(current_phase, SCREEN_BY_PHASE[RunState.Phase.HOME]))

func _load_screen(path: String) -> void:
	for child in screen_root.get_children():
		child.queue_free()
	var scene: PackedScene = load(path) as PackedScene
	if scene == null:
		push_error("Screen scene missing: " + path)
		return
	current_screen = scene.instantiate()
	screen_root.add_child(current_screen)
	if current_screen is Control:
		(current_screen as Control).set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_animate_screen_in(current_screen as Control)
	if current_screen.has_method("refresh"):
		current_screen.refresh()

func _animate_screen_in(screen: Control) -> void:
	screen.modulate.a = 0.0
	screen.position.y = 14.0
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(screen, "modulate:a", 1.0, 0.18)
	tween.parallel().tween_property(screen, "position:y", 0.0, 0.18)
