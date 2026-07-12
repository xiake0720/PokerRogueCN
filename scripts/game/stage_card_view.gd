class_name StageCardView
extends PanelContainer

signal select_requested
signal skip_requested

const ACTIVE_PANEL_TEXTURE: Texture2D = preload("res://assets/ui/runtime/frames/stage_card_active.png")
const NEXT_PANEL_TEXTURE: Texture2D = preload("res://assets/ui/runtime/frames/stage_card_next.png")
const LOCKED_PANEL_TEXTURE: Texture2D = preload("res://assets/ui/runtime/frames/stage_card_locked.png")
const SMALL_BLIND_TEXTURE: Texture2D = preload("res://assets/ui/runtime/tokens/stage_blind_small.png")
const BIG_BLIND_TEXTURE: Texture2D = preload("res://assets/ui/runtime/tokens/stage_blind_big.png")
const BOSS_BLIND_TEXTURE: Texture2D = preload("res://assets/ui/runtime/tokens/stage_blind_boss_locked.png")

@onready var active_glow: TextureRect = %ActiveGlow
@onready var card_frame: TextureRect = %CardFrame
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
	card_frame.texture = LOCKED_PANEL_TEXTURE if locked else (ACTIVE_PANEL_TEXTURE if active else NEXT_PANEL_TEXTURE)
	active_glow.visible = active
	lock_overlay.visible = locked and blind_kind != "boss"
	state_badge.text = "可选" if active else ("锁定" if locked else "下一盲注")
	state_badge.visible = active or locked
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
	_play_intro(active)


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


func _play_intro(active: bool) -> void:
	scale = Vector2.ONE
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1.025, 1.025) if active else Vector2.ONE, 0.16)
