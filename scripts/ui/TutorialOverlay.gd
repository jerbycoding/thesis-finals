# TutorialOverlay.gd
extends ColorRect

var target_node: Control = null
var is_active: bool = false
var current_tier: int = 3 # Default to FULL_ATG_FOCUS

var selection_box_scene = preload("res://scenes/ui/ATG_SelectionBox.tscn")
var selection_box: Control = null

func _ready():
	# Ensure shader is initialized
	material.set_shader_parameter("dim_alpha", 0.0)
	hide()
	
	selection_box = selection_box_scene.instantiate()
	add_child(selection_box)
	selection_box.hide()

func _process(_delta):
	if is_active and target_node and is_instance_valid(target_node):
		_update_shader_pos()
		if selection_box.visible:
			_update_selection_box_pos()

func highlight_node(node: Control, tier: int = 3):
	if not node:
		hide_overlay()
		return
		
	target_node = node
	current_tier = tier
	is_active = true
	show()
	
	_update_shader_pos()
	
	match tier:
		3: # FULL_ATG_FOCUS
			# Animate the dimming effect
			var tween = create_tween()
			tween.tween_property(material, "shader_parameter/dim_alpha", 0.7, 0.3)
			_show_selection_box()
		2: # ALERT_FLASH
			material.set_shader_parameter("dim_alpha", 0.0)
			_show_selection_box()
			_flash_selection_box()
		1: # AMBIENT_HINT (Handled by TutorialManager icon glows)
			hide_overlay()

func _show_selection_box():
	if not target_node: return
	selection_box.show()
	selection_box.activate(target_node.size)
	_update_selection_box_pos()

func _flash_selection_box():
	var tween = create_tween()
	selection_box.modulate.a = 0
	tween.tween_property(selection_box, "modulate:a", 1.0, 0.1)
	tween.tween_property(selection_box, "modulate:a", 0.2, 0.1)
	tween.tween_property(selection_box, "modulate:a", 1.0, 0.1)

func hide_overlay():
	is_active = false
	var tween = create_tween()
	tween.tween_property(material, "shader_parameter/dim_alpha", 0.0, 0.2)
	if selection_box:
		selection_box.modulate.a = 0
		selection_box.hide()
		
	await tween.finished
	hide()
	target_node = null

func _update_selection_box_pos():
	if not target_node: return
	# Match position to target node's global position relative to this overlay
	selection_box.global_position = target_node.global_position - Vector2(5, 5)
	selection_box.size = target_node.size + Vector2(10, 10)

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
