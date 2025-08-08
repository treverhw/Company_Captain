extends Label

func _process(delta: float) -> void:
	text = str(get_global_mouse_position())
