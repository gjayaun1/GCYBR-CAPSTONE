# res://scripts/Hub.gd
extends Control

const SCN_PHISHING := "res://scenes/minigames/Phishing.tscn"
const SCN_PASSWORD := "res://scenes/minigames/Password.tscn"
const SCN_RANSOM   := "res://scenes/minigames/Ransom.tscn"
const SCN_MENU     := "res://scenes/MainMenu.tscn"

@onready var phishing_btn: Button = _find_button("PhishingBtn")
@onready var password_btn: Button = _find_button("PasswordBtn")
@onready var ransom_btn:   Button = _find_button("RansomBtn")
@onready var back_btn:     Button = _find_button("BackBtn")
@onready var score_label:  Label  = _find_label("Score")  # reused as achievements label

var debug_label: Label

func _ready() -> void:
	debug_label = Label.new()
	debug_label.text = "[Hub] init"
	debug_label.modulate = Color(0,0,0)
	add_child(debug_label)

	if not _verify([
		["PhishingBtn", phishing_btn],
		["PasswordBtn", password_btn],
		["RansomBtn",   ransom_btn],
		["BackBtn",     back_btn],
		["Score",       score_label],
	]):
		_dump_tree_paths()
		return

	phishing_btn.text = "Phishing"
	password_btn.text = "Password"
	ransom_btn.text   = "Ransomware"
	back_btn.text     = "Back"

	for b in [phishing_btn, password_btn, ransom_btn, back_btn]:
		b.disabled = false
		b.mouse_filter = Control.MOUSE_FILTER_STOP

	phishing_btn.pressed.connect(func(): _go(SCN_PHISHING, "Phishing"))
	password_btn.pressed.connect(func(): _go(SCN_PASSWORD, "Password"))
	ransom_btn.pressed.connect(func(): _go(SCN_RANSOM,   "Ransomware"))
	back_btn.pressed.connect(func(): _go(SCN_MENU, "Back to Menu"))

	# --- ACHIEVEMENTS UI ---
	# Game is an autoload, so we can just use it directly.
	_update_achievements_label()
	Game.achievement_unlocked.connect(_on_achievement_unlocked)


func _update_achievements_label() -> void:
	# Build a small summary string based on Game.achievements flags
	var parts: Array[String] = []

	var pw: bool = Game.achievements.get("password_master", false)
	var ph: bool = Game.achievements.get("phishing_pro", false)
	var ra: bool = Game.achievements.get("ransomware_hero", false)

	parts.append("Password: " + ("✔" if pw else "—"))
	parts.append("Phishing: " + ("✔" if ph else "—"))
	parts.append("Ransomware: " + ("✔" if ra else "—"))

	score_label.text = "Achievements: " + " | ".join(parts)


func _on_achievement_unlocked(key: String) -> void:
	_show("[Hub] Achievement unlocked: " + key)
	_update_achievements_label()
	# If you ever add a popup UI, call it here too.


func _go(path:String, label:String) -> void:
	_show("[Hub] Click: " + label)
	if not ResourceLoader.exists(path):
		_show("[Hub] Missing scene file: " + path)
		return
	var err := get_tree().change_scene_to_file(path)
	if err != OK:
		_show("[Hub] change_scene_to_file FAILED (%s) for %s" % [err, path])

# ---------- helpers ----------
func _find_button(name:String) -> Button:
	var n := find_child(name, true, false) # recursive, exact name
	return n if n is Button else null

func _find_label(name:String) -> Label:
	var n := find_child(name, true, false)
	return n if n is Label else null

func _verify(pairs:Array) -> bool:
	for p in pairs:
		var tag:String = p[0]
		var node:Node = p[1]
		if node == null:
			_show("[Hub] Missing node: " + tag + " (check its Name in the scene)")
			return false
	return true

func _show(msg:String) -> void:
	print(msg)
	if debug_label:
		debug_label.text = msg

func _dump_tree_paths() -> void:
	print("[Hub] Scene tree:")
	_dump(self, "")

func _dump(n:Node, indent:String) -> void:
	print(indent, n.get_path())
	for c in n.get_children():
		_dump(c, indent + "  ")
