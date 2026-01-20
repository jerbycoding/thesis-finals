extends Control

signal diagnostic_action(action: String) # "verify" or "repair"

@onready var temp_label = %TempLabel
@onready var loss_label = %LossLabel
@onready var volt_label = %VoltLabel
@onready var status_label = %StatusLabel

var data: Dictionary = {}

func _ready():
	visible = false

func show_diagnostics(diagnostics: Dictionary):
	data = diagnostics
	visible = true
	
	# Temperature
	temp_label.text = "CORE TEMP: %.1f°C" % data.temp
	temp_label.add_theme_color_override("font_color", Color.RED if data.temp > 75 else Color.GREEN)
	
	# Packet Loss
	loss_label.text = "PACKET LOSS: %.1f%%" % (data.loss * 100.0)
	loss_label.add_theme_color_override("font_color", Color.RED if data.loss > 0.05 else Color.GREEN)
	
	# Voltage
	volt_label.text = "BUS VOLTAGE: %.1fV" % data.voltage
	volt_label.add_theme_color_override("font_color", Color.RED if data.voltage < 11.0 else Color.GREEN)
	
	status_label.text = "ANALYSIS: " + ("CRITICAL ERRORS DETECTED" if data.is_critical else "SYSTEM NOMINAL")
	status_label.add_theme_color_override("font_color", Color.RED if data.is_critical else Color.CYAN)
	
	if GameState:
		GameState.set_mode(GameState.GameMode.MODE_MINIGAME)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_verify_pressed():
	_close()
	diagnostic_action.emit("verify")

func _on_repair_pressed():
	_close()
	diagnostic_action.emit("repair")

func _close():
	visible = false
	if GameState:
		GameState.set_mode(GameState.GameMode.MODE_3D)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	queue_free()
