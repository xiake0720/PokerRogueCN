extends SceneTree

const RunStateScript = preload("res://scripts/run/run_state.gd")
const RESOLUTIONS: Array[Vector2i] = [
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440),
	Vector2i(1920, 1200),
	Vector2i(2520, 1080),
]

const SCENES: Dictionary = {
	"res://scenes/screens/main_menu_screen.tscn": ["TitleGroup", "MenuColumn"],
	"res://scenes/screens/run_setup_screen.tscn": ["DeckStack", "StartButton", "BackButton"],
	"res://scenes/game/game_table_screen.tscn": [
		"GameHudPanel", "JokerShelf", "ConsumableTray", "DeckArea", "HandArea",
		"BlindSelectPanel", "SettlementPanel", "ShopPanel",
	],
	"res://scenes/screens/result_screen.tscn": ["TitleLabel", "PrimaryButton", "HomeButton"],
}

var failures: Array[String] = []

func _init() -> void:
	_run.call_deferred()

func _run() -> void:
	for resolution: Vector2i in RESOLUTIONS:
		for scene_path_value: Variant in SCENES:
			var scene_path := str(scene_path_value)
			_prepare_state(scene_path)
			var viewport := SubViewport.new()
			viewport.size = resolution
			viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
			root.add_child(viewport)
			var packed: PackedScene = load(scene_path) as PackedScene
			if packed == null:
				failures.append("cannot load %s" % scene_path)
				viewport.queue_free()
				await process_frame
				continue
			var screen: Control = packed.instantiate() as Control
			viewport.add_child(screen)
			screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			await process_frame
			await process_frame
			await process_frame
			var bounds := Rect2(Vector2.ZERO, Vector2(resolution))
			for node_name: String in SCENES[scene_path]:
				var control := screen.find_child(node_name, true, false) as Control
				if control == null:
					failures.append("%s missing %s" % [scene_path, node_name])
					continue
				if not bounds.intersects(control.get_global_rect(), true):
					failures.append("%s %s outside %s" % [scene_path, node_name, resolution])
			_check_buttons(screen, scene_path, resolution, bounds)
			if scene_path.ends_with("game_table_screen.tscn"):
				await _check_game_table_phases(screen, scene_path, resolution, bounds)
			screen.queue_free()
			await process_frame
			viewport.queue_free()
			await process_frame
			packed = null
			screen = null
			await process_frame
		print("CHECKED UI resolution %dx%d" % [resolution.x, resolution.y])
	root.get_node("AudioManager").stop_all_sfx()
	root.get_node("AudioManager").stop_bgm()
	# Let queued deletes, tweens, and cached audio streams release before the
	# SceneTree exits.  One frame is not sufficient in non-verbose headless runs.
	await create_timer(0.1).timeout
	await process_frame
	await process_frame
	await process_frame
	await process_frame
	call_deferred("_finish")

func _check_buttons(screen: Control, scene_path: String, resolution: Vector2i, bounds: Rect2) -> void:
	var buttons: Array[Button] = []
	_collect_buttons(screen, buttons)
	for button: Button in buttons:
		if not button.is_visible_in_tree():
			continue
		var rect := button.get_global_rect()
		if not bounds.intersects(rect, true):
			failures.append("%s %s button outside %s" % [scene_path, button.name, resolution])
		if button.size.x + 0.5 < button.custom_minimum_size.x or button.size.y + 0.5 < button.custom_minimum_size.y:
			failures.append("%s %s compressed below minimum at %s" % [scene_path, button.name, resolution])
		if not button.text.is_empty():
			var font := button.get_theme_font("font")
			var font_size := button.get_theme_font_size("font_size")
			var text_width := 0.0
			for line: String in button.text.split("\n"):
				text_width = maxf(text_width, font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x)
			if text_width > maxf(button.size.x - 12.0, 1.0):
				failures.append("%s %s text overflows at %s" % [scene_path, button.name, resolution])
	for i in range(buttons.size()):
		var first := buttons[i]
		if not first.is_visible_in_tree() or first.flat:
			continue
		for j in range(i + 1, buttons.size()):
			var second := buttons[j]
			if not second.is_visible_in_tree() or second.flat or first.get_parent() != second.get_parent():
				continue
			if first.get_global_rect().intersects(second.get_global_rect(), false):
				failures.append("%s sibling buttons %s/%s overlap at %s" % [scene_path, first.name, second.name, resolution])

func _collect_buttons(node: Node, result: Array[Button]) -> void:
	if node is Button:
		result.append(node as Button)
	for child in node.get_children():
		_collect_buttons(child, result)


func _check_game_table_phases(table: Control, scene_path: String, resolution: Vector2i, bounds: Rect2) -> void:
	if not table.has_method("set_phase"):
		failures.append("%s is missing set_phase at %s" % [scene_path, resolution])
		return
	var phases: Array[int] = [
		RunStateScript.Phase.ROUND,
		RunStateScript.Phase.SETTLEMENT,
		RunStateScript.Phase.SHOP,
		RunStateScript.Phase.STAGE_SELECT,
	]
	for phase: int in phases:
		_prepare_game_table_phase(phase)
		table.call("set_phase", phase, true)
		await process_frame
		await process_frame
		for node_name: String in ["GameHudPanel", "JokerShelf", "ConsumableTray", "DeckArea"]:
			var control := table.find_child(node_name, true, false) as Control
			if control == null or not bounds.intersects(control.get_global_rect(), true):
				failures.append("%s %s outside %s in phase %d" % [scene_path, node_name, resolution, phase])
		_check_buttons(table, "%s phase %d" % [scene_path, phase], resolution, bounds)


func _prepare_game_table_phase(phase: int) -> void:
	var game: Node = root.get_node("Game")
	if phase == RunStateScript.Phase.ROUND:
		if game.run.phase != RunStateScript.Phase.STAGE_SELECT:
			game.start_new_run("red_deck", "UI-RESOLUTION-PHASE")
		game.run.start_round()
		return
	if phase == RunStateScript.Phase.SETTLEMENT:
		game.run.phase = phase
		game.run.settlement = {"total": 8, "reward": 4, "score": 320, "target": 300, "claimed": false}
		return
	if phase == RunStateScript.Phase.SHOP:
		game.run.phase = phase
		game.run.generate_shop(true)
		return
	game.run.phase = RunStateScript.Phase.STAGE_SELECT

func _prepare_state(scene_path: String) -> void:
	var game: Node = root.get_node("Game")
	if scene_path.ends_with("screens/main_menu_screen.tscn"):
		game.run.show_home()
		return
	if scene_path.ends_with("run_setup_screen.tscn"):
		game.run.show_deck_select()
		return
	game.start_new_run("red_deck", "UI-RESOLUTION-TEST")
	if scene_path.ends_with("result_screen.tscn"):
		game.run.phase = RunStateScript.Phase.GAME_OVER

func _finish() -> void:
	if failures.is_empty():
		print("PASS test_ui_resolutions")
		quit(0)
		return
	for failure: String in failures:
		push_error("test_ui_resolutions: %s" % failure)
	quit(1)
