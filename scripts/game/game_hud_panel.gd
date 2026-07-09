class_name GameHudPanel
extends PanelContainer

signal hand_detail_requested(hand_id: String)

@onready var shop_sign: PanelContainer = $LeftVBox/ShopSign
@onready var prompt_label: Label = $LeftVBox/PromptLabel
@onready var stage_label: Label = $LeftVBox/StageLabel
@onready var stage_desc: Label = $LeftVBox/StageDesc
@onready var score_box: PanelContainer = $LeftVBox/ScoreBox
@onready var score_label: Label = $LeftVBox/ScoreBox/ScoreLabel
@onready var selected_hand_box: PanelContainer = $LeftVBox/SelectedHandBox
@onready var current_hand_label: Label = $LeftVBox/SelectedHandBox/SelectedHandVBox/CurrentHandLabel
@onready var equation_label: Label = $LeftVBox/SelectedHandBox/SelectedHandVBox/EquationLabel
@onready var preview_score_label: Label = $LeftVBox/SelectedHandBox/SelectedHandVBox/PreviewScoreLabel
@onready var hands_label: Label = $LeftVBox/CountsGrid/HandsLabel
@onready var discards_label: Label = $LeftVBox/CountsGrid/DiscardsLabel
@onready var money_label: Label = $LeftVBox/MoneyLabel
@onready var deck_label: Label = $LeftVBox/DeckLabel
@onready var hand_list_toggle: Button = $LeftVBox/HandListToggle
@onready var hand_info_scroll: ScrollContainer = $LeftVBox/HandInfoScroll
@onready var hand_info: RichTextLabel = $LeftVBox/HandInfoScroll/HandInfo
@onready var options_button: Button = $LeftVBox/OptionsButton

var hand_list_expanded: bool = false
var current_mode: String = "battle"

func _ready() -> void:
	add_theme_stylebox_override("panel", _panel_style())
	score_box.add_theme_stylebox_override("panel", _score_box_style())
	selected_hand_box.add_theme_stylebox_override("panel", _score_box_style())
	shop_sign.add_theme_stylebox_override("panel", _shop_sign_style())
	hand_list_toggle.pressed.connect(_toggle_hand_list)
	hand_info.meta_clicked.connect(_on_hand_meta_clicked)
	hand_info.bbcode_enabled = true
	hand_info_scroll.visible = false

func refresh_run(run: RunState, mode: String) -> void:
	current_mode = mode
	shop_sign.visible = mode == "shop"
	prompt_label.visible = mode == "stage"
	stage_label.visible = mode != "shop"
	stage_desc.visible = mode != "shop"
	if mode == "stage":
		prompt_label.text = "选择你的\n下一关"
		stage_label.text = str(run.current_blind.get("name_cn", "关卡"))
		stage_desc.text = str(run.current_blind.get("description_cn", "基础规则"))
		score_label.text = "0 / %d" % run.target_score
	elif mode == "shop":
		score_label.text = "%d / %d" % [run.current_score, run.target_score]
	else:
		stage_label.text = str(run.current_blind.get("name_cn", "关卡"))
		stage_desc.text = "至少得分 %d" % run.target_score
		score_label.text = "%d / %d" % [run.current_score, run.target_score]
	hands_label.text = str(run.hands_left if mode == "battle" else run.base_hands)
	discards_label.text = str(run.discards_left if mode == "battle" else run.base_discards)
	money_label.text = "$%d" % run.money
	deck_label.text = "底注 %d/8  关卡 %d" % [run.ante, run.blind_index + 1]
	hand_info.text = _hand_info_text(run)
	if mode != "battle":
		set_selected_preview("高牌", int(run.hand_levels.get("high_card", 1)), 5, 1, "基础牌型")

func set_selected_preview(hand_name: String, level: int, chips: int, mult: int, preview_text: String) -> void:
	current_hand_label.text = "%s  等级%d" % [hand_name, level]
	equation_label.text = "%d x %d" % [chips, mult]
	preview_score_label.text = preview_text

func set_deck_text(deck_count: int, discard_count: int) -> void:
	deck_label.text = "牌库 %d / 弃牌堆 %d" % [deck_count, discard_count]

func _toggle_hand_list() -> void:
	hand_list_expanded = not hand_list_expanded
	hand_info_scroll.visible = hand_list_expanded
	hand_list_toggle.text = "牌型等级  -" if hand_list_expanded else "牌型等级  +"

func _hand_info_text(run: RunState) -> String:
	var lines: Array[String] = ["[b]牌型等级[/b]  [color=#a8b8c0]点击牌型查看说明[/color]"]
	for h in DataRegistry.get_table("poker_hands"):
		var hand_id: String = str(h.get("id", ""))
		var hand_name: String = str(h.get("name_cn", ""))
		var level: int = int(run.hand_levels.get(hand_id, 1))
		lines.append("[url=%s]%s Lv.%d[/url]" % [hand_id, hand_name, level])
	return "\n".join(lines)

func _on_hand_meta_clicked(meta: Variant) -> void:
	hand_detail_requested.emit(str(meta))

func _panel_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.09, 0.12, 0.14, 0.96)
	style.border_color = Color(0.52, 0.22, 0.12)
	style.set_border_width_all(5)
	style.set_corner_radius_all(12)
	style.content_margin_left = 24
	style.content_margin_top = 24
	style.content_margin_right = 24
	style.content_margin_bottom = 24
	return style

func _score_box_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.11, 0.12, 0.96)
	style.border_color = Color(0.18, 0.24, 0.27)
	style.set_border_width_all(3)
	style.set_corner_radius_all(12)
	style.content_margin_left = 18
	style.content_margin_top = 18
	style.content_margin_right = 18
	style.content_margin_bottom = 18
	return style

func _shop_sign_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.12, 0.13, 0.98)
	style.border_color = Color(1.0, 0.22, 0.22)
	style.set_border_width_all(5)
	style.set_corner_radius_all(14)
	style.content_margin_left = 18
	style.content_margin_top = 18
	style.content_margin_right = 18
	style.content_margin_bottom = 18
	return style
