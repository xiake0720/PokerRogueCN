extends Node

var tables: Dictionary = {}

func _ready() -> void:
	load_all()

func load_all() -> void:
	tables.clear()
	tables["poker_hands"] = _load_json("res://data/game/poker_hands.json")
	tables["jokers"] = _load_json("res://data/cards/jokers.json")
	tables["decks"] = _load_json("res://data/game/decks.json")
	tables["blinds"] = _load_json("res://data/game/blinds.json")
	tables["boss_blinds"] = _load_json("res://data/game/boss_blinds.json")
	tables["tarot_cards"] = _load_json("res://data/cards/tarot_cards.json")
	tables["planet_cards"] = _load_json("res://data/cards/planet_cards.json")
	tables["spectral_cards"] = _load_json("res://data/cards/spectral_cards.json")
	tables["vouchers"] = _load_json("res://data/cards/vouchers.json")
	tables["tags"] = _load_json("res://data/game/tags.json")
	tables["booster_packs"] = _load_json("res://data/game/booster_packs.json")

func get_table(table_name: String) -> Array:
	return tables.get(table_name, [])

func find_by_id(table_name: String, item_id: String) -> Dictionary:
	for item in get_table(table_name):
		if item.get("id", "") == item_id:
			return item
	return {}

func _load_json(path: String) -> Array:
	if not FileAccess.file_exists(path):
		push_warning("Missing data file: " + path)
		return []
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_warning("Cannot open data file: " + path)
		return []
	var text: String = file.get_as_text()
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_ARRAY:
		push_warning("JSON file must contain an array: " + path)
		return []
	return parsed
