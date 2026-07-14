extends Control

const OUTPUT_ROOT := "res://artifacts/visual_delayering_phase1/after"
const CAPTURES: Array[Dictionary] = [
	{"name": "shop_default", "resolution": Vector2i(1920, 1080)},
	{"name": "shop_product_hover", "resolution": Vector2i(1920, 1080)},
	{"name": "shop_insufficient_funds", "resolution": Vector2i(1920, 1080)},
	{"name": "shop_item_sold", "resolution": Vector2i(1920, 1080)},
	{"name": "shop_pack_open", "resolution": Vector2i(1920, 1080)},
	{"name": "shop_default", "resolution": Vector2i(1280, 720)},
]

var failures: Array[String] = []
var _active_root: Control = null


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_ROOT))
	for capture: Dictionary in CAPTURES:
		await _capture_state(str(capture.name), capture.resolution as Vector2i)
	await _cleanup_active()
	AudioManager.stop_all_sfx()
	AudioManager.stop_bgm()
	_finish()


func _capture_state(state_name: String, resolution: Vector2i) -> void:
	await _cleanup_active()
	await _set_resolution(resolution)
	_prepare_state(state_name)
	var packed := load("res://scenes/game/game_table_screen.tscn") as PackedScene
	if packed == null:
		failures.append("cannot load game table for %s" % state_name)
		return
	_active_root = packed.instantiate() as Control
	add_child(_active_root)
	_active_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	await get_tree().process_frame
	await get_tree().process_frame
	if _active_root.has_method("set_phase"):
		_active_root.call("set_phase", RunState.Phase.SHOP, true)
	await get_tree().process_frame
	await _configure_state(state_name)
	await _stabilize()
	var file_name := "%s_%dx%d.png" % [state_name, resolution.x, resolution.y]
	_save_capture("%s/%s" % [OUTPUT_ROOT, file_name])


func _prepare_state(state_name: String) -> void:
	Game.start_new_run("red_deck", "VISUAL-DELAYERING-PHASE1")
	Game.run.phase = RunState.Phase.SHOP
	Game.run.money = 28
	Game.run.jokers = [
		DataRegistry.find_by_id("jokers", "joker"),
		DataRegistry.find_by_id("jokers", "greedy_joker"),
		DataRegistry.find_by_id("jokers", "fibonacci"),
	]
	if state_name == "shop_insufficient_funds":
		Game.run.money = 0
	Game.run.generate_shop(true)
	if state_name == "shop_pack_open":
		Game.run.current_pack = {"id": "review_pack", "name_cn": "秘法补充包", "type": "tarot", "choose": 1}
		Game.run.pack_choices_left = 1
		Game.run.pack_options = [
			DataRegistry.find_by_id("tarot_cards", "fool"),
			DataRegistry.find_by_id("tarot_cards", "magician"),
			DataRegistry.find_by_id("tarot_cards", "high_priestess"),
		]


func _configure_state(state_name: String) -> void:
	var shop_panel := _active_root.find_child("ShopPanel", true, false)
	if shop_panel == null:
		failures.append("ShopPanel missing for %s" % state_name)
		return
	if shop_panel.has_method("refresh_run"):
		shop_panel.call("refresh_run", Game.run)
	await get_tree().process_frame
	var first_offer := shop_panel.find_child("JokerOfferSlot1", true, false) as Control
	if first_offer == null:
		failures.append("JokerOfferSlot1 missing for %s" % state_name)
		return
	match state_name:
		"shop_product_hover":
			first_offer.call("_on_mouse_entered")
			await get_tree().create_timer(0.16).timeout
		"shop_item_sold":
			first_offer.call("mark_sold")


func _set_resolution(resolution: Vector2i) -> void:
	get_window().mode = Window.MODE_WINDOWED
	get_window().borderless = true
	get_window().content_scale_size = resolution
	get_window().size = resolution
	await get_tree().process_frame


func _stabilize() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.6).timeout
	RenderingServer.force_draw()
	await get_tree().process_frame


func _save_capture(output_path: String) -> void:
	var texture := get_viewport().get_texture()
	if texture == null:
		failures.append("viewport texture unavailable for %s" % output_path)
		return
	var image := texture.get_image()
	if image == null:
		failures.append("viewport image unavailable for %s" % output_path)
		return
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


func _finish() -> void:
	if failures.is_empty():
		print("PASS capture_visual_delayering_phase1")
		get_tree().quit(0)
		return
	for failure: String in failures:
		push_error("capture_visual_delayering_phase1: %s" % failure)
	get_tree().quit(1)
