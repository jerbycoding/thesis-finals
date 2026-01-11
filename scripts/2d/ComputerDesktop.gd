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
	
	# Connect to game systems
	if TicketManager:
		TicketManager.ticket_added.connect(_on_ticket_added)
		TicketManager.ticket_completed.connect(_on_ticket_completed)
	
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
		# Using a subtle click or hover sound if available
		AudioManager.play_sfx(AudioManager.SFX.button_click)

func _on_app_icon_pressed(app_name: String):
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
