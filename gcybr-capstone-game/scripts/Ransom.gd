# res://scripts/Ransom.gd
extends Control

const SCN_HUB := "res://scenes/Hub.tscn"

@onready var header:   Label        = $Header
@onready var prompt:   Label        = $Prompt
@onready var bar:      ProgressBar  = $TimeBar
@onready var feedback: Label        = $Feedback
@onready var next_btn: Button       = $NextBtn
@onready var back_btn: Button       = $BackBtn

var debug_label: Label

const ROUNDS := 3
const ROUND_TIME := 2.5

var round:int = 0
var time_left:float = 0.0
var active:bool = false
var current_key:String = ""   # "P" or "B"

func _ready() -> void:
	# On-screen debug
	debug_label = Label.new()
	debug_label.modulate = Color(0,0,0)
	add_child(debug_label)
	_show("[Ransom] init")

	if not _verify_nodes():
		_dump_tree_paths()
		return

	# UI text
	header.text = "Ransomware Defense"
	feedback.text = ""
	next_btn.text = "Next"
	back_btn.text = "Back"
	next_btn.disabled = true

	# Wire buttons
	next_btn.pressed.connect(_next_round)
	back_btn.pressed.connect(func(): get_tree().change_scene_to_file(SCN_HUB))

	# Input & RNG
	set_process(true)
	randomize()

	# Start first round
	_start_round()

func _verify_nodes() -> bool:
	var req := {
		"Header": header,
		"Prompt": prompt,
		"TimeBar": bar,
		"Feedback": feedback,
		"NextBtn": next_btn,
		"BackBtn": back_btn
	}
	for k in req.keys():
		if req[k] == null:
			_fail("Missing node: " + k + " (check names/paths in Ransom.tscn)")
			return false
	return true

func _start_round() -> void:
	round += 1
	if round > ROUNDS:
		get_tree().change_scene_to_file(SCN_HUB)
		return

	# Reset state
	active = true
	time_left = ROUND_TIME
	bar.min_value = 0.0
	bar.max_value = ROUND_TIME
	bar.value = ROUND_TIME
	next_btn.disabled = true
	feedback.text = ""

	# Pick target key  (Godot 4 ternary: value_if_true if cond else value_if_false)
	current_key = "P" if (randi() % 2 == 0) else "B"
	prompt.text = "Press P to patch!" if (current_key == "P") else "Press B to backup!"
	_show("[Ransom] Round %d → key %s" % [round, current_key])

func _process(delta:float) -> void:
	if not active: return
	time_left -= delta
	bar.value = max(time_left, 0.0)
	if time_left <= 0.0:
		active = false
		feedback.text = "Too slow!"
		if Engine.has_singleton("Game"):
			Game.last_result = "lose"
		next_btn.disabled = false

func _unhandled_input(event:InputEvent) -> void:
	if not active: return
	if event is InputEventKey and event.pressed and not event.echo:
		var key := OS.get_keycode_string(event.keycode).to_upper()
		if key == current_key:
			active = false
			feedback.text = "Nice!"
			if Engine.has_singleton("Game"):
				Game.add_score(1)
				Game.last_result = "win"
			next_btn.disabled = false

func _next_round() -> void:
	_start_round()

# ---- helpers
func _show(msg:String) -> void:
	print(msg)
	if debug_label:
		debug_label.text = msg

func _fail(msg:String) -> void:
	push_error(msg)
	_show(msg)

func _dump_tree_paths() -> void:
	print("[Ransom] Scene tree:")
	_dump(self, "")

func _dump(n:Node, indent:String) -> void:
	print(indent, n.get_path())
	for c in n.get_children():
		_dump(c, indent + "  ")
