# TabletHUD.gd
extends Control

@onready var anim = $AnimationPlayer
@onready var topology_map = %TopologyMap
@onready var checklist_container = %ChecklistContainer 

var is_open: bool = false
var pulse_time: float = 0.0
var node_positions: Dictionary = {} 

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
	if is_open: close()
	else: open()

func open():
	show()
	is_open = true
	anim.play("slide_up")
	node_positions.clear() 
	_refresh_data()
	if AudioManager: AudioManager.play_notification("info")

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
		checklist_container.visible = false
	
	# Sunday Logic
	elif NarrativeDirector and NarrativeDirector.current_shift_name == "shift_sunday":
		topology_map.visible = false
		checklist_container.visible = true
		
		for child in checklist_container.get_children(): child.queue_free()
		for rack_id in sunday_hardware_data:
			var rack = sunday_hardware_data[rack_id]
			var h = HBoxContainer.new()
			
			var lbl = Label.new()
			lbl.text = "%s: %s" % [rack_id, "LOCKED" if rack.ready else "WAITING"]
			lbl.add_theme_color_override("font_color", GlobalConstants.UI_COLORS.SUCCESS_FLAT if rack.ready else GlobalConstants.UI_COLORS.TEXT_SECONDARY)
			lbl.add_theme_font_size_override("font_size", 10)
			lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			
			var btn = Button.new()
			btn.text = " SYNC "
			btn.disabled = not rack.ready
			btn.add_theme_font_size_override("font_size", 9)
			btn.pressed.connect(_on_sync_pressed.bind(rack_id))
			
			h.add_child(lbl)
			h.add_child(btn)
			checklist_container.add_child(h)

func _on_sync_pressed(rack_id: String):
	if AudioManager: AudioManager.play_sfx(AudioManager.SFX.notification_success)
	EventBus.consequence_triggered.emit("hardware_repaired", {"rack": rack_id})
	sunday_hardware_data.erase(rack_id)
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

	# 1. Draw Mesh Connections
	for id1 in node_positions:
		for id2 in node_positions:
			if id1 != id2:
				topology_map.draw_line(node_positions[id1], node_positions[id2], Color(0, 0, 0, 0.1), 1.0)

	# 2. Draw Nodes
	for n in nodes:
		var pos = node_positions[n.audit_id]
		var is_ok = n.get("is_audited")
		var color = Color.BLACK
		
		if is_ok:
			color = GlobalConstants.UI_COLORS.SUCCESS_FLAT
		elif n.get("diag_data") and n.get("diag_data").is_critical:
			color = GlobalConstants.UI_COLORS.ERROR_FLAT
		else:
			color = Color.BLACK
			
		topology_map.draw_arc(pos, 10.0, 0, TAU, 32, color, 1.5)
		topology_map.draw_circle(pos, 3.0, color)
		
		var font = ThemeDB.get_fallback_font()
		topology_map.draw_string(font, pos + Vector2(-20, 22), n.audit_id.replace("audit_", "R-"), HORIZONTAL_ALIGNMENT_CENTER, -1, 9, color)
