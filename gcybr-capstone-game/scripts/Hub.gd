# res://scripts/Hub.gd
extends Control

@onready var phishing_btn: Button = (
	get_node_or_null("/PhishingBtn") if has_node("/PhishingBtn")
	else get_node_or_null("/PhishingBtn")
)
@onready var password_btn: Button = (
	get_node_or_null("/PasswordBtn") if has_node("/PasswordBtn")
	else get_node_or_null("PasswordBtn")
)
@onready var ransom_btn: Button = (
	get_node_or_null("/RansomBtn") if has_node("/RansomBtn")
	else get_node_or_null("/RansomBtn")
)
@onready var back_btn: Button = get_node_or_null("BackBtn")
@onready var score_label: Label = get_node_or_null("Score")

var debug_label: Label

func _ready() -> void:
	debug_label = Label.new()
	add_child(debug_label)
	debug_label.text = "[Hub] init"

	var map := {
		"PhishingBtn": phishing_btn,
		"PasswordBtn": password_btn,
		"RansomBtn":   ransom_btn,
		"BackBtn":     back_btn,
		"Score":       score_label,
	}
	for k in map.keys():
		if map[k] == null:
			_fail("Missing node: " + k + ". Check names/paths in Hub.tscn.")
			_dump_tree_paths()
			return

	phishing_btn.text = "Phishing"
	password_btn.text = "Password"
	ransom_btn.text   = "Ransomware"
	back_btn.text     = "Back"

	phishing_btn.pressed.connect(_go_phishing)
	password_btn.pressed.connect(_go_password)
	ransom_btn.pressed.connect(_go_ransom)
	back_btn.pressed.connect(_back)

	if Engine.has_singleton("Game"):
		Game.score_changed.connect(_update_score)
		_update_score(Game.score)
	else:
		_update_score(0)

func _update_score(value:int) -> void:
	score_label.text = "Score: %d" % value

func _go_phishing() -> void:
	get_tree().change_scene_to_file("res://scenes/minigames/Phishing.tscn")

func _go_password() -> void:
	get_tree().change_scene_to_file("res://scenes/minigames/Password.tscn")

func _go_ransom() -> void:
	get_tree().change_scene_to_file("res://scenes/minigames/Ransom.tscn")

func _back() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _fail(msg:String) -> void:
	push_error(msg)
	if debug_label:
		debug_label.text = "[Hub] " + msg

func _dump_tree_paths() -> void:
	print("[Hub] Scene tree:")
	_dump(self, "")

func _dump(n:Node, indent:String) -> void:
	print(indent, n.get_path())
	for c in n.get_children():
		_dump(c, indent + "  ")
