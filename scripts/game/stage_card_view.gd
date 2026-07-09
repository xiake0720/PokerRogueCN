class_name StageCardView
extends PanelContainer

signal select_requested
signal skip_requested

@onready var select_button: Button = $VBox/SelectButton
@onready var title_label: Label = $VBox/TitleLabel
@onready var token_label: Label = $VBox/TokenLabel
@onready var target_label: Label = $VBox/TargetLabel
@onready var reward_label: Label = $VBox/RewardLabel
@onready var or_label: Label = $VBox/OrLabel
@onready var skip_button: Button = $VBox/SkipButton

func _ready() -> void:
	select_button.pressed.connect(func() -> void: select_requested.emit())
	skip_button.pressed.connect(func() -> void: skip_requested.emit())
	add_theme_stylebox_override("panel", _panel_style(false, false))

func setup(title: String, target_score: int, reward: int, active: bool, locked: bool, skippable: bool = true) -> void:
	title_label.text = title
	token_label.text = _token_text(title)
	target_label.text = "至少得分\n%d" % target_score
	reward_label.text = "奖励：%s" % _reward_text(reward)
	select_button.disabled = not active
	select_button.text = "选择" if active else "下一回合"
	skip_button.visible = active and skippable
	or_label.visible = active and skippable
	add_theme_stylebox_override("panel", _panel_style(active, locked))
	modulate = Color(1, 1, 1, 0.42) if locked else Color.WHITE
	_play_intro(active)

func _reward_text(reward: int) -> String:
	var text: String = ""
	for i in range(reward):
		text += "$"
	return text

func _token_text(title: String) -> String:
	if title.find("首领") >= 0:
		return "BOSS"
	if title.find("中") >= 0:
		return "BIG"
	return "SMALL"

func _play_intro(active: bool) -> void:
	scale = Vector2(1.0, 1.0)
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1.04, 1.04) if active else Vector2.ONE, 0.16)

func _panel_style(active: bool, locked: bool) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.18, 0.19, 0.96)
	if locked:
		style.border_color = Color(0.4, 0.43, 0.45)
	elif active:
		style.border_color = Color(0.0, 0.52, 0.88)
	else:
		style.border_color = Color(0.55, 0.43, 0.16)
	style.set_border_width_all(4 if active else 2)
	style.set_corner_radius_all(10)
	style.content_margin_left = 14
	style.content_margin_top = 14
	style.content_margin_right = 14
	style.content_margin_bottom = 14
	return style
