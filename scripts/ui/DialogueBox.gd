# DialogueBox.gd
# UI component for displaying NPC dialogue with choices
extends Control

signal dialogue_choice_selected(choice: Dictionary)
signal dialogue_closed()

var current_dialogue: Dictionary = {}
var current_line_index: int = 0
var npc_id: String = ""


var portrait_label: Label = null
var name_label: Label = null
var text_label: Label = null
var choices_container: VBoxContainer = null

func _ready():
	hide()
	
	# Wait for scene tree to be ready before finding nodes
	await get_tree().process_frame
	
	# Find nodes manually (more reliable for dynamically instantiated scenes)
	portrait_label = get_node_or_null("PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/PortraitLabel")
	name_label = get_node_or_null("PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/NameLabel")
	text_label = get_node_or_null("PanelContainer/MarginContainer/VBoxContainer/TextLabel")
	choices_container = get_node_or_null("PanelContainer/MarginContainer/VBoxContainer/ChoicesContainer")
	
	# Fallback: use find_child if path-based lookup fails
	if not portrait_label:
		portrait_label = find_child("PortraitLabel", true, false)
	if not name_label:
		name_label = find_child("NameLabel", true, false)
	if not text_label:
		text_label = find_child("TextLabel", true, false)
	if not choices_container:
		choices_container = find_child("ChoicesContainer", true, false)
	
	# Debug: Check if nodes were found
	if not portrait_label or not name_label or not text_label or not choices_container:
		print("⚠ WARNING: Some dialogue nodes not found!")
		print("  - portrait_label: ", portrait_label != null)
		print("  - name_label: ", name_label != null)
		print("  - text_label: ", text_label != null)
		print("  - choices_container: ", choices_container != null)

func show_dialogue(dialogue_data: Dictionary, npc: String = ""):
	npc_id = npc
	current_dialogue = dialogue_data
	current_line_index = 0
	
	# Release mouse cursor for dialogue interaction
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Wait for scene tree to be ready (important for dynamically instantiated nodes)
	await get_tree().process_frame
	
	# Ensure nodes are ready - find them if not already found
	if not portrait_label:
		portrait_label = get_node_or_null("PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/PortraitLabel")
	if not name_label:
		name_label = get_node_or_null("PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/NameLabel")
	if not text_label:
		text_label = get_node_or_null("PanelContainer/MarginContainer/VBoxContainer/TextLabel")
	if not choices_container:
		choices_container = get_node_or_null("PanelContainer/MarginContainer/VBoxContainer/ChoicesContainer")
	
	# Final check - if still null, try find_child (searches recursively)
	if not portrait_label:
		portrait_label = find_child("PortraitLabel", true, false)
	if not name_label:
		name_label = find_child("NameLabel", true, false)
	if not text_label:
		text_label = find_child("TextLabel", true, false)
	if not choices_container:
		choices_container = find_child("ChoicesContainer", true, false)
	
	# Set NPC name (with null check)
	if name_label:
		if dialogue_data.has("npc_name"):
			name_label.text = dialogue_data["npc_name"]
		else:
			name_label.text = npc_id.capitalize()
	
	# Set portrait (with null check)
	if portrait_label:
		if dialogue_data.has("portrait"):
			portrait_label.text = dialogue_data["portrait"]
		else:
			portrait_label.text = "👤"
	
	# Show first line
	_show_current_line()
	show()

func _show_current_line():
	if not current_dialogue.has("lines"):
		return
	
	var lines = current_dialogue["lines"]
	if current_line_index >= lines.size():
		# Dialogue complete
		_close_dialogue()
		return
	
	var line = lines[current_line_index]
	
	# Set text (with null check)
	if text_label and line.has("text"):
		text_label.text = line["text"]
	
	# Clear previous choices (with null check)
	if choices_container:
		for child in choices_container.get_children():
			child.queue_free()
	
	# Show choices if available
	if line.has("choices") and line["choices"].size() > 0:
		_show_choices(line["choices"])
	else:
		# Show hint text instead of button (keyboard only)
		if choices_container:
			var hint_label = Label.new()
			hint_label.text = "Press Enter or Space to continue..."
			hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			hint_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
			choices_container.add_child(hint_label)

func _show_choices(choices: Array):
	# Store choices for keyboard selection
	if not choices_container:
		return
	
	# Show choices as labels with numbers
	for i in range(choices.size()):
		var choice = choices[i] as Dictionary
		if choice:
			var choice_label = Label.new()
			choice_label.text = str(i + 1) + ". " + choice.get("text", "Choice " + str(i + 1))
			choice_label.custom_minimum_size = Vector2(200, 30)
			choice_label.add_theme_color_override("font_color", Color(0.8, 0.8, 1.0))
			choices_container.add_child(choice_label)
	
	# Add hint
	var hint_label = Label.new()
	hint_label.text = "Press 1-" + str(choices.size()) + " to select, Enter/Space to continue"
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	choices_container.add_child(hint_label)

func _on_continue_pressed():
	current_line_index += 1
	_show_current_line()

func _on_choice_selected(choice_index: int):
	var lines = current_dialogue["lines"]
	var choice: Dictionary = {} # Declare at the top of the function
	if current_line_index < lines.size():
		var line = lines[current_line_index]
		
		if line.has("choices") and choice_index < line["choices"].size():
			choice = line["choices"][choice_index]
			
			# Log choice
			if ConsequenceEngine:
				ConsequenceEngine.log_player_choice("dialogue", {
					"npc": npc_id,
					"choice": choice_index,
					"choice_text": choice.get("text", "")
				})
			
			# Handle choice effects
			if choice.has("effect"):
				_apply_choice_effect(choice["effect"])
			
			# Move to next line or close
			if choice.has("next_line"):
				current_line_index = choice["next_line"]
			else:
				current_line_index += 1
			
			_show_current_line()
	
	dialogue_choice_selected.emit(choice)

func _apply_choice_effect(effect: Dictionary):
	if effect.has("relationship_change"):
		var npc = effect.get("npc", npc_id)
		var change = effect["relationship_change"]
		if ConsequenceEngine:
			ConsequenceEngine.update_npc_relationship(npc, change)
	
	if effect.has("unlock_event"):
		# Trigger event unlock
		pass

func _close_dialogue():
	hide()
	# Restore mouse capture for 3D mode
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	# Set the game mode back to 3D to re-enable player movement
	if GameState:
		GameState.set_game_mode(GameState.GameMode.MODE_3D)

	dialogue_closed.emit()

func _input(event):
	if not visible:
		return
	
	# Close dialogue with Escape
	if event.is_action_pressed("ui_cancel"):
		_close_dialogue()
		get_viewport().set_input_as_handled()
		return
	
	# Handle keyboard input
	if event is InputEventKey and event.pressed:
		# Check if we have choices
		var line = current_dialogue.get("lines", [])
		if current_line_index < line.size():
			var current_line = line[current_line_index]
			
			# If there are choices, handle number keys
			if current_line.has("choices") and current_line["choices"].size() > 0:
				var choice_count = current_line["choices"].size()
				# Check for number keys 1-9
				if event.keycode >= KEY_1 and event.keycode <= KEY_9:
					var choice_index = event.keycode - KEY_1
					if choice_index < choice_count:
						_on_choice_selected(choice_index)
						get_viewport().set_input_as_handled()
						return
		
		# Advance dialogue with Enter or Space (when no choices or after selection)
		if event.keycode in [KEY_ENTER, KEY_SPACE] or event.is_action_pressed("ui_accept"):
			# Only advance if there are no choices (just hint label)
			if choices_container:
				var children = choices_container.get_children()
				# If only hint label, advance
				if children.size() == 1:
					_on_continue_pressed()
					get_viewport().set_input_as_handled()
