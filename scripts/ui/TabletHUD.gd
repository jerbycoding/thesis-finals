extends Control

@onready var anim = $AnimationPlayer
@onready var topology_map = %TopologyMap
@onready var radar_sweep = %RadarSweep
@onready var router_list = %ChecklistContainer # Reusing this for Sunday list

var is_open: bool = false
var pulse_time: float = 0.0
var node_positions: Dictionary = {} # id: Vector2

var sunday_hardware_data: Dictionary = {
	"RACK_1": {"req": "nvme_drive", "ready": false},
	"RACK_2": {"req": "nvme_drive", "ready": false},
	"RACK_4": {"req": "sata_drive", "ready": false},
	"RACK_5": {"req": "sata_drive", "ready": false}
}

func _ready():
	hide()
	topology_map.draw.connect(_draw_topology)
	EventBus.consequence_triggered.connect(_on_global_event)

func toggle():
	if is_open:
		close()
	else:
		open()

func open():
	show()
	is_open = true
	anim.play("slide_up")
	node_positions.clear() # Recalculate layout
	_refresh_data()
	if AudioManager:
		AudioManager.play_notification("info")

func close():
	anim.play_backwards("slide_up")
	await anim.animation_finished
	hide()
	is_open = false

func _on_global_event(type: String, details: Dictionary):
	if type == "hardware_slotted":
		var id = details.get("socket_id", "")
		if sunday_hardware_data.has(id):
			sunday_hardware_data[id].ready = true
			_refresh_data()

func _refresh_data():
	# Saturday Logic
	if NarrativeDirector and NarrativeDirector.current_shift_name == "shift_saturday":
		topology_map.visible = true
		router_list.visible = false
	
	# Sunday Logic
	elif NarrativeDirector and NarrativeDirector.current_shift_name == "shift_sunday":
		topology_map.visible = false
		router_list.visible = true
		
		for child in router_list.get_children(): child.queue_free()
		for rack_id in sunday_hardware_data:
			var rack = sunday_hardware_data[rack_id]
			var h = HBoxContainer.new()
			
			var lbl = Label.new()
			lbl.text = "%s: [%s]" % [rack_id, "READY" if rack.ready else "WAITING PART (" + rack.req.to_upper() + ")"]
			lbl.add_theme_color_override("font_color", Color.GREEN if rack.ready else Color.ORANGE)
			lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			
			var btn = Button.new()
			btn.text = "SYNC"
			btn.disabled = not rack.ready
			btn.pressed.connect(_on_sync_pressed.bind(rack_id))
			
			h.add_child(lbl)
			h.add_child(btn)
			router_list.add_child(h)

func _on_sync_pressed(rack_id: String):
	# Direct Sync Logic for Sunday (Removes Minigame to fix stacking bug)
	print("TabletHUD: Direct Sync authorized for ", rack_id)
	
	if AudioManager:
		AudioManager.play_sfx(AudioManager.SFX.notification_success)
	
	if NotificationManager:
		NotificationManager.show_notification("REBUILD INITIALIZED: " + rack_id, "success")
	
	# Trigger completion immediately
	EventBus.consequence_triggered.emit("hardware_repaired", {"rack": rack_id})
	sunday_hardware_data.erase(rack_id)
	_refresh_data()

func _process(delta):
	if is_open:
		pulse_time += delta
		if topology_map.visible:
			topology_map.queue_redraw()
		# Simple sweep animation
		if radar_sweep:
			radar_sweep.modulate.a = (sin(pulse_time * 2.0) + 1.0) * 0.05

func _draw_topology():
	var center = topology_map.size / 2
	var radius = min(topology_map.size.x, topology_map.size.y) * 0.35
	var nodes = get_tree().get_nodes_in_group("audit_nodes")
	
	if nodes.is_empty(): return
	
	# Calculate positions if needed
	if node_positions.is_empty():
		for i in range(nodes.size()):
			var angle = i * (TAU / nodes.size())
			var pos = center + Vector2(cos(angle), sin(angle)) * radius
			node_positions[nodes[i].audit_id] = pos

	# 1. Draw Mesh Connections (Lines)
	for id1 in node_positions:
		for id2 in node_positions:
			if id1 != id2:
				var alpha = 0.1 + (sin(pulse_time * 3.0) + 1.0) * 0.05
				topology_map.draw_line(node_positions[id1], node_positions[id2], Color(0, 1, 1, alpha), 1.0)

	# 2. Draw Nodes
	for n in nodes:
		var pos = node_positions[n.audit_id]
		var is_ok = n.get("is_audited")
		var color = Color.CYAN
		
		if is_ok:
			color = Color.GREEN
		elif n.get("diag_data") and n.get("diag_data").is_critical:
			# Pulse Red if critical
			var pulse = (sin(pulse_time * 10.0) + 1.0) * 0.5
			color = Color.RED.lerp(Color.ORANGE, pulse)
		else:
			color = Color.CYAN
			
		# Draw outer ring
		topology_map.draw_arc(pos, 12.0, 0, TAU, 32, color, 2.0)
		# Draw inner dot
		topology_map.draw_circle(pos, 4.0, color)
		# Draw Label
		var font = ThemeDB.get_fallback_font()
		topology_map.draw_string(font, pos + Vector2(-20, 25), n.audit_id.replace("audit_", "R-"), HORIZONTAL_ALIGNMENT_CENTER, -1, 10, color)