# res://scripts/Ransom.gd
extends Control

const SCN_HUB := "res://scenes/Hub.tscn"

@onready var header:   Label       = $Header
@onready var prompt:   Label       = $Prompt
@onready var bar:      ProgressBar = $TimeBar
@onready var feedback: Label       = $Feedback
@onready var next_btn: Button      = $NextBtn
@onready var back_btn: Button      = $BackBtn

@onready var intro_popup:     Control = $IntroPopup
@onready var intro_title:     Label   = $IntroPopup/VBox/Title
@onready var intro_body:      Label   = $IntroPopup/VBox/Body
@onready var intro_start_btn: Button  = $IntroPopup/VBox/StartBtn

var debug_label: Label

# Game config
const TOTAL_TIME := 12.0  # seconds to complete all steps

var time_left: float = 0.0
var active: bool = false

var steps: Array[String] = [
	"1) Disconnect from Wi-Fi (press D)",
	"2) Start a backup (press B)",
	"3) Run an antivirus scan (press S)"
]

var step_keys: Array[String] = ["D", "B", "S"]
var step_index: int = 0  # 0..2


func _ready() -> void:
	# On-screen debug label
	debug_label = Label.new()
	debug_label.modulate = Color(0, 0, 0)
	add_child(debug_label)
	_show("[Ransom] init")

	if not _verify_nodes():
		_dump_tree_paths()
		return

	# Basic UI text
	header.text = "Ransomware Defense"
	next_btn.text = "Play Again"
	back_btn.text = "Back"
	next_btn.disabled = true
	feedback.text = ""

	# Wire buttons
	next_btn.pressed.connect(_on_next_pressed)
	back_btn.pressed.connect(func(): Transition.change_scene(SCN_HUB))

	set_process(true)

	# Intro popup explains the changed game
	_setup_intro_popup()
	_show_intro(true)

func _setup_intro_popup() -> void:
	if intro_title:
		intro_title.text = "Ransomware Game – Overview"

	if intro_body:
		intro_body.text = (
			"Goal: React quickly when ransomware starts to spread.\n\n" +
			"You have a short countdown before your files are locked.\n\n" +
			"To protect your data, you must do THREE actions in order:\n\n" +
			"  1) Disconnect from the network (press D)\n" +
			"  2) Start a backup (press B)\n" +
			"  3) Run an antivirus scan (press S)\n\n" +
			"If you finish all three steps before the timer runs out,\n" +
			"your computer is saved. If the timer hits zero first,\n" +
			"the ransomware wins." 
			)

	if intro_start_btn:
		intro_start_btn.text = "Got it – Start"
		intro_start_btn.pressed.connect(_on_intro_start_pressed)



func _show_intro(show: bool) -> void:
	if intro_popup:
		intro_popup.visible = show

	# Disable main controls while intro is visible
	var enabled := not show
	next_btn.disabled = not enabled
	back_btn.disabled = not enabled
	active = false  # no gameplay while popup up


func _on_intro_start_pressed() -> void:
	_show_intro(false)
	_start_round()


func _verify_nodes() -> bool:
	var req := {
		"Header": header,
		"Prompt": prompt,
		"TimeBar": bar,
		"Feedback": feedback,
		"NextBtn": next_btn,
		"BackBtn": back_btn,
		"IntroPopup": intro_popup,
		"IntroPopup/Title": intro_title,
		"IntroPopup/Body": intro_body,
		"IntroPopup/StartBtn": intro_start_btn
	}
	for k in req.keys():
		if req[k] == null:
			_fail("Missing node: " + k + " (check names/paths in Ransom.tscn)")
			return false
	return true


func _start_round() -> void:
	_show("[Ransom] Starting round")
	active = true
	time_left = TOTAL_TIME
	step_index = 0
	feedback.text = ""
	next_btn.disabled = true

	# Configure progress bar
	bar.min_value = 0.0
	bar.max_value = TOTAL_TIME
	bar.value = TOTAL_TIME

	_update_prompt()


func _update_prompt() -> void:
	var remaining: Array[String] = []
	for i in range(step_index, steps.size()):
		remaining.append(steps[i])

	prompt.text = "Ransomware is running!\n\n"
	prompt.text += "Complete these steps before the timer hits zero:\n"
	prompt.text += "\n".join(remaining)


func _process(delta: float) -> void:
	if not active:
		return

	time_left -= delta
	bar.value = max(time_left, 0.0)

	if time_left <= 0.0:
		_on_time_up()


func _unhandled_input(event: InputEvent) -> void:
	if not active:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		var key := OS.get_keycode_string(event.keycode).to_upper()
		_show("[Ransom] Key pressed: " + key)

		if step_index < step_keys.size() and key == step_keys[step_index]:
			_on_correct_step()
		else:
			# Optional: give a small hint on wrong key
			feedback.text = "That’s not the next step. Follow the order shown."


func _on_correct_step() -> void:
	step_index += 1

	if step_index >= steps.size():
		_on_all_steps_done()
	else:
		feedback.text = "Good! Keep going."
		_update_prompt()


func _on_all_steps_done() -> void:
	active = false
	feedback.text = ("You did it! You disconnected, backed up, and scanned\n" +
	                "before the ransomware could lock your files."
					)
	next_btn.disabled = false

	if typeof(Game) != TYPE_NIL:
		Game.unlock_achievement("ransomware_hero")
		Game.last_result = "win"


func _on_time_up() -> void:
	active = false
	feedback.text = ("Too late! The ransomware locked your files.\n" +
	                "Next time: Disconnect (D), Backup (B), Scan (S) quickly."
					)
	next_btn.disabled = false

	if typeof(Game) != TYPE_NIL:
		Game.last_result = "lose"


func _on_next_pressed() -> void:
	_start_round()


# ---- helpers ----
func _show(msg: String) -> void:
	print(msg)
	if debug_label:
		debug_label.text = msg


func _fail(msg: String) -> void:
	push_error(msg)
	_show(msg)


func _dump_tree_paths() -> void:
	print("[Ransom] Scene tree:")
	_dump(self, "")


func _dump(n: Node, indent: String) -> void:
	print(indent, n.get_path())
	for c in n.get_children():
		_dump(c, indent + "  ")
