# ElevatorUI.gd
extends Control

signal floor_selected(floor_id: int)
signal closed()

@onready var button_grid: GridContainer = %ButtonGrid
@onready var status_label: Label = %StatusLabel
@onready var direction_arrow: Label = %DirectionArrow
@onready var abort_btn: Button = %AbortBtn

# Floor Data based on FULLGAME.md
const FLOORS = {
	1: {"label": "1", "name": "MAIN SOC OFFICE", "scene": "res://scenes/SOC_Office.tscn"},
	-1: {"label": "B1", "name": "SERVER VAULT", "scene": "res://scenes/3d/ServerVault.tscn"},
	-2: {"label": "B2", "name": "NETWORK HUB", "scene": "res://scenes/3d/NetworkHub.tscn"}
}

func _ready():
	hide()
	_setup_buttons()
	abort_btn.pressed.connect(_on_close_pressed)

func show_elevator(current_floor: int):
	show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if GameState:
		GameState.set_mode(GameState.GameMode.MODE_2D)
		
	_update_display(current_floor)
	
	# Highlight current floor button
	for btn in button_grid.get_children():
		if not btn.has_meta("floor_id"): continue
		
		var is_here = btn.get_meta("floor_id") == current_floor
		_style_button(btn, is_here)

func _update_display(floor_id: int):
	var label = "01"
	if FLOORS.has(floor_id):
		label = FLOORS[floor_id].label
	
	status_label.text = label
	direction_arrow.text = "●" # Stable

func _setup_buttons():
	# Display in logical order: 1, B1, B2
	var order = [1, -1, -2]
	for f_id in order:
		var info = FLOORS[f_id]
		var btn = Button.new()
		btn.text = info.label
		btn.custom_minimum_size = Vector2(65, 65)
		btn.tooltip_text = info.name
		btn.set_meta("floor_id", f_id)
		btn.set_meta("floor_name", info.name)
		btn.pressed.connect(_on_floor_pressed.bind(f_id))
		button_grid.add_child(btn)

func _style_button(btn: Button, active: bool):
	var style = StyleBoxFlat.new()
	style.set_corner_radius_all(40) # Circular
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	
	if active:
		style.bg_color = Color(0.2, 0.8, 0.2, 1) # Glowing Green
		style.border_color = Color(1, 1, 1, 0.5)
		btn.add_theme_color_override("font_color", Color.WHITE)
	else:
		style.bg_color = Color(0.15, 0.15, 0.15, 1) # Industrial Dark
		style.border_color = Color(0.3, 0.3, 0.3, 1)
		btn.add_theme_color_override("font_color", Color.WHITE)
		
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", style)
	btn.add_theme_stylebox_override("pressed", style)
	btn.add_theme_stylebox_override("disabled", style)

func _on_floor_pressed(f_id: int):
	if AudioManager: AudioManager.play_ui_click()
	floor_selected.emit(f_id)
	_on_close_pressed()

func _on_close_pressed():
	hide()
	if GameState:
		GameState.set_mode(GameState.GameMode.MODE_3D)
	if GameState.is_in_3d_mode():
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	closed.emit()
