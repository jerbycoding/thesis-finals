extends StaticBody3D

@export var audit_id: String = "audit_1"
@export var object_name: String = "Network Router"

var is_audited: bool = false
var diag_ui_scene = preload("res://scenes/ui/DiagnosticUI.tscn")
var minigame_scene = preload("res://scenes/ui/CalibrationMinigame.tscn")

var diag_data = {"temp": 40.0, "loss": 0.0, "voltage": 12.0, "is_critical": false}

func _ready():
	add_to_group("audit_nodes")
	_generate_random_stats()
	
	# Interaction setup
	var area = Area3D.new()
	var coll = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(2, 2, 2)
	coll.shape = shape
	area.add_child(coll)
	add_child(area)
	
	area.body_entered.connect(func(b): if b.name == "Player3D": b.set_near_npc(self, true))
	area.body_exited.connect(func(b): if b.name == "Player3D": b.set_near_npc(self, false))
	
	_update_visuals()

func _generate_random_stats():
	diag_data.is_critical = randf() < 0.4
	if diag_data.is_critical:
		diag_data.temp = randf_range(80.0, 100.0)
		diag_data.loss = 0.1
	else:
		diag_data.temp = randf_range(40.0, 50.0)
		diag_data.loss = 0.0

func start_dialogue(_id = ""):
	if is_audited: return
	var ui = diag_ui_scene.instantiate()
	get_tree().root.add_child(ui)
	ui.show_diagnostics(diag_data)
	ui.diagnostic_action.connect(_on_diagnostic_action)

func _on_diagnostic_action(action: String):
	if action == "verify" and not diag_data.is_critical:
		perform_audit()
	elif action == "repair" and diag_data.is_critical:
		_start_minigame()
	else:
		# Loss Logic: Penalty for incorrect diagnostic judgment
		if NotificationManager: 
			NotificationManager.show_notification("JUDGMENT ERROR: Operational integrity compromised!", "error")
		if IntegrityManager:
			IntegrityManager._apply_change(-5.0) # Significant penalty
		perform_audit()

func _start_minigame():
	var minigame = minigame_scene.instantiate()
	get_tree().root.add_child(minigame)
	minigame.start_game(1.0)
	minigame.minigame_success.connect(perform_audit)
	minigame.minigame_failed.connect(_on_minigame_fail)

func _on_minigame_fail():
	# Loss Logic: Penalty for failing the technical handshake
	if NotificationManager:
		NotificationManager.show_notification("HANDSHAKE FAILURE: System instability detected.", "warning")
	if IntegrityManager:
		IntegrityManager._apply_change(-2.0) # Small penalty for technical error

func perform_audit():
	is_audited = true
	EventBus.consequence_triggered.emit("audit_complete", {"id": audit_id})
	_update_visuals()

func _update_visuals():
	var mesh = get_node_or_null("MeshInstance3D")
	if mesh:
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color.GREEN if is_audited else Color.ORANGE
		mat.emission_enabled = true
		mat.emission = Color.GREEN if is_audited else Color.ORANGE
		mesh.material_override = mat

var npc_name: String:
	get: return "Audit " + object_name if not is_audited else object_name + " (Verified)"
