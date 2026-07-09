class_name GameHudPanel
extends PanelContainer

@onready var title_label: Label = $Margin/VBox/TitleLabel
@onready var desc_label: Label = $Margin/VBox/DescLabel
@onready var score_box: PanelContainer = $Margin/VBox/ScoreBox
@onready var score_label: Label = $Margin/VBox/ScoreBox/ScoreLabel
@onready var hand_box: PanelContainer = $Margin/VBox/HandBox
@onready var current_hand_label: Label = $Margin/VBox/HandBox/HandVBox/CurrentHandLabel
@onready var equation_label: Label = $Margin/VBox/HandBox/HandVBox/EquationLabel
@onready var preview_score_label: Label = $Margin/VBox/HandBox/HandVBox/PreviewScoreLabel
@onready var hands_label: Label = $Margin/VBox/CountsGrid/HandsLabel
@onready var discards_label: Label = $Margin/VBox/CountsGrid/DiscardsLabel
@onready var money_label: Label = $Margin/VBox/MoneyLabel
@onready var deck_label: Label = $Margin/VBox/DeckLabel
@onready var hand_list_toggle: Button = $Margin/VBox/HandListToggle
@onready var hand_info_scroll: ScrollContainer = $Margin/VBox/HandInfoScroll
@onready var hand_info: RichTextLabel = $Margin/VBox/HandInfoScroll/HandInfo

var hand_list_expanded: bool = false

func _ready() -> void:
	hand_list_toggle.pressed.connect(_toggle_hand_list)

func refresh_run(run: RunState, mode: String = "battle") -> void:
	title_label.text = str(run.current_blind.get("name_cn", "关卡"))
	if mode == "shop":
		desc_label.text = "商店｜底注 %d/8｜关卡 %d" % [run.ante, run.blind_index + 1]
	elif mode == "stage":
		desc_label.text = str(run.current_blind.get("description_cn", "基础规则"))
	else:
		desc_label.text = "至少得分 %d" % run.target_score
	score_label.text = "%d / %d" % [run.current_score, run.target_score]
	hands_label.text = str(run.hands_left if mode == "battle" else run.base_hands)
	discards_label.text = str(run.discards_left if mode == "battle" else run.base_discards)
	money_label.text = "$%d" % run.money
	deck_label.text = "牌库 %d / 弃牌堆 %d" % [run.deck.size(), run.discard_pile.size()] if mode == "battle" else "牌库 %d/%d" % [run.full_deck.size(), run.full_deck.size()]
	if mode != "battle":
		set_hand_preview("高牌  等级%d" % int(run.hand_levels.get("high_card", 1)), "5 x 1", "默认基础牌型")
	hand_info.text = _hand_info_text(run)

func set_hand_preview(hand_text: String, equation_text: String, preview_text: String) -> void:
	current_hand_label.text = hand_text
	equation_label.text = equation_text
	preview_score_label.text = preview_text

func _toggle_hand_list() -> void:
	hand_list_expanded = not hand_list_expanded
	hand_info_scroll.visible = hand_list_expanded
	hand_list_toggle.text = "牌型等级  -" if hand_list_expanded else "牌型等级  +"

func _hand_info_text(run: RunState) -> String:
	var lines: Array[String] = ["[b]牌型等级[/b]"]
	for h in DataRegistry.get_table("poker_hands"):
		var hand_id: String = str(h.get("id", ""))
		lines.append("%s Lv.%d  %d筹码 x %d倍率" % [str(h.get("name_cn", "")), int(run.hand_levels.get(hand_id, 1)), int(h.get("base_chips", 0)), int(h.get("base_mult", 0))])
	return "\n".join(lines)
