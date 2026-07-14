extends Node

const RunStateScript = preload("res://scripts/run/run_state.gd")
const SCENE_ROOT := "res://scenes"

var failures: Array[String] = []
var checked_paths: Array[String] = []


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	_collect_scene_paths(SCENE_ROOT, checked_paths)
	checked_paths.sort()
	_expect(not checked_paths.is_empty(), "no production scenes discovered")
	for scene_path: String in checked_paths:
		await _check_scene(scene_path)
	AudioManager.stop_all_sfx()
	AudioManager.stop_bgm()
	print("CHECKED %d production scenes" % checked_paths.size())
	_finish()


func _collect_scene_paths(directory_path: String, output: Array[String]) -> void:
	var directory := DirAccess.open(directory_path)
	if directory == null:
		failures.append("cannot open scene directory: %s" % directory_path)
		return
	directory.list_dir_begin()
	var entry := directory.get_next()
	while not entry.is_empty():
		var entry_path := directory_path.path_join(entry)
		if directory.current_is_dir():
			if not _is_excluded_directory(entry_path):
				_collect_scene_paths(entry_path, output)
		elif entry.ends_with(".tscn") and not _is_excluded_scene(entry_path):
			output.append(entry_path)
		entry = directory.get_next()
	directory.list_dir_end()


func _is_excluded_directory(path: String) -> bool:
	return path.begins_with("res://scenes/debug") or path.contains("/visual_review")


func _is_excluded_scene(path: String) -> bool:
	return path.contains("capture_") or path.contains("temporary_")


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
