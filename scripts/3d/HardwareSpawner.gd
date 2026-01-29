# HardwareSpawner.gd
extends Node3D

@export var nvme_scene: PackedScene = preload("res://scenes/3d/props/graybox/Prop_NVMe_Drive.tscn")
@export var sata_scene: PackedScene = preload("res://scenes/3d/props/graybox/Prop_SATA_Drive.tscn")
@export var config: HardwareRecoveryConfig # ADDED THIS LINE

func _ready():
	# Only run if this is a Recovery shift (e.g. Sunday)
	if NarrativeDirector and NarrativeDirector.current_shift_resource:
		if NarrativeDirector.current_shift_resource.minigame_type == "RECOVERY":
			call_deferred("_spawn_hardware")

func _spawn_hardware():
	if not config: # ADDED check
		push_error("HardwareSpawner: No HardwareRecoveryConfig assigned!")
		return

	var spawn_points = get_children().filter(func(node): return node is Marker3D)
	var total_items_to_spawn = config.nvme_to_spawn + config.sata_to_spawn + config.decoy_nvme_to_spawn + config.decoy_sata_to_spawn
	
	if spawn_points.size() < total_items_to_spawn:
		push_error("HardwareSpawner: Not enough spawn markers (%d) for configured hardware (%d)!" % [spawn_points.size(), total_items_to_spawn])
		return
	
	spawn_points.shuffle()
	var current_spawn_idx = 0

	# Spawn NVMe
	for i in range(config.nvme_to_spawn):
		if current_spawn_idx < spawn_points.size():
			var nvme = nvme_scene.instantiate()
			if not nvme.is_in_group("carriable"): nvme.add_to_group("carriable")
			spawn_points[current_spawn_idx].add_child(nvme)
			print("HardwareSpawner: Spawned NVMe at ", spawn_points[current_spawn_idx].name)
			current_spawn_idx += 1
	
	# Spawn SATA
	for i in range(config.sata_to_spawn):
		if current_spawn_idx < spawn_points.size():
			var sata = sata_scene.instantiate()
			if not sata.is_in_group("carriable"): sata.add_to_group("carriable")
			spawn_points[current_spawn_idx].add_child(sata)
			print("HardwareSpawner: Spawned SATA at ", spawn_points[current_spawn_idx].name)
			current_spawn_idx += 1

	# Spawn Decoy NVMe
	for i in range(config.decoy_nvme_to_spawn):
		if current_spawn_idx < spawn_points.size():
			var decoy = nvme_scene.instantiate()
			if not decoy.is_in_group("carriable"): decoy.add_to_group("carriable")
			decoy.set_meta("is_decoy", true) # Mark as decoy
			spawn_points[current_spawn_idx].add_child(decoy)
			print("HardwareSpawner: Spawned Decoy NVMe at ", spawn_points[current_spawn_idx].name)
			current_spawn_idx += 1

	# Spawn Decoy SATA
	for i in range(config.decoy_sata_to_spawn):
		if current_spawn_idx < spawn_points.size():
			var decoy = sata_scene.instantiate()
			if not decoy.is_in_group("carriable"): decoy.add_to_group("carriable")
			decoy.set_meta("is_decoy", true) # Mark as decoy
			spawn_points[current_spawn_idx].add_child(decoy)
			print("HardwareSpawner: Spawned Decoy SATA at ", spawn_points[current_spawn_idx].name)
			current_spawn_idx += 1
