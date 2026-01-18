# LogEntry.gd
extends PanelContainer

signal log_selected(log: LogResource, instance: Control)

@onready var time_label: Label = %TimeLabel
@onready var source_label: Label = %SourceLabel
@onready var severity_label: Label = %SeverityLabel
@onready var message_label: Label = %MessageLabel

var log_data: LogResource

func set_log_data(log: LogResource):
	log_data = log
	
	# Set text content
	if time_label: time_label.text = log.timestamp
	if source_label: source_label.text = log.source.to_upper()
	if severity_label: 
		severity_label.text = log.get_severity_text()
		severity_label.add_theme_color_override("font_color", log.get_severity_color())
	if message_label:
		message_label.text = log.message
		message_label.tooltip_text = log.message
	
	# Update visual style based on log state
	var style = get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	if style:
		if log.is_revealed:
			style.border_color = Color.MAGENTA
			style.shadow_color = Color(1.0, 0.0, 1.0, 0.2)
			style.shadow_size = 2
		else:
			style.border_color = log.get_severity_color()
		
		add_theme_stylebox_override("panel", style)

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if log_data:
			log_selected.emit(log_data, self)
		get_viewport().set_input_as_handled()

func set_highlight(active: bool):
	var style = get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	if style:
		if active:
			style.bg_color = Color(0.1, 0.2, 0.3, 0.8)
		else:
			style.bg_color = Color(0.05, 0.05, 0.1, 0.5)
		add_theme_stylebox_override("panel", style)
