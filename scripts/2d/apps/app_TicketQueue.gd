# Updated App_TicketQueue.gd
extends Control

var ticket_list: VBoxContainer = null
var selected_ticket: TicketResource = null

# Detail Panel Elements
@onready var detail_view: VBoxContainer = $ColorRect/VBoxContainer/HBoxContainer/DetailPanel/MarginContainer/DetailView
@onready var placeholder_label: Label = $ColorRect/VBoxContainer/HBoxContainer/DetailPanel/MarginContainer/PlaceholderLabel
@onready var title_label: Label = $ColorRect/VBoxContainer/HBoxContainer/DetailPanel/MarginContainer/DetailView/TitleLabel
@onready var description_label: RichTextLabel = $ColorRect/VBoxContainer/HBoxContainer/DetailPanel/MarginContainer/DetailView/DescriptionLabel
@onready var steps_container: VBoxContainer = $ColorRect/VBoxContainer/HBoxContainer/DetailPanel/MarginContainer/DetailView/StepsContainer


func _ready():
	print("======= App_TicketQueue._ready() =======")
	
	# Force visibility
	visible = true
	modulate = Color.WHITE

	
	# Wait a frame for the scene tree to be fully set up
	await get_tree().process_frame
	
	# Get ticket_list node safely
	ticket_list = get_node_or_null("ColorRect/VBoxContainer/HBoxContainer/ScrollContainer/TicketList")
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
		print("DEBUG: TicketList configured - visible: ", ticket_list.visible, " size flags: ", ticket_list.size_flags_horizontal, "/", ticket_list.size_flags_vertical)
	
	if has_node("ColorRect"):
		$ColorRect.color = Color(0.07, 0.08, 0.15, 0.95)
	
	# Ensure ScrollContainer is properly sized
	var scroll_container = get_node_or_null("ColorRect/VBoxContainer/HBoxContainer/ScrollContainer")
	if scroll_container:
		scroll_container.visible = true
		scroll_container.mouse_filter = Control.MOUSE_FILTER_PASS
		scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
		# Enable scrolling
		scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		scroll_container.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
		print("DEBUG: ScrollContainer configured")
	
	# Connect signals
	if TicketManager:
		TicketManager.ticket_added.connect(_on_ticket_added)
		TicketManager.ticket_completed.connect(_on_ticket_completed)
		TicketManager.log_attached.connect(_on_log_attached)
		print("DEBUG: Connected to TicketManager")
	
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
		
		# Populate labels
		title_label.text = "[%s] %s: %s" % [selected_ticket.severity.to_upper(), selected_ticket.ticket_id, selected_ticket.title]
		description_label.text = selected_ticket.description
		
		# Clear old steps
		for child in steps_container.get_children():
			child.queue_free()
		
		# Add new steps
		# if selected_ticket.steps.is_empty():
		# 	var no_steps_label = Label.new()
		# 	no_steps_label.text = "No specific steps outlined."
		# 	steps_container.add_child(no_steps_label)
		# else:
		# 	for i in range(selected_ticket.steps.size()):
		# 		var step = selected_ticket.steps[i]
		# 		var step_label = Label.new()
		# 		step_label.text = "%d. %s" % [i + 1, step]

		# 		steps_container.add_child(step_label)

func _on_ticket_added(ticket: TicketResource):
	if not ticket:
		print("WARNING: _on_ticket_added called with null ticket")
		return
		
	print("Adding ticket to queue: ", ticket.title)
	
	var card_scene = preload("res://scenes/2d/apps/components/TicketCard.tscn")
	if not card_scene:
		print("ERROR: Cannot load TicketCard.tscn")
		return
		
	var card = card_scene.instantiate()
	if not card:
		print("ERROR: Failed to instantiate TicketCard")
		return
		
	if not card.has_method("set_ticket"):
		print("ERROR: TicketCard missing set_ticket method")
		card.queue_free()
		return
		
	card.card_selected.connect(_on_ticket_card_selected)
	
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
	print("DEBUG: Card visible: ", card.visible, " size: ", card.size, " position: ", card.position)
	print("DEBUG: TicketList children count: ", ticket_list.get_child_count())
	print("DEBUG: TicketList size: ", ticket_list.size)
	
	# Check ScrollContainer
	var scroll_container = ticket_list.get_parent()
	if scroll_container:
		print("DEBUG: ScrollContainer size: ", scroll_container.size)
		print("DEBUG: ScrollContainer visible: ", scroll_container.visible)

func _on_ticket_card_selected(ticket: TicketResource, card_instance: Control):
	_update_detail_view(ticket)
	_highlight_card(card_instance)

func _highlight_card(selected_card: Control):
	# Reset all cards to default style
	for child in ticket_list.get_children():
		if child is PanelContainer: # TicketCard is a PanelContainer
			var style = child.get_theme_stylebox("panel")
			if style:
				style = style.duplicate() # Duplicate the style to make it unique for this instance
				style.bg_color = Color(0.1, 0.12, 0.18, 1) # Default color from TicketCard.tscn
				style.border_color = Color(0.2, 0.22, 0.3, 1) # Default border color
				child.add_theme_stylebox_override("panel", style)
	
	# Highlight the selected card
	if selected_card:
		var style = selected_card.get_theme_stylebox("panel")
		if style:
			style = style.duplicate() # Duplicate the style to make it unique for this instance
			style.bg_color = Color(0.2, 0.25, 0.35, 1) # Highlighted background
			style.border_color = Color(0.8, 0.8, 0.2, 1) # Yellow border for highlight
			selected_card.add_theme_stylebox_override("panel", style)

func _refresh_list():
	if not ticket_list:
		print("WARNING: Cannot refresh list - ticket_list is null")
		return
	
	# Clear selection and hide details
	selected_ticket = null
	_update_detail_view(null) # Clear detail view and show placeholder
		
	# Clear existing tickets
	for child in ticket_list.get_children():
		child.queue_free()
	
	# Load active tickets from TicketManager
	if TicketManager and TicketManager.has_method("get_active_tickets"):
		var active_tickets = TicketManager.get_active_tickets()
		print("DEBUG: Refreshing list with ", active_tickets.size(), " active tickets")
		for ticket in active_tickets:
			_on_ticket_added(ticket)
	else:
		print("WARNING: TicketManager not available or missing get_active_tickets method")

func _on_ticket_completed(ticket: TicketResource, completion_type: String, time_taken: float):
	print("Ticket completed: ", ticket.ticket_id, " - Type: ", completion_type)
	# Refresh the list to remove completed ticket
	_refresh_list()

func _on_log_attached(ticket_id: String, log_id: String):
	print("Log attached to ticket: ", ticket_id, " - Log: ", log_id)
	# Refresh evidence display on ticket cards
	# Find the ticket card and update its evidence display
	if ticket_list:
		for child in ticket_list.get_children():
			if child.has_method("_update_evidence_display"):
				child._update_evidence_display()
