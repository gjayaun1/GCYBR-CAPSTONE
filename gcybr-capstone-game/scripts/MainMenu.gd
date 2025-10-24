# res://scripts/MainMenu.gd
extends Control

const SCN_HUB := "res://scenes/Hub.tscn"  # ← COPY PATH EXACTLY from FileSystem (right-click → Copy Path)

@onready var start_btn: Button = $StartBtn
@onready var quit_btn: Button  = $QuitBtn
var debug_label: Label



func _ready() -> void:
	debug_label = Label.new()
	debug_label.text = "[MainMenu] ready"
	add_child(debug_label)

	if start_btn:
		start_btn.pressed.connect(_on_start_pressed)
	else:
		_show("StartBtn not found at $VBox/StartBtn (check node path)")

	if quit_btn:
		quit_btn.pressed.connect(_on_quit_pressed)
	else:
		_show("QuitBtn not found at $VBox/QuitBtn (check node path)")

func _on_start_pressed() -> void:
	_show("Start pressed → " + SCN_HUB)
	var err := get_tree().change_scene_to_file(SCN_HUB)
	if err != OK:
		_show("change_scene_to_file FAILED (" + str(err) + "). Check scene path & that Hub.tscn exists.")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _show(msg: String) -> void:
	print(msg)
	if debug_label:
		debug_label.text = msg
