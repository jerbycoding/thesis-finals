# PropSpawner.gd
# @tool allows this to run in the Godot Editor
@tool
extends Node

@export var chair_scene: PackedScene
@export var monitor_scene: PackedScene
@export var plant_scene: PackedScene
@export var clutter_scenes: Array[PackedScene] = []

@export var trigger_spawn: bool = false:
	set(val):
		if val:
			spawn_props()
		trigger_spawn = false

@export var clear_props: bool = false:
	set(val):
		if val:
			_clear_existing_props()
		clear_props = false

func _ready():
	# If we are in the game (not editor), check if props already exist
	if not Engine.is_editor_hint():
		if not _do_props_exist():
			print("PropSpawner: No baked props found, spawning at runtime.")
			spawn_props()
		else:
			print("PropSpawner: Using baked props.")

func _do_props_exist() -> bool:
	var placeholders = get_node_or_null("../Placeholders")
	if not placeholders: return false
	
	for desk in placeholders.get_children():
		if "Desk_Row" in desk.name:
			for child in desk.get_children():
				if child.name.begins_with("Generated_"):
					return true
	return false

func _clear_existing_props():
	var placeholders = get_node_or_null("../Placeholders")
	if not placeholders: return
	
	for desk in placeholders.get_children():
		if "Desk_Row" in desk.name:
			# Find nodes starting with "Generated_"
			var to_free = []
			for child in desk.get_children():
				if child.name.begins_with("Generated_"):
					to_free.append(child)
			
			for node in to_free:
				node.free() # Use free in tool mode for immediate results
				
	print("PropSpawner: Cleared all generated props.")

func spawn_props():
	if not chair_scene or not monitor_scene:
		push_warning("PropSpawner: Scenes missing!")
		return

	_clear_existing_props()
	
	var placeholders = get_node_or_null("../Placeholders")
	if not placeholders: return
	
	for desk in placeholders.get_children():
		if "Desk_Row" in desk.name:
			_populate_desk_row(desk)
	
	if Engine.is_editor_hint():
		print("PropSpawner: Population complete. Please save the scene to bake props.")

func _populate_desk_row(desk: MeshInstance3D):
	var desk_width = 16.0
	var spacing = 3.5
	var start_x = -(desk_width / 2.0) + 2.75
	
	for i in range(4):
		var local_x = start_x + (i * spacing)
		
		# 1. Spawn Monitor
		var monitor = monitor_scene.instantiate()
		monitor.name = "Generated_Monitor_" + str(i)
		desk.add_child(monitor)
		if Engine.is_editor_hint():
			monitor.owner = get_tree().edited_scene_root
		monitor.position = Vector3(local_x, 0.5, 0.2)
		
		# 2. Spawn Chair
		var chair = chair_scene.instantiate()
		chair.name = "Generated_Chair_" + str(i)
		desk.add_child(chair)
		if Engine.is_editor_hint():
			chair.owner = get_tree().edited_scene_root
		chair.position = Vector3(local_x, -0.4, -1.2)
		chair.rotation_degrees.y = 180
			
		# 3. Random Clutter
		if not clutter_scenes.is_empty() and randf() < 0.4:
			var item = clutter_scenes.pick_random().instantiate()
			item.name = "Generated_Clutter_" + str(i)
			desk.add_child(item)
			if Engine.is_editor_hint():
				item.owner = get_tree().edited_scene_root
			var side_offset = 0.6 if randf() > 0.5 else -0.6
			item.position = Vector3(local_x + side_offset, 0.45, 0.3)
			item.rotation_degrees.y = randf_range(0, 360)
