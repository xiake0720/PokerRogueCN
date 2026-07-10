extends Control

@onready var title_label: Label = %TitleLabel
@onready var status_label: Label = %StatusLabel
@onready var ante_row: HBoxContainer = %AnteRow
@onready var blind_row: HBoxContainer = %BlindRow
@onready var score_row: HBoxContainer = %ScoreRow
@onready var hands_row: HBoxContainer = %HandsRow
@onready var best_hand_row: HBoxContainer = %BestHandRow
@onready var jokers_row: HBoxContainer = %JokersRow
@onready var money_row: HBoxContainer = %MoneyRow
@onready var failure_reason_row: HBoxContainer = %FailureReasonRow
@onready var result_art_label: Label = %ResultArtLabel
@onready var primary_button: Button = %PrimaryButton
@onready var home_button: Button = %HomeButton

var _victory: bool = false

func _ready() -> void:
	home_button.pressed.connect(func() -> void: Game.run.show_home())
	primary_button.pressed.connect(_on_primary_pressed)
	refresh()

func refresh() -> void:
	var run: RunState = Game.run
	_victory = run.phase == RunState.Phase.VICTORY
	title_label.text = "通关成功" if _victory else "本局失败"
	status_label.text = "第 8 底注已经通过" if _victory else "本次挑战止步于当前盲注"
	_set_row(ante_row, "到达底注" if _victory else "当前底注", str(run.ante))
	_set_row(blind_row, "当前盲注", str(run.current_blind.get("name_cn", "盲注")))
	_set_row(score_row, "总分" if _victory else "当前分数 / 目标分", str(run.current_score) if _victory else "%d / %d" % [run.current_score, run.target_score])
	_set_row(hands_row, "总出牌次数", str(_total_hands(run)))
	_set_row(best_hand_row, "最佳牌型", _best_hand_name(run))
	_set_row(jokers_row, "持有小丑牌", "%d / %d" % [run.jokers.size(), run.joker_slots])
	_set_row(money_row, "最终资金", "$%d" % run.money)
	failure_reason_row.visible = not _victory
	_set_row(failure_reason_row, "失败原因", "出牌次数耗尽，未达到目标分")
	primary_button.text = "进入无尽模式" if _victory else "重新开始"
	result_art_label.text = "征服八个底注\n幸运常伴" if _victory else "整理牌组\n再试一次"

func _set_row(row: HBoxContainer, title: String, value: String) -> void:
	(row.get_node("Left") as Label).text = title
	(row.get_node("Right") as Label).text = value

func _total_hands(run: RunState) -> int:
	var total: int = 0
	for count_value in run.total_hand_counts.values():
		total += int(count_value)
	return total

func _best_hand_name(run: RunState) -> String:
	var best_id: String = "high_card"
	var best_count: int = -1
	for hand_id_value in run.total_hand_counts:
		var hand_id: String = str(hand_id_value)
		var count: int = int(run.total_hand_counts.get(hand_id, 0))
		if count > best_count:
			best_count = count
			best_id = hand_id
	var hand_data: Dictionary = DataRegistry.find_by_id("poker_hands", best_id)
	return str(hand_data.get("name_cn", "高牌"))

func _on_primary_pressed() -> void:
	AudioManager.play_sfx("ui_click")
	if _victory:
		Game.run.continue_endless()
	else:
		Game.start_new_run(Game.run.deck_id, Game.run.seed_text)
