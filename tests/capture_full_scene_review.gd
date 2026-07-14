extends Control

const OUTPUT_ROOT := "res://artifacts/final_scene_review"
const RESOLUTIONS: Array[Vector2i] = [
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440),
	Vector2i(1920, 1200),
	Vector2i(2520, 1080),
]
const RESOLUTION_STATES: Array[String] = [
	"home_default", "run_setup_default", "blind_select_default", "battle_default",
	"settlement_complete", "shop_default", "result_victory", "result_game_over",
	"card_detail_long", "shop_pack_open",
]
const EXTRA_STATES: Array[String] = [
	"home_start_hover", "home_options_hover", "home_language_hover",
	"run_setup_continue_disabled", "run_setup_continue_enabled", "run_setup_challenge",
	"run_setup_prev_deck_hover", "run_setup_start_hover",
	"battle_one_selected", "battle_multi_selected", "battle_sort_rank", "battle_sort_suit",
	"battle_play_disabled", "battle_discard_disabled", "settlement_claim_disabled",
	"shop_insufficient_funds", "shop_joker_slots_full", "shop_item_sold",
	"card_detail_joker", "card_detail_tarot", "card_detail_planet", "card_detail_playing_card",
]
const FULL_SCREEN_SCENES: Array[String] = [
	"res://scenes/main.tscn",
	"res://scenes/screens/main_menu_screen.tscn",
	"res://scenes/screens/run_setup_screen.tscn",
	"res://scenes/screens/result_screen.tscn",
	"res://scenes/ui/main_menu_screen.tscn",
	"res://scenes/ui/deck_select_screen.tscn",
	"res://scenes/ui/result_screen.tscn",
	"res://scenes/game/game_table_screen.tscn",
]

var failures: Array[String] = []
var _active_root: Node = null


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_ROOT))
	for resolution: Vector2i in RESOLUTIONS:
		for state_name: String in RESOLUTION_STATES:
			await _capture_state(state_name, resolution, "resolutions")
	for state_name: String in EXTRA_STATES:
		await _capture_state(state_name, Vector2i(1920, 1080), _state_group(state_name))
	var production_scenes: Array[String] = []
	_collect_scene_paths("res://scenes", production_scenes)
	production_scenes.sort()
	for scene_path: String in production_scenes:
		await _capture_raw_scene(scene_path)
	AudioManager.stop_all_sfx()
	AudioManager.stop_bgm()
	await _cleanup_active()
	_finish()


func _capture_state(state_name: String, resolution: Vector2i, group: String) -> void:
	await _cleanup_active()
	await _set_resolution(resolution)
	_prepare_state(state_name)
	var scene_path := _scene_for_state(state_name)
	var packed := load(scene_path) as PackedScene
	if packed == null:
		failures.append("cannot load %s for %s" % [scene_path, state_name])
		return
	_active_root = packed.instantiate()
	add_child(_active_root)
	if _active_root is Control:
		(_active_root as Control).set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	await get_tree().process_frame
	await get_tree().process_frame
	await _configure_state_after_ready(state_name, _active_root)
	await _stabilize()
	var file_name := "%s_%dx%d.png" % [state_name, resolution.x, resolution.y]
	await _save_capture("%s/%s/%s" % [OUTPUT_ROOT, group, file_name])


func _capture_raw_scene(scene_path: String) -> void:
	await _cleanup_active()
	await _set_resolution(Vector2i(1920, 1080))
	_prepare_state("raw_" + scene_path)
	var packed := load(scene_path) as PackedScene
	if packed == null:
		failures.append("raw capture load failed: %s" % scene_path)
		return
	var instance := packed.instantiate()
	if instance is Window:
		_active_root = instance
		add_child(instance)
		(instance as Window).popup_centered(Vector2i(520, 360))
	elif FULL_SCREEN_SCENES.has(scene_path):
		_active_root = instance
		add_child(instance)
		if instance is Control:
			(instance as Control).set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	else:
		var carrier := _create_component_carrier()
		_active_root = carrier
		add_child(carrier)
		var center := carrier.get_node("Center") as CenterContainer
		center.add_child(instance)
	await get_tree().process_frame
	await get_tree().process_frame
	await _configure_raw_component(scene_path, instance)
	await _stabilize()
	var slug := scene_path.trim_prefix("res://scenes/").trim_suffix(".tscn").replace("/", "__")
	await _save_capture("%s/components/%s_1920x1080.png" % [OUTPUT_ROOT, slug])


func _prepare_state(state_name: String) -> void:
	if state_name.begins_with("home_") or state_name.contains("main_menu_screen"):
		Game.run.show_home()
		return
	if state_name.begins_with("run_setup_") or state_name.contains("deck_select_screen") or state_name.contains("run_setup_screen"):
		Game.run.show_deck_select()
		return
	Game.start_new_run("red_deck", "FINAL-SCENE-REVIEW")
	_decorate_run()
	if state_name.begins_with("battle_"):
		Game.run.start_round()
	elif state_name.begins_with("settlement_"):
		Game.run.phase = RunState.Phase.SETTLEMENT
		Game.run.current_score = 1240
		Game.run.target_score = 900
		Game.run.settlement = {
			"stage_name": "大盲注", "reward": 5, "hand_bonus": 2, "interest": 3,
			"tag_bonus": 4, "voucher_bonus": 1, "other_bonus": 0, "total": 15,
			"score": 1240, "target": 900, "claimed": state_name == "settlement_claim_disabled",
		}
	elif state_name.begins_with("shop_"):
		Game.run.phase = RunState.Phase.SHOP
		Game.run.money = 28
		if state_name == "shop_insufficient_funds":
			Game.run.money = 0
		if state_name == "shop_joker_slots_full":
			var joker := DataRegistry.find_by_id("jokers", "joker")
			Game.run.jokers = [joker, joker, joker, joker, joker]
		Game.run.generate_shop(true)
		if state_name == "shop_pack_open":
			Game.run.current_pack = {"id": "review_pack", "name_cn": "秘法补充包", "type": "tarot", "choose": 1}
			Game.run.pack_choices_left = 1
			Game.run.pack_options = [
				DataRegistry.find_by_id("tarot_cards", "fool"),
				DataRegistry.find_by_id("tarot_cards", "magician"),
				DataRegistry.find_by_id("tarot_cards", "high_priestess"),
			]
	elif state_name.begins_with("result_victory"):
		Game.run.phase = RunState.Phase.VICTORY
		Game.run.current_score = 12500
		Game.run.target_score = 10000
	elif state_name.begins_with("result_game_over"):
		Game.run.phase = RunState.Phase.GAME_OVER
		Game.run.current_score = 220
		Game.run.target_score = 900
	elif state_name.begins_with("card_detail_"):
		Game.run.start_round()


func _configure_state_after_ready(state_name: String, root_node: Node) -> void:
	if root_node.has_method("refresh"):
		root_node.call("refresh")
	var table := root_node as GameTableScreen
	if table != null:
		table.set_phase(Game.run.phase, true)
		await get_tree().process_frame
		if state_name == "battle_one_selected":
			_select_cards(table, 1)
		elif state_name == "battle_multi_selected":
			_select_cards(table, 4)
		elif state_name == "battle_sort_rank":
			table.battle_content.sort_rank_button.button_pressed = true
		elif state_name == "battle_sort_suit":
			table.battle_content.sort_suit_button.button_pressed = true
		elif state_name == "shop_item_sold":
			table.shop_panel.joker_offer_slots[0].mark_sold()
		elif state_name.begins_with("card_detail_"):
			_show_detail_state(table, state_name)
	var hover_target := _hover_target_for_state(state_name)
	if not hover_target.is_empty():
		await _hover_control(root_node, hover_target)
	if state_name == "run_setup_continue_enabled":
		var continue_button := root_node.find_child("ContinueButton", true, false) as Button
		if continue_button != null:
			continue_button.disabled = false
	if state_name == "run_setup_challenge":
		var challenge_button := root_node.find_child("ChallengeButton", true, false) as Button
		if challenge_button != null:
			challenge_button.button_pressed = true


func _configure_raw_component(scene_path: String, instance: Node) -> void:
	if instance is PlayingCardView:
		(instance as PlayingCardView).setup(Game.run.full_deck[0])
	elif instance is JokerCardView:
		(instance as JokerCardView).setup(DataRegistry.find_by_id("jokers", "joker"), 0, true)
	elif instance is ShopOfferCard:
		(instance as ShopOfferCard).setup(DataRegistry.find_by_id("jokers", "joker"), 0, "joker")
	elif instance is StageCardView:
		(instance as StageCardView).setup("小盲注", 300, 3, true, false, true, "small", {}, "基础挑战")
	elif instance is GameTableScreen:
		(instance as GameTableScreen).set_phase(Game.run.phase, true)
	elif instance.has_method("refresh"):
		instance.call("refresh")
	await get_tree().process_frame


func _select_cards(table: GameTableScreen, count: int) -> void:
	var ids: Array = []
	for i: int in range(mini(count, Game.run.hand.size())):
		ids.append(str((Game.run.hand[i] as Dictionary).get("instance_id", "")))
	table.battle_content.selected_cards = ids
	table.battle_content.hand_area.update_selection(ids)
	table.battle_content.call("_update_selected_preview")


func _show_detail_state(table: GameTableScreen, state_name: String) -> void:
	var item: Dictionary
	match state_name:
		"card_detail_joker":
			table._detail_popup.show_joker(DataRegistry.find_by_id("jokers", "joker"))
		"card_detail_tarot", "card_detail_long":
			item = DataRegistry.find_by_id("tarot_cards", "fool").duplicate(true)
			if state_name == "card_detail_long":
				item["description_cn"] = "这是用于检查长文本换行、滚动区域、按钮安全边距与弹窗边界的详细说明。".repeat(8)
			table._detail_popup.show_item(item)
		"card_detail_planet":
			table._detail_popup.show_item(DataRegistry.find_by_id("planet_cards", "mercury"))
		"card_detail_playing_card":
			item = Game.run.hand[0].duplicate(true)
			item["name_cn"] = "扑克牌详情"
			item["description_cn"] = "红桃 A，当前牌组中的实际扑克牌。"
			table._detail_popup.show_item(item)


func _scene_for_state(state_name: String) -> String:
	if state_name.begins_with("home_"):
		return "res://scenes/screens/main_menu_screen.tscn"
	if state_name.begins_with("run_setup_"):
		return "res://scenes/screens/run_setup_screen.tscn"
	if state_name.begins_with("result_"):
		return "res://scenes/screens/result_screen.tscn"
	return "res://scenes/game/game_table_screen.tscn"


func _hover_target_for_state(state_name: String) -> String:
	match state_name:
		"home_start_hover": return "StartButton"
		"home_options_hover": return "OptionsButton"
		"home_language_hover": return "LanguageButton"
		"run_setup_prev_deck_hover": return "PrevDeckButton"
		"run_setup_start_hover": return "StartButton"
		_: return ""


func _hover_control(root_node: Node, node_name: String) -> void:
	var control := root_node.find_child(node_name, true, false) as Control
	if control == null:
		failures.append("hover target missing: %s" % node_name)
		return
	Input.warp_mouse(control.get_global_rect().get_center())
	await get_tree().process_frame
	await get_tree().process_frame


func _decorate_run() -> void:
	Game.run.money = 23
	Game.run.jokers = [
		DataRegistry.find_by_id("jokers", "joker"),
		DataRegistry.find_by_id("jokers", "greedy_joker"),
		DataRegistry.find_by_id("jokers", "fibonacci"),
	]
	Game.run.consumables = [
		DataRegistry.find_by_id("tarot_cards", "fool"),
		DataRegistry.find_by_id("planet_cards", "mercury"),
	]


func _create_component_carrier() -> Control:
	var carrier := Control.new()
	carrier.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var background := ColorRect.new()
	background.color = Color(0.025, 0.10, 0.075, 1.0)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	carrier.add_child(background)
	var center := CenterContainer.new()
	center.name = "Center"
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.offset_left = 80
	center.offset_top = 80
	center.offset_right = -80
	center.offset_bottom = -80
	carrier.add_child(center)
	return carrier


func _collect_scene_paths(directory_path: String, output: Array[String]) -> void:
	var directory := DirAccess.open(directory_path)
	if directory == null:
		failures.append("cannot open %s" % directory_path)
		return
	directory.list_dir_begin()
	var entry := directory.get_next()
	while not entry.is_empty():
		var path := directory_path.path_join(entry)
		if directory.current_is_dir():
			if not path.begins_with("res://scenes/debug"):
				_collect_scene_paths(path, output)
		elif entry.ends_with(".tscn"):
			output.append(path)
		entry = directory.get_next()
	directory.list_dir_end()


func _set_resolution(resolution: Vector2i) -> void:
	get_window().content_scale_size = resolution
	get_window().size = resolution
	await get_tree().process_frame


func _stabilize() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.35).timeout
	RenderingServer.force_draw()
	await get_tree().process_frame


func _save_capture(output_path: String) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_path.get_base_dir()))
	var image := get_viewport().get_texture().get_image()
	var error := image.save_png(output_path)
	if error != OK:
		failures.append("save failed %s: %s" % [output_path, error_string(error)])
	else:
		print("CAPTURED %s (%dx%d)" % [output_path, image.get_width(), image.get_height()])


func _cleanup_active() -> void:
	if _active_root != null and is_instance_valid(_active_root):
		_active_root.queue_free()
		await get_tree().process_frame
	_active_root = null


func _state_group(state_name: String) -> String:
	if state_name.begins_with("home_"): return "home"
	if state_name.begins_with("run_setup_"): return "run_setup"
	if state_name.begins_with("battle_"): return "game_table/battle"
	if state_name.begins_with("settlement_"): return "game_table/settlement"
	if state_name.begins_with("shop_"): return "game_table/shop"
	if state_name.begins_with("card_detail_"): return "popups"
	return "misc"


func _finish() -> void:
	if failures.is_empty():
		print("PASS capture_full_scene_review")
		get_tree().quit(0)
		return
	for failure: String in failures:
		push_error("capture_full_scene_review: %s" % failure)
	get_tree().quit(1)
