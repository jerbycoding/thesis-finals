extends Node3D

@onready var screen_mesh = $Screen_Mesh
@onready var viewport = $SubViewport
@onready var input_bridge = $InputBridge

@export var use_crt_shader: bool = false
@export var crt_shader: Shader = preload("res://shaders/crt_screen.gdshader")

func set_screen_active(_active: bool):
	if viewport:
		# ALWAYS UPDATE for ambient view
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	if screen_mesh:
		screen_mesh.visible = true

func _ready():
	# Wait a frame to ensure viewport is initialized
	await get_tree().process_frame
	
	if viewport:
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	
	if screen_mesh and viewport:
		var tex = viewport.get_texture()
		
		if use_crt_shader and crt_shader:
			var mat = ShaderMaterial.new()
			mat.shader = crt_shader
			mat.set_shader_parameter("screen_texture", tex)
			screen_mesh.material_override = mat
		else:
			# For MeshInstance3D, we use material_override or get_active_material
			var current_mat = screen_mesh.get_active_material(0)
			
			if current_mat:
				# Duplicate material so each monitor is unique
				var new_mat = current_mat.duplicate()
				
				new_mat.albedo_texture = tex
				new_mat.albedo_color = Color.WHITE 
				
				# PRO RENDERING: High fidelity for text (Master Advice #2)
				new_mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
				new_mat.anisotropy_enabled = true
				new_mat.anisotropy_strength = 16.0
				
				# MAKE IT LOOK LIKE A REAL SCREEN: Unshaded means it's not affected by room lights
				# and won't wash out into "just white"
				new_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
				
				# FIX: Orientation for QuadMesh
				new_mat.uv1_scale = Vector3(1, 1, 1)
				new_mat.uv1_offset = Vector3(0, 0, 0)
				
				new_mat.emission_enabled = false # Unshaded doesn't need emission to be bright
				
				screen_mesh.material_override = new_mat
	else:
		push_warning("Prop_Monitor: Missing nodes for screen projection")
