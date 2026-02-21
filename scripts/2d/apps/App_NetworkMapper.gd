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
	
	if NetworkState:
		NetworkState.hosts_updated.connect(_generate_map)
	
	# Auto-refresh when window is re-opened (visible)
	visibility_changed.connect(func(): if visible: _generate_map())
	
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
	# Skip if not yet in tree to avoid size calculation issues
	if not is_inside_tree(): return
	
	for child in nodes_container.get_children(): child.queue_free()
	node_instances.clear()
	
	var all_hosts = NetworkState.get_all_hosts() if NetworkState else []
	if all_hosts.is_empty(): return
	
	# CATEGORIZE BY ROLE (Hierarchical Logic)
	var core_infra = [] # Gateways, DCs, Mail, VPN
	var business_srv = [] # Finance, Web, DB, VoIP
	var end_user = [] # Workstations, IoT, Research
	
	for host in all_hosts:
		var name = host.hostname.to_upper()
		if "GATEWAY" in name or "CTRL" in name or "MAIL" in name or "VPN" in name or "DC-" in name:
			core_infra.append(host)
		elif "SRV" in name or "SERVER" in name or "VOIP" in name or "DATABASE" in name:
			business_srv.append(host)
		else:
			end_user.append(host)
	
	# LAYOUT CONSTANTS (Explicit Spacing)
	var start_x = 80.0
	var start_y = 60.0
	var row_height = 140.0
	var col_width = 150.0
	var max_map_width = 650.0 # Prevents clipping into inspector
	
	# TIER 1: CORE INFRASTRUCTURE
	for i in range(core_infra.size()):
		var pos = Vector2(start_x + (i * col_width), start_y)
		_create_node_at(core_infra[i], pos)
		
	# TIER 2: BUSINESS SERVERS
	for i in range(business_srv.size()):
		var pos = Vector2(start_x + (i * col_width), start_y + row_height)
		_create_node_at(business_srv[i], pos)
		
	# TIER 3: END-USER ASSETS (Grid Layout)
	var assets_per_row = 4
	var last_y = start_y
	for i in range(end_user.size()):
		var col = i % assets_per_row
		var row = i / assets_per_row
		var pos = Vector2(start_x + (col * col_width), start_y + (row_height * 2) + (row * row_height))
		_create_node_at(end_user[i], pos)
		last_y = pos.y
		
	# ENABLE SCROLLING: Set minimum size to encompass all nodes plus padding
	nodes_container.custom_minimum_size.y = last_y + row_height + 50.0

func _create_node_at(host: HostResource, pos: Vector2):
	var inst = node_scene.instantiate()
	nodes_container.add_child(inst)
	# 센터링 및 패딩 보정
	inst.position = pos
	inst.set_host_data(host)
	inst.pressed.connect(_on_node_pressed.bind(host))
	node_instances[host.hostname] = inst

func _on_node_pressed(host: HostResource):
	if AudioManager: AudioManager.play_ui_click()
	selected_host = host
	_update_inspector(host)
	
	# Signal for tutorial verification
	EventBus.host_selected.emit(host)
	
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
	# Procedural connection lines to show network flow (Subtle mesh)
	var crit_pos = []
	var standard_pos = []
	
	for hostname in node_instances:
		var inst = node_instances[hostname]
		var center = inst.position + (inst.size / 2)
		if inst.host_data.is_critical: crit_pos.append(center)
		else: standard_pos.append(center)
			
	# Connect Core to Rows below
	for cp in crit_pos:
		for sp in standard_pos:
			# Only draw if roughly in the same vertical column area
			if abs(cp.x - sp.x) < 100:
				draw_line(cp, sp, Color(1, 1, 1, 0.02), 1.0)
