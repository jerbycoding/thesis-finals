extends Control

@onready var nodes_container: Control = %NodesContainer
@onready var context_menu: PopupMenu = %ContextMenu
@onready var status_label: Label = %StatusLabel

var node_scene = preload("res://scenes/2d/apps/components/NetworkNode.tscn") # We need to create this too
var nodes: Dictionary = {} # hostname: Control
var selected_host: String = ""

# Layout configuration
var center_pos: Vector2 = Vector2(400, 300)
var server_radius: float = 120.0
var workstation_radius: float = 220.0

var pulse_time: float = 0.0

func _process(delta):
	pulse_time += delta
	queue_redraw()

func _ready():
	# Temporary placeholder until we create the node component
	# node_scene = Button.new() # Just for logic testing if needed, but we'll make the scene next
	
	_build_network_map()
	
	# Connect context menu
	context_menu.id_pressed.connect(_on_context_menu_action)
	
	# Start update timer
	var timer = Timer.new()
	timer.wait_time = 0.5
	timer.timeout.connect(_update_node_status)
	add_child(timer)
	timer.start()

func _build_network_map():
	if not NetworkState: return
	
	var all_hosts = NetworkState.get_all_hostnames()
	var servers = []
	var workstations = []
	
	# Categorize
	for host in all_hosts:
		if NetworkState.get_host_state(host).get("critical", false):
			servers.append(host)
		else:
			workstations.append(host)
	
	# Place Servers (Ring 1)
	var angle_step = TAU / max(1, servers.size())
	for i in range(servers.size()):
		var angle = i * angle_step
		var pos = center_pos + Vector2(cos(angle), sin(angle)) * server_radius
		_create_node(servers[i], pos, true)
		
	# Place Workstations (Ring 2)
	angle_step = TAU / max(1, workstations.size())
	for i in range(workstations.size()):
		var angle = i * angle_step + (PI/servers.size()) # Offset slightly
		var pos = center_pos + Vector2(cos(angle), sin(angle)) * workstation_radius
		_create_node(workstations[i], pos, false)
	
	queue_redraw()

func _create_node(hostname: String, position: Vector2, is_server: bool):
	var node_btn = node_scene.instantiate()
	node_btn.position = position - Vector2(30, 30) # Centered (60x60)
	
	if node_btn.has_method("set_hostname"):
		node_btn.set_hostname(hostname, is_server)
	else:
		node_btn.text = hostname # Fallback
		
	node_btn.gui_input.connect(_on_node_input.bind(hostname))
	
	nodes_container.add_child(node_btn)
	nodes[hostname] = node_btn
	
	# Store metadata for drawing lines
	node_btn.set_meta("is_server", is_server)
	node_btn.set_meta("center_pos", position)

func _update_node_status():
	if not NetworkState: return
	
	for hostname in nodes:
		var node_btn = nodes[hostname]
		var state = NetworkState.get_host_state(hostname)
		var status = state.get("status", "CLEAN")
		var is_isolated = state.get("isolated", false)
		
		var color = Color(0, 1, 1) # Cyan (Clean)
		
		if is_isolated:
			color = Color(0.5, 0.5, 0.5) # Gray
		elif status == "INFECTED":
			color = Color(1, 0, 0) # Red
		elif status == "SUSPICIOUS":
			color = Color(1, 0.5, 0) # Orange
			
		if node_btn.has_method("set_status_color"):
			node_btn.set_status_color(color)
		else:
			node_btn.modulate = color

func _draw():
	# Draw lines from center to servers, and servers to nearby workstations?
	# Simple star topology for now: Center(Gateway) -> All
	var center = center_pos
	
	# Pulse effect for lines
	var alpha = 0.2 + (sin(pulse_time * 3.0) + 1.0) * 0.15
	var line_color = Color(0, 0.8, 0.8, alpha)
	var line_width = 1.5 + (sin(pulse_time * 3.0) + 1.0) * 0.5
	
	for hostname in nodes:
		var node = nodes[hostname]
		var target = node.get_meta("center_pos")
		
		# Check if host is isolated
		var state = NetworkState.get_host_state(hostname)
		if state.get("isolated", false):
			draw_line(center, target, Color(0.3, 0.3, 0.3, 0.2), 1.0)
		else:
			# If infected, pulse red
			if state.get("status") == "INFECTED":
				var inf_alpha = 0.4 + (sin(pulse_time * 8.0) + 1.0) * 0.3
				draw_line(center, target, Color(1, 0, 0, inf_alpha), line_width + 1.0)
			else:
				draw_line(center, target, line_color, line_width)

func _on_node_input(event: InputEvent, hostname: String):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		selected_host = hostname
		context_menu.clear()
		context_menu.add_item("Scan Host", 0)
		context_menu.add_item("Isolate Host", 1)
		context_menu.add_item("Trace Connection", 2)
		context_menu.position = get_global_mouse_position()
		context_menu.popup()

func _on_context_menu_action(id: int):
	if selected_host == "": return
	
	if ArchetypeAnalyzer:
		ArchetypeAnalyzer.log_tool_used("network_map")
	
	match id:
		0: # Scan
			TerminalSystem.execute_command("scan " + selected_host)
		1: # Isolate
			TerminalSystem.execute_command("isolate " + selected_host)
		2: # Trace
			# Find IP
			var state = NetworkState.get_host_state(selected_host)
			var ip = state.get("ip", "")
			if ip != "":
				TerminalSystem.execute_command("trace " + ip)
			else:
				if NotificationManager:
					NotificationManager.show_notification("IP not resolved for host", "error")
