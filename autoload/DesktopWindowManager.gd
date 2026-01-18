# DesktopWindowManager.gd
# Autoload singleton to manage desktop application windows.
extends Node

var open_windows: Dictionary = {}  # window_id: WindowFrame
var next_window_position: Vector2 = Vector2(50, 50)
var window_z_index_base: int = 10
var focused_window: Control = null
var window_container: CanvasLayer = null

# App configuration dictionaries (moved from computer_desktop.gd)
const APP_PATHS: Dictionary = {
	"tickets": "res://scenes/2d/apps/App_TicketQueue.tscn",
	"siem": "res://scenes/2d/apps/App_SIEMViewer.tscn",
	"email": "res://scenes/2d/apps/App_EmailAnalyzer.tscn",
	"terminal": "res://scenes/2d/apps/App_Terminal.tscn",
	"handbook": "res://scenes/2d/apps/App_Handbook.tscn",
	"taskmanager": "res://scenes/2d/apps/App_TaskManager.tscn",
	"network": "res://scenes/2d/apps/App_NetworkMapper.tscn",
	"decryption": "res://scenes/2d/apps/App_Decryption.tscn"
}

const APP_TITLES: Dictionary = {
	"tickets": "Ticket Queue",
	"siem": "SIEM Log Viewer", 
	"email": "Email Analyzer",
	"terminal": "Terminal",
	"handbook": "SOC Handbook",
	"taskmanager": "Task Manager",
	"network": "Network Topology",
	"decryption": "Decryption Tool"
}

const APP_SIZES: Dictionary = {
	"tickets": Vector2(500, 600),
	"siem": Vector2(750, 550),
	"email": Vector2(900, 700),
	"terminal": Vector2(650, 450),
	"handbook": Vector2(700, 500),
	"taskmanager": Vector2(600, 400),
	"network": Vector2(800, 600),
	"decryption": Vector2(700, 500)
}

var window_frame_scene = preload("res://scenes/2d/apps/components/WindowFrame.tscn")

func _ready():
	# Create a persistent CanvasLayer for windows to ensure they stay on top
	window_container = CanvasLayer.new()
	window_container.name = "DesktopWindowLayer"
	window_container.layer = 10 # Higher than main scene and desktop background
	get_tree().root.call_deferred("add_child", window_container)
	
	# Connect to EventBus for global window management
	EventBus.window_focused.connect(_on_window_focused)
	EventBus.window_closed.connect(_on_window_closed)
	
	print("DesktopWindowManager ready.")

func open_app(app_name: String, force_new: bool = false):
	print("DesktopWindowManager: open_app called for: ", app_name, " (force_new: ", force_new, ")")
	print("DesktopWindowManager: Currently open windows: ", open_windows.keys())
	
	if app_name not in APP_PATHS:
		print("ERROR: DesktopWindowManager: Unknown app: ", app_name)
		return
	
	# Check if already open (only if not forcing new instance)
	if not force_new:
		var existing_window = _find_window_by_app(app_name)
		if existing_window and is_instance_valid(existing_window):
			print("DesktopWindowManager: App already open, focusing and bringing to front")
			window_container.visible = true # Ensure the whole layer is visible
			existing_window.visible = true 
			_focus_window(existing_window)
			existing_window.bring_to_front()
			return
		else:
			print("DesktopWindowManager: No existing window found for app: ", app_name)
	
	# Generate unique window ID
	var window_id = app_name + "_" + str(Time.get_ticks_msec())
	
	# Load window frame
	var window = window_frame_scene.instantiate()
	
	# Set window properties
	window.window_id = window_id
	window.set_title(APP_TITLES.get(app_name, app_name.capitalize()))
	window.position = _get_next_window_position()
	
	# Set window size based on app type
	window_container.visible = true
	
	# Add to layer
	window_container.add_child(window)
	print("DesktopWindowManager: Window added to layer: ", window.name)
	
	# Wait for window to be ready
	await get_tree().process_frame
	print("DesktopWindowManager: Frame processed, window should be ready now")
	
	# Double-check window is valid
	if not is_instance_valid(window):
		print("ERROR: DesktopWindowManager: Window became invalid after adding to tree!")
		return
	
	# Load app content
	var app_scene_path = APP_PATHS[app_name]
	print("DesktopWindowManager: App scene path: ", app_scene_path)
	
	if ResourceLoader.exists(app_scene_path):
		print("DesktopWindowManager: App scene exists, loading...")
		var app_scene = load(app_scene_path)
		if app_scene:
			print("DesktopWindowManager: App scene loaded successfully, calling load_content")
			window.load_content(app_scene)
			# Wait a frame to ensure content is loaded
			await get_tree().process_frame
			print("DesktopWindowManager: App content should now be loaded")
		else:
			print("ERROR: DesktopWindowManager: Failed to load app scene resource - load() returned null")
			# Create placeholder
			var placeholder = Label.new()
			placeholder.text = app_name.capitalize() + " (Failed to Load)"
			placeholder.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			placeholder.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			if window.content_container:
				window.content_container.add_child(placeholder)
			else:
				print("ERROR: DesktopWindowManager: window.content_container is also null!")
	else:
		print("ERROR: DesktopWindowManager: App scene not found at path: ", app_scene_path)
		# Create placeholder
		var placeholder = Label.new()
		placeholder.text = app_name.capitalize() + " (Scene Not Found)"
		placeholder.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		placeholder.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		if window.content_container:
			window.content_container.add_child(placeholder)
		else:
			print("ERROR: DesktopWindowManager: window.content_container is null, cannot add placeholder!")
	
	# Store reference
	open_windows[window_id] = window
	print("DesktopWindowManager: Window stored in open_windows. Total windows: ", open_windows.size())
	
	# Update next position (stagger)
	next_window_position += Vector2(30, 30)
	if next_window_position.x > 300:
		next_window_position.x = 50
	if next_window_position.y > 200:
		next_window_position.y = 50
	
	# Focus the new window
	_focus_window(window)
	window.bring_to_front()
	
	EventBus.app_opened.emit(app_name, window_id)
	print("DesktopWindowManager: Opened app: ", app_name, " at position: ", window.position)

func close_app(app_name: String, window_id: String = ""):
	if window_id and window_id in open_windows:
		if is_instance_valid(open_windows[window_id]):
			open_windows[window_id].queue_free()
		open_windows.erase(window_id)
	elif not window_id:
		# Close all windows for this app
		var windows_to_close = []
		for wid in open_windows:
			var window = open_windows[wid]
			if is_instance_valid(window) and wid.begins_with(app_name):
				windows_to_close.append(wid)
		
		for wid in windows_to_close:
			if is_instance_valid(open_windows[wid]):
				open_windows[wid].queue_free()
			open_windows.erase(wid)

func close_all_windows():
	# Close all open app windows to clear the desktop
	for window_id in open_windows:
		var window = open_windows[window_id]
		if is_instance_valid(window):
			window.queue_free()
	open_windows.clear()
	next_window_position = Vector2(50, 50) # Reset position when all closed

func hide_all_windows():
	# Hide the entire window layer and pause its processing
	if is_instance_valid(window_container):
		window_container.visible = false
		window_container.process_mode = Node.PROCESS_MODE_DISABLED
	print("DesktopWindowManager: All windows hidden and paused.")

func show_all_windows():
	# Show the window layer and resume its processing
	if is_instance_valid(window_container):
		window_container.visible = true
		window_container.process_mode = Node.PROCESS_MODE_INHERIT
	print("DesktopWindowManager: All windows shown and resumed.")

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
	print("DesktopWindowManager: Window focused: ", window.window_id)
	focused_window = window
	_update_window_z_indices()

func _on_window_closed(window: Control):
	if not window or not is_instance_valid(window):
		print("WARNING: DesktopWindowManager: Window closed callback received for invalid window")
		return
		
	var window_id = window.window_id
	if window_id.is_empty():
		print("WARNING: DesktopWindowManager: Window closed but has no window_id")
		return
		
	# Remove from tracking
	if window_id in open_windows:
		open_windows.erase(window_id)
		# Extract app_name from window_id (format: appname_timestamp)
		var app_name = window_id.split("_")[0]
		EventBus.app_closed.emit(app_name, window_id)
		print("DesktopWindowManager: Removed window from tracking: ", window_id)
	
	# Update focused window
	if focused_window == window:
		focused_window = null
		_update_window_z_indices() # Recalculate z-indices if focused window closed
	
	print("DesktopWindowManager: Closed window: ", window_id, " (", open_windows.size(), " windows remaining)")
	
	# If no windows open, reset position
	if open_windows.is_empty():
		next_window_position = Vector2(50, 50)

func _focus_window(window: Control):
	if window:
		focused_window = window
		_update_window_z_indices()

func _update_window_z_indices():
	var current_z = window_z_index_base
	var windows_to_sort: Array = []
	for window_id in open_windows:
		var window = open_windows[window_id]
		if is_instance_valid(window):
			windows_to_sort.append(window)
	
	# Sort windows by their current z_index to maintain relative ordering
	windows_to_sort.sort_custom(func(a, b): return a.z_index < b.z_index)
	
	for window in windows_to_sort:
		if window == focused_window:
			window.z_index = window_z_index_base + 100 # Highest Z-index for focused window
		else:
			window.z_index = window_z_index_base + current_z
			current_z += 1
