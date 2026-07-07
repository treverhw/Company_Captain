extends Node

func _on_play_pressed() -> void:
	get_parent().remove_child(self)
	queue_free()

## TODO: Options menu isn't implemented yet.
func _on_options_pressed() -> void:
	pass

func _on_exit_pressed() -> void:
	get_tree().quit()
