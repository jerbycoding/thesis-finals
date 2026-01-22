# App_NetworkMapper.gd
extends Control

@onready var nodes_container: Control = %NodesContainer
@onready var context_menu: PopupMenu = %ContextMenu
@onready var status_label: Label = %StatusLabel

# Inspector Nodes
@onready var hostname_label: Label = %HostnameLabel
@onready var ip_label: Label = %IPLabel
@onready var status_value_label: Label = %StatusValueLabel
@onready var criticality_label: Label = %CriticalityLabel

var node_scene = preload("res://scenes/2d/apps/components/NetworkNode.tscn")
var node_instances: Dictionary = {} # hostname -> instance
var selected_host: HostResource = null

func _ready():
	print("======= App_NetworkMapper (Dashboard Redesign) Ready =======")
	
	_initialize_context_menu()
	EventBus.host_status_changed.connect(_on_host_status_changed)
	
	# Initial Map Generation
	_generate_map()
	
	# Default Inspector State
	_clear_inspector()

func _initialize_context_menu():
	context_menu.clear()
	context_menu.add_item("Perform Forensic Scan", 0)
	context_menu.add_item("Trace Network Path", 1)
	context_menu.add_separator()
	context_menu.add_item("ISOLATE HOST", 2)
	context_menu.index_pressed.connect(_on_context_item_pressed)

func _generate_map():
	for child in nodes_container.get_children(): child.queue_free()
	node_instances.clear()
	
	var hosts = NetworkState.get_all_hosts() if NetworkState else []
	if hosts.is_empty(): return
	
	var center = nodes_container.size / 2
	if center == Vector2.ZERO: center = Vector2(350, 300)
	
	var radius = 220.0
	for i in range(hosts.size()):
		var host = hosts[i]
		var angle = i * (TAU / hosts.size())
		var pos = center + Vector2(cos(angle), sin(angle)) * radius
		
		var inst = node_scene.instantiate()
		nodes_container.add_child(inst)
		inst.position = pos - (inst.size / 2)
		inst.set_host_data(host)
		
		inst.pressed.connect(_on_node_pressed.bind(host))
		node_instances[host.hostname] = inst

func _on_node_pressed(host: HostResource):
	if AudioManager: AudioManager.play_ui_click()
	selected_host = host
	_update_inspector(host)
	
	# Visual selection on map
	for h in node_instances:
		var inst = node_instances[h]
		if inst.has_method("set_highlight"):
			inst.set_highlight(h == host.hostname)

func _update_inspector(host: HostResource):
	hostname_label.text = host.hostname.to_upper()
	ip_label.text = host.ip_address
	
	var current_status = GlobalConstants.HOST_STATUS.CLEAN
	if NetworkState:
		var state = NetworkState.get_host_state(host.hostname)
		var s = state.get("status", 0)
		if typeof(s) == TYPE_INT: current_status = s
		else:
			match str(s):
				"CLEAN": current_status = 0
				"SUSPICIOUS": current_status = 1
				"INFECTED": current_status = 2
				"ISOLATED": current_status = 3
	
	status_value_label.text = host.get_status_string().to_upper()
	
	# Color coding status
	var status_color = Color.WHITE
	match current_status:
		GlobalConstants.HOST_STATUS.CLEAN: status_color = GlobalConstants.UI_COLORS.SUCCESS_FLAT
		GlobalConstants.HOST_STATUS.INFECTED: status_color = GlobalConstants.UI_COLORS.ERROR_FLAT
		GlobalConstants.HOST_STATUS.SUSPICIOUS: status_color = GlobalConstants.UI_COLORS.WARNING_FLAT
		GlobalConstants.HOST_STATUS.ISOLATED: status_color = Color.GRAY
	
	status_value_label.add_theme_color_override("font_color", status_color)
	criticality_label.text = host.get_criticality_string().to_upper()
	
	status_label.text = "ANALYSIS: MONITORING " + host.hostname

func _clear_inspector():
	hostname_label.text = "NO_SELECTION"
	ip_label.text = "---.---.---.---"
	status_value_label.text = "OFFLINE"
	criticality_label.text = "UNKNOWN"
	status_label.text = "ANALYSIS: SYSTEM_NOMINAL"

func _on_host_status_changed(hostname: String, _new_status: int):
	if node_instances.has(hostname):
		var host = NetworkState.get_host(hostname)
		node_instances[hostname].set_host_data(host)
		if selected_host and selected_host.hostname == hostname:
			_update_inspector(host)

func _on_context_item_pressed(index: int):
	if not selected_host: return
	# Context menu implementation...
	pass

func _draw():
	# Procedural connection lines between nodes
	var hosts = node_instances.keys()
	for i in range(hosts.size()):
		var p1 = node_instances[hosts[i]].position + (node_instances[hosts[i]].size / 2)
		# Draw lines to next 2 nodes to create a mesh look
		for j in [1, 2]:
			var target_idx = (i + j) % hosts.size()
			var p2 = node_instances[hosts[target_idx]].position + (node_instances[hosts[target_idx]].size / 2)
			draw_line(p1, p2, Color(1, 1, 1, 0.05), 1.0)
