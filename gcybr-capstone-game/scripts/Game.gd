# res://scripts/Game.gd
extends Node

signal score_changed(value: int)
signal high_score_changed(value: int)

var score: int = 0
var high_score: int = 0
var last_result: String = ""

const SAVE_PATH := "user://cyberedu_save.cfg"

func _ready() -> void:
	load_save()
	score_changed.emit(score)
	high_score_changed.emit(high_score)

func add_score(amount: int) -> void:
	score += amount
	if score > high_score:
		high_score = score
		high_score_changed.emit(high_score)
		save()
	score_changed.emit(score)

func reset_score() -> void:
	score = 0
	score_changed.emit(score)

func save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("scores", "high_score", high_score)
	cfg.set_value("scores", "last_score", score)  # optional, for future use
	var err := cfg.save(SAVE_PATH)
	if err != OK:
		push_warning("Game.gd: Could not save score file at %s" % SAVE_PATH)

func load_save() -> void:
	var cfg := ConfigFile.new()
	var err := cfg.load(SAVE_PATH)
	if err == OK:
		high_score = int(cfg.get_value("scores", "high_score", 0))
	else:
		high_score = 0
