# DialogueBox.gd
extends Control

signal dialogue_choice_selected(choice: Dictionary)
signal dialogue_closed()

var current_dialogue: Dictionary = {}
var current_line_index: int = 0
var npc_id: String = ""

@onready var portrait_label: Label = %PortraitLabel
@onready var name_label: Label = %NameLabel
@onready var text_label: RichTextLabel = %TextLabel
@onready var scroll_container: ScrollContainer = %Scroll
@onready var choices_container: VBoxContainer = %ChoicesContainer
@onready var main_panel: PanelContainer = %MainPanel

func _ready():
	hide()
	modulate.a = 1.0

func show_dialogue(dialogue_data: Dictionary, npc: String = ""):
	npc_id = npc
	current_dialogue = dialogue_data
	current_line_index = 0
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	show()
	modulate.a = 0
	
	if dialogue_data.has("npc_name"):
		name_label.text = dialogue_data["npc_name"].to_upper()
	else:
		name_label.text = npc_id.to_upper()
	
	if dialogue_data.has("portrait"):
		portrait_label.text = dialogue_data["portrait"]
	else:
		portrait_label.text = "👤"
	
	_show_current_line()
	create_tween().tween_property(self, "modulate:a", 1.0, 0.2)

func _show_current_line():
	if not current_dialogue.has("lines"): return
	var lines = current_dialogue["lines"]
	if current_line_index >= lines.size():
		_close_dialogue()
		return
	
	# Reset scroll to top for new text
	if scroll_container:
		scroll_container.scroll_vertical = 0
	
	var line = lines[current_line_index]
	var raw_text = line.get("text", "")
	
	# Apply placeholders if they exist (Sprint 11)
	if current_dialogue.has("placeholders") and not current_dialogue["placeholders"].is_empty():
		raw_text = raw_text.format(current_dialogue["placeholders"])
		
	text_label.text = raw_text
	
	for child in choices_container.get_children():
		child.queue_free()
	
	if line.has("choices") and line["choices"].size() > 0:
		_show_choices(line["choices"])
	else:
		_add_continue_button()

func _show_choices(choices: Array):
	for i in range(choices.size()):
		var choice = choices[i]
		var btn = Button.new()
		btn.text = " [" + str(i + 1) + "] " + choice.get("text", "CHOICE")
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.custom_minimum_size.y = 40
		_style_choice_button(btn)
		btn.pressed.connect(_on_choice_selected.bind(i))
		btn.mouse_entered.connect(_on_hover)
		choices_container.add_child(btn)
		if i == 0: btn.grab_focus()

func _add_continue_button():
	var btn = Button.new()
	btn.text = "PROCEED_PROTOCOL [SPACE]"
	btn.alignment = HORIZONTAL_ALIGNMENT_CENTER
	btn.custom_minimum_size.y = 45
	_style_choice_button(btn)
	btn.pressed.connect(_on_continue_pressed)
	btn.mouse_entered.connect(_on_hover)
	choices_container.add_child(btn)
	btn.grab_focus()

func _style_choice_button(btn: Button):
	var style = StyleBoxFlat.new()
	style.bg_color = Color.BLACK
	style.content_margin_left = 15
	style.content_margin_right = 15
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", style)
	btn.add_theme_stylebox_override("pressed", style)
	btn.add_theme_color_override("font_color", Color.WHITE)
	btn.add_theme_font_size_override("font_size", 11)

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
			if ConsequenceEngine:
				ConsequenceEngine.log_player_choice("dialogue", {
					"npc": npc_id, "choice": choice_index, "choice_text": choice.get("text", "")
				})
			dialogue_choice_selected.emit(choice)
			if choice.has("next_line"): current_line_index = choice["next_line"]
			else: current_line_index += 1
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
	if event is InputEventKey and event.pressed:
		if event.keycode >= KEY_1 and event.keycode <= KEY_9:
			var idx = event.keycode - KEY_1
			var line = current_dialogue.get("lines", [])
			if current_line_index < line.size():
				var choices = line[current_line_index].get("choices", [])
				if idx < choices.size():
					_on_choice_selected(idx)
					get_viewport().set_input_as_handled()
		if event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
			var line = current_dialogue.get("lines", [])
			if current_line_index < line.size() and line[current_line_index].get("choices", []).is_empty():
				_on_continue_pressed()
				get_viewport().set_input_as_handled()
