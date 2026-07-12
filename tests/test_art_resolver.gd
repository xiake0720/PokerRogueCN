extends SceneTree

const ArtResolverScript = preload("res://scripts/ui/art_resolver.gd")
var failures: Array[String] = []

func _init() -> void:
	_run.call_deferred()

func _run() -> void:
	_check_table("jokers", "joker")
	_check_table("vouchers", "voucher")
	_check_table("booster_packs", "pack")
	_check_table("tarot_cards", "tarot")
	_check_table("planet_cards", "planet")
	_check_table("spectral_cards", "spectral")
	_check_table("decks", "deck")
	_check_table("blinds", "blind")
	_expect(ArtResolverScript.get_deck_back("red_deck") != null, "red deck back must resolve")
	_expect(ArtResolverScript.get_blind_token("small_blind") != null, "small blind token must resolve")
	_finish("test_art_resolver")

func _check_table(table: String, kind: String) -> void:
	var registry: Node = root.get_node("DataRegistry")
	for raw_item in registry.get_table(table):
		var item: Dictionary = raw_item
		var texture: Texture2D
		match kind:
			"joker": texture = ArtResolverScript.get_joker_art(str(item.get("id", "")))
			"voucher": texture = ArtResolverScript.get_voucher_art(str(item.get("id", "")))
			"pack": texture = ArtResolverScript.get_pack_art(str(item.get("id", "")))
			"deck": texture = ArtResolverScript.get_deck_back(str(item.get("id", "")))
			"blind": texture = ArtResolverScript.get_blind_token(str(item.get("id", "")))
			_: texture = ArtResolverScript.get_consumable_art(kind, str(item.get("id", "")))
		_expect(texture != null, "%s art must resolve for %s" % [kind, item.get("id", "")])

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _finish(test_name: String) -> void:
	if failures.is_empty():
		print("PASS %s" % test_name)
		quit(0)
		return
	for failure in failures:
		push_error("%s: %s" % [test_name, failure])
	quit(1)
