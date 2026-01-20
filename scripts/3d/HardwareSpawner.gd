# HardwareSpawner.gd
extends Node3D

@export var nvme_scene: PackedScene = preload("res://scenes/3d/props/Prop_NVMe_Drive.tscn")
@export var sata_scene: PackedScene = preload("res://scenes/3d/props/Prop_SATA_Drive.tscn")

func _ready():
	# Only run on Sunday
	if NarrativeDirector and NarrativeDirector.current_shift_name == "shift_sunday":
		call_deferred("_spawn_hardware")

func _spawn_hardware():
	var spawn_points = get_children().filter(func(node): return node is Marker3D)
	if spawn_points.size() < 4:
		print("HardwareSpawner: Not enough spawn markers!")
		return
	
	spawn_points.shuffle()
	
	# Spawn 2 NVMe
	for i in range(2):
		var nvme = nvme_scene.instantiate()
		spawn_points[i].add_child(nvme)
		print("HardwareSpawner: Spawned NVMe at ", spawn_points[i].name)
	
	# Spawn 2 SATA
	for i in range(2, 4):
		var sata = sata_scene.instantiate()
		spawn_points[i].add_child(sata)
		print("HardwareSpawner: Spawned SATA at ", spawn_points[i].name)
	
	# Optional: Spawn "Empty" or "Dead" drives at other points to make it harder
	for i in range(2, min(5, spawn_points.size())):
		var decoy = sata_scene.instantiate()
		decoy.set_meta("is_decoy", true) # We could add logic to make these not work
		spawn_points[i].add_child(decoy)
