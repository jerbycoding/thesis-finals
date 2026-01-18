extends Node

enum GameMode { MODE_3D, MODE_2D, MODE_DIALOGUE }

var current_mode = GameMode.MODE_3D
var current_computer = null
var desktop_instance = null
var is_paused: bool = false
var pause_menu_instance: Control = null

func _ready():
	# Instantiate pause menu but keep it hidden
	var pause_scene = load("res://scenes/ui/PauseMenu.tscn")
	if pause_scene:
		pause_menu_instance = pause_scene.instantiate()
		get_tree().root.call_deferred("add_child", pause_menu_instance)

func _input(event):
	if event.is_action_pressed("ui_cancel"): # Usually ESC
		if get_tree().current_scene.name == "TitleScreen":
			return
			
		set_paused(!is_paused)

func set_paused(paused: bool):
	is_paused = paused
	get_tree().paused = paused
	
	if pause_menu_instance:
		if paused:
			pause_menu_instance.show_menu()
		else:
			pause_menu_instance.hide_menu()
	
	print("GameState: Session ", "PAUSED" if paused else "RESUMED")

func set_mode(mode: GameMode):
	if mode != current_mode:
		current_mode = mode
		EventBus.game_mode_changed.emit(mode)

func set_game_mode(mode: GameMode):
	set_mode(mode)

func is_in_3d_mode():
	return current_mode == GameMode.MODE_3D

func is_in_2d_mode():
	return current_mode == GameMode.MODE_2D
