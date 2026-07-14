extends SceneTree

const THEME_PATH := "res://assets/ui/theme/game_theme.tres"
const SHOP_PATH := "res://scenes/game/phases/shop_panel.tscn"
const OFFER_PATH := "res://scenes/shop/shop_offer_card.tscn"
const OFFER_SCRIPT_PATH := "res://scripts/shop/shop_offer_card.gd"

var failures: Array[String] = []


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	var theme_source := FileAccess.get_file_as_string(THEME_PATH)
	var shop_source := FileAccess.get_file_as_string(SHOP_PATH)
	var offer_source := FileAccess.get_file_as_string(OFFER_PATH)
	var offer_script := FileAccess.get_file_as_string(OFFER_SCRIPT_PATH)

	_expect(
		theme_source.contains("PanelContainer/styles/panel = SubResource(\"StyleBox_layout_panel\")"),
		"ordinary PanelContainer must default to the transparent layout style"
	)
	_expect(
		not theme_source.contains("PanelContainer/styles/panel = ExtResource(\"33_panel\")"),
		"ordinary PanelContainer must not inherit the ornate panel"
	)
	for variation: String in ["LayoutPanel", "SurfacePanel", "OrnatePanel", "CardPanel", "PopupSurface"]:
		_expect(theme_source.contains("%s/base_type" % variation), "theme variation missing: %s" % variation)
	_expect(
		theme_source.contains("PopupPanel/styles/panel = SubResource(\"StyleBox_layout_panel\")"),
		"PopupPanel must default to a transparent background"
	)
	_check_popup_double_backgrounds("res://scenes")

	var forbidden_card_layers: Array[String] = [
		"CardBackground", "ProductFrame", "HoverFrame", "HoverGlow", "TriggerFrame",
	]
	for layer_name: String in forbidden_card_layers:
		_expect(not offer_source.contains("name=\"%s\"" % layer_name), "shop offer keeps redundant layer %s" % layer_name)
	_expect(
		offer_source.count("theme_type_variation = &\"CardPanel\"") == 1,
		"shop offer must have exactly one persistent full-card shell"
	)
	_expect(
		not offer_script.contains("hover_glow") and not offer_script.contains("ProductFrame"),
		"hover must not rely on a border node"
	)
	_expect(offer_script.contains("Vector2(1.025, 1.025)"), "hover scale must remain at or below 1.03")
	_expect(offer_script.contains("Vector2(0.0, -8.0)"), "hover must lift the card by 6-10 pixels")

	var forbidden_shop_frames: Array[String] = [
		"panel_ornate.tres", "shop_offers_panel.png", "shop_voucher_panel.png", "shop_packs_panel.png",
	]
	for resource_name: String in forbidden_shop_frames:
		_expect(not shop_source.contains(resource_name), "shop keeps region-level decorative frame %s" % resource_name)
	_expect(
		shop_source.count("theme_type_variation = &\"SurfacePanel\"") == 1,
		"shop must expose exactly one weak page-level surface"
	)
	_finish()


func _check_popup_double_backgrounds(directory_path: String) -> void:
	var scene_paths: Array[String] = []
	_collect_scene_paths(directory_path, scene_paths)
	for scene_path: String in scene_paths:
		var records := _parse_scene_nodes(FileAccess.get_file_as_string(scene_path))
		for record: Dictionary in records:
			if str(record.get("type", "")) != "PopupPanel":
				continue
			for child: Dictionary in records:
				if str(child.get("type", "")) != "PanelContainer":
					continue
				if str(child.get("parent_path", "")) != str(record.get("path", "")):
					continue
				var popup_style := str(record.get("panel_style", ""))
				var child_style := str(child.get("panel_style", ""))
				_expect(
					popup_style.is_empty() or child_style.is_empty() or popup_style != child_style,
					"%s draws the same decoration on PopupPanel and its direct PanelContainer child" % scene_path
				)


func _parse_scene_nodes(source: String) -> Array[Dictionary]:
	var records: Array[Dictionary] = []
	var current: Dictionary = {}
	for raw_line: String in source.split("\n"):
		var line := raw_line.strip_edges()
		if line.begins_with("[node "):
			if not current.is_empty():
				records.append(current)
			var node_name := _attribute(line, "name")
			var parent_path := _attribute(line, "parent")
			if parent_path == ".":
				parent_path = ""
			var node_path := node_name if parent_path.is_empty() else "%s/%s" % [parent_path, node_name]
			current = {
				"path": node_path,
				"parent_path": parent_path,
				"type": _attribute(line, "type"),
				"panel_style": "",
			}
		elif not current.is_empty() and line.begins_with("theme_override_styles/panel = "):
			current["panel_style"] = line.trim_prefix("theme_override_styles/panel = ")
	if not current.is_empty():
		records.append(current)
	return records


func _attribute(line: String, attribute_name: String) -> String:
	var marker := "%s=\"" % attribute_name
	var start := line.find(marker)
	if start < 0:
		return ""
	start += marker.length()
	var finish := line.find("\"", start)
	return line.substr(start, finish - start) if finish >= start else ""


func _collect_scene_paths(directory_path: String, output: Array[String]) -> void:
	var directory := DirAccess.open(directory_path)
	if directory == null:
		failures.append("cannot scan %s" % directory_path)
		return
	directory.list_dir_begin()
	var entry := directory.get_next()
	while not entry.is_empty():
		var path := directory_path.path_join(entry)
		if directory.current_is_dir():
			_collect_scene_paths(path, output)
		elif entry.ends_with(".tscn"):
			output.append(path)
		entry = directory.get_next()
	directory.list_dir_end()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _finish() -> void:
	if failures.is_empty():
		print("PASS test_visual_complexity")
		quit(0)
		return
	for failure: String in failures:
		push_error("test_visual_complexity: %s" % failure)
	quit(1)
