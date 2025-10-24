extends Control

const ROUNDS := 3
var round:int = 0
var current_key:String = ""   # "P" or "B"
var time_left:float = 2.5     # seconds per round
var active:bool = false
@onready var bar:ProgressBar = $TimeBar

func _ready() -> void:
	$Header.text = "Ransomware Defense"
	$NextBtn.text = "Next"
	$BackBtn.text = "Back"
	$NextBtn.disabled = true
	$NextBtn.pressed.connect(_next_round)
	$BackBtn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/Hub.tscn"))
	_start_round()

func _start_round() -> void:
	round += 1
	if round > ROUNDS:
		get_tree().change_scene_to_file("res://scenes/Hub.tscn")
		return
	time_left = 2.5
	bar.min_value = 0
	bar.max_value = 2.5
	bar.value = 2.5
	active = true
	current_key = (randi() % 2 == 0) ? "P" : "B"
	var text = (current_key == "P") ? "Press P to patch!" : "Press B to backup!"
	$Prompt.text = text
	$Feedback.text = ""
	$NextBtn.disabled = true

func _process(delta:float) -> void:
	if not active: return
	time_left -= delta
	bar.value = max(time_left, 0.0)
	if time_left <= 0.0:
		active = false
		$Feedback.text = "Too slow!"
		Game.last_result = "lose"
		$NextBtn.disabled = false

func _unhandled_input(event:InputEvent) -> void:
	if not active: return
	if event is InputEventKey and event.pressed and not event.echo:
		var key = OS.get_keycode_string(event.keycode).to_upper()
		if key == current_key:
			active = false
			$Feedback.text = "Nice!"
			Game.add_score(1)
			Game.last_result = "win"
			$NextBtn.disabled = false

func _next_round() -> void:
	_start_round()
