extends Control

const OUTPUT_ROOT := "res://docs/ui_phase1_1_review"
const RESOLUTIONS: Array[Vector2i] = [
	Vector2i(1280, 720),
	Vector2i(1920, 1080),
	Vector2i(1920, 1200),
	Vector2i(2520, 1080),
]
const STATES: Array[String] = [
	"battle_default",
	"battle_hover",
	"battle_focus",
	"battle_selected_1",
	"battle_selected_5",
	"battle_selection_limit",
	"battle_play_disabled",
	"battle_sort_rank",
	"battle_sort_suit",
	"shop_default",
	"shop_insufficient_funds",
	"shop_slots_full",
	"shop_sold",
	"shop_pack_open",
	"blind_active",
	"blind_locked",
	"settlement_before_claim",
	"settlement_after_claim",
]

var failures: Array[String] = []
var _active_table: GameTableScreen = null
var _output_bucket := "after"
var _state_filter := ""


func _ready() -> void:
	_parse_args()
	_run.call_deferred()


func _parse_args() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--output="):
			_output_bucket = argument.trim_prefix("--output=")
		elif argument.begins_with("--state="):
			_state_filter = argument.trim_prefix("--state=")


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_ROOT.path_join(_output_bucket)))
	for resolution: Vector2i in RESOLUTIONS:
		for state_name: String in STATES:
			if not _state_filter.is_empty() and state_name != _state_filter:
				continue
			await _capture_state(state_name, resolution)
	AudioManager.stop_all_sfx()
	AudioManager.stop_bgm()
	await _cleanup_active()
	call_deferred("_finish")


func _capture_state(state_name: String, resolution: Vector2i) -> void:
	await _cleanup_active()
	await _set_resolution(resolution)
	_prepare_run(state_name)
	var packed := load("res://scenes/game/game_table_screen.tscn") as PackedScene
	if packed == null:
		failures.append("cannot load game table for %s" % state_name)
		return
	_active_table = packed.instantiate() as GameTableScreen
	add_child(_active_table)
	_active_table.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	await get_tree().process_frame
	await get_tree().process_frame
	_active_table.set_phase(Game.run.phase, true)
	await get_tree().process_frame
	await _configure_state(state_name)
	await _stabilize(state_name)
	var file_name := "%s_%dx%d.png" % [state_name, resolution.x, resolution.y]
	await _save_capture(OUTPUT_ROOT.path_join(_output_bucket).path_join(file_name))


func _prepare_run(state_name: String) -> void:
	Game.start_new_run("red_deck", "UI-PHASE-1-1-REVIEW")
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
	if state_name.begins_with("battle_"):
		Game.run.start_round()
		return
	if state_name.begins_with("shop_"):
		Game.run.phase = RunState.Phase.SHOP
		if state_name == "shop_insufficient_funds":
			Game.run.money = 0
		elif state_name == "shop_slots_full":
			var joker := DataRegistry.find_by_id("jokers", "joker")
			Game.run.jokers = [joker, joker, joker, joker, joker]
		Game.run.generate_shop(true)
		if state_name == "shop_pack_open":
			Game.run.current_pack = {
				"id": "review_pack",
				"name_cn": "秘法补充包",
				"type": "tarot",
				"choose": 1,
			}
			Game.run.pack_choices_left = 1
			Game.run.pack_options = [
				DataRegistry.find_by_id("tarot_cards", "fool"),
				DataRegistry.find_by_id("tarot_cards", "magician"),
				DataRegistry.find_by_id("tarot_cards", "high_priestess"),
			]
		return
	if state_name.begins_with("blind_"):
		Game.run.phase = RunState.Phase.STAGE_SELECT
		Game.run.blind_index = 1 if state_name == "blind_active" else 0
		return
	Game.run.phase = RunState.Phase.SETTLEMENT
	Game.run.current_score = 1240
	Game.run.target_score = 900
	var claimed := state_name == "settlement_after_claim"
	Game.run.money = 43 if claimed else 28
	Game.run.settlement_claimed = claimed
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
		"claimed": claimed,
	}


func _configure_state(state_name: String) -> void:
	if state_name.begins_with("battle_"):
		await _configure_battle_state(state_name)
	elif state_name == "shop_sold":
		_active_table.shop_panel.joker_offer_slots[0].mark_sold()


func _configure_battle_state(state_name: String) -> void:
	var battle := _active_table.battle_content
	match state_name:
		"battle_hover":
			await _hover_card(battle.hand_area.card_views[2])
		"battle_focus":
			battle.hand_area.card_views[2].grab_focus()
		"battle_selected_1":
			_select_cards(battle, 1)
		"battle_selected_5":
			_select_cards(battle, 5)
		"battle_selection_limit":
			_select_cards(battle, 5)
		"battle_play_disabled":
			battle.play_button.disabled = true
		"battle_sort_rank":
			battle.sort_rank_button.button_pressed = true
		"battle_sort_suit":
			battle.sort_suit_button.button_pressed = true
	await get_tree().process_frame


func _select_cards(battle: BattleContent, count: int) -> void:
	var ids: Array = []
	for i: int in range(mini(count, Game.run.hand.size())):
		ids.append(str((Game.run.hand[i] as Dictionary).get("instance_id", "")))
	battle.selected_cards = ids
	battle.hand_area.update_selection(ids)
	battle.call("_update_selected_preview")
	battle.call("_update_action_buttons")


func _hover_card(card: PlayingCardView) -> void:
	Input.warp_mouse(card.get_global_rect().get_center())
	await get_tree().process_frame
	await get_tree().process_frame


func _set_resolution(resolution: Vector2i) -> void:
	get_window().content_scale_size = resolution
	get_window().size = resolution
	await get_tree().process_frame


func _stabilize(state_name: String) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(2.0 if state_name.begins_with("settlement_") else 0.35).timeout
	RenderingServer.force_draw()
	await get_tree().process_frame


func _save_capture(output_path: String) -> void:
	var image := get_viewport().get_texture().get_image()
	var error := image.save_png(output_path)
	if error != OK:
		failures.append("save failed %s: %s" % [output_path, error_string(error)])
	else:
		print("CAPTURED %s (%dx%d)" % [output_path, image.get_width(), image.get_height()])


func _cleanup_active() -> void:
	if _active_table != null and is_instance_valid(_active_table):
		_active_table.queue_free()
		await get_tree().process_frame
	_active_table = null


func _finish() -> void:
	if failures.is_empty():
		print("PASS capture_ui_phase1_1 %s" % _output_bucket)
		get_tree().quit(0)
		return
	for failure: String in failures:
		push_error("capture_ui_phase1_1: %s" % failure)
	get_tree().quit(1)
