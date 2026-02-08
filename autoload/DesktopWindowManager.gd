# DesktopWindowManager.gd
# Autoload singleton to manage desktop application windows.
extends Node

var open_windows: Dictionary = {}  # window_id: WindowFrame
var next_window_position: Vector2 = Vector2(50, 50)
var window_z_index_base: int = 10
var focused_window: Control = null
var active_window_container: Control = null

var app_configs: Dictionary = {} # app_id -> AppConfig resource
const APP_CONFIG_DIR = "res://resources/apps/"

var window_frame_scene = preload("res://scenes/2d/apps/components/WindowFrame.tscn")

func _ready():
	_load_app_configs()
	
	# Connect to EventBus for global window management
	EventBus.window_focused.connect(_on_window_focused)
	EventBus.window_closed.connect(_on_window_closed)
	EventBus.shift_ended.connect(func(_results): close_all_windows())
	
	print("DesktopWindowManager ready.")

func register_container(container: Control):
	active_window_container = container
	print("DesktopWindowManager: Registered window container: ", container.name)

func _load_app_configs():
	app_configs.clear()
	var app_resources = FileUtil.load_and_validate_resources(APP_CONFIG_DIR, "AppConfig")
	for res in app_resources:
		if res is AppConfig:
			app_configs[res.app_id] = res
	print("DesktopWindowManager: Loaded %d application configurations." % app_configs.size())


## The currently active permission profile. If null, all apps are allowed.
var active_permission_profile: AppPermissionProfile = null

func can_open_app(app_name: String) -> Dictionary:
	"""Returns {'allowed': bool, 'reason': String}"""
	if not app_configs.has(app_name):
		return {"allowed": false, "reason": "Application not registered."}
	
	var config = app_configs[app_name]
	
	# Check Active Profile (Tutorial/Narrative Restrictions)
	if active_permission_profile != null:
		if not active_permission_profile.is_allowed(app_name):
			return {
				"allowed": false, 
				"reason": active_permission_profile.restricted_message
			}

	# Check Logic Restrictions (Context-based)
	if not config.is_restricted:
		return {"allowed": true, "reason": ""}
		
	var allowed = false
	if TicketManager:
		for ticket in TicketManager.get_active_tickets():
			if ticket.category == config.required_category or ticket.required_tool == config.required_tool_id:
				allowed = true
				break
				
	return {
		"allowed": allowed,
		"reason": config.restriction_message if not allowed else ""
	}

func open_app(app_name: String, force_new: bool = false):
	if not app_configs.has(app_name):
		print("ERROR: DesktopWindowManager: Unknown app: ", app_name)
		return
		
	var config = app_configs[app_name]
		
	# Check permissions
	var permission = can_open_app(app_name)
	if not permission.allowed:
		print("DesktopWindowManager: Permission denied for app: ", app_name)
		if NotificationManager:
			NotificationManager.show_notification(permission.reason, "warning")
		if AudioManager:
			AudioManager.play_notification("error")
		return
	
	# Check if already open (only if not forcing new instance)
	if not force_new:
		var existing_window = _find_window_by_app(app_name)
		if existing_window and is_instance_valid(existing_window):
			print("DesktopWindowManager: App already open, focusing and bringing to front")
			existing_window.visible = true 
			_focus_window(existing_window)
			existing_window.move_to_front() # Bring to front in scene tree
			return
		else:
			print("DesktopWindowManager: No existing window found for app: ", app_name)
	
	# FIND CONTAINER
	if not is_instance_valid(active_window_container):
		print("ERROR: DesktopWindowManager: No active window container registered!")
		return
		
	var container = active_window_container

	# Generate unique window ID
	var window_id = app_name + "_" + str(Time.get_ticks_msec())
	
	# Load window frame
	var window = window_frame_scene.instantiate()
	
	# Set window properties
	window.window_id = window_id
	window.set_title(config.title)
	window.position = _get_next_window_position()
	
	# Store reference IMMEDIATELY to prevent race conditions during 'await'
	open_windows[window_id] = window
	
	# Add to layer
	container.add_child(window)
	
	# Wait for window to be ready
	await get_tree().process_frame
	
	# Double-check window is valid after await
	if not is_instance_valid(window):
		open_windows.erase(window_id)
		return
	
	# Load app content
	var app_scene_path = config.scene_path
	
	if ResourceLoader.exists(app_scene_path):
		var app_scene = load(app_scene_path)
		if app_scene:
			window.load_content(app_scene)
			# Wait a frame to ensure content is loaded
			await get_tree().process_frame
		else:
			print("ERROR: DesktopWindowManager: Failed to load app scene resource")
			_cleanup_failed_window(window_id)
			return
	else:
		print("ERROR: DesktopWindowManager: App scene not found: ", app_scene_path)
		_cleanup_failed_window(window_id)
		return
	
	# Update next position (stagger)
	next_window_position += Vector2(30, 30)
	if next_window_position.x > 300:
		next_window_position.x = 50
	if next_window_position.y > 200:
		next_window_position.y = 50
	
	# Focus the new window
	_focus_window(window)
	window.move_to_front()
	
	# Intelligent Dismiss
	var desktop = get_tree().root.find_child("ComputerDesktop", true, false)
	if desktop and "start_menu_instance" in desktop:
		if desktop.start_menu_instance: desktop.start_menu_instance.visible = false
	
	EventBus.app_opened.emit(app_name, window_id)
	print("DesktopWindowManager: Opened app: ", app_name, " at position: ", window.position)

func _cleanup_failed_window(window_id: String):
	if window_id in open_windows:
		var window = open_windows[window_id]
		if is_instance_valid(window):
			window.queue_free()
		open_windows.erase(window_id)

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
	print("DesktopWindowManager: Closing all windows.")
	# Close all open app windows to clear the desktop
	for window_id in open_windows:
		var window = open_windows[window_id]
		if is_instance_valid(window):
			window.queue_free()
			
	open_windows.clear()
	next_window_position = Vector2(50, 50) # Reset position when all closed

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
	
	# Intelligent Dismiss: Close Start Menu when clicking any window
	var desktop = get_tree().root.find_child("ComputerDesktop", true, false)
	if desktop and "start_menu_instance" in desktop:
		if desktop.start_menu_instance and desktop.start_menu_instance.visible:
			desktop.start_menu_instance.visible = false

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
	
	# Clean up invalid references first
	var invalid_ids = []
	for window_id in open_windows:
		var window = open_windows[window_id]
		if is_instance_valid(window):
			windows_to_sort.append(window)
		else:
			invalid_ids.append(window_id)
	
	for id in invalid_ids:
		open_windows.erase(id)
	
	# Sort windows by their current z_index to maintain relative ordering
	windows_to_sort.sort_custom(func(a, b): 
		if not is_instance_valid(a) or not is_instance_valid(b): return false
		return a.z_index < b.z_index
	)
	
	for window in windows_to_sort:
		if not is_instance_valid(window): continue
		if window == focused_window:
			window.z_index = window_z_index_base + 100 # Highest Z-index for focused window
		else:
			window.z_index = window_z_index_base + current_z
			current_z += 1
