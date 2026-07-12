extends SceneTree

const RunStateScript = preload("res://scripts/run/run_state.gd")
const RESOLUTIONS: Array[Vector2i] = [
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(1920, 1200),
	Vector2i(2520, 1080),
]

const SCENES: Dictionary = {
	"res://scenes/ui/main_menu_screen.tscn": ["TitleGroup", "MenuColumn"],
	"res://scenes/ui/deck_select_screen.tscn": ["DeckStack", "StartButton", "BackButton"],
	"res://scenes/game/stage_select_screen.tscn": ["HUD", "SmallBlindCard", "BossBlindCard"],
	"res://scenes/game/battle_screen.tscn": ["HUD", "HandArea", "PlayButton", "DiscardButton"],
	"res://scenes/game/settlement_screen.tscn": ["HUD", "TotalRow", "ClaimButton"],
	"res://scenes/shop/joker_shop_screen.tscn": ["HUD", "JokerOfferSlot1", "NextButton"],
	"res://scenes/ui/result_screen.tscn": ["TitleLabel", "PrimaryButton", "HomeButton"],
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
				viewport.free()
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
			viewport.free()
			await process_frame
		print("CHECKED UI resolution %dx%d" % [resolution.x, resolution.y])
	root.get_node("AudioManager").stop_all_sfx()
	await process_frame
	_finish()

func _prepare_state(scene_path: String) -> void:
	var game: Node = root.get_node("Game")
	if scene_path.ends_with("main_menu_screen.tscn"):
		game.run.show_home()
		return
	if scene_path.ends_with("deck_select_screen.tscn"):
		game.run.show_deck_select()
		return
	game.start_new_run("red_deck", "UI-RESOLUTION-TEST")
	if scene_path.ends_with("battle_screen.tscn"):
		game.run.start_round()
	elif scene_path.ends_with("settlement_screen.tscn"):
		game.run.phase = RunStateScript.Phase.SETTLEMENT
		game.run.settlement = {"total": 8, "reward": 4, "score": 320, "target": 300}
	elif scene_path.ends_with("joker_shop_screen.tscn"):
		game.run.phase = RunStateScript.Phase.SHOP
		game.run.generate_shop(true)
	elif scene_path.ends_with("result_screen.tscn"):
		game.run.phase = RunStateScript.Phase.GAME_OVER

func _finish() -> void:
	if failures.is_empty():
		print("PASS test_ui_resolutions")
		quit(0)
		return
	for failure: String in failures:
		push_error("test_ui_resolutions: %s" % failure)
	quit(1)
