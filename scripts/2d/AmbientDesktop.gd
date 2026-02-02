extends Control

# AmbientDesktop.gd
# Synchronizes the 3D monitor view with the real GameState desktop.

var ambient_window_scene = preload("res://scenes/2d/AmbientWindow.tscn")
var ambient_windows = {} # window_id -> AmbientWindow instance

@onready var window_container = %AppWindowContainer

func _ready():
	z_index = 0
	visible = true
	# Ensure container is ready
	if not window_container:
		push_error("AmbientDesktop: AppWindowContainer not found!")

func _process(_delta):
	# Sync with real desktop manager
	if not DesktopWindowManager: return
	
	# Get real windows
	var real_windows = DesktopWindowManager.open_windows
	
	# 1. Update or Create
	for wid in real_windows:
		var real_win = real_windows[wid]
		if not is_instance_valid(real_win): continue
		
		# Skip if window is hidden
		if not real_win.visible:
			if wid in ambient_windows:
				ambient_windows[wid].visible = false
			continue
			
		if not wid in ambient_windows:
			_create_ambient_window(wid, real_win)
		
		_sync_window_state(wid, real_win)
	
	# 2. Cleanup Removed
	var to_remove = []
	for wid in ambient_windows:
		if not wid in real_windows:
			to_remove.append(wid)
	
	for wid in to_remove:
		_remove_ambient_window(wid)

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
	# Calculate ratio between the real desktop size and this ambient viewport size
	var real_container = real_win.get_parent()
	if not is_instance_valid(real_container): return
	
	var real_size = real_container.size
	var my_size = window_container.size
	
	# Avoid division by zero
	if real_size.x <= 1 or real_size.y <= 1: return
	
	var scale_factor = my_size / real_size
	
	# Sync transform
	amb_win.position = real_win.position * scale_factor
	amb_win.size = real_win.size * scale_factor
	
	# Sync Z-Index (Layering)
	amb_win.z_index = real_win.z_index
	amb_win.visible = real_win.visible
	
	# Move to front if Z-index is high to ensure draw order in container
	if real_win.z_index > 100: # Arbitrary "Focused" threshold
		amb_win.move_to_front()

func _remove_ambient_window(wid: String):
	if wid in ambient_windows:
		if is_instance_valid(ambient_windows[wid]):
			ambient_windows[wid].queue_free()
		ambient_windows.erase(wid)