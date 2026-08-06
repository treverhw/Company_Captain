extends CanvasLayer

@onready var bar: ProgressBar = $Panel/ProgressBar
@onready var label: Label = $Panel/Label

func begin(text: String) -> void:
	label.text = text
	bar.value = 0
	visible = true

func step(current: int, total: int) -> void:
	bar.max_value = total
	bar.value = current

func finish() -> void:
	visible = false
