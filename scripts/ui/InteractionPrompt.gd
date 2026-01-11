extends Control

func _ready():
	visible = false  # Ensure hidden on start

func show_prompt():
	visible = true

func hide_prompt():
	visible = false
