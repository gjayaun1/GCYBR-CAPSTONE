# res://scripts/Transition.gd
extends Control

@onready var fade_rect: ColorRect = $FadeRect

var duration: float = 0.4

func _ready() -> void:
	# Draw above everything
	z_index = 1024
	top_level = true
	call_deferred("_move_to_front")

	# Cover whole screen
	set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)

	# Don't block mouse by default
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Start fully transparent
	fade_rect.visible = true
	fade_rect.modulate.a = 0.0
	# _fade_in()  # optional at startup

func _move_to_front() -> void:
	var p := get_parent()
	if p:
		p.move_child(self, p.get_child_count() - 1)

func change_scene(path: String) -> void:
	# While transitioning, block clicks so players don't double-press
	mouse_filter = Control.MOUSE_FILTER_STOP
	fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP

	var t := create_tween()
	t.tween_property(fade_rect, "modulate:a", 1.0, duration)
	t.tween_callback(Callable(self, "_after_fade_out").bind(path))

func _after_fade_out(path: String) -> void:
	get_tree().change_scene_to_file(path)
	_fade_in()

func _fade_in() -> void:
	var t := create_tween()
	t.tween_property(fade_rect, "modulate:a", 0.0, duration)
	t.tween_callback(Callable(self, "_end_transition"))

func _end_transition() -> void:
	# Let clicks pass through again
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
