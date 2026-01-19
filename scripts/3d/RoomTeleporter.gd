# RoomTeleporter.gd
# Handles teleporting the player between scenes (e.g., SOC Office to Briefing Room)
extends Area3D

@export_file("*.tscn") var target_scene_path: String = ""
@export var narrative_to_trigger: String = ""
@export var interaction_text: String = "Enter Elevator"
@export var is_elevator: bool = false
@export var current_floor: int = 1

var player_in_range: bool = false
var elevator_ui_scene = preload("res://scenes/ui/ElevatorUI.tscn")
var elevator_ui_instance: Control = null

@onready var door_visual = get_node_or_null("ElevatorDoor")

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	if is_elevator:
		elevator_ui_instance = elevator_ui_scene.instantiate()
		get_tree().root.call_deferred("add_child", elevator_ui_instance)
		elevator_ui_instance.floor_selected.connect(_on_floor_selected)

func _on_body_entered(body):
	if body.name == "Player3D":
		player_in_range = true
		if door_visual and door_visual.has_method("open"):
			door_visual.open()
		if body.has_method("set_near_npc"):
			body.set_near_npc(self, true)

func _on_body_exited(body):
	if body.name == "Player3D":
		player_in_range = false
		if door_visual and door_visual.has_method("close"):
			door_visual.close()
		if body.has_method("set_near_npc"):
			body.set_near_npc(self, false)

func _input(event):
	if player_in_range and event.is_action_pressed("interact"):
		if is_elevator and elevator_ui_instance:
			elevator_ui_instance.show_elevator(current_floor)
		elif not target_scene_path.is_empty():
			_teleport_to(target_scene_path, narrative_to_trigger)
		else:
			push_warning("RoomTeleporter: No action defined.")

func _on_floor_selected(floor_id: int):
	var floor_info = elevator_ui_instance.FLOORS.get(floor_id)
	if floor_info:
		var title_card = ""
		match floor_id:
			-1: title_card = "[ MAINTENANCE WINDOW: HARDWARE RECOVERY ]"
			-2: title_card = "[ MAINTENANCE WINDOW: PREVENTATIVE AUDIT ]"
			2: title_card = "[ FLOOR 2: EXECUTIVE SUITE ]"
		
		_teleport_to(floor_info.scene, "", title_card)

func _teleport_to(path: String, narrative: String = "", title_card: String = ""):
	print("Teleporting to: ", path)
	if TransitionManager:
		TransitionManager.change_scene_to(path, narrative, title_card)

# Helper for the PlayerController set_near_npc call
var npc_name: String:
	get: return interaction_text
