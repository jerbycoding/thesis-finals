extends PanelContainer

signal card_selected(ticket: TicketResource, card_instance: Control)
signal completion_requested(ticket: TicketResource)

@onready var title_label: Label = %TitleLabel
@onready var severity_label: Label = %SeverityLabel
@onready var time_label: Label = %TimeLabel
@onready var evidence_label: Label = %EvidenceLabel
@onready var complete_button: Button = %CompleteButton

var ticket: TicketResource
var update_timer: Timer

func _ready():
	# Ensure card is visible
	visible = true
	modulate = Color.WHITE
	
	# Setup completion button
	if complete_button:
		complete_button.pressed.connect(_on_complete_pressed)
	
	# Audio feedback
	mouse_entered.connect(func(): if AudioManager: AudioManager.play_ui_hover())
	
	# Ensure the card is clickable
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Optimization: Use a timer instead of _process
	update_timer = Timer.new()
	update_timer.wait_time = 1.0
	update_timer.timeout.connect(_on_update_timer_timeout)
	add_child(update_timer)
	update_timer.start()

func _on_update_timer_timeout():
	if ticket and is_instance_valid(ticket):
		_update_time_display()
		_update_evidence_display()

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if AudioManager: AudioManager.play_ui_click()
		if ticket:
			card_selected.emit(ticket, self)
		get_viewport().set_input_as_handled()

func set_ticket(t: TicketResource):
	if not t:
		print("ERROR: set_ticket called with null ticket")
		return
	
	ticket = t
	
	# Set text content using @onready variables
	title_label.text = t.get_formatted_title()
	severity_label.text = t.severity
	_update_time_display()
	_update_evidence_display()
	
	# Ensure labels are visible
	title_label.visible = true
	severity_label.visible = true
	time_label.visible = true
	if evidence_label:
		evidence_label.visible = true
	
	# Set severity color
	match t.severity:
		"Low":
			severity_label.add_theme_color_override("font_color", Color.GREEN)
		"Medium":
			severity_label.add_theme_color_override("font_color", Color.YELLOW)
		"High":
			severity_label.add_theme_color_override("font_color", Color.ORANGE)
		"Critical":
			severity_label.add_theme_color_override("font_color", Color.RED)
		_:
			severity_label.add_theme_color_override("font_color", Color.WHITE)
	
	print("DEBUG: TicketCard set_ticket complete - Title: ", title_label.text, " Visible: ", visible)

func _update_time_display():
	if not ticket or not time_label:
		return
		
	# Calculate remaining time from expiry timestamp
	var current_time = Time.get_ticks_msec()
	var remaining_msec = max(0, ticket.expiry_timestamp - current_time)
	var remaining_time = remaining_msec / 1000.0
	
	var total_seconds = int(remaining_time)
	var minutes = total_seconds / 60
	var seconds = total_seconds % 60
	
	# Format: "MM:SS" or "X min Y sec" or just "X sec"
	if minutes > 0:
		time_label.text = "%d:%02d" % [minutes, seconds]
	else:
		time_label.text = "%d sec" % int(remaining_time)
	
	# Change color based on remaining time
	if remaining_time < 30:
		time_label.add_theme_color_override("font_color", Color.RED)
	elif remaining_time < 60:
		time_label.add_theme_color_override("font_color", Color.ORANGE)
	else:
		time_label.add_theme_color_override("font_color", Color.WHITE)

func _update_evidence_display():
	if not ticket or not evidence_label:
		return
	
	var evidence = ticket.get_evidence_count()
	var attached = evidence.attached
	var required = evidence.required
	
	if required > 0:
		evidence_label.text = "Evidence: %d/%d" % [attached, required]
		# Color code: green if complete, yellow if partial, red if none
		if attached >= required:
			evidence_label.add_theme_color_override("font_color", Color.GREEN)
		elif attached > 0:
			evidence_label.add_theme_color_override("font_color", Color.YELLOW)
		else:
			evidence_label.add_theme_color_override("font_color", Color.WHITE)
	else:
		evidence_label.text = "Evidence: %d" % attached
		evidence_label.add_theme_color_override("font_color", Color.WHITE)

func _on_complete_pressed():
	print("DEBUG: Complete button pressed for ticket: ", ticket.ticket_id)
	if AudioManager:
		AudioManager.play_sfx(AudioManager.SFX.button_click)
	
	# Instead of showing a local modal, we tell the app to show it
	completion_requested.emit(ticket)
