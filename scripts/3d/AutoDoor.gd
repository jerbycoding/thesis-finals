# AutoDoor.gd
# Reusable door that opens when player approaches
extends Area3D

@onready var sliding_door = $SlidingDoor

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "Player3D":
		if sliding_door and sliding_door.has_method("open"):
			sliding_door.open()

func _on_body_exited(body):
	if body.name == "Player3D":
		if sliding_door and sliding_door.has_method("close"):
			sliding_door.close()
