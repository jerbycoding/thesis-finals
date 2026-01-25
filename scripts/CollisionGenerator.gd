# CollisionGenerator.gd
# Automatically generates static collision for MeshInstance3D nodes.
extends Node

@export var recursive: bool = true

func _ready():
	_generate_collision(get_parent())

func _generate_collision(node: Node):
	# Skip the doors and anything with manual collision
	if "SlidingDoor" in node.name or "ElevatorDoor" in node.name:
		return

	if node is MeshInstance3D:
		# Check if this mesh already has manual collision
		var has_manual = false
		for child in node.get_children():
			if child is StaticBody3D or child is AnimatableBody3D:
				has_manual = true
				break
		
		if not has_manual:
			if node.name.to_lower().contains("floor"):
				# SPECIAL CASE: Thicken the floor to prevent sinking/snagging
				var static_body = StaticBody3D.new()
				var collision_shape = CollisionShape3D.new()
				var box_shape = BoxShape3D.new()
				# Use the floor size but give it 1m depth
				var floor_size = Vector3(24, 1, 20) 
				if node.mesh is PlaneMesh:
					floor_size = Vector3(node.mesh.size.x, 1.0, node.mesh.size.y)
				box_shape.size = floor_size
				collision_shape.shape = box_shape
				# Shift collision down so the top is at y=0
				collision_shape.position.y = -0.5
				static_body.add_child(collision_shape)
				node.add_child(static_body)
				print("CollisionGenerator: [FLOOR] Generated thick floor for ", node.name)
			elif node.mesh is BoxMesh:
				var static_body = StaticBody3D.new()
				var collision_shape = CollisionShape3D.new()
				var box_shape = BoxShape3D.new()
				# SAFETY MARGIN: Make collision slightly smaller than mesh
				# This prevents physics from stopping the NPC before navigation does.
				box_shape.size = node.mesh.size * 0.98 
				collision_shape.shape = box_shape
				static_body.add_child(collision_shape)
				node.add_child(static_body)
				print("CollisionGenerator: [BOX] Optimized with safety margin for ", node.name)
			else:
				node.create_convex_collision()
				print("CollisionGenerator: [CONVEX] Generated for ", node.name)
		else:
			print("CollisionGenerator: Skipping manual collision node: ", node.name)
	
	if recursive:
		for child in node.get_children():
			_generate_collision(child)
