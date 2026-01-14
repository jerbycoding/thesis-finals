# DialogueManager.gd
# Autoload singleton to manage the dialogue system.
extends Node

var dialogue_box_scene = preload("res://scenes/ui/DialogueBox.tscn")
var dialogue_box_instance: Control = null

var current_npc: Node = null

func _ready():
	# Instantiate the dialogue box and add it to the root of the tree
	# so it persists across scene changes.
	dialogue_box_instance = dialogue_box_scene.instantiate()
	get_tree().root.call_deferred("add_child", dialogue_box_instance)
	dialogue_box_instance.dialogue_choice_selected.connect(_on_dialogue_choice_selected)
	dialogue_box_instance.dialogue_closed.connect(_on_dialogue_closed)
	print("DialogueManager ready.")

func start_dialogue(requesting_npc: Node, dialogue_resource: DialogueDataResource):
	# requesting_npc can be null for 'remote' terminal calls
	
	if dialogue_resource == null:
		print("ERROR: DialogueManager started with a null dialogue resource.")
		return

	# Validation Step: Ensure the dialogue data is safe to run
	if not validate_dialogue(dialogue_resource):
		var npc_name = requesting_npc.npc_name if is_instance_valid(requesting_npc) else "Unknown"
		push_error("DialogueManager: Refused to start invalid dialogue for %s" % npc_name)
		return

	current_npc = requesting_npc
	
	# Construct the dialogue_data dictionary from the resource
	var dialogue_data = {
		"npc_name": dialogue_resource.npc_name,
		"portrait": dialogue_resource.portrait,
		"lines": dialogue_resource.lines
	}
	
	# Show the dialogue
	var display_name = dialogue_resource.npc_name
	if is_instance_valid(current_npc):
		display_name = current_npc.npc_name
		
	dialogue_box_instance.show_dialogue(dialogue_data, display_name)
	
	# Set game mode to Dialogue
	GameState.set_game_mode(GameState.GameMode.MODE_DIALOGUE)

func validate_dialogue(resource: DialogueDataResource) -> bool:
	var lines = resource.lines
	var line_count = lines.size()
	
	for i in range(line_count):
		var line = lines[i]
		if not line.has("text"):
			push_error("Dialogue Resource Error: Line %d is missing 'text' key." % i)
			return false
			
		if line.has("choices"):
			for choice in line["choices"]:
				if choice.has("next_line"):
					var target = choice["next_line"]
					if target < 0 or target >= line_count:
						push_error("Dialogue Resource Error: Line %d has choice with invalid next_line: %d" % [i, target])
						return false
	return true

func _on_dialogue_choice_selected(choice: Dictionary):
	if is_instance_valid(current_npc) and current_npc.has_method("_on_dialogue_choice_selected"):
		# Forward the choice to the NPC that started the dialogue
		current_npc._on_dialogue_choice_selected(choice)
	else:
		# If it was a remote call (no NPC node), we can still apply effects directly here
		if choice.has("effect"):
			_apply_remote_choice_effect(choice["effect"])

func _apply_remote_choice_effect(effect: Dictionary):
	if effect.has("relationship_change"):
		var npc_id = effect.get("npc", "ciso")
		var change = effect.get("relationship_change", 0.0)
		if ConsequenceEngine:
			ConsequenceEngine.update_npc_relationship(npc_id, change)
	
	if effect.has("change_scene"):
		var scene_path = effect.get("change_scene", "")
		var narrative = effect.get("then_start_narrative", "")
		if TransitionManager:
			TransitionManager.change_scene_to(scene_path, narrative)

func _on_dialogue_closed():
	_close_dialogue_session()

func _close_dialogue_session():
	# This function is called when the dialogue box is closed, either by finishing
	# the dialogue or by the player pressing Escape.
	
	# Restore mouse capture for 3D gameplay
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# We only change the mode back to 3D. The dialogue box handles hiding itself.
	if GameState.current_mode == GameState.GameMode.MODE_DIALOGUE:
		GameState.set_game_mode(GameState.GameMode.MODE_3D)

	current_npc = null
