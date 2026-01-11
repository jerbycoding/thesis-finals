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
	if not is_instance_valid(requesting_npc):
		print("ERROR: DialogueManager started with an invalid NPC.")
		return
	
	if dialogue_resource == null:
		print("ERROR: DialogueManager started with a null dialogue resource.")
		return

	current_npc = requesting_npc
	
	# Construct the dialogue_data dictionary from the resource
	var dialogue_data = {
		"npc_name": dialogue_resource.npc_name,
		"portrait": dialogue_resource.portrait,
		"lines": dialogue_resource.lines
	}
	
	# Show the dialogue
	dialogue_box_instance.show_dialogue(dialogue_data, current_npc.npc_name)
	
	# Set game mode to Dialogue
	GameState.set_game_mode(GameState.GameMode.MODE_DIALOGUE)

func _on_dialogue_choice_selected(choice: Dictionary):
	if is_instance_valid(current_npc) and current_npc.has_method("_on_dialogue_choice_selected"):
		# Forward the choice to the NPC that started the dialogue
		current_npc._on_dialogue_choice_selected(choice)
	else:
		print("ERROR: current_npc is not valid or does not have _on_dialogue_choice_selected method.")

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
