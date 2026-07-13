class_name BlindSelectPanel
extends Control

@onready var stage_cards: Array[StageCardView] = [
	%SmallBlindCard, %BigBlindCard, %BossBlindCard,
]


func _ready() -> void:
	for i: int in range(stage_cards.size()):
		stage_cards[i].select_requested.connect(_on_stage_select_requested.bind(i))
		stage_cards[i].skip_requested.connect(_on_stage_skip_requested.bind(i))


func refresh_run(run: RunState) -> void:
	var blind_ids: Array[String] = ["small_blind", "big_blind", str(run.current_blind.get("id", "boss_none"))]
	var default_names: Array[String] = ["小盲注", "大盲注", "首领盲注"]
	for i: int in range(stage_cards.size()):
		var blind_data: Dictionary = DataRegistry.find_by_id("blinds", blind_ids[i])
		var title: String = str(blind_data.get("name_cn", default_names[i]))
		if i == 2 and title.is_empty():
			title = "首领盲注"
		var is_active: bool = i == run.blind_index
		var is_locked: bool = i < run.blind_index or i > run.blind_index + 1
		var tag_data: Dictionary = run.current_skip_tag() if is_active and i < 2 else {}
		stage_cards[i].setup(
			title,
			run.target_preview_for_stage(i),
			int(blind_data.get("reward", 3 + i)),
			is_active,
			is_locked,
			i < 2,
			["small", "big", "boss"][i],
			tag_data,
			str(blind_data.get("description_cn", ""))
		)


func _on_stage_select_requested(index: int) -> void:
	if index != Game.run.blind_index:
		return
	for card: StageCardView in stage_cards:
		card.set_process_input(false)
	Game.run.start_round()


func _on_stage_skip_requested(index: int) -> void:
	if index == Game.run.blind_index and index < 2:
		Game.run.skip_blind()
