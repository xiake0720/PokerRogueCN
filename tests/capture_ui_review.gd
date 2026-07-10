extends Control

const RunStateScript = preload("res://scripts/run/run_state.gd")
const OUTPUT_DIR := "res://artifacts/ui_review"
const CAPTURES: Array[Dictionary] = [
	{"name": "home", "scene": "res://scenes/ui/main_menu_screen.tscn"},
	{"name": "deck_select", "scene": "res://scenes/ui/deck_select_screen.tscn"},
	{"name": "stage_select", "scene": "res://scenes/game/stage_select_screen.tscn"},
	{"name": "battle", "scene": "res://scenes/game/battle_screen.tscn"},
	{"name": "settlement", "scene": "res://scenes/game/settlement_screen.tscn"},
	{"name": "shop", "scene": "res://scenes/shop/joker_shop_screen.tscn"},
	{"name": "victory", "scene": "res://scenes/ui/result_screen.tscn"},
	{"name": "game_over", "scene": "res://scenes/ui/result_screen.tscn"},
]

var failures: Array[String] = []

func _ready() -> void:
	_run.call_deferred()

func _run() -> void:
	get_window().size = Vector2i(1920, 1080)
	get_window().content_scale_size = Vector2i(1920, 1080)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	for capture: Dictionary in CAPTURES:
		_prepare_state(str(capture.name))
		var packed: PackedScene = load(str(capture.scene)) as PackedScene
		if packed == null:
			failures.append("cannot load %s" % capture.scene)
			continue
		var screen: Node = packed.instantiate()
		add_child(screen)
		if screen is Control:
			(screen as Control).set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		await get_tree().process_frame
		await get_tree().process_frame
		await get_tree().create_timer(0.3).timeout
		RenderingServer.force_draw()
		await get_tree().process_frame
		var image: Image = get_viewport().get_texture().get_image()
		var output_path := "%s/%s.png" % [OUTPUT_DIR, capture.name]
		var save_error: Error = image.save_png(output_path)
		if save_error != OK:
			failures.append("failed to save %s: %s" % [output_path, error_string(save_error)])
		else:
			print("CAPTURED %s (%dx%d)" % [output_path, image.get_width(), image.get_height()])
		screen.free()
		await get_tree().process_frame
	_finish()

func _prepare_state(capture_name: String) -> void:
	var game: Node = get_node("/root/Game")
	match capture_name:
		"home":
			game.run.show_home()
		"deck_select":
			game.run.show_deck_select()
		_:
			game.start_new_run("red_deck", "UI-REVIEW-2026")
			_decorate_run()
			match capture_name:
				"battle":
					game.run.start_round()
				"settlement":
					game.run.phase = RunStateScript.Phase.SETTLEMENT
					game.run.current_score = 1240
					game.run.target_score = 900
					game.run.hands_left = 2
					game.run.settlement = {
						"stage_name": "大盲注", "reward": 5, "hand_bonus": 2,
						"interest": 3, "tag_bonus": 4, "voucher_bonus": 1,
						"other_bonus": 0, "total": 15, "score": 1240,
						"target": 900, "claimed": false,
					}
				"shop":
					game.run.phase = RunStateScript.Phase.SHOP
					game.run.money = 28
					game.run.generate_shop(true)
				"victory":
					game.run.phase = RunStateScript.Phase.VICTORY
					game.run.ante = 9
					game.run.current_score = 182400
				"game_over":
					game.run.phase = RunStateScript.Phase.GAME_OVER
					game.run.ante = 4
					game.run.current_score = 7800
					game.run.target_score = 12000

func _decorate_run() -> void:
	var registry: Node = get_node("/root/DataRegistry")
	var run = get_node("/root/Game").run
	run.money = 23
	run.jokers = [
		registry.find_by_id("jokers", "joker"),
		registry.find_by_id("jokers", "greedy_joker"),
		registry.find_by_id("jokers", "fibonacci"),
	]
	run.consumables = [
		registry.find_by_id("tarot_cards", "the_fool"),
		registry.find_by_id("planet_cards", "mercury"),
	]
	run.total_hand_counts["pair"] = 8
	run.total_hand_counts["flush"] = 5

func _finish() -> void:
	if failures.is_empty():
		print("PASS capture_ui_review")
		get_tree().quit(0)
		return
	for failure: String in failures:
		push_error("capture_ui_review: %s" % failure)
	get_tree().quit(1)
