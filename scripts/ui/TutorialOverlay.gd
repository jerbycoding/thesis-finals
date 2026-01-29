# TutorialOverlay.gd
extends ColorRect

var target_node: Control = null
var is_active: bool = false

func _ready():
	# Ensure shader is initialized
	material.set_shader_parameter("dim_alpha", 0.0)
	hide()

func _process(_delta):
	if is_active and target_node and is_instance_valid(target_node):
		_update_shader_pos()

func highlight_node(node: Control):
	if not node:
		hide_overlay()
		return
		
	target_node = node
	is_active = true
	show()
	
	_update_shader_pos()
	
	# Animate the dimming effect
	var tween = create_tween()
	tween.tween_property(material, "shader_parameter/dim_alpha", 0.7, 0.3)

func hide_overlay():
	is_active = false
	var tween = create_tween()
	tween.tween_property(material, "shader_parameter/dim_alpha", 0.0, 0.2)
	await tween.finished
	hide()
	target_node = null

func _update_shader_pos():
	if not target_node: return
	
	# Get global screen position and size
	var global_pos = target_node.global_position
	var size = target_node.size
	
	# Viewport size for normalization
	var vp_size = get_viewport().get_visible_rect().size
	
	# Convert to UV space (0.0 - 1.0)
	var uv_pos = global_pos / vp_size
	var uv_size = size / vp_size
	
	material.set_shader_parameter("target_uv_pos", uv_pos)
	material.set_shader_parameter("target_uv_size", uv_size)
