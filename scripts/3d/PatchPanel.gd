extends Node3D

@export var panel_id: String = "panel_alpha"
@export var is_malicious: bool = false

@onready var restricted_socket = $Socket_Restricted
@onready var monitor_socket = $Socket_Monitor
@onready var label_3d = $Label3D

var minigame_scene = preload("res://scenes/ui/CalibrationMinigame.tscn")

func _ready():
	# If this panel is the "infected" one, it starts with a cable in the wrong spot
	if is_malicious:
		_spawn_rogue_cable()
	
	monitor_socket.object_inserted.connect(_on_cable_secured)
	restricted_socket.accepted_hardware_type = "none" # Can't plug back into restricted

func _spawn_rogue_cable():
	var cable_scene = load("res://scenes/3d/props/graybox/Prop_PatchCable.tscn")
	var cable = cable_scene.instantiate()
	get_tree().root.call_deferred("add_child", cable)
	
	# Wait a frame then snap to restricted socket
	await get_tree().process_frame
	restricted_socket.on_object_inserted(cable)
	# Force the socket to NOT be occupied so we can take it OUT
	restricted_socket.is_occupied = false 
	
	# Mark this node for the scanner
	add_to_group("audit_nodes")
	set_meta("is_infected", true)

func _on_cable_secured(_obj):
	print("Patch Panel: Cable secured in Monitor Port. Starting Calibration.")
	
	if NotificationManager:
		NotificationManager.show_notification("CONNECTION DETECTED: Calibrating...", "info")
	
	# Trigger Minigame
	var minigame = minigame_scene.instantiate()
	get_tree().root.add_child(minigame)
	minigame.start_game(1.3)
	minigame.minigame_success.connect(_on_calibration_complete)

func _on_calibration_complete():
	if NotificationManager:
		NotificationManager.show_notification("PANEL SECURED: Rogue path neutralized.", "success")
	
	EventBus.consequence_triggered.emit("task_update", {"id": "remove_implant"})
	EventBus.consequence_triggered.emit("audit_complete", {"id": panel_id})
	
	# Visual feedback
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color.GREEN
	mat.emission_enabled = true
	mat.emission = Color.GREEN
	$PanelMesh.material_override = mat
