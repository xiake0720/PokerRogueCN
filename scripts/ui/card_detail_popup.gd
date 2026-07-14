class_name CardDetailPopup
extends PopupPanel

@onready var title_label: Label = $Panel/Margin/VBox/TitleLabel
@onready var type_label: Label = $Panel/Margin/VBox/TypeLabel
@onready var description_scroll: ScrollContainer = $Panel/Margin/VBox/DescriptionScroll
@onready var desc_label: Label = $Panel/Margin/VBox/DescriptionScroll/DescLabel
@onready var close_button: Button = $Panel/Margin/VBox/CloseButton

const POPUP_SIZE := Vector2i(460, 420)

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
	_open_centered()

func show_item(item: Dictionary) -> void:
	title_label.text = str(item.get("name_cn", "商品"))
	type_label.text = "%s  价格：$%d" % [
		_kind_text(str(item.get("kind", "item"))),
		int(item.get("cost", 0))
	]
	desc_label.text = str(item.get("description_cn", ""))
	_open_centered()

func _open_centered() -> void:
	description_scroll.scroll_vertical = 0
	popup_centered(POPUP_SIZE)
	description_scroll.set_deferred("scroll_vertical", 0)

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
	style.set_border_width_all(3)
	style.set_corner_radius_all(10)
	return style
