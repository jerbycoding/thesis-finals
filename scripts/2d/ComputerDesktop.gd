# computer_desktop.gd
extends Control

# Desktop app management
signal app_opened(app_name: String, window_id: String)
signal app_closed(app_name: String, window_id: String)

var shift_report_scene = preload("res://scenes/2d/apps/App_ShiftReport.tscn")

@onready var dock_icons: HBoxContainer = %DockIcons
@onready var utility_bar: VBoxContainer = %LeftUtilityBar
@onready var app_window_container: Control = %AppWindowContainer
@onready var lcd_group = %LCD_Group
@onready var desktop_bg = %DesktopBackground
@onready var monitor_assembly = %MonitorAssembly

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
	
	# Connect app icons
	_setup_container_connections(dock_icons)
	_setup_container_connections(utility_bar)
	
	# Connect signals
	EventBus.ticket_added.connect(_on_ticket_added)
	EventBus.ticket_completed.connect(_on_ticket_completed)
	EventBus.consequence_triggered.connect(_on_consequence_triggered)
	EventBus.world_event_triggered.connect(_on_world_event)
	
	if NotificationManager:
		NotificationManager.set_desktop(self)
	
	print("DesktopManager ready - Window system active")

func _process(_delta):
	pass

func _setup_container_connections(container: Control):
	if not container: return
	for child in container.get_children():
		if child is Button:
			var app_name = child.name.to_lower().replace("_icon", "")
			if app_name == "exitbutton": continue
			child.pressed.connect(_on_app_icon_pressed.bind(app_name))
			child.mouse_entered.connect(func(): if AudioManager: AudioManager.play_ui_hover())

func _on_app_icon_pressed(app_name: String):
	if AudioManager: AudioManager.play_ui_click()
	if DesktopWindowManager:
		DesktopWindowManager.open_app(app_name)

func _on_world_event(event_id: String, active: bool, _duration: float):
	if event_id == GlobalConstants.EVENTS.POWER_FLICKER and active:
		visible = false
		await get_tree().create_timer(0.2).timeout
		visible = true
		if DesktopWindowManager: DesktopWindowManager.close_all_windows()

func _on_ticket_added(ticket_data: TicketResource):
	if DesktopWindowManager:
		if not DesktopWindowManager._find_window_by_app("tickets"):
			DesktopWindowManager.open_app("tickets")

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
