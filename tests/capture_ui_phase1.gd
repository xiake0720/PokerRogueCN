extends Control

const OUTPUT_DIR := "res://artifacts/ui_phase1_after"
const RESOLUTIONS: Array[Vector2i] = [Vector2i(1280, 720), Vector2i(1920, 1080)]
const STATES: Array[String] = ["battle", "blind_select", "shop", "settlement"]

var _active_root: Node = null
var _failures: Array[String] = []


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	var requested_state := _requested_state()
	for state_name: String in STATES:
		if not requested_state.is_empty() and state_name != requested_state:
			continue
		for resolution: Vector2i in RESOLUTIONS:
			await _capture_state(state_name, resolution)
	await _cleanup_active()
	if _failures.is_empty():
		print("PASS capture_ui_phase1")
		get_tree().quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	get_tree().quit(1)


func _capture_state(state_name: String, resolution: Vector2i) -> void:
	await _cleanup_active()
	get_window().content_scale_size = resolution
	get_window().size = resolution
	_prepare_run(state_name)
	var packed := load("res://scenes/game/game_table_screen.tscn") as PackedScene
	if packed == null:
		_failures.append("cannot load game table for %s" % state_name)
		return
	_active_root = packed.instantiate()
	add_child(_active_root)
	if _active_root is Control:
		(_active_root as Control).set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	await get_tree().process_frame
	await get_tree().process_frame
	var table := _active_root as GameTableScreen
	table.set_phase(Game.run.phase, true)
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.35).timeout
	RenderingServer.force_draw()
	await get_tree().process_frame
	var image := get_viewport().get_texture().get_image()
	var output_path := "%s/%s_%dx%d.png" % [OUTPUT_DIR, state_name, resolution.x, resolution.y]
	var save_error := image.save_png(output_path)
	if save_error != OK:
		_failures.append("save failed %s: %s" % [output_path, error_string(save_error)])
	else:
		print("CAPTURED %s" % output_path)


func _prepare_run(state_name: String) -> void:
	Game.start_new_run("red_deck", "UI-PHASE1-REVIEW")
	Game.run.money = 28
	Game.run.jokers = [
		DataRegistry.find_by_id("jokers", "joker"),
		DataRegistry.find_by_id("jokers", "greedy_joker"),
		DataRegistry.find_by_id("jokers", "fibonacci"),
	]
	Game.run.consumables = [
		DataRegistry.find_by_id("tarot_cards", "fool"),
		DataRegistry.find_by_id("planet_cards", "mercury"),
	]
	match state_name:
		"battle":
			Game.run.start_round()
		"blind_select":
			Game.run.phase = RunState.Phase.STAGE_SELECT
		"shop":
			Game.run.phase = RunState.Phase.SHOP
			Game.run.generate_shop(true)
		"settlement":
			Game.run.phase = RunState.Phase.SETTLEMENT
			Game.run.current_score = 1240
			Game.run.target_score = 900
			Game.run.settlement = {
				"stage_name": "大盲注",
				"reward": 5,
				"hand_bonus": 2,
				"interest": 3,
				"tag_bonus": 4,
				"voucher_bonus": 1,
				"other_bonus": 0,
				"total": 15,
				"score": 1240,
				"target": 900,
				"claimed": false,
			}


func _requested_state() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--state="):
			return argument.trim_prefix("--state=")
	return ""


func _cleanup_active() -> void:
	if _active_root != null and is_instance_valid(_active_root):
		_active_root.queue_free()
		await get_tree().process_frame
	_active_root = null
