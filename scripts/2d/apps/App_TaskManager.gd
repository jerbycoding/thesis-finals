# App_TaskManager.gd
extends Control

@onready var cpu_graph = %CPUGraph
@onready var net_graph = %NetGraph
@onready var cpu_legend = %CPULegend
@onready var net_legend = %NetLegend

# History for 4 CPU Cores
var cpu_data: Array[Array] = [[], [], [], []]
# History for Net (Down/Up)
var net_data: Array[Array] = [[], []]

var max_history = 60
var colors = [Color.GREEN, Color.RED, Color.CYAN, Color.GOLD]

func _ready():
	# Initialize history with noise
	for i in range(4):
		for j in range(max_history):
			cpu_data[i].append(randf_range(10, 30))
	for i in range(2):
		for j in range(max_history):
			net_data[i].append(randf_range(2, 10))
			
	cpu_graph.draw.connect(_draw_cpu)
	net_graph.draw.connect(_draw_net)
	
	# Update timer
	var timer = Timer.new()
	timer.wait_time = 0.5
	timer.timeout.connect(_on_tick)
	add_child(timer)
	timer.start()

func _on_tick():
	# Procedural Update
	for i in range(4):
		cpu_data[i].pop_front()
		var target = 20.0
		if NarrativeDirector and NarrativeDirector.is_shift_active():
			target += 15.0
		cpu_data[i].append(clamp(target + randf_range(-10, 10), 0, 100))
		
	for i in range(2):
		net_data[i].pop_front()
		net_data[i].append(clamp(5.0 + randf_range(-3, 3), 0, 100))
		
	_update_legends()
	cpu_graph.queue_redraw()
	net_graph.queue_redraw()

func _update_legends():
	cpu_legend.text = "CPU1 %d%%  CPU2 %d%%  CPU3 %d%%  CPU4 %d%%" % [
		int(cpu_data[0].back()), int(cpu_data[1].back()), 
		int(cpu_data[2].back()), int(cpu_data[3].back())
	]
	net_legend.text = "Download: %d B/s  Upload: %d B/s" % [
		int(net_data[0].back() * 50), int(net_data[1].back() * 20)
	]

func _draw_cpu():
	_draw_background_grid(cpu_graph)
	for i in range(4):
		_draw_data_line(cpu_graph, cpu_data[i], colors[i])

func _draw_net():
	_draw_background_grid(net_graph)
	_draw_data_line(net_graph, net_data[0], Color.GREEN)
	_draw_data_line(net_graph, net_data[1], Color.RED)

func _draw_background_grid(canvas: Control):
	var size = canvas.size
	var grid_color = Color(1, 1, 1, 0.05)
	
	# Vertical Lines
	for i in range(1, 5):
		var x = (size.x / 4) * i
		canvas.draw_line(Vector2(x, 0), Vector2(x, size.y), grid_color, 1.0)
		
	# Horizontal Lines
	for i in range(1, 4):
		var y = (size.y / 4) * i
		canvas.draw_line(Vector2(0, y), Vector2(size.x, y), grid_color, 1.0)

func _draw_data_line(canvas: Control, data: Array, color: Color):
	var size = canvas.size
	var step = size.x / (max_history - 1)
	var points = PackedVector2Array()
	
	for i in range(data.size()):
		var x = i * step
		var y = size.y - (data[i] / 100.0 * size.y)
		points.append(Vector2(x, y))
		
	if points.size() > 1:
		canvas.draw_polyline(points, color, 1.5, true)
