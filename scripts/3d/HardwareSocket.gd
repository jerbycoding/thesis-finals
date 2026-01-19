# HardwareSocket.gd
extends CharacterBody3D

signal object_inserted(obj: Node3D)

@export var accepted_hardware_type: String = "generic"
@export var is_occupied: bool = false

func _ready():
	add_to_group("socket")
	
	# Set up interaction area
	if not has_node("InteractionArea"):
		var area = Area3D.new()
		area.name = "InteractionArea"
		var coll = CollisionShape3D.new()
		var shape = BoxShape3D.new()
		shape.size = Vector3(1.5, 1.5, 1.5)
		coll.shape = shape
		area.add_child(coll)
		add_child(area)
		
		area.body_entered.connect(func(b): if b.name == "Player3D": b.set_near_npc(self, true))
		area.body_exited.connect(func(b): if b.name == "Player3D": b.set_near_npc(self, false))

func on_object_inserted(obj: Node3D):
	if is_occupied: return
	
	var h_type = obj.get("hardware_type") if "hardware_type" in obj else ""
	
	if h_type == accepted_hardware_type or accepted_hardware_type == "generic":
		print("Hardware Socket: Valid object inserted!")
		is_occupied = true
		
		# Snapping: Move the object exactly to the socket's position
		obj.global_transform = global_transform
		
		object_inserted.emit(obj)
		EventBus.consequence_triggered.emit("hardware_repaired", {"type": h_type})
		
		if AudioManager:
			AudioManager.play_sfx(AudioManager.SFX.notification_success)
	else:
		print("Hardware Socket: Incompatible hardware type.")
		if AudioManager:
			AudioManager.play_sfx(AudioManager.SFX.notification_error)

# Helper for the PlayerController set_near_npc call
var npc_name: String:
	get: return "Target Socket (" + accepted_hardware_type.capitalize() + ")"
