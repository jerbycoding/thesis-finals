extends Node3D
class_name MonitorInputBridge

# Master script for 3D-to-2D UI Interaction
# Handles Raycast -> UV mapping -> Viewport Input Injection

@export_group("References")
@export var subviewport: SubViewport
@export var screen_mesh: MeshInstance3D
@export var interaction_area: Area3D

@export_group("Config")
@export var physics_layer: int = 20 # Layer 20 for monitors

# State
var is_active: bool = false
var last_uv: Vector2 = Vector2.ZERO
var pressed_keys: Dictionary = {} # scancode -> bool
var virtual_cursor: Sprite2D = null
var current_mesh_size: Vector2 = Vector2(0.912, 0.513) # Dynamic fallback

func _ready():
	_setup_collision()
	_update_mesh_size()
	# Disable SubViewport input by default; we forward manually
	if subviewport:
		subviewport.gui_disable_input = false

func _update_mesh_size():
	if screen_mesh and screen_mesh.mesh:
		if screen_mesh.mesh is QuadMesh:
			current_mesh_size = screen_mesh.mesh.size
		else:
			var aabb = screen_mesh.get_aabb()
			current_mesh_size = Vector2(aabb.size.x, aabb.size.y)

func _setup_collision():
	if not interaction_area: return
	
	# Set dedicated physics layer for occlusion-proof raycasting
	interaction_area.collision_layer = 0
	interaction_area.set_collision_layer_value(physics_layer, true)
	interaction_area.collision_mask = 0
	
	# Metadata for raycast detection
	interaction_area.set_meta("is_monitor", true)
	interaction_area.set_meta("bridge", self)

func activate():
	is_active = true
	pressed_keys.clear()
	
	# Force SubViewport to recognize mouse entry immediately (Master Advice #3)
	if subviewport:
		subviewport.notification(Viewport.NOTIFICATION_VP_MOUSE_ENTER)
		
		# Find the virtual cursor if it exists in the viewport
		# It's inside a CanvasLayer named 'CursorLayer'
		var cursor_layer = subviewport.find_child("CursorLayer", true, false)
		if cursor_layer:
			virtual_cursor = cursor_layer.find_child("VirtualCursor", true, false)
		
		if virtual_cursor:
			virtual_cursor.visible = true
			
		_sync_initial_mouse_state()

func deactivate():
	if not is_active: return
	is_active = false
	
	# Flush stuck keys (Master Advice #4)
	_flush_stuck_keys()
	
	if subviewport:
		subviewport.notification(Viewport.NOTIFICATION_VP_MOUSE_EXIT)
	
	if virtual_cursor:
		virtual_cursor.visible = false

func _sync_initial_mouse_state():
	# Push a synthetic motion event to the current mouse position
	var mouse_pos = get_viewport().get_mouse_position()
	var uv = _get_uv_from_screen_pos(mouse_pos)
	if uv != Vector2(-1, -1):
		_inject_mouse_motion(uv)
		last_uv = uv
	else:
		# Fallback to center if raycast misses during init
		_inject_mouse_motion(Vector2(0.5, 0.5))
		last_uv = Vector2(0.5, 0.5)

func _process(_delta):
	if not is_active: return
	
	# Real-time raycasting for smooth mouse movement
	var mouse_pos = get_viewport().get_mouse_position()
	var uv = _get_uv_from_screen_pos(mouse_pos)
	
	if uv != Vector2(-1, -1):
		_inject_mouse_motion(uv)
		last_uv = uv

func _get_uv_from_screen_pos(screen_pos: Vector2) -> Vector2:
	var camera = get_viewport().get_camera_3d()
	if not camera: return Vector2(-1, -1)
	
	var from = camera.project_ray_origin(screen_pos)
	var to = from + camera.project_ray_normal(screen_pos) * 5.0
	
	var space = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = 1 << (physics_layer - 1)
	query.collide_with_areas = true
	
	var result = space.intersect_ray(query)
	if result and result.collider == interaction_area:
		# Convert hit to local UV
		var local_hit = screen_mesh.to_local(result.position)
		var uv = Vector2(
			(local_hit.x / current_mesh_size.x) + 0.5,
			1.0 - ((local_hit.y / current_mesh_size.y) + 0.5)
		)
		return uv.clamp(Vector2.ZERO, Vector2.ONE)
	
	return Vector2(-1, -1)

func _inject_mouse_motion(uv: Vector2):
	if not subviewport: return
	
	var pixel_pos = uv * Vector2(subviewport.size)
	var prev_pixel_pos = last_uv * Vector2(subviewport.size)
	
	# Update Virtual Cursor
	if virtual_cursor:
		virtual_cursor.position = pixel_pos
	
	# Forward to Viewport
	var ev = InputEventMouseMotion.new()
	ev.position = pixel_pos
	ev.global_position = pixel_pos
	ev.relative = pixel_pos - prev_pixel_pos
	subviewport.push_input(ev)

func handle_mouse_button(event: InputEventMouseButton):
	if not is_active or not subviewport: return
	
	var pixel_pos = last_uv * Vector2(subviewport.size)
	var ev = event.duplicate()
	ev.position = pixel_pos
	ev.global_position = pixel_pos
	subviewport.push_input(ev)

func handle_key(event: InputEventKey):
	if not is_active or not subviewport: return
	
	# Track for flushing
	if event.pressed:
		pressed_keys[event.physical_keycode] = true
	else:
		pressed_keys.erase(event.physical_keycode)
		
	subviewport.push_input(event)

func _flush_stuck_keys():
	if not subviewport: return
	for sc in pressed_keys.keys():
		var ev = InputEventKey.new()
		ev.physical_keycode = sc
		ev.pressed = false
		subviewport.push_input(ev)
	pressed_keys.clear()
	Input.flush_buffered_events()
