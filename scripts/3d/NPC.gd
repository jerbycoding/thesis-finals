
# Base script for all NPCs in the game
extends CharacterBody3D

@export var npc_id: String = "npc"
@export var npc_name: String = "NPC"
@export var dialogue_resources: Dictionary = {}

var player_nearby: bool = false
var interaction_area: Area3D = null

func _ready():

	# Find interaction area
	interaction_area = $InteractionArea
	if interaction_area:
		interaction_area.body_entered.connect(_on_body_entered)
		interaction_area.body_exited.connect(_on_body_exited)
	
	# Connect to NarrativeDirector
	if NarrativeDirector:
		NarrativeDirector.npc_interaction_requested.connect(_on_narrative_interaction_requested)

func _on_body_entered(body):
	if body.name == "Player3D":
		player_nearby = true
		# Show interaction prompt
		if body.has_method("set_near_npc"):
			body.set_near_npc(self, true)

func _on_body_exited(body):
	if body.name == "Player3D":
		player_nearby = false
		# Hide interaction prompt
		if body.has_method("set_near_npc"):
			body.set_near_npc(self, false)

func _input(event):
	if player_nearby and event.is_action_pressed("interact"):
		start_dialogue("default")

func start_dialogue(dialogue_id: String = "default"):
	# Delegate starting the dialogue to the DialogueManager.
	# This avoids scene-specific instances and ensures the dialogue UI
	# is handled by a persistent system.
	if DialogueManager:
		var dialogue_resource = get_dialogue(dialogue_id)
		if dialogue_resource:
			DialogueManager.start_dialogue(self, dialogue_resource)
		else:
			push_warning("No dialogue resource found for ID '%s' on NPC '%s'" % [dialogue_id, npc_name])
	else:
		push_error("DialogueManager not found. Cannot start dialogue.")

func _on_dialogue_choice_selected(choice: Dictionary):
	# This function is now called by the DialogueManager when a choice is made.
	# Handle choice effects
	if choice.has("effect"):
		_apply_choice_effect(choice["effect"])


func _apply_choice_effect(effect: Dictionary):
	# This function is called when a dialogue choice with an 'effect' is made.

	# Handle relationship changes first, as they are synchronous.
	if effect.has("relationship_change"):
		var npc = effect.get("npc", npc_id)
		var change = effect.get("relationship_change", 0.0)
		if ConsequenceEngine:
			ConsequenceEngine.update_npc_relationship(npc, change)
	
	# Handle scene changes, which are asynchronous and may have a follow-up action.
	if effect.has("change_scene"):
		var scene_path = effect.get("change_scene", "")
		var narrative_to_start_after = effect.get("then_start_narrative", "")
		
		if scene_path.is_empty():
			push_error("NPC effect has 'change_scene' but the path is empty.")
			return
			
		if TransitionManager:
			# Pass both the scene to change to, and the narrative to start after completion.
			TransitionManager.change_scene_to(scene_path, narrative_to_start_after)
		else:
			push_error("NPC effect cannot change scene, TransitionManager is not available.")



func _on_narrative_interaction_requested(requested_npc_id: String, dialogue_id: String):
	if requested_npc_id == npc_id:
		start_dialogue(dialogue_id)

func get_dialogue(dialogue_id: String) -> DialogueDataResource:
	# Load from the exported dictionary of resources
	if dialogue_resources.has(dialogue_id):
		return dialogue_resources[dialogue_id]
	return null
