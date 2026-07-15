extends Node

const RunStateScript = preload("res://scripts/run/run_state.gd")
const PRODUCTION_SCENES: Array[String] = [
	"res://scenes/cards/joker_card_view.tscn",
	"res://scenes/cards/playing_card_view.tscn",
	"res://scenes/game/game_hud_panel.tscn",
	"res://scenes/game/game_table_screen.tscn",
	"res://scenes/game/phases/battle_content.tscn",
	"res://scenes/game/phases/blind_select_panel.tscn",
	"res://scenes/game/phases/settlement_panel.tscn",
	"res://scenes/game/phases/shop_panel.tscn",
	"res://scenes/game/stage_card_view.tscn",
	"res://scenes/game/table/consumable_tray.tscn",
	"res://scenes/game/table/deck_area.tscn",
	"res://scenes/game/table/joker_shelf.tscn",
	"res://scenes/main.tscn",
	"res://scenes/screens/main_menu_screen.tscn",
	"res://scenes/screens/result_screen.tscn",
	"res://scenes/screens/run_setup_screen.tscn",
	"res://scenes/shop/shop_offer_card.tscn",
	"res://scenes/ui/card_detail_popup.tscn",
	"res://scenes/ui/deck_select_screen.tscn",
	"res://scenes/ui/floating_score_label.tscn",
	"res://scenes/ui/main_menu_screen.tscn",
	"res://scenes/ui/result_screen.tscn",
	"res://scenes/ui/shared/bottom_sheet_host.tscn",
	"res://scenes/ui/shared/consumable_slot_view.tscn",
]

var failures: Array[String] = []
var checked_paths: Array[String] = []


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	checked_paths.assign(PRODUCTION_SCENES)
	_expect(not checked_paths.is_empty(), "no production scenes discovered")
	for scene_path: String in checked_paths:
		await _check_scene(scene_path)
	AudioManager.stop_all_sfx()
	AudioManager.stop_bgm()
	print("CHECKED %d production scenes" % checked_paths.size())
	_finish()

func _check_scene(scene_path: String) -> void:
	_prepare_state(scene_path)
	_expect(ResourceLoader.exists(scene_path, "PackedScene"), "resource does not exist: %s" % scene_path)
	var packed := ResourceLoader.load(scene_path, "PackedScene", ResourceLoader.CACHE_MODE_REUSE) as PackedScene
	if packed == null:
		failures.append("load failed: %s" % scene_path)
		return
	var instance := packed.instantiate()
	if instance == null:
		failures.append("instantiate failed: %s" % scene_path)
		return
	add_child(instance)
	await get_tree().process_frame
	await get_tree().process_frame
	_expect(is_instance_valid(instance) and instance.is_inside_tree(), "instance became invalid in tree: %s" % scene_path)
	instance.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
	print("PASS production scene: %s" % scene_path)


func _prepare_state(scene_path: String) -> void:
	if scene_path.ends_with("main_menu_screen.tscn"):
		Game.run.show_home()
		return
	if scene_path.ends_with("deck_select_screen.tscn") or scene_path.ends_with("run_setup_screen.tscn"):
		Game.run.show_deck_select()
		return
	Game.start_new_run("red_deck", "ALL-PRODUCTION-SCENES")
	if scene_path.ends_with("result_screen.tscn"):
		Game.run.phase = RunStateScript.Phase.GAME_OVER
		Game.run.current_score = 120
		Game.run.target_score = 300


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _finish() -> void:
	if failures.is_empty():
		print("PASS test_all_production_scenes")
		get_tree().quit(0)
		return
	for failure: String in failures:
		push_error("test_all_production_scenes: %s" % failure)
	get_tree().quit(1)
