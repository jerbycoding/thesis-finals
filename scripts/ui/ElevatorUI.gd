# ElevatorUI.gd
extends Control

signal floor_selected(floor_id: int)
signal closed()

@onready var button_container: VBoxContainer = %ButtonContainer
@onready var status_label: Label = %StatusLabel

# Floor Data based on FULLGAME.md
const FLOORS = {
	2: {"name": "EXECUTIVE SUITE", "desc": "Narrative / CISO Office", "scene": "res://scenes/3d/ExecutiveSuite.tscn"},
	1: {"name": "MAIN SOC OFFICE", "desc": "Standard Operations", "scene": "res://scenes/SOC_Office.tscn"},
	-1: {"name": "SERVER VAULT", "desc": "Hardware Maintenance", "scene": "res://scenes/3d/ServerVault.tscn"},
	-2: {"name": "NETWORK HUB", "desc": "Infrastructure Audit", "scene": "res://scenes/3d/NetworkHub.tscn"}
}

func _ready():
	hide()
	_setup_buttons()

func show_elevator(current_floor: int):
	show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Disable player movement
	if GameState:
		GameState.set_mode(GameState.GameMode.MODE_2D)
		
	status_label.text = "CURRENT FLOOR: " + str(current_floor)
	
	# Update button availability (e.g., lock weekend floors during weekdays)
	# For now, all are open for testing.
	
	# Highlight current floor
	for btn in button_container.get_children():
		if not btn.has_meta("floor_id"):
			continue
			
		if btn.get_meta("floor_id") == current_floor:
			btn.disabled = true
			btn.text = "[ " + btn.get_meta("floor_name") + " ]"
		else:
			btn.disabled = false
			btn.text = btn.get_meta("floor_name")

func _setup_buttons():
	for f_id in FLOORS:
		var info = FLOORS[f_id]
		var btn = Button.new()
		btn.text = info.name
		btn.custom_minimum_size.y = 50
		btn.set_meta("floor_id", f_id)
		btn.set_meta("floor_name", info.name)
		btn.pressed.connect(_on_floor_pressed.bind(f_id))
		button_container.add_child(btn)
		
		# Move Floor 2 to top (reverse order of dictionary if needed)
	
	var close_btn = Button.new()
	close_btn.text = "CANCEL"
	close_btn.flat = true
	close_btn.pressed.connect(_on_close_pressed)
	button_container.add_child(close_btn)

func _on_floor_pressed(f_id: int):
	if AudioManager: AudioManager.play_ui_click()
	floor_selected.emit(f_id)
	_on_close_pressed()

func _on_close_pressed():
	hide()
	
	# Restore player movement
	if GameState:
		GameState.set_mode(GameState.GameMode.MODE_3D)
		
	if GameState.is_in_3d_mode():
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	closed.emit()
