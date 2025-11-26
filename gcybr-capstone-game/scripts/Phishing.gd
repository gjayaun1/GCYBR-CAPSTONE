# res://scripts/Phishing.gd
extends Control

const SCN_HUB := "res://scenes/Hub.tscn"

@onready var header:      Label         = $Header
@onready var email_box:   Panel         = $EmailBox
@onready var body:        RichTextLabel = $EmailBox/Body
@onready var phish_btn:   Button        = $Buttons/PhishBtn
@onready var legit_btn:   Button        = $Buttons/LegitBtn
@onready var feedback:    Label         = $Feedback
@onready var next_btn:    Button        = $NextBtn
@onready var back_btn:    Button        = $BackBtn

@onready var intro_popup:     Control = $IntroPopup
@onready var intro_title:     Label   = $IntroPopup/VBox/Title
@onready var intro_body:      Label   = $IntroPopup/VBox/Body
@onready var intro_start_btn: Button  = $IntroPopup/VBox/StartBtn
@onready var overlay: Control = $IntroPopupOverlay


var debug_label: Label

var items: Array = [
	{ "text": "Your package is on hold. Pay a $1 fee to release it.", "is_phish": true },
	{ "text": "IT notice: Maintenance tonight 11pm–1am. No action needed.", "is_phish": false },
	{ "text": "Urgent: Verify your account or it will be deleted.", "is_phish": true },
	{ "text": "Team: Slides from today’s meeting attached.", "is_phish": false },
	{ "text": "Security alert: Unusual sign-in from a new device.", "is_phish": true },
]

var index: int = 0
var answered: bool = false


func _ready() -> void:
	debug_label = Label.new()
	debug_label.modulate = Color(0, 0, 0)
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
	back_btn.pressed.connect(func(): Transition.change_scene(SCN_HUB))

	_setup_intro_popup()
	_show_intro(true)


func _setup_intro_popup() -> void:
	if intro_title:
		intro_title.text = "Phishing Game – Overview"

	if intro_body:
		intro_body.text = (
			"Goal: Learn how to spot phishing emails and messages.\n\n" +
			"In this activity you'll see different messages and must decide\n" +
			"whether they are SAFE or PHISHING.\n\n" +
			"Look for red flags like:\n" +
			" • Urgent or threatening language (\"act now or your account is closed\")\n" +
			" • Requests for passwords or personal information\n" +
			" • Suspicious links or email addresses\n" +
			" • Spelling/grammar errors or weird formatting."
		)

	if intro_start_btn:
		intro_start_btn.text = "Got it – Start"
		intro_start_btn.pressed.connect(_on_intro_start_pressed)


func _show_intro(show: bool) -> void:
	if overlay:
		overlay.visible = show

	if intro_popup:
		intro_popup.visible = show

	var enabled := not show
	phish_btn.disabled = not enabled
	legit_btn.disabled = not enabled
	next_btn.disabled = true   # always disabled until answer
	back_btn.disabled = not enabled



func _on_intro_start_pressed() -> void:
	_show_intro(false)
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
		"BackBtn": back_btn,
		"IntroPopup": intro_popup,
		"IntroPopup/Title": intro_title,
		"IntroPopup/Body": intro_body,
		"IntroPopup/StartBtn": intro_start_btn,
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


func _answer(guess_is_phish: bool) -> void:
	if answered:
		return
	answered = true

	var item = items[index]
	var correct: bool = (guess_is_phish == item["is_phish"])

	if correct:
		if typeof(Game) != TYPE_NIL:
			Game.add_score(1)
		feedback.text = "Correct!"
	else:
		feedback.text = "Oops!"

	next_btn.disabled = false


func _next() -> void:
	index += 1
	if index >= items.size():
		if typeof(Game) != TYPE_NIL:
			Game.unlock_achievement("phishing_pro")
			Game.last_result = "win"
		Transition.change_scene(SCN_HUB)
	else:
		_show_current()


# ---- helpers
func _show(msg: String) -> void:
	print(msg)
	if debug_label:
		debug_label.text = msg


func _fail(msg: String) -> void:
	push_error(msg)
	_show(msg)


func _dump_tree_paths() -> void:
	print("[Phishing] Scene tree:")
	_dump(self, "")


func _dump(n: Node, indent: String) -> void:
	print(indent, n.get_path())
	for c in n.get_children():
		_dump(c, indent + "  ")
