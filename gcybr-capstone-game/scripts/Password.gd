# res://scripts/Password.gd
extends Control

const SCN_HUB := "res://scenes/Hub.tscn"

@onready var header:     Label     = $Header
@onready var rule1:      Label     = $RuleList/Rule1
@onready var rule2:      Label     = $RuleList/Rule2
@onready var rule3:      Label     = $RuleList/Rule3
@onready var field:      LineEdit  = $Field
@onready var check_btn:  Button    = $CheckBtn
@onready var feedback:   Label     = $Feedback
@onready var back_btn:   Button    = $BackBtn

var debug_label: Label

func _ready() -> void:
	debug_label = Label.new()
	debug_label.modulate = Color(0,0,0)
	add_child(debug_label)
	_show("[Password] init")

	if not _verify_nodes():
		_dump_tree_paths()
		return

	# UI text
	header.text = "Password Builder"
	rule1.text  = "Rule: at least 8 characters"
	rule2.text  = "Rule: include at least one digit"
	rule3.text  = "Rule: include at least one symbol (!@#$...)"
	check_btn.text = "Check"
	back_btn.text  = "Back"

	# Wiring
	check_btn.disabled = false
	check_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	field.text_submitted.connect(func(_t): _check())
	check_btn.pressed.connect(_check)
	back_btn.pressed.connect(func(): get_tree().change_scene_to_file(SCN_HUB))

func _verify_nodes() -> bool:
	var req := {
		"Header": header,
		"RuleList/Rule1": rule1,
		"RuleList/Rule2": rule2,
		"RuleList/Rule3": rule3,
		"Field": field,
		"CheckBtn": check_btn,
		"Feedback": feedback,
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

	for i in p.length():
		var ch := p[i]               # single-character String
		if ch >= "0" and ch <= "9":
			ok_digit = true
		elif ch in "!@#$%^&*()-_=+[]{};:'\",.<>/?\\|`~":
			ok_symbol = true

	if ok_len and ok_digit and ok_symbol:
		feedback.text = "Great! Password accepted."
		if Engine.has_singleton("Game"):
			Game.add_score(1)
			Game.last_result = "win"
	else:
		var misses := []
		if not ok_len:   misses.append("≥ 8 chars")
		if not ok_digit: misses.append("a digit")
		if not ok_symbol:misses.append("a symbol")
		feedback.text = "Not strong enough — need " + ", ".join(misses) + "."
		if Engine.has_singleton("Game"):
			Game.last_result = "lose"

# ---- helpers
func _show(msg:String) -> void:
	print(msg)
	if debug_label: debug_label.text = msg

func _fail(msg:String) -> void:
	push_error(msg)
	_show(msg)

func _dump_tree_paths() -> void:
	print("[Password] Scene tree:")
	_dump(self, "")

func _dump(n:Node, indent:String) -> void:
	print(indent, n.get_path())
	for c in n.get_children():
		_dump(c, indent + "  ")
