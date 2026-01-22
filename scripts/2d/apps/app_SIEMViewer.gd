# app_SIEMViewer.gd
extends Control

@onready var log_list: VBoxContainer = %LogList
@onready var volume_graph: Control = %VolumeGraph
@onready var stats_label: Label = %StatsLabel
@onready var close_inspector_button: Button = %CloseInspectorButton
@onready var inspector_pane: Control = %InspectorPane
@onready var log_detail_label: RichTextLabel = %LogDetailLabel

var log_entry_scene = preload("res://scenes/2d/apps/components/LogEntry.tscn")
var pool: UIObjectPool

var selected_log: LogResource = null
var log_history_data: Array[int] = [] # For the graph
const GRAPH_MAX_POINTS = 60

func _ready():
	print("======= App_SIEMViewer (Forensics Redesign) Ready =======")
	
	pool = UIObjectPool.new()
	add_child(pool)
	
	volume_graph.draw.connect(_draw_graph)
	close_inspector_button.pressed.connect(_on_close_inspector_pressed)
	
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

func _on_log_added(log: LogResource):
	_add_log_entry(log, true)
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
	if not entry.log_selected.is_connected(_on_log_selected):
		entry.log_selected.connect(_on_log_selected)

func _on_log_selected(log: LogResource, instance: Control):
	selected_log = log
	inspector_pane.visible = true
	log_detail_label.text = log.get_forensic_report()
	
	for child in log_list.get_children():
		if child.has_method("set_highlight"):
			child.set_highlight(child == instance)

func _on_close_inspector_pressed():
	inspector_pane.visible = false
	selected_log = null
