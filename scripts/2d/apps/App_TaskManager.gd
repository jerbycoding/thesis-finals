# App_TaskManager.gd
extends Control

@onready var cpu_graph = %CPU_Graph
@onready var net_graph = %Net_Graph
@onready var cpu_value_label = %CPU_Value
@onready var net_value_label = %Net_Value
@onready var event_label = %Event_Label

var cpu_history: Array[float] = []
var net_history: Array[float] = []
var max_history = 50

var base_cpu = 15.0
var base_net = 2.0

var active_events: Dictionary = {}

func _ready():
	visible = true
	modulate = Color.WHITE
	
	# Connect to NarrativeDirector for world events
	if NarrativeDirector:
		NarrativeDirector.world_event.connect(_on_world_event)
	
	# Initialize history with base values
	for i in range(max_history):
		cpu_history.append(base_cpu + randf_range(-2, 2))
		net_history.append(base_net + randf_range(-0.5, 0.5))
	
	# Connect graphs to draw
	cpu_graph.draw.connect(_draw_cpu_graph)
	net_graph.draw.connect(_draw_net_graph)
	
	# Update timer
	var timer = Timer.new()
	timer.wait_time = 0.5
	timer.timeout.connect(_on_update_tick)
	add_child(timer)
	timer.start()

func _on_world_event(event_id: String, active: bool, duration: float):
	if active:
		active_events[event_id] = true
		print("TaskManager: System event active: ", event_id)
	else:
		if active_events.has(event_id):
			active_events.erase(event_id)
			print("TaskManager: System event cleared: ", event_id)

func _on_update_tick():
	# Calculate target values based on "Lag" or events
	var target_cpu = base_cpu
	var target_net = base_net
	var status_text = "SYSTEM STATUS: NOMINAL"
	var status_color = Color.GREEN
	
	# Apply event-based multipliers
	if active_events.has("SIEM_LAG"):
		target_net += 50.0 + randf_range(0, 100)
		status_text = "STATUS: NETWORK INSTABILITY"
		status_color = Color.YELLOW
	
	if active_events.has("ZERO_DAY"):
		target_cpu += 40.0 + randf_range(0, 20)
		status_text = "STATUS: HIGH RESOURCE DEMAND"
		status_color = Color.ORANGE
	
	if active_events.has("FALSE_FLAG"):
		target_cpu += 20.0 + randf_range(0, 10)
		status_text = "STATUS: HIGH BACKGROUND PROCESS VOLUME"
		status_color = Color.YELLOW
	
	# If we have a lot of active tickets, CPU goes up
	if TicketManager:
		target_cpu += TicketManager.get_active_tickets().size() * 5.0
	
	# Random spikes
	target_cpu += randf_range(-3, 3)
	target_net += randf_range(-1, 1)
	
	# Update history
	cpu_history.pop_front()
	cpu_history.append(clamp(target_cpu, 0, 100))
	
	net_history.pop_front()
	net_history.append(clamp(target_net, 0, 1000))
	
	# Update Labels
	cpu_value_label.text = "%d%%" % int(cpu_history.back())
	net_value_label.text = "%.1f Mbps" % net_history.back()
	
	# Override status if critical
	if cpu_history.back() > 90:
		status_text = "SYSTEM STATUS: CRITICAL LOAD"
		status_color = Color.RED
	elif active_events.is_empty() and cpu_history.back() > 70:
		status_text = "SYSTEM STATUS: HIGH LOAD"
		status_color = Color.ORANGE
	
	event_label.text = status_text
	event_label.add_theme_color_override("font_color", status_color)
	
	# Redraw
	cpu_graph.queue_redraw()
	net_graph.queue_redraw()

func _draw_cpu_graph():
	_draw_line_graph(cpu_graph, cpu_history, Color.CYAN, 100.0)

func _draw_net_graph():
	_draw_line_graph(net_graph, net_history, Color.GREEN, 100.0) # Normalized to 100 for visual

func _draw_line_graph(canvas: Control, data: Array[float], color: Color, max_val: float):
	var size = canvas.size
	var step = size.x / (max_history - 1)
	
	var points = PackedVector2Array()
	for i in range(data.size()):
		var x = i * step
		var y = size.y - (data[i] / max_val * size.y)
		points.append(Vector2(x, y))
	
	if points.size() > 1:
		canvas.draw_polyline(points, color, 2.0, true)
		
		# Draw a subtle gradient fill below
		var fill_points = PackedVector2Array()
		fill_points.append(Vector2(0, size.y)) # Bottom left
		for p in points:
			fill_points.append(p)
		fill_points.append(Vector2(size.x, size.y)) # Bottom right
		
		var fill_color = color
		fill_color.a = 0.2
		canvas.draw_colored_polygon(fill_points, fill_color)
