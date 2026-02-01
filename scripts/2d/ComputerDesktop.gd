# computer_desktop.gd
extends Control

# Desktop app management
signal app_opened(app_name: String, window_id: String)
signal app_closed(app_name: String, window_id: String)

var shift_report_scene = preload("res://scenes/2d/apps/App_ShiftReport.tscn")

@onready var dock_icons: HBoxContainer = %DockIcons
@onready var utility_bar: VBoxContainer = %LeftUtilityBar
@onready var app_window_container: Control = %AppWindowContainer

func _ready():
	# Set as background layer
	z_index = 0
	visible = true
	
	if not app_window_container:
		print("ERROR: AppWindowContainer node not found in scene tree!")
		push_error("AppWindowContainer is missing - windows cannot be created")
	else:
		app_window_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
		# REGISTER WITH MANAGER (Debt #3 Fix)
		if DesktopWindowManager:
			DesktopWindowManager.register_container(app_window_container)
	
	# Connect app icons from all containers
	_setup_container_connections(dock_icons)
	_setup_container_connections(utility_bar)
	
	# Connect to EventBus for gameplay events
	EventBus.ticket_added.connect(_on_ticket_added)
	EventBus.ticket_completed.connect(_on_ticket_completed)
	EventBus.consequence_triggered.connect(_on_consequence_triggered)
	EventBus.world_event_triggered.connect(_on_world_event)
	
	# Set desktop instance for NotificationManager
	if NotificationManager:
		NotificationManager.set_desktop(self)
	
	# Notify Manager that desktop is ready for highlighting
	if TutorialManager and TutorialManager.is_tutorial_active:
		TutorialManager._update_visual_focus()
	
	print("DesktopManager ready - Window system active")

func _setup_container_connections(container: Control):
	if not container: return
	
	for child in container.get_children():
		if child is Button:
			var app_name = child.name.to_lower().replace("_icon", "")
			
			if app_name == "exitbutton": continue # Skip exit
			
			# Setup initial tooltips for restricted apps
			if DesktopWindowManager and app_name in DesktopWindowManager.app_configs:
				var config = DesktopWindowManager.app_configs[app_name]
				if config.is_restricted:
					var status = DesktopWindowManager.can_open_app(app_name)
					if not status.allowed:
						child.tooltip_text = status.reason
			
			# Connect signals
			child.pressed.connect(_on_app_icon_pressed.bind(app_name))
			child.mouse_entered.connect(_on_app_icon_hover)
			
			print("Connected icon: ", child.name, " -> ", app_name)

func _on_app_icon_hover():
	if AudioManager:
		AudioManager.play_ui_hover()

func _on_app_icon_pressed(app_name: String):
	if AudioManager:
		AudioManager.play_ui_click()
	
	if DesktopWindowManager:
		DesktopWindowManager.open_app(app_name)
		# Clear glow when app is opened (if it was actually opened)
		if DesktopWindowManager._find_window_by_app(app_name):
			set_icon_glow(app_name, false)

func _on_world_event(event_id: String, active: bool, _duration: float):
	if event_id == GlobalConstants.EVENTS.POWER_FLICKER and active:
		_simulate_power_flicker()

func _simulate_power_flicker():
	print("🔌 DESKTOP: Power surge detected. Systems resetting.")
	# Flash desktop off and on
	visible = false
	await get_tree().create_timer(0.2).timeout
	visible = true
	await get_tree().create_timer(0.1).timeout
	visible = false
	await get_tree().create_timer(0.3).timeout
	visible = true
	
	# Close all windows (simulating a crash/reset)
	if DesktopWindowManager:
		DesktopWindowManager.close_all_windows()
	
	if NotificationManager:
		NotificationManager.show_notification("CRITICAL: Power surge detected. Local sessions terminated.", "error")

func _on_ticket_added(ticket_data: TicketResource):
	print("New ticket in queue: ", ticket_data.title)
	
	if DesktopWindowManager:
		# Auto-open tickets app if not open
		if not DesktopWindowManager._find_window_by_app("tickets"):
			print("Auto-opening Ticket Queue for new ticket")
			DesktopWindowManager.open_app("tickets")
		
		# AUTO-POP: If ticket is Critical, open the required tool immediately
		if ticket_data.severity == "Critical" and ticket_data.required_tool != "none":
			print("CRITICAL Incident: Auto-popping tool ", ticket_data.required_tool)
			DesktopWindowManager.open_app(ticket_data.required_tool)
		
		# ICON GLOW: Apply glow to relevant tool icon
		if ticket_data.required_tool != "none":
			set_icon_glow(ticket_data.required_tool, true)
			
		# DYNAMIC AUTHORIZATION: Grant permission for restricted apps based on data
		for app_name in DesktopWindowManager.app_configs:
			var config = DesktopWindowManager.app_configs[app_name]
			if config.is_restricted:
				if ticket_data.category == config.required_category or ticket_data.required_tool == config.required_tool_id:
					var icon_name = app_name.capitalize() + "_Icon"
					if app_name == "siem": icon_name = "SIEM_Icon" # Special case for SIEM caps
					
					var btn = dock_icons.get_node_or_null(icon_name)
					if not btn: btn = utility_bar.get_node_or_null(icon_name)
					
					if btn:
						btn.tooltip_text = "AUTHORIZATION GRANTED: High-Priority Incident in Progress"

func set_icon_glow(app_name: String, active: bool):
	var icon_name = app_name.capitalize() + "_Icon"
	# Handle cases like SIEM (all caps)
	if app_name == "siem": icon_name = "SIEM_Icon"
	
	var icon_btn = dock_icons.get_node_or_null(icon_name)
	if not icon_btn: icon_btn = utility_bar.get_node_or_null(icon_name)
	
	if not icon_btn: return
	
	if active:
		# Create pulsing animation
		var tween = create_tween().set_loops()
		tween.tween_property(icon_btn, "modulate", Color(1.5, 0.5, 1.5, 1.0), 0.8).set_trans(Tween.TRANS_SINE)
		tween.tween_property(icon_btn, "modulate", Color.WHITE, 0.8).set_trans(Tween.TRANS_SINE)
		icon_btn.set_meta("glow_tween", tween)
	else:
		if icon_btn.has_meta("glow_tween"):
			var tween = icon_btn.get_meta("glow_tween")
			if tween: tween.kill()
			icon_btn.modulate = Color.WHITE
			icon_btn.remove_meta("glow_tween")

func _on_consequence_triggered(consequence_type: String, _details: Dictionary):
	if consequence_type == "escalation":
		print("Desktop: Escalation detected. Activating SIEM glow.")
		set_icon_glow("siem", true)

func _on_ticket_completed(ticket: TicketResource, completion_type: String, time_taken: float):
	print("Ticket completed: ", ticket.ticket_id, " as ", completion_type)
	# Remove glow when ticket is solved
	if ticket.required_tool != "none":
		set_icon_glow(ticket.required_tool, false)

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
