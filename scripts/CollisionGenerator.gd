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
			# PERFORMANCE OPTIMIZATION:
			# If it's a BoxMesh, use a primitive BoxShape3D (High Performance)
			# Otherwise, use Convex Collision (Medium Performance)
			if node.mesh is BoxMesh:
				var static_body = StaticBody3D.new()
				var collision_shape = CollisionShape3D.new()
				var box_shape = BoxShape3D.new()
				box_shape.size = node.mesh.size
				collision_shape.shape = box_shape
				static_body.add_child(collision_shape)
				node.add_child(static_body)
				print("CollisionGenerator: [BOX] Optimized collision for ", node.name)
			else:
				node.create_convex_collision()
				print("CollisionGenerator: [CONVEX] Generated for ", node.name)
		else:
			print("CollisionGenerator: Skipping manual collision node: ", node.name)
	
	if recursive:
		for child in node.get_children():
			_generate_collision(child)
