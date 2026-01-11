# DialogueBox.gd
# UI component for displaying NPC dialogue with choices
extends Control

signal dialogue_choice_selected(choice: Dictionary)
signal dialogue_closed()

var current_dialogue: Dictionary = {}
var current_line_index: int = 0
var npc_id: String = ""


@onready var portrait_label: Label = %PortraitLabel
@onready var name_label: Label = %NameLabel
@onready var text_label: RichTextLabel = %TextLabel
@onready var choices_container: VBoxContainer = %ChoicesContainer
@onready var main_panel: PanelContainer = %MainPanel

func _ready():
	# Start hidden
	hide()
	modulate.a = 0

func show_dialogue(dialogue_data: Dictionary, npc: String = ""):
	npc_id = npc
	current_dialogue = dialogue_data
	current_line_index = 0
	
	# Release mouse cursor for dialogue interaction
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Initial state for animation
	show()
	modulate.a = 0
	
	# Ensure nodes are ready
	_ensure_nodes_ready()
	
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
	
	# Animate in (Alpha fade only to avoid position conflicts)
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.3)

func _ensure_nodes_ready():
	if not portrait_label:
		portrait_label = %PortraitLabel
	if not name_label:
		name_label = %NameLabel
	if not text_label:
		text_label = %TextLabel
	if not choices_container:
		choices_container = %ChoicesContainer
	if not main_panel:
		main_panel = %MainPanel

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
			hint_label.text = " [ PRESS ENTER TO CONTINUE ] "
			hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
			hint_label.add_theme_color_override("font_color", Color(0.2, 1.0, 0.2, 0.6))
			hint_label.add_theme_font_size_override("font_size", 14)
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
			
			# The signal is emitted, and the connected object (the NPC via the DialogueManager)
			# will handle the consequences. The DialogueBox itself does not.
			dialogue_choice_selected.emit(choice)
			
			# Move to next line or close
			if choice.has("next_line"):
				var next_idx = choice["next_line"]
				if next_idx >= 0 and next_idx < lines.size():
					current_line_index = next_idx
				else:
					push_error("Dialogue Error: Choice 'next_line' index %d is out of bounds (Size: %d)" % [next_idx, lines.size()])
					_close_dialogue()
					return
			else:
				current_line_index += 1
			
			_show_current_line()


func _close_dialogue():
	hide()
	# The DialogueManager is responsible for changing game state and mouse mode.
	# This UI element just signals that it has been closed.
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
