# ExfiltrationStream.gd
extends HBoxContainer

@onready var label = $Label
@onready var progress_bar = $ProgressBar

func set_label(text: String):
	label.text = text

func set_progress(value: float):
	progress_bar.value = value

func set_complete():
	progress_bar.value = 100
	label.add_theme_color_override("font_color", Color(0, 1, 0, 1))
