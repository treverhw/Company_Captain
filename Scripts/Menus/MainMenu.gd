extends Node

func _on_play_pressed() -> void:
	get_parent().add_child(load("res://Scenes/Planet.tscn").instantiate())
	get_parent().remove_child(self)
	queue_free()

func _on_options_pressed() -> void:
	pass # Replace with function body.

func _on_exit_pressed() -> void:
	get_tree().quit()
