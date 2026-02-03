### 1. Conflict Check (Mouse Mode)
No conflict: `Input.mouse_mode = Input.MOUSE_MODE_HIDDEN` hides the OS cursor but does not affect mouse tracking. `get_viewport().get_mouse_position()` and `event.position` in `_input` remain accurate for raycasting. No need for `event.relative` accumulation—use `event.position` directly for reliable 3D-to-2D mapping.

### 2. SubViewport Focus
`push_input(event)` processes events but does not automatically grant focus. Explicitly call `grab_focus()` on the root or target `Control` (e.g., a Panel or TextEdit) inside the SubViewport to enable keyboard input. Do this on interaction start for terminals/SIEM logs.

### 3. The "Handover" Frame Gap
Yes, a 1-frame lag risk exists due to input propagation/sub-viewport init. Mitigate by:
- Manually checking `get_viewport().get_mouse_position()` in `_input`.
- Immediately pushing a synthetic `InputEventMouseMotion` with current `pixel_pos` on soft-lock start to force "mouse enter" state.

### 4. Z-Index of Virtual Cursor
Set a high `z_index` (e.g., 1000) on the `TextureRect`, but for bulletproof top-layering without `move_to_front()`, parent it under a `CanvasLayer` (layer=10) in the SubViewport. This renders it above all other Controls independently.

### Master Script Structure
```gdscript
extends Node3D  # Attach to monitor root

@export var camera: Camera3D
@export var interaction_area: Area3D
@export var sub_viewport: SubViewport
@export var screen_mesh: MeshInstance3D
@export var view_anchor: Marker3D
@export var virtual_cursor: TextureRect  # Child of CanvasLayer in SubViewport
@export var ui_root: Control  # Root Control in SubViewport for focus

var camera_tween: Tween
var is_interacting: bool = false
var pressed_keys: Dictionary = {}  # For flush

func _ready():
    # Setup
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    sub_viewport.size = Vector2(1920, 1080)  # High-res
    interaction_area.collision_layer = 1 << 19  # Layer 20 (bit 19)
    virtual_cursor.visible = false
    virtual_cursor.z_index = 1000  # Fallback; use CanvasLayer.layer = 10 in editor
    _setup_material()  # From prev advice

func _input(event):
    if not is_interacting:
        if event is InputEventKey and event.is_action_pressed("ui_cancel"):
            _end_soft_lock()
        return
    
    # Forward all during interact
    if is_interacting:
        sub_viewport.push_input(event, true)
        if event is InputEventKey:
            if event.pressed:
                pressed_keys[event.keycode] = true
            else:
                pressed_keys.erase(event.keycode)
        get_viewport().set_input_as_handled()
    
    if event is InputEventMouse:
        _handle_mouse_event(event)

func _handle_mouse_event(event: InputEventMouse):
    # Raycast (masked)
    var mouse_pos = event.position
    var ray_origin = camera.project_ray_origin(mouse_pos)
    var ray_end = ray_origin + camera.project_ray_normal(mouse_pos) * 1000.0
    var space_state = get_world_3d().direct_space_state
    var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
    query.collide_with_areas = true
    query.collision_mask = 1 << 19  # Layer 20 only
    
    var result = space_state.intersect_ray(query)
    
    if result and result.collider == interaction_area:
        # UV to pixel
        var local_point = screen_mesh.to_local(result.position)
        var quad_size = screen_mesh.mesh.size
        var uv = Vector2(
            (local_point.x + quad_size.x / 2.0) / quad_size.x,
            1.0 - ((local_point.y + quad_size.y / 2.0) / quad_size.y)  # Flip Y if needed
        ).clamp(Vector2.ZERO, Vector2.ONE)
        var pixel_pos = uv * sub_viewport.size
        
        # Forward event
        var forwarded_event = _clone_mouse_event(event, pixel_pos)
        sub_viewport.push_input(forwarded_event, true)
        
        # Virtual cursor
        virtual_cursor.position = pixel_pos - virtual_cursor.size / 2.0
        virtual_cursor.visible = true
        
        # Start interact on click
        if event is InputEventMouseButton and event.pressed and not is_interacting:
            _start_soft_lock(pixel_pos)  # Pass pos for immediate enter
    else:
        virtual_cursor.visible = false
        if is_interacting and event is InputEventMouseButton and event.pressed:
            _end_soft_lock()

func _clone_mouse_event(event: InputEventMouse, pos: Vector2) -> InputEventMouse:
    var new_event
    if event is InputEventMouseMotion:
        new_event = InputEventMouseMotion.new()
        new_event.relative = event.relative
        new_event.velocity = event.velocity
    elif event is InputEventMouseButton:
        new_event = InputEventMouseButton.new()
        new_event.button_index = event.button_index
        new_event.pressed = event.pressed
        new_event.double_click = event.double_click
        new_event.factor = event.factor
    new_event.position = pos
    new_event.global_position = pos
    new_event.button_mask = event.button_mask
    return new_event

func _start_soft_lock(initial_pixel_pos: Vector2):
    is_interacting = true
    Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
    ui_root.grab_focus()  # Ensure keyboard focus
    
    # Immediate mouse enter sim
    var enter_event = InputEventMouseMotion.new()
    enter_event.position = initial_pixel_pos
    sub_viewport.push_input(enter_event, true)
    
    if camera_tween: camera_tween.kill()
    camera_tween = create_tween()
    camera_tween.set_parallel(true).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
    camera_tween.tween_property(camera, "global_transform", view_anchor.global_transform, 0.5)

func _end_soft_lock():
    if not is_interacting: return
    is_interacting = false
    _flush_inputs()
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    virtual_cursor.visible = false
    # Tween back if desired

func _flush_inputs():
    for keycode in pressed_keys.keys():
        var up_event = InputEventKey.new()
        up_event.keycode = keycode
        up_event.pressed = false
        up_event.echo = false
        sub_viewport.push_input(up_event, true)
    pressed_keys.clear()

func _setup_material():  # Example from prev
    var mat = StandardMaterial3D.new()
    mat.albedo_texture = sub_viewport.get_texture()
    mat.emission_enabled = true
    mat.emission = Color.WHITE
    mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
    screen_mesh.material_override = mat
```