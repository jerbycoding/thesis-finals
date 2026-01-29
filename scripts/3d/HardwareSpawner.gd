# HardwareSpawner.gd
extends Node3D

@export var server_blade_scene: PackedScene = preload("res://scenes/3d/props/graybox/Prop_CarriableBlade.tscn")
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

	# Spawn Standard Blades (Replacing NVMe/SATA counts with unified Blade spawns)
	var blades_to_spawn = config.nvme_to_spawn + config.sata_to_spawn
	for i in range(blades_to_spawn):
		if current_spawn_idx < spawn_points.size():
			var blade = server_blade_scene.instantiate()
			if not blade.is_in_group("carriable"): blade.add_to_group("carriable")
			spawn_points[current_spawn_idx].add_child(blade)
			print("HardwareSpawner: Spawned Server Blade at ", spawn_points[current_spawn_idx].name)
			current_spawn_idx += 1

	# Spawn Decoy Blades
	var decoys_to_spawn = config.decoy_nvme_to_spawn + config.decoy_sata_to_spawn
	for i in range(decoys_to_spawn):
		if current_spawn_idx < spawn_points.size():
			var decoy = server_blade_scene.instantiate()
			if not decoy.is_in_group("carriable"): decoy.add_to_group("carriable")
			decoy.set_meta("is_decoy", true) # Mark as decoy
			spawn_points[current_spawn_idx].add_child(decoy)
			print("HardwareSpawner: Spawned Decoy Blade at ", spawn_points[current_spawn_idx].name)
			current_spawn_idx += 1
