extends Node

func _on_play_pressed() -> void:
	get_parent().add_child(load("res://Scenes/Locational/Planet.tscn").instantiate())
	get_parent().remove_child(self)
	queue_free()

func _on_options_pressed() -> void:
	print(get_node("VBoxContainer/Play").global_position.distance_to(get_node("VBoxContainer/Options").global_position))

	pass # Replace with function body.

func _on_exit_pressed() -> void:
	get_tree().quit()
