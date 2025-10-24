# res://scripts/Phishing.gd
extends Control

const SCN_HUB := "res://scenes/Hub.tscn"

# Required children (we'll verify before use)
@onready var header:   Label          = $Header
@onready var email_box: Panel          = $EmailBox
@onready var body:     RichTextLabel  = $EmailBox/Body
@onready var phish_btn: Button        = $Buttons/PhishBtn
@onready var legit_btn: Button        = $Buttons/LegitBtn
@onready var feedback: Label          = $Feedback
@onready var next_btn: Button         = $NextBtn
@onready var back_btn: Button         = $BackBtn

var debug_label: Label

var items:Array = [
	{ "text": "Your package is on hold. Pay a $1 fee to release it.", "is_phish": true },
	{ "text": "IT notice: Maintenance tonight 11pm–1am. No action needed.", "is_phish": false },
	{ "text": "Urgent: Verify your account or it will be deleted.", "is_phish": true },
	{ "text": "Team: Slides from today’s meeting attached.", "is_phish": false },
	{ "text": "Security alert: Unusual sign-in from a new device.", "is_phish": true },
]
var index:int = 0
var answered:bool = false

func _ready() -> void:
	# On-screen debug so we don't rely on Output
	debug_label = Label.new()
	debug_label.modulate = Color(0,0,0)
	add_child(debug_label)
	_show("[Phishing] init")

	if not _verify_nodes():
		_dump_tree_paths()
		return

	header.text = "Phishing Classifier"
	phish_btn.text = "Phish"
	legit_btn.text = "Legit"
	next_btn.text = "Next"
	back_btn.text = "Back"

	phish_btn.disabled = false
	legit_btn.disabled = false
	phish_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	legit_btn.mouse_filter = Control.MOUSE_FILTER_STOP

	phish_btn.pressed.connect(func(): _answer(true))
	legit_btn.pressed.connect(func(): _answer(false))
	next_btn.pressed.connect(_next)
	back_btn.pressed.connect(func(): get_tree().change_scene_to_file(SCN_HUB))

	_show_current()

func _verify_nodes() -> bool:
	var req = {
		"Header": header,
		"EmailBox": email_box,
		"EmailBox/Body": body,
		"Buttons/PhishBtn": phish_btn,
		"Buttons/LegitBtn": legit_btn,
		"Feedback": feedback,
		"NextBtn": next_btn,
		"BackBtn": back_btn
	}
	for k in req.keys():
		if req[k] == null:
			_fail("Missing node: " + k + " (check names/paths in Phishing.tscn)")
			return false
	return true

func _show_current() -> void:
	var item = items[index]
	body.text = item["text"]
	feedback.text = ""
	answered = false
	next_btn.disabled = true

func _answer(guess_is_phish:bool) -> void:
	if answered: return
	answered = true
	var item = items[index]
	var correct:bool = (guess_is_phish == item["is_phish"])
	if correct:
		if Engine.has_singleton("Game"):
			Game.add_score(1)
		feedback.text = "Correct!"
	else:
		feedback.text = "Oops!"
	next_btn.disabled = false

func _next() -> void:
	index += 1
	if index >= items.size():
		get_tree().change_scene_to_file(SCN_HUB)
	else:
		_show_current()

# ---- helpers
func _show(msg:String) -> void:
	print(msg)
	if debug_label: debug_label.text = msg

func _fail(msg:String) -> void:
	push_error(msg)
	_show(msg)

func _dump_tree_paths() -> void:
	print("[Phishing] Scene tree:")
	_dump(self, "")

func _dump(n:Node, indent:String) -> void:
	print(indent, n.get_path())
	for c in n.get_children():
		_dump(c, indent + "  ")
