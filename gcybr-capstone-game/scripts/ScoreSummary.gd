# res://scripts/ScoreSummary.gd
extends Control

@onready var title_label: Label    = $VBox/TitleLabel
@onready var score_label: Label    = $VBox/ScoreLabel
@onready var high_label: Label     = $VBox/HighScoreLabel
@onready var back_btn: Button      = $VBox/BackBtn

func _ready() -> void:
	title_label.text = "Session Summary"
	score_label.text = "Score this session: %d" % Game.score
	high_label.text  = "Best score: %d" % Game.high_score

	back_btn.text = "Back to Main Menu"
	back_btn.pressed.connect(_back_to_menu)

	# Make sure any new high score is written to disk
	Game.save()

func _back_to_menu() -> void:
	Game.reset_score()
	Transition.change_scene("res://scenes/MainMenu.tscn")
