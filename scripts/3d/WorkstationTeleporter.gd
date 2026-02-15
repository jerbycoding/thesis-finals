# WorkstationTeleporter.gd
# Handles the transition from the 3D SOC office to the specialized Workstation scene.
extends Area3D

@export_file("*.tscn") var workstation_scene: String = "res://scenes/3d/WorkstationRoom.tscn"
@export var interaction_text: String = "Enter in your workstation"

var player_in_range: bool = false

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "Player3D":
		player_in_range = true
		if body.has_method("set_near_npc"):
			body.set_near_npc(self, true)

func _on_body_exited(body):
	if body.name == "Player3D":
		player_in_range = false
		if body.has_method("set_near_npc"):
			body.set_near_npc(self, false)

func _input(event):
	if player_in_range and event.is_action_pressed("interact"):
		_enter_workstation()

func _enter_workstation():
	print("[Workstation] Transitioning to workstation scene...")
	if TransitionManager:
		# Use TransitionManager for a clean fade/load
		TransitionManager.change_scene_to(workstation_scene, "", "[ LOADING WORKSTATION ]")
	else:
		get_tree().change_scene_to_file(workstation_scene)

# Property for PlayerController/Interaction UI compatibility
var npc_name: String:
	get: return interaction_text
