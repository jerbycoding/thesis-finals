# computer_desktop.gd
extends Control

# Desktop app management
signal app_opened(app_name: String, window_id: String)
signal app_closed(app_name: String, window_id: String)

var shift_report_scene = preload("res://scenes/2d/apps/App_ShiftReport.tscn")

func _ready():
	# Set as top layer
	z_index = 10
	visible = true
	
	# Verify window container exists
	var container = get_node_or_null("ColorRect/AppWindowContainer")
	if not container:
		print("ERROR: AppWindowContainer node not found in scene tree!")
		push_error("AppWindowContainer is missing - windows cannot be created")
	else:
		print("DesktopManager ready - Window container found: ", container.name)
		# Ensure container is set up correctly
		container.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Allow clicks to pass through to windows
	
	# Connect app icons
	_setup_app_connections()
	
	# Connect to game systems
	if TicketManager:
		TicketManager.ticket_added.connect(_on_ticket_added)
		TicketManager.ticket_completed.connect(_on_ticket_completed)
	
	# Set desktop instance for NotificationManager
	if NotificationManager:
		NotificationManager.set_desktop(self)
	
	print("DesktopManager ready - Window system active")

func close_all_windows():
	if DesktopWindowManager:
		DesktopWindowManager.close_all_windows()

func _setup_app_connections():
	print("Setting up app connections...")
	
	# Connect all icon buttons
	var icons = [
		"SIEM_Icon",
		"Email_Icon", 
		"Terminal_Icon",
		"Tickets_Icon"
	]
	
	for icon_name in icons:
		var button = get_node("ColorRect/AppLauncher/" + icon_name)
		if button:
			button.mouse_filter = Control.MOUSE_FILTER_PASS
			
			# Get app name from icon name
			var app_name = icon_name.to_lower().replace("_icon", "")
			
			# Connect signal (disconnect first if already connected)
			if button.pressed.is_connected(_on_app_icon_pressed):
				button.pressed.disconnect(_on_app_icon_pressed)
			
			button.pressed.connect(_on_app_icon_pressed.bind(app_name))
			print("Connected icon: ", icon_name, " -> ", app_name)

func _on_app_icon_pressed(app_name: String):
	print("DEBUG: App icon pressed: ", app_name)
	if DesktopWindowManager:
		DesktopWindowManager.open_app(app_name)

func _on_ticket_added(ticket_data: TicketResource):
	print("New ticket in queue: ", ticket_data.title)
	
	# Auto-open tickets app if not open
	if DesktopWindowManager and not DesktopWindowManager._find_window_by_app("tickets"):
		print("Auto-opening Ticket Queue for new ticket")
		DesktopWindowManager.open_app("tickets")

func _on_ticket_completed(ticket: TicketResource, completion_type: String, time_taken: float):
	print("Ticket completed: ", ticket.ticket_id, " as ", completion_type)

func _input(event):
	# Close focused window with Escape
	if DesktopWindowManager and event.is_action_pressed("ui_cancel") and DesktopWindowManager.focused_window:
		var focused_window = DesktopWindowManager.focused_window
		if is_instance_valid(focused_window):
			# Properly close the window through its close handler
			if focused_window.has_method("_on_close_pressed"):
				focused_window._on_close_pressed()
			else:
				focused_window.queue_free()
		get_viewport().set_input_as_handled()
