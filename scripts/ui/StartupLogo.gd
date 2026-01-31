extends Control

@onready var container = %VBoxContainer

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	# Initial state
	container.modulate.a = 0
	
	# Sequence using Tweens
	var tween = create_tween()
	tween.tween_property(container, "modulate:a", 1.0, 1.0).set_delay(0.5)
	tween.tween_interval(1.5)
	tween.tween_property(container, "modulate:a", 0.0, 0.5)
	
	await tween.finished
	get_tree().change_scene_to_file("res://scenes/ui/TitleScreen.tscn")

func _input(event):
	if event is InputEventKey or event is InputEventMouseButton:
		# Skip intro on any key/mouse click
		get_tree().change_scene_to_file("res://scenes/ui/TitleScreen.tscn")
