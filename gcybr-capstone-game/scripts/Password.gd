# res://scripts/Password.gd
extends Control

const SCN_HUB := "res://scenes/Hub.tscn"

@onready var header:    Label    = $MainPanel/Margin/VBox/Header
@onready var rule1:     Label    = $MainPanel/Margin/VBox/ContentRow/RulesBox/Rule1
@onready var rule2:     Label    = $MainPanel/Margin/VBox/ContentRow/RulesBox/Rule2
@onready var rule3:     Label    = $MainPanel/Margin/VBox/ContentRow/RulesBox/Rule3
@onready var field:     LineEdit = $MainPanel/Margin/VBox/ContentRow/InputBox/Field
@onready var check_btn: Button   = $MainPanel/Margin/VBox/ContentRow/InputBox/CheckBtn
@onready var feedback:  Label    = $MainPanel/Margin/VBox/ContentRow/InputBox/Feedback
@onready var back_btn:  Button   = $BackBtn
@onready var task_label: Label   = $MainPanel/Margin/VBox/ContentRow/InputBox/TaskLabel

var debug_label: Label

const SYMBOLS := "!@#$%^&*()-_=+[]{};:'\",.<>/?\\|`~"

enum Phase { STRONG, WEAK, DONE }
var phase: int = Phase.STRONG
var strong_done := false
var weak_done := false


func _ready() -> void:
	debug_label = Label.new()
	debug_label.modulate = Color(0, 0, 0)
	add_child(debug_label)
	_show("[Password] init")

	if not _verify_nodes():
		_dump_tree_paths()
		return

	# Static UI text
	header.text = "Password Builder"
	rule1.text = "Rule 1: At least 8 characters."
	rule2.text = "Rule 2: Include at least one number (0–9)."
	rule3.text = "Rule 3: Include at least one symbol (" + SYMBOLS + ")"

	field.placeholder_text = "Type your password here…"

	check_btn.text = "Check password"
	back_btn.text  = "Back"

	check_btn.disabled = false
	check_btn.mouse_filter = Control.MOUSE_FILTER_STOP

	field.text_submitted.connect(func(_t): _check())
	check_btn.pressed.connect(_check)
	back_btn.pressed.connect(_on_back_pressed)

	_set_phase(Phase.STRONG)


func _set_phase(p: int) -> void:
	phase = p

	match phase:
		Phase.STRONG:
			header.text = "Password Builder – Strong Password"
			feedback.modulate = Color(1, 1, 1)
			feedback.text = "Task 1:\nCreate a STRONG password that follows all the rules above,\nthen press Check."
			field.clear()

		Phase.WEAK:
			header.text = "Password Builder – Weak Password"
			feedback.modulate = Color(1, 1, 1)
			feedback.text = "Task 2:\nNow create a WEAK password that breaks at least one rule.\n" + \
			                "It should be missing length, a number, or a symbol."
			field.clear()

		Phase.DONE:
			header.text = "Password Builder – Complete"
			feedback.modulate = Color(0.7, 1.0, 0.7)
			feedback.text = "You finished this activity. You can go back to the hub."
			check_btn.disabled = true


func _on_back_pressed() -> void:
	Game.last_result = "quit"
	Transition.change_scene(SCN_HUB)


func _verify_nodes() -> bool:
	var req := {
		"MainPanel/Margin/VBox/Header": header,
		"RulesBox/Rule1": rule1,
		"RulesBox/Rule2": rule2,
		"RulesBox/Rule3": rule3,
		"InputBox/Field": field,
		"InputBox/CheckBtn": check_btn,
		"InputBox/Feedback": feedback,
		"BackBtn": back_btn
	}

	for k in req.keys():
		if req[k] == null:
			_fail("Missing node: " + k + " (check names/paths in Password.tscn)")
			return false

	return true



func _check() -> void:
	var p := field.text

	var ok_len := p.length() >= 8
	var ok_digit := false
	var ok_symbol := false

	for i in range(p.length()):
		var ch := p.substr(i, 1)
		if ch >= "0" and ch <= "9":
			ok_digit = true
		elif ch in SYMBOLS:
			ok_symbol = true

	var is_strong := ok_len and ok_digit and ok_symbol

	var misses: Array[String] = []

	if not ok_len:
		misses.append("at least 8 characters")

	if not ok_digit:
		misses.append("a number (0–9)")

	if not ok_symbol:
		misses.append("a symbol (" + SYMBOLS + ")")

	match phase:

		Phase.STRONG:
			if is_strong:
				strong_done = true
				feedback.modulate = Color(0.7, 1.0, 0.7)
				feedback.text = "Nice! That is a strong password.\n\n" + \
				                "Next: create a WEAK password that breaks at least one rule."
				Game.last_result = "strong_ok"
				_set_phase(Phase.WEAK)
			else:
				feedback.modulate = Color(1.0, 0.7, 0.7)
				feedback.text = "Not strong enough yet.\nMissing: " + ", ".join(misses) + "."
				Game.last_result = "lose"

		Phase.WEAK:
			if is_strong:
				feedback.modulate = Color(1.0, 0.85, 0.6)
				feedback.text = "This is still a strong password.\n" + \
				                "For this task, make it WEAK by breaking at least one rule."
				Game.last_result = "lose"
			else:
				weak_done = true
				_finish_success(misses)

		Phase.DONE:
			return


func _finish_success(misses: Array[String]) -> void:
	_set_phase(Phase.DONE)

	var reason := ", ".join(misses)

	feedback.modulate = Color(0.7, 1.0, 0.7)
	feedback.text = "Correct!\nThis is a WEAK password because it is missing: " + reason + ".\n\n" + \
	                "You completed both tasks."

	Game.unlock_achievement("password_master")
	Game.last_result = "win"


# --------------------------------------------------------------------
# Helpers
# --------------------------------------------------------------------
func _show(msg: String) -> void:
	print(msg)
	if debug_label:
		debug_label.text = msg


func _fail(msg: String) -> void:
	push_error(msg)
	_show(msg)


func _dump_tree_paths() -> void:
	print("[Password] Scene tree:")
	_dump(self, "")


func _dump(n: Node, indent: String) -> void:
	print(indent, n.get_path())
	for c in n.get_children():
		_dump(c, indent + "  ")
