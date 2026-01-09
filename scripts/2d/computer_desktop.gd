# computer_desktop.gd
extends Control

# Desktop app management
signal app_opened(app_name: String, window_id: String)
signal app_closed(app_name: String, window_id: String)

var open_windows: Dictionary = {}  # window_id: WindowFrame
var next_window_position: Vector2 = Vector2(50, 50)
var window_z_index_base: int = 10
var current_ticket_notification: String = ""
var focused_window: Control = null

const APP_PATHS: Dictionary = {
	"tickets": "res://scenes/2d/apps/App_TicketQueue.tscn",
	"siem": "res://scenes/2d/apps/App_SIEMViewer.tscn",
	"email": "res://scenes/2d/apps/App_EmailAnalyzer.tscn",
	"terminal": "res://scenes/2d/apps/App_Terminal.tscn"
}

const APP_TITLES: Dictionary = {
	"tickets": "Ticket Queue",
	"siem": "SIEM Log Viewer", 
	"email": "Email Analyzer",
	"terminal": "Terminal"
}

const APP_SIZES: Dictionary = {
	"tickets": Vector2(500, 600),
	"siem": Vector2(750, 550),
	"email": Vector2(900, 700),
	"terminal": Vector2(650, 450)
}

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
	# Close all open app windows to clear the desktop
	for window_id in open_windows:
		var window = open_windows[window_id]
		if is_instance_valid(window):
			window.queue_free()
	open_windows.clear()

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
	open_app(app_name)

func open_app(app_name: String, force_new: bool = false):
	print("DEBUG: open_app called for: ", app_name, " (force_new: ", force_new, ")")
	print("DEBUG: Currently open windows: ", open_windows.keys())
	
	if app_name not in APP_PATHS:
		print("ERROR: Unknown app: ", app_name)
		return
	
	# Check if already open (only if not forcing new instance)
	if not force_new:
		var existing_window = _find_window_by_app(app_name)
		if existing_window and is_instance_valid(existing_window):
			print("App already open, focusing and bringing to front")
			_focus_window(existing_window)
			existing_window.bring_to_front()
			return
		else:
			print("DEBUG: No existing window found for app: ", app_name)
	
	# Generate unique window ID
	var window_id = app_name + "_" + str(Time.get_ticks_msec())
	
	# Load window frame
	var window_scene = preload("res://scenes/2d/apps/components/WindowFrame.tscn")
	var window = window_scene.instantiate()
	
	# Set window properties
	window.window_id = window_id
	window.set_title(APP_TITLES.get(app_name, app_name.capitalize()))
	window.position = _get_next_window_position()
	
	# Set window size based on app type
	var app_size = APP_SIZES.get(app_name, Vector2(600, 400)) # Default size
	window.custom_minimum_size = app_size
	window.size = app_size
	
	# Connect window signals
	window.window_focused.connect(_on_window_focused)
	window.window_closed.connect(_on_window_closed)
	
	# Add to container - use safer node access
	var container = get_node_or_null("ColorRect/AppWindowContainer")
	if not container:
		print("ERROR: AppWindowContainer not found! Cannot add window.")
		window.queue_free()
		return
	
	container.add_child(window)
	print("DEBUG: Window added to container: ", container.name)
	
	# Wait for window to be ready - use call_deferred to ensure it's in the scene tree first
	# Then wait for the next frame to ensure all nodes are initialized
	await get_tree().process_frame
	print("DEBUG: Frame processed, window should be ready now")
	
	# Double-check window is valid
	if not is_instance_valid(window):
		print("ERROR: Window became invalid after adding to tree!")
		return
	
	# Load app content
	var app_scene_path = APP_PATHS[app_name]
	print("DEBUG: App scene path: ", app_scene_path)
	
	if ResourceLoader.exists(app_scene_path):
		print("DEBUG: App scene exists, loading...")
		var app_scene = load(app_scene_path)
		if app_scene:
			print("DEBUG: App scene loaded successfully, calling load_content")
			window.load_content(app_scene)
			# Wait a frame to ensure content is loaded
			await get_tree().process_frame
			print("DEBUG: App content should now be loaded")
		else:
			print("ERROR: Failed to load app scene resource - load() returned null")
			# Create placeholder
			var placeholder = Label.new()
			placeholder.text = app_name.capitalize() + " (Failed to Load)"
			placeholder.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			placeholder.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			if window.content_container:
				window.content_container.add_child(placeholder)
			else:
				print("ERROR: window.content_container is also null!")
	else:
		print("ERROR: App scene not found at path: ", app_scene_path)
		# Create placeholder
		var placeholder = Label.new()
		placeholder.text = app_name.capitalize() + " (Scene Not Found)"
		placeholder.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		placeholder.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		if window.content_container:
			window.content_container.add_child(placeholder)
		else:
			print("ERROR: window.content_container is null, cannot add placeholder!")
	
	# Store reference
	open_windows[window_id] = window
	print("DEBUG: Window stored in open_windows. Total windows: ", open_windows.size())
	
	# Update next position (stagger)
	next_window_position += Vector2(30, 30)
	if next_window_position.x > 300:
		next_window_position.x = 50
	if next_window_position.y > 200:
		next_window_position.y = 50
	
	# Focus the new window
	_focus_window(window)
	window.bring_to_front()
	
	# Emit signal
	app_opened.emit(app_name, window_id)
	
	print("DEBUG: Opened app: ", app_name, " at position: ", window.position)

func _find_window_by_app(app_name: String) -> Control:
	for window_id in open_windows:
		var window = open_windows[window_id]
		# Check if window is still valid
		if not is_instance_valid(window):
			# Clean up invalid window reference
			open_windows.erase(window_id)
			continue
		# Check if this window belongs to the app
		if window_id.begins_with(app_name + "_"):
			return window
	return null

func _get_next_window_position() -> Vector2:
	return next_window_position

func _on_window_focused(window: Control):
	print("Window focused: ", window.window_id)
	focused_window = window
	
	# Update z-index for all windows - bring focused to front
	var current_z = window_z_index_base
	for window_id in open_windows:
		var other_window = open_windows[window_id]
		if is_instance_valid(other_window):
			if other_window == window:
				# Focused window gets highest z-index
				other_window.z_index = window_z_index_base + 100
			else:
				# Other windows get lower z-index
				other_window.z_index = window_z_index_base + current_z
				current_z += 1
	
	# Also call bring_to_front for visual consistency
	if is_instance_valid(window):
		window.bring_to_front()

func _on_window_closed(window: Control):
	if not window or not is_instance_valid(window):
		print("WARNING: Window closed callback received for invalid window")
		return
		
	var window_id = window.window_id
	if window_id.is_empty():
		print("WARNING: Window closed but has no window_id")
		return
		
	var app_name = window_id.split("_")[0]
	
	# Remove from tracking
	if window_id in open_windows:
		open_windows.erase(window_id)
		print("Removed window from tracking: ", window_id)
	
	# Update focused window
	if focused_window == window:
		focused_window = null
	
	# Emit signal
	app_closed.emit(app_name, window_id)
	
	print("Closed window: ", window_id, " (", open_windows.size(), " windows remaining)")
	
	# If no windows open, reset position
	if open_windows.is_empty():
		next_window_position = Vector2(50, 50)

func _focus_window(window: Control):
	if window:
		window.z_index = window_z_index_base + 100
		focused_window = window

func close_app(app_name: String, window_id: String = ""):
	if window_id and window_id in open_windows:
		open_windows[window_id].queue_free()
		open_windows.erase(window_id)
	elif not window_id:
		# Close all windows for this app
		var windows_to_close = []
		for wid in open_windows:
			if wid.begins_with(app_name):
				windows_to_close.append(wid)
		
		for wid in windows_to_close:
			open_windows[wid].queue_free()
			open_windows.erase(wid)

func _on_ticket_added(ticket_data: TicketResource):
	print("New ticket in queue: ", ticket_data.title)
	current_ticket_notification = "New Ticket: " + ticket_data.title
	
	# Auto-open tickets app if not open
	if not _find_window_by_app("tickets"):
		print("Auto-opening Ticket Queue for new ticket")
		open_app("tickets")

func _on_ticket_completed(ticket: TicketResource, completion_type: String, time_taken: float):
	print("Ticket completed: ", ticket.ticket_id, " as ", completion_type)
	current_ticket_notification = ""

func get_open_apps() -> Array:
	var apps = []
	for window_id in open_windows:
		var app_name = window_id.split("_")[0]
		if app_name not in apps:
			apps.append(app_name)
	return apps

func has_open_apps() -> bool:
	return open_windows.size() > 0

func get_window_count() -> int:
	# Clean up invalid references first
	_cleanup_invalid_windows()
	return open_windows.size()

func _cleanup_invalid_windows():
	# Remove any invalid window references
	var invalid_windows = []
	for window_id in open_windows:
		var window = open_windows[window_id]
		if not is_instance_valid(window):
			invalid_windows.append(window_id)
	
	for window_id in invalid_windows:
		open_windows.erase(window_id)
		print("Cleaned up invalid window reference: ", window_id)

func _input(event):
	# Close focused window with Escape
	if event.is_action_pressed("ui_cancel") and focused_window:
		if is_instance_valid(focused_window):
			# Properly close the window through its close handler
			if focused_window.has_method("_on_close_pressed"):
				focused_window._on_close_pressed()
			else:
				focused_window.queue_free()
		get_viewport().set_input_as_handled()
