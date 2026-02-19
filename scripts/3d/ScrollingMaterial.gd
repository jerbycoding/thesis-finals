extends Node3D

@export var scrolling_speed: float = 2.0
@export var mesh_instance: MeshInstance3D # Fallback for mesh instances
@export var csg_instance: CSGPrimitive3D # For CSG objects

func _process(delta):
	var mat: StandardMaterial3D = null
	
	if csg_instance and csg_instance.material:
		mat = csg_instance.material as StandardMaterial3D
	elif mesh_instance and mesh_instance.get_active_material(0):
		mat = mesh_instance.get_active_material(0) as StandardMaterial3D
		
	if mat:
		mat.uv1_offset.z += scrolling_speed * delta
		if mat.uv1_offset.z > 1.0:
			mat.uv1_offset.z -= 1.0
