# app_SIEMViewer.gd
extends Control

@onready var log_list: VBoxContainer = %LogList
@onready var ticket_dropdown: OptionButton = %TicketDropdown
@onready var attach_button: Button = %AttachButton
@onready var log_detail_label: RichTextLabel = %LogDetailLabel
@onready var close_inspector_button: Button = %CloseInspectorButton
@onready var inspector_pane: Control = %InspectorPane
@onready var filter_all: Button = %FilterAll
@onready var filter_security: Button = %FilterSecurity
@onready var filter_high_severity: Button = %FilterHighSeverity
@onready var time_header: Label = %TimeHeader
@onready var source_header: Label = %SourceHeader
@onready var severity_header: Label = %SeverityHeader
@onready var message_header: Label = %MessageHeader

var log_entry_scene = preload("res://scenes/2d/apps/components/LogEntry.tscn")

var current_filter: String = "all"  # "all", "security", "high"
var selected_log: LogResource = null
var is_lagging: bool = false

const MAX_VISIBLE_LOGS = 50

func _ready():
	print("======= App_SIEMViewer (Bottom Drawer) Ready =======")
	
	visible = true
	modulate = Color.WHITE
	
	if inspector_pane:
		inspector_pane.visible = false
	
	# Connect buttons
	_setup_filters()
	_setup_attach_section()
	
	if close_inspector_button:
		close_inspector_button.pressed.connect(_on_close_inspector_pressed)
	
	# Initialize header widths to match LogEntry.tscn
	if time_header: time_header.custom_minimum_size = Vector2(100, 0)
	if source_header: source_header.custom_minimum_size = Vector2(120, 0)
	if severity_header: severity_header.custom_minimum_size = Vector2(70, 0)
	
	# Connect to LogSystem
	if LogSystem:
		LogSystem.log_added.connect(_on_log_added)
	
	# Connect to TicketManager
	if TicketManager:
		TicketManager.ticket_added.connect(_on_ticket_added)
		TicketManager.log_attached.connect(_on_log_attached)
	
	# Connect to NarrativeDirector for events
	if NarrativeDirector:
		NarrativeDirector.world_event.connect(_on_world_event)
	
	# Load existing logs
	_refresh_logs()
	_refresh_ticket_dropdown()

func _process(_delta):
	if is_lagging:
		if randf() < 0.1:
			modulate.a = randf_range(0.5, 0.9)
		else:
			modulate.a = 1.0
	elif modulate.a != 1.0:
		modulate.a = 1.0

func _on_world_event(event_id: String, active: bool, _duration: float):
	if event_id == "SIEM_LAG":
		is_lagging = active
		if not active: modulate.a = 1.0

func _setup_filters():
	if filter_all: filter_all.pressed.connect(func(): current_filter = "all"; _refresh_logs())
	if filter_security: filter_security.pressed.connect(func(): current_filter = "security"; _refresh_logs())
	if filter_high_severity: filter_high_severity.pressed.connect(func(): current_filter = "high"; _refresh_logs())

func _refresh_logs():
	if not log_list: return
	
	selected_log = null
	if log_detail_label:
		log_detail_label.clear()
		log_detail_label.append_text("[i]Select an entry from the stream to begin forensic analysis...[/i]")
	
	for child in log_list.get_children():
		child.queue_free()
	
	var logs_to_show: Array[LogResource] = []
	if LogSystem:
		match current_filter:
			"all": logs_to_show = LogSystem.get_all_logs()
			"security": logs_to_show = LogSystem.get_logs_by_category("Security")
			"high": logs_to_show = LogSystem.get_logs_by_severity(4)
			_: logs_to_show = LogSystem.get_all_logs()
	
	logs_to_show.sort_custom(func(a, b): return a.timestamp > b.timestamp)
	
	for log in logs_to_show:
		_add_log_entry(log)

func _on_log_added(log: LogResource):
	# Incremental Update: Only add if it matches current filter
	var should_show = false
	match current_filter:
		"all": should_show = true
		"security": should_show = (log.category == "Security")
		"high": should_show = (log.severity >= 4)
	
	if should_show:
		_add_log_entry(log, true) # Prepend newest

func _add_log_entry(log: LogResource, prepend: bool = false):
	if not log or not log_list: return
	
	var entry = log_entry_scene.instantiate()
	if prepend:
		log_list.add_child(entry)
		log_list.move_child(entry, 0)
	else:
		log_list.add_child(entry)
	
	entry.set_log_data(log)
	entry.log_selected.connect(_on_log_selected)
	
	# Performance Cap: Remove oldest logs if over limit
	if log_list.get_child_count() > MAX_VISIBLE_LOGS:
		var oldest = log_list.get_child(log_list.get_child_count() - 1)
		log_list.remove_child(oldest)
		oldest.queue_free()

func _on_log_selected(log: LogResource, instance: Control):
	selected_log = log
	_highlight_selected_log(instance)
	_show_log_details(log)

func _highlight_selected_log(selected_instance: Control):
	for child in log_list.get_children():
		if child.has_method("set_highlight"):
			child.set_highlight(child == selected_instance)

func _setup_attach_section():
	if attach_button: attach_button.pressed.connect(_on_attach_button_pressed)

func _on_close_inspector_pressed():
	if inspector_pane:
		inspector_pane.visible = false
	selected_log = null
	_highlight_selected_log(null)

func _show_log_details(log: LogResource):
	if inspector_pane:
		inspector_pane.visible = true
	
	_refresh_ticket_dropdown()
	if log_detail_label:
		log_detail_label.clear()
		
		var params = {
			"id": log.log_id,
			"time": log.timestamp,
			"color": log.get_severity_color().to_html(),
			"risk": log.get_severity_text(),
			"source": log.source,
			"ip": log.ip_address if log.ip_address != "" else "N/A",
			"host": log.hostname if log.hostname != "" else "N/A",
			"message": log.message
		}
		
		var body = CorporateVoice.get_formatted_phrase("siem_inspector_body", params)
		log_detail_label.append_text(body)

func _refresh_ticket_dropdown():
	if not ticket_dropdown: return
	ticket_dropdown.clear()
	ticket_dropdown.add_item("Select Case...")
	if TicketManager:
		for ticket in TicketManager.get_active_tickets():
			var display_text = ticket.ticket_id + ": " + ticket.title
			if display_text.length() > 30:
				display_text = display_text.substr(0, 27) + "..."
			ticket_dropdown.add_item(display_text)

func _on_attach_button_pressed():
	if not selected_log or ticket_dropdown.selected <= 0: return
	var ticket = TicketManager.get_active_tickets()[ticket_dropdown.selected - 1]
	if TicketManager.attach_log_to_ticket(ticket.ticket_id, selected_log.log_id):
		if NotificationManager: NotificationManager.show_notification("Evidence attached to " + ticket.ticket_id, "success")
		selected_log = null
		_highlight_selected_log(null)
		if inspector_pane:
			inspector_pane.visible = false

func _on_ticket_added(_ticket: TicketResource): _refresh_ticket_dropdown()
func _on_log_attached(_t_id, _l_id): pass
