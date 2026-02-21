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
	
	if ConfigManager:
		ConfigManager.setting_changed.connect(_on_config_changed)
		use_crt_shader = ConfigManager.settings.display.crt_enabled
	
	_update_screen_material()

func _on_config_changed(_section: String, key: String, value: Variant):
	if key == "crt_enabled":
		use_crt_shader = value
		_update_screen_material()

func _update_screen_material():
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
			# Use unshaded high-fidelity material for clarity
			var new_mat = StandardMaterial3D.new()
			new_mat.albedo_texture = tex
			new_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			new_mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
			new_mat.anisotropy_enabled = true
			new_mat.anisotropy_strength = 16.0
			screen_mesh.material_override = new_mat
	else:
		push_warning("Prop_Monitor: Missing nodes for screen projection")
