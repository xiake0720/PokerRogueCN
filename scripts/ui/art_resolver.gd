class_name ArtResolver
extends RefCounted

## Central, data-driven resolver for non-playing-card artwork.
##
## Dedicated mappings and category fallbacks are declared in
## `assets/cards/card_art_manifest.json`.  No texture path is assembled from an
## untrusted id, and missing art always resolves to a checked, text-free PNG.

const MANIFEST_PATH: String = "res://assets/cards/card_art_manifest.json"

static var _manifest: Dictionary = {}
static var _manifest_loaded: bool = false
static var _texture_cache: Dictionary = {}
static var _warned_keys: Dictionary = {}


static func resolve_texture(kind: String, art_id: String, subtype: String = "") -> Texture2D:
	var path: String = resolve_path(kind, art_id, subtype)
	if path.is_empty():
		return null
	if _texture_cache.has(path):
		return _texture_cache[path] as Texture2D
	var texture: Texture2D = ResourceLoader.load(path, "Texture2D") as Texture2D
	if texture != null:
		_texture_cache[path] = texture
	else:
		_warn_once("load:%s" % path, "ArtResolver 无法加载纹理：%s" % path)
	return texture


static func resolve(kind: String, art_id: String, subtype: String = "") -> Texture2D:
	return resolve_texture(kind, art_id, subtype)


static func get_joker_art(joker_id: String) -> Texture2D:
	return resolve_texture("joker", joker_id)


static func get_consumable_art(kind: String, consumable_id: String) -> Texture2D:
	return resolve_texture("consumable", consumable_id, kind)


static func get_voucher_art(voucher_id: String) -> Texture2D:
	return resolve_texture("voucher", voucher_id)


static func get_pack_art(pack_id: String) -> Texture2D:
	return resolve_texture("pack", pack_id)


static func get_deck_back(deck_id: String) -> Texture2D:
	return resolve_texture("deck", deck_id)


static func get_blind_token(blind_id: String) -> Texture2D:
	return resolve_texture("blind", blind_id)


static func resolve_path(kind: String, art_id: String, subtype: String = "") -> String:
	_ensure_manifest()
	var requested_kind: String = kind.strip_edges().to_lower()
	var normalized_kind: String = _normalize_kind(requested_kind)
	var normalized_subtype: String = subtype.strip_edges().to_lower()
	if normalized_subtype.is_empty() and requested_kind in ["tarot", "planet", "spectral"]:
		normalized_subtype = requested_kind

	var kinds: Dictionary = _manifest.get("kinds", {}) as Dictionary
	var kind_entry: Dictionary = kinds.get(normalized_kind, {}) as Dictionary
	if not kind_entry.is_empty():
		var clean_id: String = art_id.strip_edges()
		var items: Dictionary = kind_entry.get("items", {}) as Dictionary
		var dedicated_path: String = str(items.get(clean_id, ""))
		if _is_loadable_texture(dedicated_path):
			return dedicated_path

		if normalized_kind == "consumable" and normalized_subtype.is_empty():
			normalized_subtype = _consumable_subtype(kind_entry, clean_id)
		var subtype_fallbacks: Dictionary = kind_entry.get("fallback_by_subtype", {}) as Dictionary
		var subtype_path: String = str(subtype_fallbacks.get(normalized_subtype, ""))
		if _is_loadable_texture(subtype_path):
			return subtype_path

		var fallback_path: String = str(kind_entry.get("fallback", ""))
		if _is_loadable_texture(fallback_path):
			var known_ids: Array = kind_entry.get("known_ids", []) as Array
			if not clean_id.is_empty() and not items.has(clean_id) and not known_ids.has(clean_id):
				_warn_once(
					"fallback:%s:%s" % [normalized_kind, clean_id],
					"美术资源缺少专属映射，已使用 %s fallback：%s" % [normalized_kind, clean_id]
				)
			return fallback_path

	var unknown_path: String = str(_manifest.get("unknown_fallback", ""))
	if _is_loadable_texture(unknown_path):
		_warn_once(
			"unknown:%s:%s" % [normalized_kind, art_id],
			"ArtResolver 收到未知资源类型或无可用分类 fallback：%s/%s" % [normalized_kind, art_id]
		)
		return unknown_path
	return ""


static func resolve_texture_for_data(data: Dictionary, kind_hint: String = "") -> Texture2D:
	var kind: String = kind_hint.strip_edges().to_lower()
	if kind.is_empty():
		kind = str(data.get("kind", "")).strip_edges().to_lower()
	if kind.is_empty():
		kind = _infer_kind(data)
	var subtype: String = ""
	if kind in ["tarot", "planet", "spectral"]:
		subtype = kind
	elif _normalize_kind(kind) == "consumable":
		subtype = str(data.get("type", data.get("subtype", ""))).strip_edges().to_lower()
	return resolve_texture(kind, str(data.get("id", "")), subtype)


static func resolve_path_for_data(data: Dictionary, kind_hint: String = "") -> String:
	var kind: String = kind_hint.strip_edges().to_lower()
	if kind.is_empty():
		kind = str(data.get("kind", "")).strip_edges().to_lower()
	if kind.is_empty():
		kind = _infer_kind(data)
	var subtype: String = ""
	if kind in ["tarot", "planet", "spectral"]:
		subtype = kind
	elif _normalize_kind(kind) == "consumable":
		subtype = str(data.get("type", data.get("subtype", ""))).strip_edges().to_lower()
	return resolve_path(kind, str(data.get("id", "")), subtype)


static func has_dedicated_art(kind: String, art_id: String) -> bool:
	_ensure_manifest()
	var kinds: Dictionary = _manifest.get("kinds", {}) as Dictionary
	var kind_entry: Dictionary = kinds.get(_normalize_kind(kind), {}) as Dictionary
	var items: Dictionary = kind_entry.get("items", {}) as Dictionary
	var path: String = str(items.get(art_id, ""))
	return _is_loadable_texture(path)


static func is_using_fallback(kind: String, art_id: String) -> bool:
	return not has_dedicated_art(kind, art_id) and not resolve_path(kind, art_id).is_empty()


static func manifest_snapshot() -> Dictionary:
	_ensure_manifest()
	return _manifest.duplicate(true)


static func clear_cache() -> void:
	_manifest.clear()
	_texture_cache.clear()
	_warned_keys.clear()
	_manifest_loaded = false


static func _ensure_manifest() -> void:
	if _manifest_loaded:
		return
	_manifest_loaded = true
	if not FileAccess.file_exists(MANIFEST_PATH):
		_warn_once("manifest:missing", "缺少美术资源清单：%s" % MANIFEST_PATH)
		return
	var payload: String = FileAccess.get_file_as_string(MANIFEST_PATH)
	var parsed: Variant = JSON.parse_string(payload)
	if not (parsed is Dictionary):
		_warn_once("manifest:invalid", "美术资源清单不是有效 JSON 对象：%s" % MANIFEST_PATH)
		return
	_manifest = parsed as Dictionary
	if int(_manifest.get("schema_version", 0)) != 1:
		_warn_once("manifest:schema", "不支持的美术资源清单版本：%s" % str(_manifest.get("schema_version", 0)))
		_manifest.clear()


static func _normalize_kind(kind: String) -> String:
	match kind.strip_edges().to_lower():
		"jokers", "joker_card":
			return "joker"
		"vouchers", "coupon":
			return "voucher"
		"packs", "booster", "booster_pack":
			return "pack"
		"tarot", "planet", "spectral", "consumables":
			return "consumable"
		"decks", "card_back":
			return "deck"
		"blinds", "boss_blind":
			return "blind"
		_:
			return kind.strip_edges().to_lower()


static func _consumable_subtype(kind_entry: Dictionary, art_id: String) -> String:
	var subtype_ids: Dictionary = kind_entry.get("subtype_ids", {}) as Dictionary
	for subtype_value: Variant in subtype_ids.keys():
		var subtype: String = str(subtype_value)
		var ids: Array = subtype_ids.get(subtype_value, []) as Array
		if art_id in ids:
			return subtype
	return ""


static func _infer_kind(data: Dictionary) -> String:
	var card_type: String = str(data.get("type", "")).strip_edges().to_lower()
	if card_type in ["tarot", "planet", "spectral"]:
		return card_type
	if data.has("rarity") and data.has("sell_value"):
		return "joker"
	if data.has("choose") and data.has("show"):
		return "pack"
	if data.has("start_money") and data.has("joker_slots"):
		return "deck"
	if data.has("score_mult") and data.has("reward"):
		return "blind"
	return ""


static func _is_loadable_texture(path: String) -> bool:
	return (
		not path.is_empty()
		and path.begins_with("res://")
		and not path.contains("..")
		and ResourceLoader.exists(path, "Texture2D")
	)


static func _warn_once(key: String, message: String) -> void:
	if _warned_keys.has(key):
		return
	_warned_keys[key] = true
	push_warning(message)
