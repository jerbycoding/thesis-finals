# LogEntry.gd
extends PanelContainer

signal log_selected(log: LogResource, instance: Control)

@onready var status_dot: ColorRect = %StatusDot
@onready var time_label: Label = %TimeLabel
@onready var message_label: RichTextLabel = %MessageLabel

var log_data: LogResource

func _ready():
	mouse_entered.connect(func(): if AudioManager: AudioManager.play_ui_hover())

func set_log_data(log: LogResource):
	log_data = log
	
	if time_label:
		time_label.text = log.timestamp
		
	if message_label:
		message_label.text = log.get_formatted_message()
		
	if status_dot:
		# Circle style
		status_dot.custom_minimum_size = Vector2(8, 8)
		if log.severity >= 4:
			status_dot.color = GlobalConstants.UI_COLORS.ERROR_FLAT
		elif log.severity >= 3:
			status_dot.color = GlobalConstants.UI_COLORS.WARNING_FLAT
		else:
			status_dot.color = GlobalConstants.UI_COLORS.INFO_BLUE

func set_zebra_style(is_even: bool):
	var style = get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	if style:
		if is_even:
			# Very subtle charcoal for zebra rows
			style.bg_color = Color(1, 1, 1, 0.02) 
		else:
			# Fully transparent for alternate rows
			style.bg_color = Color(0, 0, 0, 0)
		add_theme_stylebox_override("panel", style)

func _gui_input(event: InputEvent):
	# Restore selection on click, but DO NOT consume the event
	# This allows Godot to still see the click-and-hold for dragging
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if log_data:
			log_selected.emit(log_data, self)

func _get_drag_data(_at_position: Vector2):
	if not log_data: return null
	
	# Keep side-effect for drag start
	if AudioManager: AudioManager.play_ui_click()
	log_selected.emit(log_data, self)
	
	# Create high-visibility forensic drag preview
	var preview = PanelContainer.new()
	preview.z_index = 200 # Ensure it stays above all windows (Base is 10)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color.BLACK
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.2, 0.6, 1, 1) # Cyber Blue
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 5
	style.content_margin_bottom = 5
	preview.add_theme_stylebox_override("panel", style)
	
	var label = Label.new()
	label.text = "📎 EVIDENCE: " + log_data.log_id
	label.theme_type_variation = "HeaderSmall"
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_font_size_override("font_size", 11)
	preview.add_child(label)
	
	set_drag_preview(preview)
	
	if AudioManager: AudioManager.play_ui_hover()
	
	return {
		"type": "log_evidence",
		"log_id": log_data.log_id
	}

func set_highlight(active: bool):
	var style = get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	if style:
		if active:
			# Technical blue highlight for selected log
			style.bg_color = Color(0.2, 0.6, 1, 0.15)
			style.border_width_left = 3
			style.border_color = Color(0.2, 0.6, 1, 1)
		else:
			style.bg_color = Color(0, 0, 0, 0)
			style.border_width_left = 0
		add_theme_stylebox_override("panel", style)