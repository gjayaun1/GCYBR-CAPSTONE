extends Control

class_name EmailItem
var items:Array = [
	{ "text": "Your package is on hold. Click here to pay a $1 fee.", "is_phish": true },
	{ "text": "IT: Scheduled maintenance tonight 11pm–1am.", "is_phish": false },
	{ "text": "Urgent: Verify your account or it will be deleted.", "is_phish": true },
	{ "text": "Team meeting slides attached from today’s standup.", "is_phish": false },
	{ "text": "Security alert: unusual sign-in from new device.", "is_phish": true },
]
var index:int = 0
var answered:bool = false

@onready var body:RichTextLabel = $EmailBox/Body
@onready var feedback:Label = $Feedback
@onready var next_btn:Button = $NextBtn

func _ready() -> void:
	$Header.text = "Phishing Classifier"
	$Buttons/PhishBtn.text = "Phish"
	$Buttons/LegitBtn.text = "Legit"
	$BackBtn.text = "Back"
	next_btn.text = "Next"
	$Buttons/PhishBtn.pressed.connect(func(): _answer(true))
	$Buttons/LegitBtn.pressed.connect(func(): _answer(false))
	$BackBtn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/Hub.tscn"))
	next_btn.pressed.connect(_next)
	_show_current()

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
		Game.add_score(1)
		feedback.text = "Correct!"
		Game.last_result = "win"
	else:
		feedback.text = "Oops!"
		Game.last_result = "lose"
	next_btn.disabled = false

func _next() -> void:
	index += 1
	if index >= items.size():
		get_tree().change_scene_to_file("res://scenes/Hub.tscn")
	else:
		_show_current()
