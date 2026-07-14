extends Control

const SCREEN_BY_PHASE = {
	RunState.Phase.HOME: "res://scenes/screens/main_menu_screen.tscn",
	RunState.Phase.DECK_SELECT: "res://scenes/screens/run_setup_screen.tscn",
	RunState.Phase.GAME_OVER: "res://scenes/screens/result_screen.tscn",
	RunState.Phase.VICTORY: "res://scenes/screens/result_screen.tscn",
}
const GAME_TABLE_PATH := "res://scenes/game/game_table_screen.tscn"
const GAMEPLAY_PHASES: Array[int] = [
	RunState.Phase.STAGE_SELECT,
	RunState.Phase.ROUND,
	RunState.Phase.SETTLEMENT,
	RunState.Phase.SHOP,
]

@onready var screen_root: Control = $ScreenRoot

var current_phase: int = -1
var current_screen: Node = null
var current_screen_path: String = ""
var _screen_tween: Tween = null
var _bound_run: RunState = null

func _ready() -> void:
	Game.run_replaced.connect(_bind_run)
	_bind_run()

func _bind_run() -> void:
	if _bound_run != null and _bound_run.changed.is_connected(_on_run_changed):
		_bound_run.changed.disconnect(_on_run_changed)
	_bound_run = Game.run
	if not Game.run.changed.is_connected(_on_run_changed):
		Game.run.changed.connect(_on_run_changed)
	current_phase = -1
	_on_run_changed()

func _on_run_changed() -> void:
	var next_phase: int = Game.run.phase
	_sync_bgm_for_phase(next_phase)
	if GAMEPLAY_PHASES.has(next_phase):
		var entering_table := current_screen_path != GAME_TABLE_PATH or current_screen == null
		if entering_table:
			_load_screen(GAME_TABLE_PATH, true)
		if current_screen != null and current_screen.has_method("set_phase"):
			current_screen.set_phase(next_phase, entering_table)
		current_phase = next_phase
		return
	var next_path: String = SCREEN_BY_PHASE.get(next_phase, SCREEN_BY_PHASE[RunState.Phase.HOME])
	if current_phase == next_phase and current_screen_path == next_path and current_screen != null:
		if current_screen.has_method("refresh"):
			current_screen.refresh()
		return
	current_phase = next_phase
	_load_screen(next_path, true)
	if current_screen != null and current_screen.has_method("refresh"):
		current_screen.refresh()

func _load_screen(path: String, animate: bool) -> void:
	if _screen_tween != null and _screen_tween.is_valid():
		_screen_tween.kill()
	for child in screen_root.get_children():
		child.queue_free()
	var scene: PackedScene = load(path) as PackedScene
	if scene == null:
		push_error("Screen scene missing: " + path)
		return
	current_screen = scene.instantiate()
	current_screen_path = path
	screen_root.add_child(current_screen)
	if current_screen is Control:
		(current_screen as Control).set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		if animate:
			_animate_screen_in(current_screen as Control)

func _animate_screen_in(screen: Control) -> void:
	screen.modulate.a = 0.0
	screen.position.y = 14.0
	_screen_tween = create_tween()
	_screen_tween.set_trans(Tween.TRANS_QUAD)
	_screen_tween.set_ease(Tween.EASE_OUT)
	_screen_tween.tween_property(screen, "modulate:a", 1.0, 0.18)
	_screen_tween.parallel().tween_property(screen, "position:y", 0.0, 0.18)

func _sync_bgm_for_phase(phase: int) -> void:
	match phase:
		RunState.Phase.SHOP:
			AudioManager.play_bgm("shop_loop")
		RunState.Phase.STAGE_SELECT, RunState.Phase.ROUND, RunState.Phase.SETTLEMENT:
			AudioManager.play_bgm("game_loop")
		_:
			AudioManager.play_bgm("menu_loop")
