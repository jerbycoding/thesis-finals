# TabletHUD.gd
extends Control

@onready var anim = $AnimationPlayer
@onready var topology_map = %TopologyMap
@onready var checklist_container = %ChecklistContainer 
@onready var minigame_host = %MinigameHost
@onready var live_layout = %LiveLayout
@onready var title_label = $HardwareFrame/ScreenMargin/ScreenContent/ContentMargin/VBox/Header/Title

var is_open: bool = false
var pulse_time: float = 0.0
var node_positions: Dictionary = {} 
var dynamic_sunday_hardware_data: Dictionary = {} 

var current_minigame: Node = null
var rule_slider_scene = load("res://scenes/ui/RuleSliderMinigame.tscn")

@export var config: HardwareRecoveryConfig 

func _ready():
	hide()
	topology_map.draw.connect(_draw_topology)
	topology_map.gui_input.connect(_on_map_gui_input)
	EventBus.consequence_triggered.connect(_on_global_event)
	EventBus.shift_started.connect(_on_shift_started)
	
	if not config:
		push_error("TabletHUD: No HardwareRecoveryConfig assigned!")
		return
	
	# Initial check in case shift already started
	if NarrativeDirector and NarrativeDirector.current_shift_resource:
		if NarrativeDirector.current_shift_resource.minigame_type == "RECOVERY":
			_initialize_dynamic_hardware_data()

func _on_shift_started(_shift_id: String):
	if NarrativeDirector and NarrativeDirector.current_shift_resource:
		if NarrativeDirector.current_shift_resource.minigame_type == "RECOVERY":
			_initialize_dynamic_hardware_data()

func _on_map_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var click_pos = event.position
		var closest_node = ""
		var min_dist = 30.0 # Interaction radius
		
		for id in node_positions:
			var dist = click_pos.distance_to(node_positions[id])
			if dist < min_dist:
				min_dist = dist
				closest_node = id
		
		if closest_node != "":
			print("TabletHUD: Remote selecting node ", closest_node)
			EventBus.audit_node_selected.emit(closest_node)
			if AudioManager: AudioManager.play_ui_click()

func toggle():
	if is_open: close()
	else: open()

func open():
	show()
	is_open = true
	anim.play("slide_up")
	node_positions.clear() 
	
	# Reset to default view (Map)
	if current_minigame:
		current_minigame.queue_free()
		current_minigame = null
	
	_refresh_data()
		
	if AudioManager: AudioManager.play_notification("info")

func close():
	# If a minigame is running, stop it
	if current_minigame:
		current_minigame.queue_free()
		current_minigame = null
		live_layout.visible = true
		minigame_host.visible = false

	anim.play_backwards("slide_up")
	await anim.animation_finished
	hide()
	is_open = false

func set_header_title(text: String):
	if title_label:
		title_label.text = text

func load_minigame(type: String):
	# Clear previous
	if current_minigame:
		current_minigame.queue_free()
		current_minigame = null
	
	live_layout.visible = false
	minigame_host.visible = true
	
	match type:
		"RULE_SLIDER":
			set_header_title("APP: ACL_SIGNAL_CALIBRATION")
			if rule_slider_scene:
				current_minigame = rule_slider_scene.instantiate()
				if GameState and GameState.current_computer:
					var target_id = "ROUTER_ALPHA"
					if GameState.current_computer.has_method("get_node_id"):
						target_id = GameState.current_computer.get_node_id()
					else:
						target_id = GameState.current_computer.name.to_upper()
					current_minigame.set_target(target_id)
				else:
					current_minigame.set_target("ROUTER_ALPHA")
			else:
				push_error("TabletHUD: Failed to load RuleSlider scene!")
				return
		"RAID_SYNC":
			set_header_title("APP: MASTER_RAID_INITIALIZER")
			var scene = load("res://scenes/ui/RaidSyncMinigame.tscn")
			if scene:
				current_minigame = scene.instantiate()
			else:
				push_error("TabletHUD: Failed to load RaidSync scene!")
				return
		_:
			push_error("TabletHUD: Unknown minigame type: ", type)
			return
			
	if current_minigame:
		minigame_host.add_child(current_minigame)
		current_minigame.completed.connect(_on_minigame_completed)
		current_minigame.failed.connect(_on_minigame_failed)
		if current_minigame.has_method("start"):
			current_minigame.start()

func _on_minigame_completed(results: Dictionary):
	print("TabletHUD: Minigame Won! Results: ", results)
	if AudioManager: AudioManager.play_sfx(AudioManager.SFX.notification_success)
	# Notify globally for Day 7 payoff
	if results.get("type") == "RAID_REBUILD":
		EventBus.consequence_triggered.emit("RAID_REBUILD", results)
	close()

func _on_minigame_failed(reason: String):
	print("TabletHUD: Minigame Failed! Reason: ", reason)
	if AudioManager: AudioManager.play_sfx(AudioManager.SFX.notification_error)
	# For Day 6, we might want to reload
	if NarrativeDirector and NarrativeDirector.current_shift_resource:
		if NarrativeDirector.current_shift_resource.minigame_type == "AUDIT":
			load_minigame("RULE_SLIDER")

func _initialize_dynamic_hardware_data():
	dynamic_sunday_hardware_data.clear()
	if config:
		for socket_id in config.socket_requirements:
			dynamic_sunday_hardware_data[socket_id] = {"req": config.socket_requirements[socket_id], "ready": false}

func _on_global_event(type: String, details: Dictionary):
	if type == "hardware_slotted":
		var id = details.get("socket_id", "")
		var slotted_type = details.get("type", "")
		if dynamic_sunday_hardware_data.has(id):
			if dynamic_sunday_hardware_data[id].req == slotted_type:
				dynamic_sunday_hardware_data[id].ready = true
			_refresh_data()

func _refresh_data():
	if not is_instance_valid(live_layout): return
	live_layout.visible = true
	minigame_host.visible = false
	set_header_title("FIELD_COMM_UNIT_v4.4")
	
	if not NarrativeDirector or not NarrativeDirector.current_shift_resource: return
	
	var type = NarrativeDirector.current_shift_resource.minigame_type
	if type == "AUDIT":
		topology_map.visible = true
		checklist_container.visible = false
	elif type == "RECOVERY":
		topology_map.visible = false
		checklist_container.visible = true
		
		var ready_count = 0
		var total_count = dynamic_sunday_hardware_data.size()
		
		for child in checklist_container.get_children(): child.queue_free()
		
		# Checklist Header
		var header = Label.new()
		header.text = "MASTER_BACKPLANE_STATUS:"
		header.add_theme_font_size_override("font_size", 11)
		checklist_container.add_child(header)
		
		for rack_id in dynamic_sunday_hardware_data:
			var rack = dynamic_sunday_hardware_data[rack_id]
			if rack.ready: ready_count += 1
			
			var lbl = Label.new()
			lbl.text = "- %s: %s" % [rack_id, "[LINKED]" if rack.ready else "[OFFLINE]"]
			lbl.add_theme_color_override("font_color", GlobalConstants.UI_COLORS.SUCCESS_FLAT if rack.ready else GlobalConstants.UI_COLORS.TEXT_SECONDARY)
			lbl.add_theme_font_size_override("font_size", 10)
			checklist_container.add_child(lbl)
		
		# The Master Button
		var spacer = Control.new()
		spacer.custom_minimum_size.y = 20
		checklist_container.add_child(spacer)
		
		var master_btn = Button.new()
		master_btn.text = " INITIALIZE RAID ARRAY "
		master_btn.disabled = (ready_count < total_count or total_count == 0)
		master_btn.add_theme_font_size_override("font_size", 12)
		
		if not master_btn.disabled:
			master_btn.add_theme_color_override("font_color", Color.WHITE)
		
		master_btn.pressed.connect(func(): load_minigame("RAID_SYNC"))
		checklist_container.add_child(master_btn)
		
		if ready_count == total_count and total_count > 0:
			if NotificationManager:
				NotificationManager.show_notification("HARDWARE SYNC READY: Finalize via Tablet", "info")

func _on_sync_pressed(rack_id: String, hardware_type: String):
	if AudioManager: AudioManager.play_sfx(AudioManager.SFX.notification_success)
	EventBus.consequence_triggered.emit("hardware_repaired", {"rack": rack_id, "type": hardware_type})
	dynamic_sunday_hardware_data.erase(rack_id)
	_refresh_data()

func _process(delta):
	if is_open:
		pulse_time += delta
		if topology_map.visible:
			topology_map.queue_redraw()

func _draw_topology():
	var center = topology_map.size / 2
	var radius = min(topology_map.size.x, topology_map.size.y) * 0.35
	var nodes = get_tree().get_nodes_in_group("audit_nodes")
	
	if nodes.is_empty(): return
	
	if node_positions.is_empty():
		for i in range(nodes.size()):
			var angle = i * (TAU / nodes.size())
			var pos = center + Vector2(cos(angle), sin(angle)) * radius
			node_positions[nodes[i].audit_id] = pos

	for id1 in node_positions:
		for id2 in node_positions:
			if id1 != id2:
				topology_map.draw_line(node_positions[id1], node_positions[id2], Color(0, 0, 0, 0.1), 1.0)

	for n in nodes:
		var pos = node_positions[n.audit_id]
		var is_ok = n.get("is_audited")
		var color = Color.BLACK
		
		if is_ok: color = GlobalConstants.UI_COLORS.SUCCESS_FLAT
		elif n.get("diag_data") and n.get("diag_data").is_critical: color = GlobalConstants.UI_COLORS.ERROR_FLAT
		else: color = Color.BLACK
			
		topology_map.draw_arc(pos, 10.0, 0, TAU, 32, color, 1.5)
		topology_map.draw_circle(pos, 3.0, color)
		
		var font = ThemeDB.get_fallback_font()
		topology_map.draw_string(font, pos + Vector2(-20, 22), n.audit_id.replace("audit_", "R-"), HORIZONTAL_ALIGNMENT_CENTER, -1, 9, color)
