extends Node

const RunStateScript = preload("res://scripts/run/run_state.gd")

signal run_replaced

var run: RunState

func _ready() -> void:
	run = RunStateScript.new()
	run.show_home()

func start_new_run(deck_id: String = "red_deck") -> void:
	run = RunStateScript.new()
	run.start_new_run(deck_id)
	emit_signal("run_replaced")
