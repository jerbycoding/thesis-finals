extends Control

@onready var container = %VBoxContainer
@onready var logo_text = %LogoText

var is_transitioning = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	# Initial state
	container.modulate.a = 0
	
	# Sequence using Tweens
	var tween = create_tween()
	
	# 1. Start with a terminal chirp
	tween.tween_callback(func(): 
		if AudioManager: AudioManager.play_terminal_beep(-5.0)
	).set_delay(0.5)
	
	# 2. Fade in the logo
	tween.tween_property(container, "modulate:a", 1.0, 0.8).set_trans(Tween.TRANS_QUAD)
	
	# 3. Hold
	tween.tween_interval(2.0)
	
	# 4. "CRT Power Off" effect
	tween.tween_callback(_on_logo_finished)

func _input(event):
	if is_transitioning: return
	
	if event is InputEventKey or event is InputEventMouseButton:
		if event.pressed:
			_on_logo_finished()

func _on_logo_finished():
	if is_transitioning: return
	is_transitioning = true
	
	# Visual "Power Off" / Glitch
	var tween = create_tween()
	for i in range(3):
		tween.tween_property(container, "modulate:a", 0.2, 0.05)
		tween.tween_property(container, "modulate:a", 1.0, 0.05)
	
	tween.tween_property(container, "scale:y", 0.01, 0.1)
	tween.tween_property(container, "modulate:a", 0.0, 0.1)
	
	await tween.finished
	
	# Hand off to TransitionManager for a professional fade to 3D
	if TransitionManager:
		TransitionManager.change_scene_to("res://scenes/3d/MainMenu3D.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/3d/MainMenu3D.tscn")