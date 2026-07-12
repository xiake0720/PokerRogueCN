extends Node

const MANIFEST_PATH := "res://assets/ui/runtime/buttons/button_manifest.json"

var failures: Array[String] = []


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	var manifest := _load_manifest()
	if manifest.is_empty():
		_finish()
		return
	_check_all_scenes_parse()
	_check_buttons(Array(manifest.get("buttons", [])))
	_check_extracted_hashes(Dictionary(manifest.get("extracted_source_hashes", {})))
	_check_required_variations(Array(manifest.get("theme_variations", [])))
	_finish()


func _load_manifest() -> Dictionary:
	if not FileAccess.file_exists(MANIFEST_PATH):
		_fail("button manifest is missing")
		return {}
	var file := FileAccess.open(MANIFEST_PATH, FileAccess.READ)
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		_fail("button manifest is not valid JSON")
		return {}
	return parsed as Dictionary


func _check_all_scenes_parse() -> void:
	for path in _collect_files("res://scenes", ".tscn"):
		var scene := ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
		if scene == null:
			_fail("scene failed to parse: %s" % path)


func _check_buttons(buttons: Array) -> void:
	if buttons.is_empty():
		_fail("manifest contains no buttons")
		return
	for raw_button in buttons:
		var button: Dictionary = raw_button
		var label := "%s :: %s" % [button.get("scene", ""), button.get("node_path", "")]
		var styles: Dictionary = button.get("styles", {})
		var flat_art := bool(button.get("flat_art_button", false))
		for state in ["normal", "hover", "pressed", "disabled", "focus"]:
			var source := str(styles.get(state, ""))
			if source.is_empty() and not (flat_art and state != "focus"):
				_fail("%s missing %s style" % [label, state])
			elif source.begins_with("res://") and not ResourceLoader.exists(source):
				_fail("%s references missing %s style: %s" % [label, state, source])
		var texture := str(button.get("texture", ""))
		if not texture.is_empty():
			if not FileAccess.file_exists(texture):
				_fail("%s references missing texture: %s" % [label, texture])
			if "/reference" in texture.to_lower() or "screenshot" in texture.to_lower():
				_fail("%s uses a reference image as button art" % label)
			if not "/runtime/" in texture and bool(button.get("preserve_exclusive_art", false)):
				_fail("%s special style does not use normalized runtime art" % label)
		_check_geometry(button, label)
		if not str(button.get("scene", "")).begins_with("res://scenes/debug/"):
			_check_content_stability(button, label)
			_check_special_fallbacks(button, label)


func _check_geometry(button: Dictionary, label: String) -> void:
	var minimum: Array = button.get("minimum_size", [])
	if minimum.size() < 2 or float(minimum[0]) <= 0.0 or float(minimum[1]) <= 0.0:
		return
	var margins: Dictionary = button.get("texture_margin", {})
	var horizontal := float(margins.get("left", 0.0)) + float(margins.get("right", 0.0))
	var vertical := float(margins.get("top", 0.0)) + float(margins.get("bottom", 0.0))
	if horizontal >= float(minimum[0]):
		_fail("%s horizontal texture margins exceed minimum width" % label)
	if vertical >= float(minimum[1]):
		_fail("%s vertical texture margins exceed minimum height" % label)


func _check_content_stability(button: Dictionary, label: String) -> void:
	var details: Dictionary = button.get("style_details", {})
	var reference := JSON.stringify(Dictionary(details.get("normal", {})).get("content_margin", {}))
	for state in ["hover", "pressed", "disabled"]:
		var current := JSON.stringify(Dictionary(details.get(state, {})).get("content_margin", {}))
		if current != reference:
			_fail("%s changes content margins in %s state" % [label, state])


func _check_special_fallbacks(button: Dictionary, label: String) -> void:
	var scene := str(button.get("scene", ""))
	var name := str(button.get("name", ""))
	var styles: Dictionary = button.get("styles", {})
	var disabled := str(styles.get("disabled", ""))
	if scene.ends_with("battle_screen.tscn") and not "/buttons/battle/" in disabled:
		_fail("%s battle disabled style falls back outside battle family" % label)
	if scene.ends_with("deck_select_screen.tscn") and name == "ContinueButton" and not "/deck_select/tab_center/" in disabled:
		_fail("%s ContinueButton lost its tab disabled appearance" % label)
	if scene.ends_with("shop_offer_card.tscn") and name == "BuyButton" and not "/buttons/shop/buy/" in disabled:
		_fail("%s BuyButton lost its compact shop disabled appearance" % label)
	if scene.ends_with("main_menu_screen.tscn"):
		if styles.get("normal", "") == styles.get("hover", ""):
			_fail("%s home hover is not visually distinct" % label)
		if styles.get("normal", "") == styles.get("pressed", ""):
			_fail("%s home pressed is not visually distinct" % label)


func _check_extracted_hashes(hashes: Dictionary) -> void:
	for path_value in hashes:
		var path := str(path_value)
		if not FileAccess.file_exists(path):
			_fail("extracted source was removed: %s" % path)
			continue
		if FileAccess.get_sha256(path) != str(hashes[path_value]):
			_fail("extracted source was modified: %s" % path)


func _check_required_variations(variations: Array) -> void:
	for required in [
		"PrimaryRedButton", "PrimaryGoldButton", "SecondaryRedButton", "SecondaryGoldButton",
		"SmallRedButton", "SmallGoldButton", "TabButton", "IconButton", "DangerButton"
	]:
		if not variations.has(required):
			_fail("missing Theme Type Variation: %s" % required)


func _collect_files(root: String, suffix: String) -> Array[String]:
	var result: Array[String] = []
	var directory := DirAccess.open(root)
	if directory == null:
		_fail("cannot open directory: %s" % root)
		return result
	directory.list_dir_begin()
	var entry := directory.get_next()
	while not entry.is_empty():
		if entry != "." and entry != "..":
			var path := root.path_join(entry)
			if directory.current_is_dir():
				result.append_array(_collect_files(path, suffix))
			elif entry.ends_with(suffix):
				result.append(path)
		entry = directory.get_next()
	directory.list_dir_end()
	return result


func _fail(message: String) -> void:
	failures.append(message)


func _finish() -> void:
	if failures.is_empty():
		print("PASS test_button_integrity")
		get_tree().quit(0)
		return
	for message in failures:
		push_error("test_button_integrity: " + message)
	get_tree().quit(1)
