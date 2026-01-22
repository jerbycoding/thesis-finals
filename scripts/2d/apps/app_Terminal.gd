# app_Terminal.gd
extends Control

var command_history: Array[String] = []
var history_index: int = -1
var current_ticket_id: String = ""

@onready var output_text: RichTextLabel = %OutputText
@onready var command_input: LineEdit = %CommandInput
@onready var metadata_box: PanelContainer = %MetadataBox
@onready var metadata_label: RichTextLabel = %MetadataLabel

# --- Typewriter Logic ---
var _output_queue: Array[String] = []
var _is_typing: bool = false
var _typewriter_speed: float = 0.01
var _current_tween: Tween

func _ready():
	print("======= App_Terminal (TUI Redesign) Ready =======")
	
	visible = true
	modulate = Color.WHITE
	
	command_input.text_submitted.connect(_on_command_submitted)
	command_input.grab_focus()
	
	_append_output("[color=gray]SOC_CORE v4.4 Operating System[/color]\n[color=gray]Unauthorized access is strictly prohibited.[/color]\n\n")
	_append_output("Type [color=cyan]help[/color] to list available forensic modules.\n\n")

func _on_command_submitted(command: String):
	if command.strip_edges().is_empty(): return
	
	if AudioManager: AudioManager.play_terminal_beep()
	
	command_history.append(command)
	history_index = command_history.size()
	command_input.text = ""
	
	_append_output("[color=gray]> " + command + "[/color]\n")
	
	if TerminalSystem:
		var result = await TerminalSystem.execute_command(command)
		
		# If the result looks like metadata (e.g. from scan or status), show it in the box
		if "module" in command.to_lower() or "scan" in command.to_lower() or "status" in command.to_lower():
			_show_metadata(result.output)
		else:
			_append_output(result.output + "\n")
	else:
		_append_output("[color=red]SYSTEM_ERROR: Module backend unreachable.[/color]\n")

func _show_metadata(text: String):
	metadata_box.visible = true
	metadata_label.text = text
	
	# Small animation
	metadata_box.modulate.a = 0
	var tween = create_tween()
	tween.tween_property(metadata_box, "modulate:a", 1.0, 0.2)

func _append_output(text: String):
	output_text.append_text(text)
	_scroll_to_bottom()

func _scroll_to_bottom():
	var scroll_container = output_text.get_parent()
	if scroll_container is ScrollContainer:
		await get_tree().process_frame
		scroll_container.scroll_vertical = scroll_container.get_v_scroll_bar().max_value

func _input(event):
	if not visible: return
	
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_UP and not command_history.is_empty():
			history_index = max(0, history_index - 1)
			command_input.text = command_history[history_index]
		elif event.keycode == KEY_DOWN and not command_history.is_empty():
			history_index = min(command_history.size(), history_index + 1)
			if history_index == command_history.size():
				command_input.text = ""
			else:
				command_input.text = command_history[history_index]