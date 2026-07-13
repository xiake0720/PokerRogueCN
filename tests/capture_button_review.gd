extends Control

const RunStateScript = preload("res://scripts/run/run_state.gd")
const OUTPUT_DIR := "res://artifacts/button_review"
const CAPTURES: Array[Dictionary] = [
	{"name": "button_gallery", "scene": "res://scenes/debug/button_style_gallery.tscn"},
	{"name": "home_buttons", "scene": "res://scenes/screens/main_menu_screen.tscn"},
	{"name": "deck_select_buttons", "scene": "res://scenes/screens/run_setup_screen.tscn"},
	{"name": "stage_buttons", "scene": "res://scenes/game/game_table_screen.tscn"},
	{"name": "battle_buttons", "scene": "res://scenes/game/game_table_screen.tscn"},
	{"name": "settlement_button", "scene": "res://scenes/game/game_table_screen.tscn"},
	{"name": "shop_buttons", "scene": "res://scenes/game/game_table_screen.tscn"},
	{"name": "result_buttons", "scene": "res://scenes/screens/result_screen.tscn"},
	{"name": "popup_buttons", "scene": "res://scenes/ui/card_detail_popup.tscn"},
]

var failures: Array[String] = []


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	get_window().size = Vector2i(1920, 1080)
	get_window().content_scale_size = Vector2i(1920, 1080)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	for capture in CAPTURES:
		var capture_name := str(capture.name)
		print("PREPARING %s" % capture_name)
		_prepare_state(capture_name)
		var packed := load(str(capture.scene)) as PackedScene
		if packed == null:
			failures.append("cannot load %s" % capture.scene)
			continue
		var screen := packed.instantiate()
		add_child(screen)
		if screen is Control and not screen is PopupPanel:
			(screen as Control).set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		await get_tree().process_frame
		await get_tree().process_frame
		if screen is CardDetailPopup:
			(screen as CardDetailPopup).show_item({
				"name_cn": "按钮焦点预览", "kind": "item", "cost": 12,
				"description_cn": "关闭按钮使用小型次级样式，支持键盘与手柄焦点。",
			})
		await get_tree().process_frame
		_apply_state_preview(screen, capture_name)
		await get_tree().process_frame
		await get_tree().process_frame
		await get_tree().process_frame
		RenderingServer.force_draw()
		await get_tree().process_frame
		var image := get_viewport().get_texture().get_image()
		var output_path := "%s/%s.png" % [OUTPUT_DIR, capture_name]
		var save_error := image.save_png(output_path)
		if save_error != OK:
			failures.append("failed to save %s: %s" % [output_path, error_string(save_error)])
		else:
			print("CAPTURED %s (%dx%d)" % [output_path, image.get_width(), image.get_height()])
		if screen is PopupPanel:
			(screen as PopupPanel).hide()
		screen.free()
		await get_tree().process_frame
	_finish()


func _prepare_state(capture_name: String) -> void:
	var game := get_node("/root/Game")
	match capture_name:
		"home_buttons", "button_gallery", "popup_buttons":
			game.run.show_home()
		"deck_select_buttons":
			game.run.show_deck_select()
		_:
			game.start_new_run("red_deck", "BUTTON-REVIEW-2026")
			game.run.money = 23
			match capture_name:
				"battle_buttons":
					game.run.start_round()
				"settlement_button":
					game.run.phase = RunStateScript.Phase.SETTLEMENT
					game.run.settlement = {"total": 15, "reward": 5, "score": 1240, "target": 900, "claimed": false}
				"shop_buttons":
					game.run.phase = RunStateScript.Phase.SHOP
					game.run.generate_shop(true)
				"result_buttons":
					game.run.phase = RunStateScript.Phase.VICTORY


func _apply_state_preview(screen: Node, capture_name: String) -> void:
	match capture_name:
		"home_buttons":
			_preview(screen, "OptionsButton", "hover")
			_preview(screen, "QuitButton", "pressed")
			_preview(screen, "LanguageButton", "focus")
		"deck_select_buttons":
			_preview(screen, "NewRunButton", "selected")
			_preview(screen, "ContinueButton", "disabled")
			_preview(screen, "ChallengeButton", "hover")
			_preview(screen, "NextDeckButton", "focus")
		"stage_buttons":
			var select_buttons := screen.find_children("SelectButton", "Button", true, false)
			var skip_buttons := screen.find_children("SkipButton", "Button", true, false)
			if not select_buttons.is_empty():
				_set_preview(select_buttons[0] as Button, "hover")
			if not skip_buttons.is_empty():
				_set_preview(skip_buttons[0] as Button, "disabled")
		"battle_buttons":
			_preview(screen, "PlayButton", "disabled")
			_preview(screen, "DiscardButton", "hover")
			_preview(screen, "SortRankButton", "selected")
			_preview(screen, "SortSuitButton", "focus")
		"settlement_button":
			_preview(screen, "ClaimButton", "pressed")
		"shop_buttons":
			_preview(screen, "NextButton", "hover")
			_preview(screen, "RerollButton", "disabled")
			var buy_buttons := screen.find_children("BuyButton", "Button", true, false)
			if buy_buttons.size() > 0:
				_set_preview(buy_buttons[0] as Button, "normal")
			if buy_buttons.size() > 1:
				_set_preview(buy_buttons[1] as Button, "disabled")
		"result_buttons":
			_preview(screen, "PrimaryButton", "focus")
			_preview(screen, "HomeButton", "hover")
		"popup_buttons":
			_preview(screen, "CloseButton", "focus")


func _preview(root_node: Node, node_name: String, state: String) -> void:
	var button := root_node.find_child(node_name, true, false) as Button
	if button == null:
		failures.append("%s missing %s for state preview" % [root_node.name, node_name])
		return
	_set_preview(button, state)


func _set_preview(button: Button, state: String) -> void:
	match state:
		"hover", "pressed":
			button.add_theme_stylebox_override("normal", button.get_theme_stylebox(state))
		"disabled":
			button.disabled = true
		"focus":
			button.grab_focus()
		"selected":
			button.toggle_mode = true
			button.button_pressed = true
	button.queue_redraw()


func _finish() -> void:
	if failures.is_empty():
		print("PASS capture_button_review")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error("capture_button_review: " + failure)
	get_tree().quit(1)
