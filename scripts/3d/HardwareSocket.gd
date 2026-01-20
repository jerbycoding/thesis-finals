# HardwareSocket.gd
extends CharacterBody3D

signal object_inserted(obj: Node3D)

@export var socket_id: String = "RACK_1"
@export var accepted_hardware_type: String = "generic"
@export var is_occupied: bool = false

func _ready():
	add_to_group("socket")
	
	# Create the interaction area so the player can "see" the rack
	var area = Area3D.new()
	area.name = "InteractionArea"
	var coll = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(1.5, 1.5, 1.5)
	coll.shape = shape
	area.add_child(coll)
	add_child(area)
	
	# Connect to player detection
	area.body_entered.connect(func(b): if b.name == "Player3D": b.set_near_npc(self, true))
	area.body_exited.connect(func(b): if b.name == "Player3D": b.set_near_npc(self, false))

func can_accept_object(obj: Node3D) -> bool:
	if is_occupied: return false
	var h_type = obj.get("hardware_type") if "hardware_type" in obj else ""
	return h_type == accepted_hardware_type or accepted_hardware_type == "generic"

func on_object_inserted(obj: Node3D):
	if is_occupied: return
	
	var h_type = obj.get("hardware_type") if "hardware_type" in obj else ""
	
	if can_accept_object(obj):
		print("Hardware Socket: Valid object slotted: ", h_type)
		is_occupied = true
		
		# Reparent to socket for perfect placement
		if obj.get_parent():
			obj.get_parent().remove_child(obj)
		add_child(obj)
		obj.position = Vector3.ZERO
		obj.rotation = Vector3.ZERO
		
		# Hybrid Rule: Slotted in 3D, now notify the 2D Tablet
		EventBus.consequence_triggered.emit("hardware_slotted", {
			"socket_id": socket_id,
			"type": h_type
		})
		
		if AudioManager:
			AudioManager.play_sfx(AudioManager.SFX.notification_success)
	else:
		# This fallback is rarely reached now due to PlayerController check
		_show_rejection_feedback()

func _show_rejection_feedback():
	if NotificationManager:
		NotificationManager.show_notification("INCOMPATIBLE HARDWARE: Part does not fit!", "error")
	if AudioManager:
		AudioManager.play_sfx(AudioManager.SFX.notification_error)

# Helper for the PlayerController UI prompt
var npc_name: String:
	get: return "Slot into " + socket_id + " (" + accepted_hardware_type.to_upper().replace("_", " ") + ")"