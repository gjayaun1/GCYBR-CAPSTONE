extends Control

@onready var field:LineEdit = $Field
@onready var feedback:Label = $Feedback

func _check() -> void:
	var p = field.text
	var ok_len = p.length() >= 8
	var ok_digit = false
	var ok_symbol = false
	for ch in p:
		if ch.is_digit(): ok_digit = true
		elif ch in "!@#$%^&*()-_=+[]{};:'\",.<>/?\\|`~":
			ok_symbol = true
	if ok_len and ok_digit and ok_symbol:
		feedback.text = "Great! Password accepted."
		Game.add_score(1)
		Game.last_result = "win"
	else:
		feedback.text = "Not strong enough—try again."
		Game.last_result = "lose"
