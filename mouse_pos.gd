extends Label

func _process(_delta: float) -> void:
	text = str(get_global_mouse_position())
