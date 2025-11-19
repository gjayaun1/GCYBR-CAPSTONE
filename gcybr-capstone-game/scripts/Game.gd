# res://scripts/Game.gd
extends Node

signal score_changed(value: int)
signal high_score_changed(value: int)
signal achievement_unlocked(key: String)

var score: int = 0
var high_score: int = 0
var last_result: String = ""

# Simple achievement flags
var achievements := {
	"password_master": false,
	"phishing_pro": false,
	"ransomware_hero": false
}

const SAVE_PATH := "user://cyberedu_save.cfg"

func _ready() -> void:
	load_save()
	score_changed.emit(score)
	high_score_changed.emit(high_score)


# ---------- SCORE (you can ignore if you’re not using) ----------

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


# ---------- ACHIEVEMENTS ----------

func unlock_achievement(key: String) -> void:
	if not achievements.has(key):
		push_warning("Game.gd: Unknown achievement key: %s" % key)
		return

	if achievements[key]:
		# Already unlocked, do nothing
		return

	achievements[key] = true
	achievement_unlocked.emit(key)
	save()


# ---------- SAVE / LOAD ----------

func save() -> void:
	var cfg := ConfigFile.new()
	# scores (optional)
	cfg.set_value("scores", "high_score", high_score)
	cfg.set_value("scores", "last_score", score)

	# achievements
	for key in achievements.keys():
		cfg.set_value("achievements", key, achievements[key])

	var err := cfg.save(SAVE_PATH)
	if err != OK:
		push_warning("Game.gd: Could not save score file at %s" % SAVE_PATH)

func load_save() -> void:
	var cfg := ConfigFile.new()
	var err := cfg.load(SAVE_PATH)
	if err == OK:
		high_score = int(cfg.get_value("scores", "high_score", 0))
		score      = int(cfg.get_value("scores", "last_score", 0))

		for key in achievements.keys():
			achievements[key] = bool(cfg.get_value("achievements", key, false))
	else:
		high_score = 0
		score = 0
		# defaults for achievements already set above
