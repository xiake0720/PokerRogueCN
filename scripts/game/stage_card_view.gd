class_name StageCardView
extends PanelContainer

signal select_requested
signal skip_requested

const SMALL_BLIND_TEXTURE: Texture2D = preload("res://assets/ui/runtime/tokens/stage_blind_small.png")
const BIG_BLIND_TEXTURE: Texture2D = preload("res://assets/ui/runtime/tokens/stage_blind_big.png")
const BOSS_BLIND_TEXTURE: Texture2D = preload("res://assets/ui/runtime/tokens/stage_blind_boss_locked.png")

@onready var active_glow: PanelContainer = %ActiveGlow
@onready var card_frame: PanelContainer = %CardFrame
@onready var content: Control = %Content
@onready var badge_background: PanelContainer = %BadgeBackground
@onready var state_badge: Label = %StateBadge
@onready var blind_token: TextureRect = %BlindToken
@onready var lock_overlay: TextureRect = %LockOverlay
@onready var select_button: Button = %SelectButton
@onready var skip_button: Button = %SkipButton
@onready var title_label: Label = %TitleLabel
@onready var description_label: Label = %DescriptionLabel
@onready var target_label: Label = %TargetLabel
@onready var reward_label: Label = %RewardLabel
@onready var tag_reward_panel: PanelContainer = %TagRewardPanel
@onready var tag_reward_label: Label = %TagRewardLabel

var _last_visual_state: String = ""
var _intro_tween: Tween = null


func _ready() -> void:
	select_button.pressed.connect(func() -> void: select_requested.emit())
	skip_button.pressed.connect(func() -> void: skip_requested.emit())
	pivot_offset = custom_minimum_size * 0.5


func setup(
	title: String,
	target_score: int,
	reward: int,
	active: bool,
	locked: bool,
	skippable: bool = true,
	blind_kind: String = "small",
	tag_data: Dictionary = {},
	description: String = ""
) -> void:
	title_label.text = title
	description_label.text = description
	target_label.text = _format_score(target_score)
	reward_label.text = "奖励：%s" % _reward_text(reward)
	blind_token.texture = _blind_texture(blind_kind)
	card_frame.theme_type_variation = &"StageCardActive" if active else (&"StageCardLocked" if locked else &"StageCardNext")
	active_glow.visible = active
	card_frame.self_modulate = Color.WHITE
	content.modulate = Color.WHITE if active else (Color(0.9, 0.93, 0.88, 1.0) if not locked else Color(0.58, 0.61, 0.59, 1.0))
	lock_overlay.visible = locked and blind_kind != "boss"
	state_badge.text = "当前" if active else ("未解锁" if locked else "下一盲注")
	badge_background.self_modulate = Color(0.95, 0.68, 0.24, 1.0) if active else (Color(0.38, 0.57, 0.43, 1.0) if not locked else Color(0.42, 0.44, 0.43, 1.0))
	select_button.disabled = not active
	select_button.text = "挑战" if active else ("未解锁" if locked else "下一盲注")
	var has_tag: bool = not tag_data.is_empty()
	tag_reward_panel.visible = active and skippable and has_tag
	tag_reward_label.text = "跳过：%s\n%s" % [
		str(tag_data.get("name_cn", "标签奖励")),
		str(tag_data.get("description_cn", "")),
	]
	skip_button.visible = active and skippable and has_tag
	skip_button.disabled = not active
	tooltip_text = "%s\n%s" % [title, description]
	var visual_state := "active" if active else ("locked" if locked else "next")
	if visual_state != _last_visual_state:
		_last_visual_state = visual_state
		_play_intro()


func _reward_text(reward: int) -> String:
	var text: String = ""
	for _index in range(max(reward, 0)):
		text += "$"
	return text


func _blind_texture(blind_kind: String) -> Texture2D:
	match blind_kind:
		"big":
			return BIG_BLIND_TEXTURE
		"boss":
			return BOSS_BLIND_TEXTURE
		_:
			return SMALL_BLIND_TEXTURE


func _format_score(value: int) -> String:
	var digits: String = str(max(value, 0))
	var grouped: String = ""
	while digits.length() > 3:
		grouped = ",%s%s" % [digits.right(3), grouped]
		digits = digits.left(digits.length() - 3)
	return digits + grouped


func _play_intro() -> void:
	if _intro_tween != null and _intro_tween.is_valid():
		_intro_tween.kill()
	scale = Vector2(0.985, 0.985)
	modulate.a = 0.0
	_intro_tween = create_tween().set_parallel(true)
	_intro_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_intro_tween.tween_property(self, "modulate:a", 1.0, 0.16)
	_intro_tween.tween_property(self, "scale", Vector2.ONE, 0.2)
	_intro_tween.finished.connect(func() -> void: _intro_tween = null, CONNECT_ONE_SHOT)


func _exit_tree() -> void:
	if _intro_tween != null and _intro_tween.is_valid():
		_intro_tween.kill()
	_intro_tween = null
