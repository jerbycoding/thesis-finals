# CarryableHardware.gd
extends CharacterBody3D # Using CharacterBody3D so it can be detected by interaction areas

@export var hardware_type: String = "generic" # "hard_drive", "cable", etc.

func _ready():
	add_to_group("carryable")
	
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

# Helper for the PlayerController set_near_npc call
var npc_name: String:
	get: return hardware_type.replace("_", " ").capitalize()
