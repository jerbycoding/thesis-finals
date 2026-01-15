# RoomTeleporter.gd
# Handles teleporting the player between scenes (e.g., SOC Office to Briefing Room)
extends Area3D

@export_file("*.tscn") var target_scene_path: String = ""
@export var narrative_to_trigger: String = ""
@export var interaction_text: String = "Enter Elevator"

var player_in_range: bool = false

@onready var door_visual = get_node_or_null("ElevatorDoor")

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

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
		if not target_scene_path.is_empty():
			print("Teleporting to: ", target_scene_path)
			if TransitionManager:
				TransitionManager.change_scene_to(target_scene_path, narrative_to_trigger)
		else:
			push_warning("RoomTeleporter: No target scene path set.")

# Helper for the PlayerController set_near_npc call
var npc_name: String:
	get: return interaction_text
