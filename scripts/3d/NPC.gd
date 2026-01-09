# NPC.gd
# Base script for all NPCs in the game
extends CharacterBody3D

@export var npc_id: String = "npc"
@export var npc_name: String = "NPC"
@export var dialogue_data: Dictionary = {}

var player_nearby: bool = false
var interaction_area: Area3D = null
var dialogue_box_scene = preload("res://scenes/ui/DialogueBox.tscn")
static var dialogue_box_instance: Control = null

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
	# Get dialogue data
	var dialogue = get_dialogue(dialogue_id)
	if dialogue.is_empty():
		print("⚠ No dialogue found for: ", dialogue_id)
		return
	
	# Create dialogue box if it doesn't exist
	if not dialogue_box_instance:
		dialogue_box_instance = dialogue_box_scene.instantiate()
		get_tree().root.add_child(dialogue_box_instance)
		dialogue_box_instance.dialogue_choice_selected.connect(_on_dialogue_choice_selected)
	
	# Show dialogue
	dialogue_box_instance.show_dialogue(dialogue, npc_id)
	
	# Disable player movement
	if GameState:
		GameState.set_game_mode(GameState.GameMode.MODE_DIALOGUE)

func _on_dialogue_choice_selected(choice: Dictionary):
	# Handle choice effects
	if choice.has("effect"):
		_apply_choice_effect(choice["effect"])

func _apply_choice_effect(effect: Dictionary):
	if effect.has("relationship_change"):
		var npc = effect.get("npc", npc_id)
		var change = effect["relationship_change"]
		if ConsequenceEngine:
			ConsequenceEngine.update_npc_relationship(npc, change)
	
	if effect.has("change_scene"):
		var scene_path = effect["change_scene"]
		if TransitionManager:
			TransitionManager.change_scene_to(scene_path)
			
	if effect.has("start_narrative"):
		if NarrativeDirector:
			NarrativeDirector.start_shift()

func _on_narrative_interaction_requested(requested_npc_id: String, dialogue_id: String):
	if requested_npc_id == npc_id:
		start_dialogue(dialogue_id)

func get_dialogue(dialogue_id: String) -> Dictionary:
	# Override in child classes or load from JSON
	if dialogue_data.has(dialogue_id):
		return dialogue_data[dialogue_id]
	return {}

