extends Node
signal score_changed(new_score:int)
var score:int = 0
var last_result:String = ""  # e.g., "win"/"lose" for a minigame

func add_score(n:int) -> void:
	score += n
	emit_signal("score_changed", score)

func reset() -> void:
	score = 0
	last_result = ""
	emit_signal("score_changed", score)
