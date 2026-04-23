# computer_desktop.gd
extends Control

# Desktop app management
signal app_opened(app_name: String, window_id: String)
signal app_closed(app_name: String, window_id: String)

var shift_report_scene = preload("res://scenes/2d/apps/App_ShiftReport.tscn")

@onready var start_menu_button: Button = %StartMenuButton
@onready var start_glow_frame: Panel = %GlowFrame
@onready var tasks_container: HBoxContainer = %ActiveTasksContainer
@onready var app_window_container: Control = %AppWindowContainer

var taskbar_icon_scene = preload("res://scenes/2d/TaskbarIcon.tscn")
var start_menu_scene = preload("res://scenes/2d/StartMenu.tscn")
var start_menu_instance = null
var _start_glow_tween: Tween = null

func _ready():
	# Set as background layer
	z_index = 0
	visible = true
	
	# FORCE FULL RECT: Ensure desktop fills the entire window
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	if not app_window_container:
		print("ERROR: AppWindowContainer node not found in scene tree!")
	else:
		app_window_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if DesktopWindowManager:
			DesktopWindowManager.register_container(app_window_container)
	
	# Register for notifications
	if NotificationManager:
		NotificationManager.set_desktop(self)
	
	# Connect signals
	EventBus.app_opened.connect(_on_app_opened)
	EventBus.app_closed.connect(_on_app_closed)
	EventBus.window_focused.connect(_on_window_focused)
	EventBus.ticket_added.connect(_on_ticket_added)
	EventBus.world_event_triggered.connect(_on_world_event)
	
	if start_menu_button:
		start_menu_button.pressed.connect(_on_start_menu_pressed)
	
	# Instantiate Start Menu
	start_menu_instance = start_menu_scene.instantiate()
	add_child(start_menu_instance)
	start_menu_instance.z_index = 100 # ALWAYS ON TOP
	start_menu_instance.app_selected.connect(_on_app_selected)
	
	# Initial taskbar sync
	_refresh_taskbar()

func _on_start_menu_pressed():
	if start_menu_instance:
		start_menu_instance.toggle()
		if AudioManager: AudioManager.play_ui_click()

func _on_app_selected(app_id: String):
	if DesktopWindowManager:
		await DesktopWindowManager.open_app(app_id)
	if AudioManager:
		AudioManager.play_ui_click()
	# Start menu handles its own visibility on selection, but we ensure it here
	if start_menu_instance: start_menu_instance.visible = false

func _refresh_taskbar():
	if not tasks_container: return
	
	# Clear
	for child in tasks_container.get_children():
		child.queue_free()
		
	# Populate from DesktopWindowManager
	if DesktopWindowManager:
		for wid in DesktopWindowManager.open_windows:
			var win = DesktopWindowManager.open_windows[wid]
			_add_taskbar_icon(win)

func _on_app_opened(_app_name: String, window_id: String):
	if DesktopWindowManager and window_id in DesktopWindowManager.open_windows:
		_add_taskbar_icon(DesktopWindowManager.open_windows[window_id])
	# Auto-close start menu when app opens
	if start_menu_instance: start_menu_instance.visible = false

func _add_taskbar_icon(window):
	if not tasks_container or not is_instance_valid(window): return
	
	# Check if icon already exists
	for child in tasks_container.get_children():
		if is_instance_valid(child) and child.has_method("get_target_window"):
			if child.target_window == window:
				return
			
	var icon = taskbar_icon_scene.instantiate()
	tasks_container.add_child(icon)
	icon.setup(window)

func _on_app_closed(_app_name: String, _window_id: String):
	# Icons clean themselves up in their _process
	pass

func _on_window_focused(_window: Control):
	# Auto-close start menu when clicking a window
	if start_menu_instance and start_menu_instance.visible:
		start_menu_instance.visible = false

func _on_world_event(event_id: String, active: bool, _duration: float):
	if event_id == GlobalConstants.EVENTS.POWER_FLICKER:
		if active:
			# Station Crash
			visible = false
			if DesktopWindowManager: 
				DesktopWindowManager.close_all_windows()
			if AudioManager: 
				AudioManager.play_terminal_beep(-5.0)
		else:
			# Power Restored
			visible = true
			if AudioManager: 
				AudioManager.play_notification("success")

func _on_ticket_added(ticket_data: TicketResource):
	# PASSIVE NOTIFICATION: Instead of opening the app, show a toast
	if NotificationManager:
		NotificationManager.show_notification("NEW TICKET: " + ticket_data.ticket_id, "warning")
	
	if AudioManager:
		AudioManager.play_notification("new_ticket")
	
	# Logic to pulse the taskbar icon can be added here if the app is already open
	# Or we can pulse a 'Ticket' shortcut if we had one. 
	# For now, the toast is the primary non-intrusive alert.

func _on_ticket_completed(_ticket: TicketResource, _type: String, _time: float):
	pass

func _on_consequence_triggered(_type: String, _details: Dictionary):
	pass

func _input(event):
	if DesktopWindowManager and event.is_action_pressed("ui_cancel") and DesktopWindowManager.focused_window:
		var fw = DesktopWindowManager.focused_window
		if is_instance_valid(fw):
			if fw.has_method("_on_close_pressed"): fw._on_close_pressed()
			else: fw.queue_free()
		get_viewport().set_input_as_handled()

func set_icon_glow(app_id: String, active: bool):
	# Special case for start menu itself
	if app_id == "start":
		_pulse_start_menu(active)
		return
		
	# Forward to start menu instance for internal highlighting
	if start_menu_instance and start_menu_instance.has_method("set_app_glow"):
		start_menu_instance.set_app_glow(app_id, active)
		
	# Logic: If the app is NOT open, we must glow the Start Menu to show where to find it.
	# If it IS open, we glow the taskbar icon.
	var is_open = false
	if DesktopWindowManager:
		for wid in DesktopWindowManager.open_windows:
			if wid.begins_with(app_id):
				is_open = true
				break
	
	if not is_open:
		_pulse_start_menu(active)
	else:
		# Stop start menu glow if we were glowing it for this app
		_pulse_start_menu(false)
		# Find and glow the taskbar icon
		for child in tasks_container.get_children():
			if child.has_method("get_target_window") and is_instance_valid(child.target_window):
				if child.target_window.window_id.begins_with(app_id):
					if child.has_method("set_glow"):
						child.set_glow(active)

func _pulse_start_menu(active: bool):
	if _start_glow_tween:
		_start_glow_tween.kill()
		_start_glow_tween = null
	
	if not active:
		if start_glow_frame: start_glow_frame.visible = false
		return
		
	if start_glow_frame:
		start_glow_frame.visible = true
		start_glow_frame.modulate.a = 1.0
		_start_glow_tween = create_tween().set_loops()
		_start_glow_tween.tween_property(start_glow_frame, "modulate:a", 0.2, 0.6).set_trans(Tween.TRANS_SINE)
		_start_glow_tween.tween_property(start_glow_frame, "modulate:a", 1.0, 0.6).set_trans(Tween.TRANS_SINE)
