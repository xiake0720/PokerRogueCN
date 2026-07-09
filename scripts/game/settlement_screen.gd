extends Control

@onready var panel: PanelContainer = $Center/Panel
@onready var lines: VBoxContainer = $Center/Panel/VBox/Lines
@onready var claim_button: Button = $Center/Panel/VBox/ClaimButton

func _ready() -> void:
	panel.add_theme_stylebox_override("panel", _panel_style())
	claim_button.pressed.connect(func(): Game.run.claim_settlement())
	refresh()

func refresh() -> void:
	for child in lines.get_children():
		child.queue_free()
	var s: Dictionary = Game.run.settlement
	_add_line("提现", "$%d" % s.get("total", 0), 28)
	_add_line("完成关卡", s.get("stage_name", ""))
	_add_line("本关分数", "%d / %d" % [s.get("score", 0), s.get("target", 0)])
	_add_line("基础奖励", "$%d" % s.get("reward", 0))
	_add_line("剩余出牌奖励", "$%d" % s.get("hand_bonus", 0))
	_add_line("利息奖励", "$%d" % s.get("interest", 0))

func _add_line(left_text: String, right_text: String, font_size: int = 20) -> void:
	var row: HBoxContainer = HBoxContainer.new()
	var left: Label = Label.new()
	left.text = left_text
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.add_theme_font_size_override("font_size", font_size)
	var right: Label = Label.new()
	right.text = right_text
	right.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	right.add_theme_font_size_override("font_size", font_size)
	row.add_child(left)
	row.add_child(right)
	lines.add_child(row)

func _panel_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.15, 0.18, 0.96)
	style.border_color = Color(0.48, 0.56, 0.68)
	style.set_border_width_all(2)
	style.set_corner_radius_all(12)
	style.content_margin_left = 28
	style.content_margin_top = 24
	style.content_margin_right = 28
	style.content_margin_bottom = 24
	return style
