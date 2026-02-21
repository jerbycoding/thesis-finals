# app_SIEMViewer.gd
extends Control

@onready var log_list: VBoxContainer = %LogList
@onready var volume_graph: Control = %VolumeGraph
@onready var stats_label: Label = %StatsLabel
@onready var close_inspector_button: Button = %CloseInspectorButton
@onready var inspector_pane: Control = %InspectorPane
@onready var log_detail_label: RichTextLabel = %LogDetailLabel

# NEW UI REFERENCES
@onready var search_edit: LineEdit = %SearchEdit
@onready var filter_critical: Button = %FilterCritical
@onready var filter_auth: Button = %FilterAuth
@onready var filter_malware: Button = %FilterMalware

var log_entry_scene = preload("res://scenes/2d/apps/components/LogEntry.tscn")
var pool: UIObjectPool

var selected_log: LogResource = null
var log_history_data: Array[int] = [] # For the graph
const GRAPH_MAX_POINTS = 60

# Filter State
var current_filter_text: String = ""
var only_critical: bool = false

func _ready():
	print("======= App_SIEMViewer (Forensics Redesign) Ready =======")
	
	pool = UIObjectPool.new()
	add_child(pool)
	
	volume_graph.draw.connect(_draw_graph)
	close_inspector_button.pressed.connect(_on_close_inspector_pressed)
	
	# Connect Search & Filters
	search_edit.text_changed.connect(_on_search_changed)
	filter_critical.toggled.connect(_on_filter_critical_toggled)
	filter_auth.pressed.connect(func(): search_edit.text = "auth"; _on_search_changed("auth"))
	filter_malware.pressed.connect(func(): search_edit.text = "malware"; _on_search_changed("malware"))
	
	# Connect to EventBus
	EventBus.log_added.connect(_on_log_added)
	
	# Initialize graph data
	for i in range(GRAPH_MAX_POINTS):
		log_history_data.append(randi_range(5, 15))
	
	_refresh_logs()
	
	# Graph update timer
	var timer = Timer.new()
	timer.wait_time = 1.0
	timer.timeout.connect(_update_graph_data)
	add_child(timer)
	timer.start()

func _on_search_changed(new_text: String):
	current_filter_text = new_text.to_lower()
	_apply_filters()

func _on_filter_critical_toggled(button_pressed: bool):
	only_critical = button_pressed
	_apply_filters()

func _apply_filters():
	var visible_count = 0
	for child in log_list.get_children():
		if child.has_method("get_log_data"):
			var log = child.get_log_data()
			var matches_text = current_filter_text == "" or \
				current_filter_text in log.message.to_lower() or \
				current_filter_text in log.hostname.to_lower() or \
				current_filter_text in log.ip_address.to_lower() or \
				current_filter_text in log.source.to_lower()
			
			var matches_critical = not only_critical or log.severity >= 4
			
			child.visible = matches_text and matches_critical
			if child.visible:
				visible_count += 1
	
	stats_label.text = "FILTERED: %d events matching criteria" % visible_count

func _update_graph_data():
	log_history_data.pop_front()
	var noise = randi_range(-2, 2)
	log_history_data.append(clamp(10 + noise, 0, 40))
	volume_graph.queue_redraw()

func _draw_graph():
	var size = volume_graph.size
	var step = size.x / (GRAPH_MAX_POINTS - 1)
	var max_val = 40.0
	
	var points = PackedVector2Array()
	for i in range(log_history_data.size()):
		var x = i * step
		var y = size.y - (log_history_data[i] / max_val * size.y)
		points.append(Vector2(x, y))
	
	volume_graph.draw_polyline(points, GlobalConstants.UI_COLORS.INFO_BLUE, 2.0, true)
	
	# Subtle fill
	var fill_points = PackedVector2Array()
	fill_points.append(Vector2(0, size.y))
	for p in points: fill_points.append(p)
	fill_points.append(Vector2(size.x, size.y))
	
	var fill_color = GlobalConstants.UI_COLORS.INFO_BLUE
	fill_color.a = 0.1
	volume_graph.draw_colored_polygon(fill_points, fill_color)

func _refresh_logs():
	if not log_list: return
	pool.release_all(log_entry_scene.resource_path)
	
	var logs = LogSystem.get_all_logs() if LogSystem else []
	stats_label.text = "ANALYSIS: %d events discovered" % logs.size()
	
	for log in logs:
		_add_log_entry(log)
	
	_apply_filters()

func _on_log_added(log: LogResource):
	_add_log_entry(log, true)
	_apply_filters()
	# Spike the graph
	log_history_data[log_history_data.size()-1] += 5
	volume_graph.queue_redraw()

func _add_log_entry(log: LogResource, prepend: bool = false):
	var entry = pool.acquire(log_entry_scene)
	if prepend:
		log_list.add_child(entry)
		log_list.move_child(entry, 0)
	else:
		log_list.add_child(entry)
	
	entry.set_log_data(log)
	
	# Implement Zebra Stripping
	var is_even = log_list.get_child_count() % 2 == 0
	if entry.has_method("set_zebra_style"):
		entry.set_zebra_style(is_even)
		
	if not entry.log_selected.is_connected(_on_log_selected):
		entry.log_selected.connect(_on_log_selected)

func _on_log_selected(log: LogResource, instance: Control):
	# Social/Event Consequence: Apply artificial lag
	var lag_duration = 0.1
	if LogSystem:
		lag_duration *= LogSystem.siem_lag_multiplier
	
	if lag_duration > 0.1:
		log_detail_label.text = "[center][i]Retrieving forensic data...[/i][/center]"
		await get_tree().create_timer(lag_duration).timeout
		# Re-verify if this is still the selected log after wait
		if selected_log != log: return

	selected_log = log
	inspector_pane.visible = true
	
	# Format forensic report with extra metadata
	var report = log.get_forensic_report()
	log_detail_label.text = report
	
	for child in log_list.get_children():
		if child.has_method("set_highlight"):
			child.set_highlight(child == instance)

func _on_close_inspector_pressed():
	inspector_pane.visible = false
	selected_log = null
