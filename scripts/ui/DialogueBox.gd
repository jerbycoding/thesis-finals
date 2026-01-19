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
	hide()
	modulate.a = 1.0 # Ensure visible by default

func show_dialogue(dialogue_data: Dictionary, npc: String = ""):
	npc_id = npc
	current_dialogue = dialogue_data
	current_line_index = 0
	
	# Release mouse cursor for dialogue interaction
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	show()
	modulate.a = 0
	
	# Ensure nodes are ready
	_ensure_nodes_ready()
	
	# Set NPC name
	if name_label:
		if dialogue_data.has("npc_name"):
			name_label.text = dialogue_data["npc_name"]
		else:
			name_label.text = npc_id.capitalize()
	
	# Set portrait
	if portrait_label:
		if dialogue_data.has("portrait"):
			portrait_label.text = dialogue_data["portrait"]
		else:
			portrait_label.text = "👤"
	
	# Show first line
	_show_current_line()
	
	# Simple fade in
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.2)

func _ensure_nodes_ready():
	if not portrait_label: portrait_label = %PortraitLabel
	if not name_label: name_label = %NameLabel
	if not text_label: text_label = %TextLabel
	if not choices_container: choices_container = %ChoicesContainer
	if not main_panel: main_panel = %MainPanel

func _show_current_line():
	if not current_dialogue.has("lines"): return
	
	var lines = current_dialogue["lines"]
	if current_line_index >= lines.size():
		_close_dialogue()
		return
	
	var line = lines[current_line_index]
	
	if text_label and line.has("text"):
		text_label.text = line["text"]
	
	# Clear previous choices
	if choices_container:
		for child in choices_container.get_children():
			child.queue_free()
	
	# Show choices
	if line.has("choices") and line["choices"].size() > 0:
		_show_choices(line["choices"])
	else:
		# Show Continue Button instead of just text hint
		_add_continue_button()

func _show_choices(choices: Array):
	if not choices_container: return
	
	for i in range(choices.size()):
		var choice = choices[i] as Dictionary
		if choice:
			var btn = Button.new()
			btn.text = str(i + 1) + ". " + choice.get("text", "Choice")
			btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
			btn.custom_minimum_size = Vector2(0, 40)
			
			# Styling
			btn.add_theme_color_override("font_color", Color(0.8, 0.8, 1.0))
			btn.add_theme_color_override("font_hover_color", Color(1, 1, 1))
			
			# Connect signals
			btn.pressed.connect(_on_choice_selected.bind(i))
			btn.mouse_entered.connect(_on_hover)
			
			choices_container.add_child(btn)

func _add_continue_button():
	if not choices_container: return
	
	var btn = Button.new()
	btn.text = "CONTINUE [SPACE]"
	btn.alignment = HORIZONTAL_ALIGNMENT_CENTER
	btn.custom_minimum_size = Vector2(0, 40)
	btn.pressed.connect(_on_continue_pressed)
	btn.mouse_entered.connect(_on_hover)
	
	choices_container.add_child(btn)
	# Grab focus for keyboard users
	btn.grab_focus()

func _on_hover():
	if AudioManager: AudioManager.play_ui_hover()

func _on_continue_pressed():
	if AudioManager: AudioManager.play_ui_click()
	current_line_index += 1
	_show_current_line()

func _on_choice_selected(choice_index: int):
	if AudioManager: AudioManager.play_ui_click()
	
	var lines = current_dialogue["lines"]
	if current_line_index < lines.size():
		var line = lines[current_line_index]
		if line.has("choices") and choice_index < line["choices"].size():
			var choice = line["choices"][choice_index]
			
			# Log choice
			if ConsequenceEngine:
				ConsequenceEngine.log_player_choice("dialogue", {
					"npc": npc_id,
					"choice": choice_index,
					"choice_text": choice.get("text", "")
				})
			
			dialogue_choice_selected.emit(choice)
			
			# Navigate or Close
			if choice.has("next_line"):
				current_line_index = choice["next_line"]
			else:
				current_line_index += 1
			
			_show_current_line()

func _close_dialogue():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	await tween.finished
	hide()
	dialogue_closed.emit()

func _input(event):
	if not visible: return
	
	if event.is_action_pressed("ui_cancel"):
		_close_dialogue()
		get_viewport().set_input_as_handled()
		return
	
	# Number keys for choices
	if event is InputEventKey and event.pressed:
		if event.keycode >= KEY_1 and event.keycode <= KEY_9:
			var idx = event.keycode - KEY_1
			# Check if valid
			var line = current_dialogue.get("lines", [])
			if current_line_index < line.size():
				var choices = line[current_line_index].get("choices", [])
				if idx < choices.size():
					_on_choice_selected(idx)
					get_viewport().set_input_as_handled()
		
		# Space/Enter to continue (only if no choices or if button focused)
		if event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
			# Check if we are at a "Continue" state
			var line = current_dialogue.get("lines", [])
			if current_line_index < line.size() and line[current_line_index].get("choices", []).is_empty():
				_on_continue_pressed()
				get_viewport().set_input_as_handled()