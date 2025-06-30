extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_play_pressed() -> void:
	get_parent().add_child(load("res://Scenes/Combat.tscn").instantiate())
	#Call Play
	queue_free()

func _on_options_pressed() -> void:
	pass # Replace with function body.

func _on_exit_pressed() -> void:
	get_tree().quit()
