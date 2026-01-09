extends PanelContainer

signal card_selected(ticket: TicketResource, card_instance: Control)

@onready var title_label: Label = $MarginContainer/VBoxContainer/TitleLabel
@onready var severity_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/SeverityLabel
@onready var time_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/TimeLabel
@onready var evidence_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/EvidenceLabel
@onready var complete_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/CompleteButton

var ticket: TicketResource
# var time_node: Label = null # REMOVED
var completion_modal: AcceptDialog = null

func _ready():
	# Ensure card is visible
	visible = true
	modulate = Color.WHITE
	custom_minimum_size = Vector2(400, 80)
	
	# Setup completion button
	if complete_button:
		complete_button.pressed.connect(_on_complete_pressed)
	
	# Load completion modal
	var modal_scene = preload("res://scenes/2d/apps/components/CompletionModal.tscn")
	if modal_scene:
		completion_modal = modal_scene.instantiate()
		add_child(completion_modal)
		completion_modal.completion_selected.connect(_on_completion_selected)
	
	# Ensure the card is clickable
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	print("DEBUG: TicketCard _ready() - visible: ", visible, " size: ", size)

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if ticket:
			card_selected.emit(ticket, self)
		get_viewport().set_input_as_handled()

func set_ticket(t: TicketResource):
	if not t:
		print("ERROR: set_ticket called with null ticket")
		return
	
	ticket = t
	
	# Set text content using @onready variables
	title_label.text = t.title
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

func _process(delta):
	if ticket and time_label and is_instance_valid(ticket):
		# Update ticket time from TicketManager if available
		if TicketManager:
			var active_ticket = TicketManager.get_ticket_by_id(ticket.ticket_id)
			if active_ticket:
				ticket.base_time = active_ticket.base_time
			else:
				# Ticket is no longer active, stop processing to prevent warnings.
				set_process(false)
				return
		_update_time_display()
		_update_evidence_display()

func _update_time_display():
	if not ticket or not time_label:
		return
		
	var remaining_time = max(0, ticket.base_time)
	var total_seconds = int(remaining_time)
	var minutes = total_seconds / 60  # In GDScript 4.x, use // for integer division, but / works with int
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
	if completion_modal and ticket:
		completion_modal.show_for_ticket(ticket)
	else:
		print("ERROR: Cannot show completion modal - modal or ticket is null")

func _on_completion_selected(completion_type: String):
	print("DEBUG: Completion type selected: ", completion_type, " for ticket: ", ticket.ticket_id)
	if TicketManager and ticket:
		TicketManager.complete_ticket(ticket.ticket_id, completion_type)
		# The ticket will be removed from the queue by TicketManager
		# The card will be cleaned up when the ticket list refreshes
