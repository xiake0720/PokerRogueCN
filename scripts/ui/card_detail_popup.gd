class_name CardDetailPopup
extends PopupPanel

@onready var title_label: Label = $Panel/Margin/VBox/TitleLabel
@onready var type_label: Label = $Panel/Margin/VBox/TypeLabel
@onready var desc_label: Label = $Panel/Margin/VBox/DescLabel
@onready var close_button: Button = $Panel/Margin/VBox/CloseButton

func _ready() -> void:
	close_button.pressed.connect(hide)
	$Panel.add_theme_stylebox_override("panel", _panel_style())

func show_joker(joker: Dictionary) -> void:
	title_label.text = str(joker.get("name_cn", "小丑牌"))
	type_label.text = "稀有度：%s  售价：$%d" % [
		_rarity_text(str(joker.get("rarity", "common"))),
		int(joker.get("cost", 0))
	]
	desc_label.text = str(joker.get("description_cn", ""))
	popup_centered(Vector2(630, 360))

func show_item(item: Dictionary) -> void:
	title_label.text = str(item.get("name_cn", "商品"))
	type_label.text = "%s  价格：$%d" % [
		_kind_text(str(item.get("kind", "item"))),
		int(item.get("cost", 0))
	]
	desc_label.text = str(item.get("description_cn", ""))
	popup_centered(Vector2(630, 360))

func show_hand(hand_data: Dictionary, level: int = 1) -> void:
	var name_cn: String = str(hand_data.get("name_cn", "牌型"))
	var name_en: String = str(hand_data.get("name_en", ""))
	var base_chips: int = int(hand_data.get("base_chips", 0))
	var base_mult: int = int(hand_data.get("base_mult", 0))
	var level_chips: int = int(hand_data.get("level_chips", 0))
	var level_mult: int = int(hand_data.get("level_mult", 0))
	title_label.text = name_cn
	type_label.text = "%s  Lv.%d" % [name_en, level]
	desc_label.text = "%s\n\n基础分：%d筹码 × %d倍率\n每次升级：+%d筹码，+%d倍率" % [
		_hand_rule_text(str(hand_data.get("id", ""))),
		base_chips,
		base_mult,
		level_chips,
		level_mult
	]
	popup_centered(Vector2(720, 430))

func _hand_rule_text(hand_id: String) -> String:
	match hand_id:
		"high_card":
			return "没有组成其他牌型时，以最高计分牌作为高牌。"
		"pair":
			return "包含两张相同点数的牌。"
		"two_pair":
			return "包含两组不同点数的对子。"
		"three_kind":
			return "包含三张相同点数的牌。"
		"straight":
			return "五张点数连续的牌，花色不限。"
		"flush":
			return "五张相同花色的牌，点数不限。"
		"full_house":
			return "三条加一对。"
		"four_kind":
			return "包含四张相同点数的牌。"
		"straight_flush":
			return "五张连续且花色相同的牌。"
		"royal_flush":
			return "同一花色的 10、J、Q、K、A。"
		"five_kind":
			return "通过复制牌形成五张相同点数的牌。"
		"flush_house":
			return "同一花色的葫芦。"
		"flush_five":
			return "五张相同点数且花色相同的牌。"
		_:
			return "特殊牌型。"

func _rarity_text(rarity: String) -> String:
	match rarity:
		"uncommon":
			return "罕见"
		"rare":
			return "稀有"
		"legendary":
			return "传奇"
		_:
			return "普通"

func _kind_text(kind: String) -> String:
	match kind:
		"joker":
			return "小丑牌"
		"voucher":
			return "优惠券"
		"pack":
			return "补充包"
		_:
			return "商品"

func _panel_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.14, 0.16, 0.98)
	style.border_color = Color(0.78, 0.82, 0.88)
	style.set_border_width_all(5)
	style.set_corner_radius_all(15)
	return style
