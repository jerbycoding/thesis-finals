# app_SIEMViewer.gd
extends Control

@onready var log_list: VBoxContainer = %LogList
@onready var attach_section: PanelContainer = %AttachSection
@onready var ticket_dropdown: OptionButton = %TicketDropdown
@onready var attach_button: Button = %AttachButton
@onready var log_detail_section: PanelContainer = %LogDetailSection
@onready var log_detail_label: RichTextLabel = %LogDetailLabel
@onready var filter_all: Button = %FilterAll
@onready var filter_security: Button = %FilterSecurity
@onready var filter_high_severity: Button = %FilterHighSeverity

var current_filter: String = "all"  # "all", "security", "high"
var selected_log: LogResource = null

func _ready():
	print("======= App_SIEMViewer._ready() =======")
	
	# Force visibility
	visible = true
	modulate = Color.WHITE
	
	# Wait a frame for the scene tree to be fully set up
	await get_tree().process_frame
	
	if not log_list:
		print("ERROR: Could not find LogList node! App may not display correctly.")
		push_error("LogList node missing in App_SIEMViewer")
	else:
		print("DEBUG: LogList found: ", log_list.name)
		# Ensure LogList is properly configured
		log_list.visible = true
		log_list.mouse_filter = Control.MOUSE_FILTER_PASS
		log_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		log_list.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	
	# Setup filter buttons
	_setup_filters()
	
	# Setup attach section
	_setup_attach_section()
	
	# Connect to LogSystem
	if LogSystem:
		LogSystem.log_added.connect(_on_log_added)
		print("DEBUG: Connected to LogSystem")
	
	# Connect to TicketManager
	if TicketManager:
		TicketManager.ticket_added.connect(_on_ticket_added)
		TicketManager.log_attached.connect(_on_log_attached)
	
	# Load existing logs
	await get_tree().process_frame
	_refresh_logs()
	_refresh_ticket_dropdown()
	
	print("======= App_SIEMViewer Ready Complete =======")

func _setup_filters():
	if filter_all:
		filter_all.pressed.connect(_on_filter_all)
	if filter_security:
		filter_security.pressed.connect(_on_filter_security)
	if filter_high_severity:
		filter_high_severity.pressed.connect(_on_filter_high)

func _on_filter_all():
	current_filter = "all"
	_refresh_logs()

func _on_filter_security():
	current_filter = "security"
	_refresh_logs()

func _on_filter_high():
	current_filter = "high"
	_refresh_logs()

func _refresh_logs():
	if not log_list:
		print("WARNING: Cannot refresh logs - log_list is null")
		return
	
	# Clear selection and hide details
	selected_log = null
	if attach_section:
		attach_section.visible = false
	if log_detail_section:
		log_detail_section.visible = false
	
	# Clear existing logs
	for child in log_list.get_children():
		child.queue_free()
	
	# Get logs based on filter
	var logs_to_show: Array[LogResource] = []
	
	if LogSystem:
		match current_filter:
			"all":
				logs_to_show = LogSystem.get_all_logs()
			"security":
				logs_to_show = LogSystem.get_logs_by_category("Security")
			"high":
				logs_to_show = LogSystem.get_logs_by_severity(4)  # High and Critical
			_:
				logs_to_show = LogSystem.get_all_logs()
	else:
		print("WARNING: LogSystem not available")
	
	print("DEBUG: Refreshing logs with filter: ", current_filter, " - ", logs_to_show.size(), " logs")
	
	# Sort logs by timestamp (newest first)
	logs_to_show.sort_custom(func(a, b): return a.timestamp > b.timestamp)
	
	# Add logs to list
	for log in logs_to_show:
		_add_log_entry(log)

func _on_log_added(log: LogResource):
	print("New log added: ", log.log_id)
	_refresh_logs()

func _add_log_entry(log: LogResource):
	if not log or not log_list:
		return
	
	# Create log entry UI
	var entry = _create_log_entry(log)
	log_list.add_child(entry)
	
	# Ensure entry expands horizontally
	entry.size_flags_horizontal = Control.SIZE_EXPAND_FILL

func _create_log_entry(log: LogResource) -> Control:
	# Create a container for the log entry
	var container = PanelContainer.new()
	container.custom_minimum_size = Vector2(0, 45) # Reduced height for higher density
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# Set background color based on severity
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.12, 0.18, 0.8)
	style.border_width_left = 4 # Slightly thicker border for better visibility
	style.border_color = log.get_severity_color()
	container.add_theme_stylebox_override("panel", style)
	
	# Create horizontal layout
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)
	container.add_child(hbox)
	
	# Timestamp
	var time_label = Label.new()
	time_label.text = " " + log.timestamp # Add leading space for alignment
	time_label.custom_minimum_size = Vector2(80, 0)
	time_label.add_theme_font_size_override("font_size", 11)
	time_label.tooltip_text = "Recorded: " + log.timestamp
	time_label.mouse_filter = Control.MOUSE_FILTER_PASS
	hbox.add_child(time_label)
	
	# Source
	var source_label = Label.new()
	source_label.text = log.source
	source_label.custom_minimum_size = Vector2(120, 0)
	source_label.add_theme_font_size_override("font_size", 11)
	source_label.tooltip_text = "Origin: " + log.source
	source_label.mouse_filter = Control.MOUSE_FILTER_PASS
	hbox.add_child(source_label)
	
	# Severity badge
	var severity_label = Label.new()
	severity_label.text = log.get_severity_text()
	severity_label.custom_minimum_size = Vector2(70, 0)
	severity_label.add_theme_font_size_override("font_size", 10)
	severity_label.add_theme_color_override("font_color", log.get_severity_color())
	severity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	severity_label.tooltip_text = "Severity Level: " + str(log.severity)
	severity_label.mouse_filter = Control.MOUSE_FILTER_PASS
	hbox.add_child(severity_label)
	
	# Message (truncated)
	var message_label = Label.new()
	var message_text = log.message
	if message_text.length() > 60:
		message_text = message_text.substr(0, 57) + "..."
	message_label.text = message_text
	message_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	message_label.add_theme_font_size_override("font_size", 11)
	message_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	message_label.tooltip_text = log.message # Show full message on hover
	message_label.mouse_filter = Control.MOUSE_FILTER_PASS
	hbox.add_child(message_label)
	
	# Make clickable
	container.mouse_filter = Control.MOUSE_FILTER_PASS
	container.gui_input.connect(_on_log_entry_clicked.bind(log, container))
	
	return container

func _on_log_entry_clicked(event: InputEvent, log: LogResource, container: Control):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# Select this log
		selected_log = log
		print("DEBUG: Log selected: ", log.log_id)
		
		# Visual feedback - highlight selected
		_highlight_selected_log(container)
		
		# Show attach button or detail view
		_show_log_details(log)

func _highlight_selected_log(selected_container: Control):
	# Reset all entries
	for child in log_list.get_children():
		if child is PanelContainer:
			var style = child.get_theme_stylebox("panel")
			if style:
				style.bg_color = Color(0.1, 0.12, 0.18, 0.8)
	
	# Highlight selected
	if selected_container:
		var style = selected_container.get_theme_stylebox("panel")
		if style:
			style.bg_color = Color(0.2, 0.25, 0.35, 0.9)

func _setup_attach_section():
	if attach_section:
		attach_section.visible = false
	if log_detail_section:
		log_detail_section.visible = false
	
	if attach_button:
		attach_button.pressed.connect(_on_attach_button_pressed)
	
	if ticket_dropdown:
		ticket_dropdown.item_selected.connect(_on_ticket_selected)

func _show_log_details(log: LogResource):
	# Show attach section when log is selected
	if attach_section:
		attach_section.visible = true
		_refresh_ticket_dropdown()

	# Show and populate the log detail section
	if log_detail_section and log_detail_label:
		log_detail_section.visible = true
		
		var details_text = ""
		details_text += "[b]Timestamp:[/b] %s\n" % log.timestamp
		details_text += "[b]Severity:[/b] [color=%s]%s[/color]\n" % [log.get_severity_color().to_html(), log.get_severity_text()]
		details_text += "[b]Source:[/b] %s\n" % log.source
		if not log.ip_address.is_empty():
			details_text += "[b]IP Address:[/b] %s\n" % log.ip_address
		if not log.hostname.is_empty():
			details_text += "[b]Hostname:[/b] %s\n" % log.hostname
		
		details_text += "\n[b]Message:[/b]\n%s" % log.message
		
		log_detail_label.text = details_text

func _refresh_ticket_dropdown():
	if not ticket_dropdown:
		return
	
	ticket_dropdown.clear()
	ticket_dropdown.add_item("Select Ticket...")
	
	if TicketManager:
		var active_tickets = TicketManager.get_active_tickets()
		for ticket in active_tickets:
			var display_text = ticket.ticket_id + ": " + ticket.title
			ticket_dropdown.add_item(display_text)

func _on_ticket_selected(index: int):
	# Ticket selected from dropdown
	if index == 0:
		return  # "Select Ticket..." placeholder

func _on_attach_button_pressed():
	if not selected_log:
		print("⚠ No log selected")
		return
	
	var selected_index = ticket_dropdown.selected
	if selected_index <= 0:
		print("⚠ No ticket selected")
		return
	
	if not TicketManager:
		print("⚠ TicketManager not available")
		return
	
	# Get selected ticket
	var active_tickets = TicketManager.get_active_tickets()
	if selected_index - 1 >= active_tickets.size():
		print("⚠ Invalid ticket selection")
		return
	
	var ticket = active_tickets[selected_index - 1]
	
	# Attach log to ticket
	if TicketManager.attach_log_to_ticket(ticket.ticket_id, selected_log.log_id):
		print("✓ Log attached successfully!")
		if NotificationManager:
			NotificationManager.show_notification("✓ Log attached to " + ticket.ticket_id, "success", 3.0)
		# Hide attach section
		if attach_section:
			attach_section.visible = false
		selected_log = null
	else:
		print("⚠ Failed to attach log")
		if NotificationManager:
			NotificationManager.show_notification("⚠ Log already attached", "warning", 3.0)

func _on_ticket_added(ticket: TicketResource):
	_refresh_ticket_dropdown()

func _on_log_attached(ticket_id: String, log_id: String):
	print("DEBUG: Log attached signal received: ", log_id, " -> ", ticket_id)
	# Could refresh UI here if needed
