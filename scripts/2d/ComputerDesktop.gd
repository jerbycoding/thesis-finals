# computer_desktop.gd
extends Control

# Desktop app management
signal app_opened(app_name: String, window_id: String)
signal app_closed(app_name: String, window_id: String)

var shift_report_scene = preload("res://scenes/2d/apps/App_ShiftReport.tscn")

@onready var app_launcher: GridContainer = %AppLauncher
@onready var exit_button: Button = %ExitButton
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
	
	# Connect app icons
	_setup_app_connections()
	
	# Connect to EventBus for gameplay events
	EventBus.ticket_added.connect(_on_ticket_added)
	EventBus.ticket_completed.connect(_on_ticket_completed)
	EventBus.consequence_triggered.connect(_on_consequence_triggered)
	
	# Set desktop instance for NotificationManager
	if NotificationManager:
		NotificationManager.set_desktop(self)
	
	print("DesktopManager ready - Window system active")

func _setup_app_connections():
	if not app_launcher: return
	
	for child in app_launcher.get_children():
		if child is Button:
			var app_name = child.name.to_lower().replace("_icon", "")
			
			# Disconnect if needed
			if child.pressed.is_connected(_on_app_icon_pressed):
				child.pressed.disconnect(_on_app_icon_pressed)
			
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
		# Clear glow when app is opened
		_set_icon_glow(app_name, false)

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
			_set_icon_glow(ticket_data.required_tool, true)

func _set_icon_glow(app_name: String, active: bool):
	var icon_name = app_name.capitalize() + "_Icon"
	# Handle cases like SIEM (all caps)
	if app_name == "siem": icon_name = "SIEM_Icon"
	
	var icon_btn = app_launcher.get_node_or_null(icon_name)
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
		_set_icon_glow("siem", true)

func _on_ticket_completed(ticket: TicketResource, completion_type: String, time_taken: float):
	print("Ticket completed: ", ticket.ticket_id, " as ", completion_type)
	# Remove glow when ticket is solved
	if ticket.required_tool != "none":
		_set_icon_glow(ticket.required_tool, false)

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
