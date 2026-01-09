extends Node

enum GameMode { MODE_3D, MODE_2D, MODE_DIALOGUE }

signal game_mode_changed(mode)

var current_mode = GameMode.MODE_3D
var current_computer = null
var desktop_instance = null

func set_mode(mode: GameMode):
	if mode != current_mode:
		current_mode = mode
		game_mode_changed.emit(mode)

func set_game_mode(mode: GameMode):
	set_mode(mode)

func is_in_3d_mode():
	return current_mode == GameMode.MODE_3D

func is_in_2d_mode():
	return current_mode == GameMode.MODE_2D
