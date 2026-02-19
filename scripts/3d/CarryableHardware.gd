# CarryableHardware.gd
extends CharacterBody3D # Using CharacterBody3D so it can be detected by interaction areas

@export var hardware_type: String = "generic" # "hard_drive", "cable", etc.

@onready var beacon_light: OmniLight3D = get_node_or_null("BeaconLight")
var _pulse_time: float = 0.0
var _is_in_vault: bool = false

func _ready():
	add_to_group("carryable")
	
	# Only enable beacon logic in the Server Vault
	if get_tree().current_scene:
		_is_in_vault = get_tree().current_scene.name == "ServerVault"
	
	# Set up a generic interaction area if one doesn't exist
	if not has_node("InteractionArea"):
		var area = Area3D.new()
		area.name = "InteractionArea"
		var coll = CollisionShape3D.new()
		var shape = BoxShape3D.new()
		shape.size = Vector3(1, 1, 1)
		coll.shape = shape
		area.add_child(coll)
		add_child(area)
		
		area.body_entered.connect(func(b): if b.name == "Player3D": b.set_near_npc(self, true))
		area.body_exited.connect(func(b): if b.name == "Player3D": b.set_near_npc(self, false))

func _process(delta):
	if _is_in_vault and beacon_light:
		_update_beacon(delta)

func _update_beacon(delta):
	var parent = get_parent()
	if not parent: return
	
	# Don't pulse if slotted into a rack or being carried by the player
	# Sockets are in the "socket" group. Player carry marker usually has "Carry" in name.
	var is_slotted = parent.is_in_group("socket")
	var is_carried = "Marker" in parent.name and not parent is Marker3D
	
	if not is_slotted and not is_carried:
		_pulse_time += delta * 4.0
		beacon_light.light_energy = 1.5 + sin(_pulse_time) * 1.5
		beacon_light.visible = true
	else:
		beacon_light.light_energy = 0
		beacon_light.visible = false

# Helper for the PlayerController set_near_npc call
var npc_name: String:
	get: return hardware_type.replace("_", " ").capitalize()
