# App_TicketQueue.gd
extends Control

var selected_ticket: TicketResource = null
var pool: UIObjectPool
var card_scene = preload("res://scenes/2d/apps/components/TicketCard.tscn")

# UI Elements
@onready var ticket_list: VBoxContainer = %TicketList
@onready var detail_view: VBoxContainer = %DetailView
@onready var placeholder_label: Label = %PlaceholderLabel
@onready var title_label: Label = %TitleLabel
@onready var description_label: RichTextLabel = %DescriptionLabel
@onready var steps_container: VBoxContainer = %StepsContainer
@onready var completion_modal: Control = %CompletionModal
@onready var required_tool_label: Label = %RequiredToolLabel


func _ready():
	print("======= App_TicketQueue._ready() =======")
	
	# Initialize Pool
	pool = UIObjectPool.new()
	add_child(pool)
	
	# Force visibility
	visible = true
	modulate = Color.WHITE

	# Initialize modal
	if completion_modal:
		completion_modal.completion_selected.connect(_on_completion_selected)
	
	# Wait a frame for the scene tree to be fully set up
	await get_tree().process_frame
	
	if not ticket_list:
		print("ERROR: Could not find TicketList node! App may not display correctly.")
		push_error("TicketList node missing in App_TicketQueue")
	else:
		print("DEBUG: TicketList found: ", ticket_list.name)
		# Ensure TicketList is properly configured
		ticket_list.visible = true
		ticket_list.mouse_filter = Control.MOUSE_FILTER_PASS
		# Set size flags - horizontal expand, vertical shrink (so it can scroll)
		ticket_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		ticket_list.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	
	# Connect signals
	EventBus.ticket_added.connect(_on_ticket_added)
	EventBus.ticket_completed.connect(_on_ticket_completed)
	EventBus.log_attached_to_ticket.connect(_on_log_attached)
	print("DEBUG: Connected to EventBus")
	
	# Load existing tickets
	await get_tree().process_frame
	_refresh_list()
	
	# Initialize detail view state
	_update_detail_view(null)
	
	print("======= App_TicketQueue Ready Complete =======")

# This function updates the detail panel with the selected ticket's info
func _update_detail_view(ticket: TicketResource):
	selected_ticket = ticket
	
	if not selected_ticket:
		# Show placeholder, hide details
		placeholder_label.visible = true
		detail_view.visible = false
	else:
		# Hide placeholder, show details
		placeholder_label.visible = false
		detail_view.visible = true
		
		# Update tool label visibility
		if required_tool_label:
			if selected_ticket.required_tool != "none" and selected_ticket.required_tool != "":
				required_tool_label.text = "REQUIRED TOOL: " + selected_ticket.required_tool.to_upper()
				required_tool_label.visible = true
			else:
				required_tool_label.visible = false
		
		# Populate labels
		title_label.text = "[%s] %s: %s" % [selected_ticket.severity.to_upper(), selected_ticket.ticket_id, selected_ticket.title]
		description_label.text = selected_ticket.description
		
		# Clear old steps
		for child in steps_container.get_children():
			child.queue_free()
		
		# Add new steps
		if selected_ticket.steps.is_empty():
			var no_steps_label = Label.new()
			no_steps_label.text = "No specific steps outlined."
			steps_container.add_child(no_steps_label)
		else:
			for i in range(selected_ticket.steps.size()):
				var step = selected_ticket.steps[i]
				var step_label = Label.new()
				step_label.text = "%d. %s" % [i + 1, step]

				steps_container.add_child(step_label)

func _on_ticket_added(ticket: TicketResource):
	if not ticket:
		print("WARNING: _on_ticket_added called with null ticket")
		return
		
	print("Adding ticket to queue: ", ticket.title)
	
	# Use Pool to acquire instance
	var card = pool.acquire(card_scene)
	
	if not card.card_selected.is_connected(_on_ticket_card_selected):
		card.card_selected.connect(_on_ticket_card_selected)
	if not card.completion_requested.is_connected(_on_ticket_completion_requested):
		card.completion_requested.connect(_on_ticket_completion_requested)
	
	# Add to list
	ticket_list.add_child(card)
	
	# Now that the card is in the tree, its _ready() has run, and @onready vars are initialized.
	card.set_ticket(ticket)
	
	# Ensure TicketList expands to fit content
	ticket_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	# Force update layout
	await get_tree().process_frame
	
	# Verify card is in the scene tree
	if card.is_inside_tree():
		card.queue_redraw()
		print("DEBUG: Card is in scene tree")
	else:
		print("ERROR: Card is NOT in scene tree!")
	
	print("TicketCard added to list: ", ticket.title)

func _on_ticket_card_selected(ticket: TicketResource, card_instance: Control):
	_update_detail_view(ticket)
	_highlight_card(card_instance)

func _on_ticket_completion_requested(ticket: TicketResource):
	if completion_modal:
		completion_modal.show_for_ticket(ticket)

func _on_completion_selected(completion_type: String):
	if completion_modal and completion_modal.current_ticket:
		var ticket_id = completion_modal.current_ticket.ticket_id
		print("DEBUG: Finalizing completion for ticket: ", ticket_id, " Type: ", completion_type)
		if TicketManager:
			TicketManager.complete_ticket(ticket_id, completion_type)

func _highlight_card(selected_card: Control):
	# Reset all cards to default style
	for child in ticket_list.get_children():
		if child is PanelContainer:
			var style = child.get_theme_stylebox("panel")
			if style:
				style = style.duplicate()
				style.bg_color = Color(0.07, 0.08, 0.15, 0.8) # Default
				style.border_color = Color(0.2, 0.22, 0.3, 1) # Default border
				child.add_theme_stylebox_override("panel", style)
	
	# Highlight the selected card
	if selected_card:
		var style = selected_card.get_theme_stylebox("panel")
		if style:
			style = style.duplicate()
			style.bg_color = Color(0.1, 0.15, 0.25, 0.9) # Highlighted
			style.border_color = Color(0.2, 1.0, 0.2, 1) # Cyber Green border
			selected_card.add_theme_stylebox_override("panel", style)

func _refresh_list():
	if not ticket_list:
		print("WARNING: Cannot refresh list - ticket_list is null")
		return
	
	# Clear selection and hide details
	selected_ticket = null
	_update_detail_view(null) # Clear detail view and show placeholder
		
	# Release all cards to pool
	pool.release_all(card_scene.resource_path)
	
	# Load active tickets from TicketManager
	if TicketManager and TicketManager.has_method("get_active_tickets"):
		var active_tickets = TicketManager.get_active_tickets()
		print("DEBUG: Refreshing list with ", active_tickets.size(), " active tickets")
		for ticket in active_tickets:
			_on_ticket_added(ticket)
	else:
		print("WARNING: TicketManager not available or missing get_active_tickets method")

func _on_ticket_completed(_ticket: TicketResource, _completion_type: String, _time_taken: float):
	# Refresh the list to remove completed ticket
	_refresh_list()

func _on_log_attached(_ticket_id: String, _log_id: String):
	# Refresh evidence display on ticket cards
	if ticket_list:
		for child in ticket_list.get_children():
			if child.has_method("_update_evidence_display"):
				child._update_evidence_display()