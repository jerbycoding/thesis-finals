extends Node3D

@onready var screen_mesh = $Geometry/Bezel/Screen_Glass
@onready var viewport = $SubViewport

func set_screen_active(active: bool):
	if viewport:
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS if active else SubViewport.UPDATE_DISABLED
	if screen_mesh:
		screen_mesh.visible = active

func _ready():
	# Wait a frame to ensure viewport is initialized
	await get_tree().process_frame
	
	if screen_mesh and viewport:
		var tex = viewport.get_texture()
		
		# CSGBox3D stores material in the 'material' property
		var current_mat = screen_mesh.material
		
		if current_mat:
			# Duplicate material so each monitor is unique
			var new_mat = current_mat.duplicate()
			
			new_mat.albedo_texture = tex
			# Set base color to white so texture isn't tinted dark
			new_mat.albedo_color = Color.WHITE 
			
			new_mat.emission_enabled = false
			new_mat.emission_texture = tex
			new_mat.emission = Color.WHITE
			new_mat.emission_energy_multiplier = 0.0
			
			screen_mesh.material = new_mat
			# print("Monitor Screen Texture Applied")
	else:
		push_warning("Prop_Monitor: Missing nodes for screen projection")
