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

@onready var intro_popup:     Control = $IntroPopup
@onready var intro_title:     Label   = $IntroPopup/VBox/Title
@onready var intro_body:      Label   = $IntroPopup/VBox/Body
@onready var intro_start_btn: Button  = $IntroPopup/VBox/StartBtn


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

	header.text = "Password Builder"
	rule1.text = "Rule 1: At least 8 characters."
	rule2.text = "Rule 2: Include at least one number (0–9)."
	rule3.text = "Rule 3: Include at least one symbol (" + SYMBOLS + ")"

	field.placeholder_text = "Type your password here…"

	check_btn.text = "Check"
	back_btn.text  = "Back"

	check_btn.disabled = false
	check_btn.mouse_filter = Control.MOUSE_FILTER_STOP

	field.text_submitted.connect(func(_t): _check())
	check_btn.pressed.connect(_check)
	back_btn.pressed.connect(_on_back_pressed)

	_setup_intro_popup()
	_show_intro(true)


func _setup_intro_popup() -> void:
	if intro_title:
		intro_title.text = "Password Game – Overview"

	if intro_body:
		intro_body.text = (
			"Goal: Learn what makes a strong vs weak password.\n\n" +
			"In this activity you'll do two tasks:\n" +
			" • First, create a STRONG password that follows all the rules.\n" +
			" • Then, create a WEAK password that breaks at least one rule.\n\n" +
			"For a strong password, focus on:\n" +
			" • Length: at least 8 characters\n" +
			" • Variety: include at least one number and one symbol\n" +
			" • Avoid obvious stuff: no names, birthdays, or simple words like \"password\".\n"
		)

	if intro_start_btn:
		intro_start_btn.text = "Got it – Start"
		intro_start_btn.pressed.connect(_on_intro_start_pressed)


func _show_intro(show: bool) -> void:
	if intro_popup:
		intro_popup.visible = show

	var enabled := not show
	field.editable = enabled
	check_btn.disabled = not enabled
	back_btn.disabled  = not enabled


func _on_intro_start_pressed() -> void:
	_show_intro(false)
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
	if typeof(Game) != TYPE_NIL:
		Game.last_result = "quit"
	Transition.change_scene(SCN_HUB)


func _verify_nodes() -> bool:
	var req := {
		"Header": header,
		"Rule1": rule1,
		"Rule2": rule2,
		"Rule3": rule3,
		"Field": field,
		"CheckBtn": check_btn,
		"Feedback": feedback,
		"BackBtn": back_btn,
		"IntroPopup": intro_popup,
		"IntroPopup/Title": intro_title,
		"IntroPopup/Body": intro_body,
		"IntroPopup/StartBtn": intro_start_btn,
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
				if typeof(Game) != TYPE_NIL:
					Game.last_result = "strong_ok"
				_set_phase(Phase.WEAK)
			else:
				feedback.modulate = Color(1.0, 0.7, 0.7)
				feedback.text = "Not strong enough yet.\nMissing: " + ", ".join(misses) + "."
				if typeof(Game) != TYPE_NIL:
					Game.last_result = "lose"

		Phase.WEAK:
			if is_strong:
				feedback.modulate = Color(1.0, 0.85, 0.6)
				feedback.text = "This is still a strong password.\n" + \
				                "For this task, make it WEAK by breaking at least one rule."
				if typeof(Game) != TYPE_NIL:
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

	if typeof(Game) != TYPE_NIL:
		Game.unlock_achievement("password_master")
		Game.last_result = "win"


# ---- helpers ----
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
