# Base script for all NPCs in the game
extends CharacterBody3D
class_name BaseNPC

@export var npc_id: String = "npc"
@export var npc_name: String = "NPC"
@export var dialogue_resources: Dictionary = {}

var player_nearby: bool = false
var interaction_area: Area3D = null
var is_highlighted: bool = false
var highlight_tween: Tween
var animator: Node3D = null

func set_highlight(active: bool):
	is_highlighted = active
	
	# Find mesh to highlight
	var mesh = get_node_or_null("MeshInstance3D")
	if not mesh:
		# Try to find any MeshInstance3D in children (e.g. from imported GLB)
		for child in get_children():
			if child is MeshInstance3D:
				mesh = child
				break
			elif child.get_child_count() > 0:
				for gchild in child.get_children():
					if gchild is MeshInstance3D:
						mesh = gchild
						break
	
	if not mesh: return

	if highlight_tween:
		highlight_tween.kill()
	
	if active:
		highlight_tween = create_tween().set_loops()
		highlight_tween.tween_property(mesh, "transparency", 0.3, 0.5)
		highlight_tween.tween_property(mesh, "transparency", 0.0, 0.5)
	else:
		mesh.transparency = 0.0

func _ready():
	add_to_group("npcs")
	# Find animator in children
	for child in get_children():
		if child.has_method("update_movement"):
			animator = child
			break
			
	# Find interaction area
	interaction_area = get_node_or_null("InteractionArea")
	if interaction_area:
		interaction_area.body_entered.connect(_on_body_entered)
		interaction_area.body_exited.connect(_on_body_exited)
	
	# Connect to EventBus
	EventBus.npc_interaction_requested.connect(_on_narrative_interaction_requested)
	
	# Announce readiness for narrative triggers
	EventBus.npc_ready.emit(npc_id)

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

func start_dialogue(dialogue_id: String = "default"):
	# Delegate starting the dialogue to the DialogueManager.
	# This avoids scene-specific instances and ensures the dialogue UI
	# is handled by a persistent system.
	print("NPC [%s]: Manually starting dialogue '%s'" % [npc_name, dialogue_id])
	
	if DialogueManager:
		var dialogue_resource = get_dialogue(dialogue_id)
		if dialogue_resource:
			DialogueManager.start_dialogue(self, dialogue_resource)
		else:
			push_warning("NPC [%s]: Failed to find dialogue '%s'" % [npc_name, dialogue_id])
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
	
	if effect.has("favor"):
		var favor_data = effect["favor"]
		if ConsequenceEngine:
			ConsequenceEngine.apply_social_favor(favor_data.get("id", ""), favor_data.get("cost", 0.0), npc_id)
	
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
	# 1. Check if it's already in the manual overrides dictionary
	if dialogue_resources.has(dialogue_id):
		return dialogue_resources[dialogue_id]
	
	# 2. Convention-based discovery: res://resources/dialogue/[npc_id]_[dialogue_id].tres
	var convention_path = "res://resources/dialogue/" + npc_id + "_" + dialogue_id + ".tres"
	print("NPC [%s]: Searching for dialogue at convention path: %s" % [npc_name, convention_path])
	
	if ResourceLoader.exists(convention_path):
		var res = load(convention_path)
		if res is DialogueDataResource:
			# Cache it
			dialogue_resources[dialogue_id] = res
			return res
			
	push_warning("No dialogue resource found for ID '%s' on NPC '%s' (Checked: %s)" % [dialogue_id, npc_name, convention_path])
	return null
