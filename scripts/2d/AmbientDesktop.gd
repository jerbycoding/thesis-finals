extends Control

# AmbientDesktop.gd
# Synchronizes the 3D monitor view with the real GameState desktop.

var ambient_window_scene = preload("res://scenes/2d/AmbientWindow.tscn")
var ambient_windows = {} # window_id -> AmbientWindow instance

@onready var window_container = %AppWindowContainer
@onready var tasks_container = get_node_or_null("%ActiveTasksContainer")

var taskbar_icon_scene = preload("res://scenes/2d/TaskbarIcon.tscn")
var ambient_taskbar_icons = {} # window_id -> Icon instance

func _ready():
	z_index = 0
	visible = true
	
	# FORCE FULL RECT: Ensure it fills the SubViewport
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Ensure Taskbar is visible but non-interactive
	var taskbar = get_node_or_null("%Taskbar")
	if taskbar:
		taskbar.visible = true
		taskbar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	if not window_container:
		push_error("AmbientDesktop: AppWindowContainer not found!")

func _process(_delta):
	# Sync with real desktop manager
	if not DesktopWindowManager: return
	
	var real_windows = DesktopWindowManager.open_windows
	
	# 1. Sync Windows
	for wid in real_windows:
		var real_win = real_windows[wid]
		if not is_instance_valid(real_win): continue
		
		if not wid in ambient_windows:
			_create_ambient_window(wid, real_win)
		
		var amb_win = ambient_windows[wid]
		amb_win.visible = real_win.visible
		if amb_win.visible:
			_sync_window_state(wid, real_win)
			
		# 2. Sync Taskbar Icons
		if tasks_container and not wid in ambient_taskbar_icons:
			_create_ambient_taskbar_icon(wid, real_win)
	
	# 3. Cleanup Removed
	var to_remove = []
	for wid in ambient_windows:
		if not wid in real_windows:
			to_remove.append(wid)
	
	for wid in to_remove:
		_remove_ambient_window(wid)
		_remove_ambient_taskbar_icon(wid)

func _create_ambient_taskbar_icon(wid: String, window: Control):
	if not tasks_container: return
	
	var icon = taskbar_icon_scene.instantiate()
	tasks_container.add_child(icon)
	icon.setup(window)
	
	# Disable interaction
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in icon.get_children():
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE
			
	ambient_taskbar_icons[wid] = icon

func _remove_ambient_taskbar_icon(wid: String):
	if wid in ambient_taskbar_icons:
		if is_instance_valid(ambient_taskbar_icons[wid]):
			ambient_taskbar_icons[wid].queue_free()
		ambient_taskbar_icons.erase(wid)


func _create_ambient_window(wid: String, _real_win: Control):
	if not window_container: return
	
	var win = ambient_window_scene.instantiate()
	window_container.add_child(win)
	ambient_windows[wid] = win
	
	# Setup title
	var title = "Application"
	var app_id = wid.split("_")[0]
	
	if DesktopWindowManager.app_configs.has(app_id):
		title = DesktopWindowManager.app_configs[app_id].title
	
	if win.has_method("setup"):
		win.setup(app_id, title)

func _sync_window_state(wid: String, real_win: Control):
	var amb_win = ambient_windows[wid]
	
	# SCALE CALCULATION
	# Use DesktopWindowManager container size as reference
	var real_size = Vector2(1280, 720) # Fallback to standard
	if DesktopWindowManager and DesktopWindowManager.active_window_container:
		real_size = DesktopWindowManager.active_window_container.size
	
	var my_size = window_container.size
	
	# Avoid division by zero
	if real_size.x <= 1 or real_size.y <= 1 or my_size.x <= 1 or my_size.y <= 1: return
	
	var scale_factor = my_size / real_size
	
	# Sync transform
	amb_win.position = real_win.position * scale_factor
	amb_win.size = real_win.size * scale_factor
	
	# Sync Z-Index (Layering)
	amb_win.z_index = real_win.z_index
	amb_win.visible = real_win.visible
	
	# Handle Window Ordering in Container
	# Use actual scene tree order to match Z-index visuals
	if real_win == DesktopWindowManager.focused_window:
		amb_win.move_to_front()

func _remove_ambient_window(wid: String):
	if wid in ambient_windows:
		if is_instance_valid(ambient_windows[wid]):
			ambient_windows[wid].queue_free()
		ambient_windows.erase(wid)