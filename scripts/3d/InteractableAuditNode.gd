extends StaticBody3D

@export var audit_id: String = "audit_1"
@export var object_name: String = "Network Router"
@export var config: CalibrationMinigameConfig # ADDED THIS LINE

var is_audited: bool = false
var modal_scene = load("res://scenes/ui/AuditSelectionModal.tscn")
var minigame_scene = load("res://scenes/ui/CalibrationMinigame.tscn")

var diag_data = {"temp": 40.0, "loss": 0.0, "voltage": 12.0, "is_critical": false}

func _ready():
	add_to_group("audit_nodes")
	if not config: # ADDED check
		push_error("InteractableAuditNode: No CalibrationMinigameConfig assigned!")
		return
	_generate_random_stats()
	
	# INITIALIZE 3D TECHNICAL TABLE & HIDE IT
	if has_node("%RouterTechnicalTable") and VariableRegistry:
		var identity = VariableRegistry.generate_asset_identity(audit_id)
		get_node("%RouterTechnicalTable").set_identity(identity)
	
	if has_node("AssetTag3D"):
		get_node("AssetTag3D").visible = false
		
	# LISTEN FOR TABLET SELECTION
	EventBus.audit_node_selected.connect(_on_node_selected_remotely)
	
	# Interaction setup
	var area = Area3D.new()
	var coll = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(2, 2, 2)
	coll.shape = shape
	area.add_child(coll)
	add_child(area)
	
	area.body_entered.connect(func(b): 
		if b.name == "Player3D": b.set_near_npc(self, true)
	)
	area.body_exited.connect(func(b): 
		if b.name == "Player3D": b.set_near_npc(self, false)
	)
	
	_update_visuals()

func _generate_random_stats():
	# Use config.is_critical_probability
	diag_data.is_critical = randf() < config.is_critical_probability if config else false
	if diag_data.is_critical:
		diag_data.temp = randf_range(80.0, 100.0)
		diag_data.loss = 0.1
	else:
		diag_data.temp = randf_range(40.0, 50.0)
		diag_data.loss = 0.0

func _on_node_selected_remotely(id: String):
	if has_node("AssetTag3D"):
		var tag = get_node("AssetTag3D")
		if id == audit_id:
			tag.visible = true
			# Auto-hide after 10 seconds to keep world clean
			var timer = get_tree().create_timer(10.0)
			timer.timeout.connect(func(): 
				if is_instance_valid(tag): tag.visible = false
			)
		else:
			tag.visible = false

func start_dialogue(_id = ""):
	if is_audited: return
	
	var player = get_tree().root.find_child("Player3D", true, false)
	if player: player.modal_active = true
	
	var modal = modal_scene.instantiate()
	get_tree().root.add_child(modal)
	modal.setup(diag_data.is_critical)
	modal.action_selected.connect(_on_modal_action)

func _on_modal_action(type: String):
	var player = get_tree().root.find_child("Player3D", true, false)
	if player: player.modal_active = false
	
	if type == "cancel": return
	
	if diag_data.is_critical:
		# If it's bad, you MUST do the minigame
		_start_minigame()
	else:
		# If it's good, you just verify and it finishes instantly
		perform_audit()

func _start_minigame():
	var minigame = minigame_scene.instantiate()
	if config: # Pass the config to the minigame BEFORE adding to tree
		minigame.config = config
	get_tree().root.add_child(minigame)
	minigame.start_game(1.0) # difficulty_modifier is still passed, but config handles main params
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
	var mesh = get_node_or_null("%StatusIndicator")
	if mesh:
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color.GREEN if is_audited else Color.ORANGE
		mat.emission_enabled = true
		mat.emission = Color.GREEN if is_audited else Color.ORANGE
		mat.emission_energy_multiplier = 2.0
		mesh.material_override = mat

var npc_name: String:
	get: return "Audit " + object_name if not is_audited else object_name + " (Verified)"
