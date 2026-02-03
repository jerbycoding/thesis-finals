# **Final Verification & Master Script Implementation**

## **Verification Answers:**

### **1. Mouse Mode & Raycasting Accuracy:**
```gdscript
# YES, get_mouse_position() works with MOUSE_MODE_HIDDEN
# But there's a critical nuance:
func _handle_mouse_capture():
    # Method A: Direct position (accurate but has edge cases)
    var mouse_pos = get_viewport().get_mouse_position()
    
    # Method B: Accumulated relative (bulletproof for extended use)
    var accumulated_mouse_pos := Vector2.ZERO
    
    func _input(event):
        if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_HIDDEN:
            accumulated_mouse_pos += event.relative
            # Clamp to viewport bounds
            accumulated_mouse_pos = accumulated_mouse_pos.clamp(
                Vector2.ZERO, 
                get_viewport().size
            )
    
    # RECOMMENDATION: Use BOTH for reliability
    func get_accurate_mouse_position() -> Vector2:
        if Input.mouse_mode == Input.MOUSE_MODE_HIDDEN:
            return accumulated_mouse_pos
        else:
            return get_viewport().get_mouse_position()
```

### **2. SubViewport Focus:**
```gdscript
# You MUST explicitly set focus for keyboard input
func _initialize_viewport_focus():
    # Get the root control of your UI
    var ui_root: Control = $SubViewport.get_child(0) as Control
    
    if ui_root:
        # Call on the main thread after a frame
        await get_tree().process_frame
        ui_root.grab_focus()
        
        # Also ensure viewport is processing
        $SubViewport.gui_disable_input = false
        $SubViewport.gui_focus_neighbor_bottom = ui_root.get_path()
        
        # For multi-window UI, focus the appropriate control
        _focus_active_window(ui_root)

func _focus_active_window(root: Control):
    # Example: Find the top-most window
    var windows = root.find_children("*", "Window", true)
    if windows.size() > 0:
        windows[-1].grab_focus()
```

### **3. Handover Frame Gap Solution:**
```gdscript
func _enter_interaction_immediate():
    # Phase 1: Prepare viewport BEFORE camera moves
    $SubViewport.gui_disable_input = false
    $SubViewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    
    # Phase 2: Inject synthetic mouse enter event
    var enter_event = InputEventMouseMotion.new()
    enter_event.position = _calculate_initial_mouse_position()
    enter_event.global_position = enter_event.position
    
    # Force mouse inside state
    $SubViewport.push_input(enter_event)
    
    # Phase 3: Only THEN start camera tween
    _start_camera_tween()
    
    # Phase 4: After 1 frame, inject button press/release to activate controls
    await get_tree().process_frame
    _simulate_mouse_click_for_activation()

func _simulate_mouse_click_for_activation():
    # Some UI elements need a click to activate
    var click_down = InputEventMouseButton.new()
    click_down.button_index = MOUSE_BUTTON_LEFT
    click_down.pressed = true
    click_down.position = _calculate_initial_mouse_position()
    $SubViewport.push_input(click_down)
    
    var click_up = InputEventMouseButton.new()
    click_up.button_index = MOUSE_BUTTON_LEFT
    click_up.pressed = false
    click_up.position = click_down.position
    $SubViewport.push_input(click_up)
```

### **4. Virtual Cursor Z-Index Guarantee:**
```gdscript
func _create_always_on_top_cursor():
    # Method 1: Direct CanvasLayer (RECOMMENDED)
    var cursor_layer = CanvasLayer.new()
    cursor_layer.layer = 100  # Very high layer
    cursor_layer.follow_viewport_enabled = false
    
    var cursor_sprite = Sprite2D.new()
    cursor_sprite.texture = cursor_texture
    cursor_sprite.z_index = 9999  # Max within layer
    cursor_sprite.z_as_relative = false  # Critical!
    cursor_sprite.top_level = true  # Ignores parent transforms
    
    cursor_layer.add_child(cursor_sprite)
    $SubViewport.add_child(cursor_layer)
    
    # Method 2: If you MUST use Control nodes
    var cursor_control = Control.new()
    cursor_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
    cursor_control.z_index = 2147483647  # Max int32
    cursor_control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    
    var cursor_texture_rect = TextureRect.new()
    cursor_texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    cursor_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP
    cursor_texture_rect.z_index = 2147483647
    
    cursor_control.add_child(cursor_texture_rect)
    
    # Add to viewport LAST so it renders on top
    await get_tree().process_frame
    $SubViewport.add_child(cursor_control)
```

# **MASTER SCRIPT: Complete 3D Monitor Interaction System**

```gdscript
## MasterMonitorSystem.gd
## Complete professional SOC simulator monitor interaction
## Place this on your Monitor root node

extends Node3D
class_name InteractiveMonitor

# ========== EXPORTS ==========
@export_group("Scene References")
@export var screen_mesh: MeshInstance3D
@export var interaction_area: Area3D
@export var camera_anchor: Marker3D
@export var player_camera: Camera3D

@export_group("Viewport Configuration")
@export var viewport_resolution: Vector2 = Vector2(1920, 1080)
@export var screen_physical_size: Vector2 = Vector2(0.8, 0.45)  # 16:9 for 0.8m width
@export var viewport_ui_scene: PackedScene

@export_group("Interaction Settings")
@export_range(0.1, 2.0) var transition_duration: float = 0.4
@export var interaction_distance: float = 2.0
@export var physics_layer: int = 20  # Layer 20 for monitors
@export var cursor_texture: Texture2D

# ========== CONSTANTS ==========
const MOUSE_ACCUMULATION_MAX = 1000.0

# ========== STATE ==========
enum MonitorState {
    IDLE,
    HOVERED,
    INTERACTING,
    TRANSITIONING_OUT
}

var current_state: MonitorState = MonitorState.IDLE
var is_mouse_over: bool = false
var accumulated_mouse_pos: Vector2 = Vector2.ZERO
var original_camera_transform: Transform3D
var original_mouse_mode: Input.MouseMode
var pressed_keys: Dictionary = {}
var pressed_buttons: Dictionary = {}
var last_mouse_uv: Vector2 = Vector2.ZERO

# ========== NODE REFERENCES ==========
@onready var sub_viewport: SubViewport = $SubViewport
@onready var ui_root: Control = null
@onready var virtual_cursor: Sprite2D = null
@onready var interaction_shape: CollisionShape3D = interaction_area.get_child(0)

# ========== LIFECYCLE ==========
func _ready():
    _initialize_monitor()
    _setup_physics_layers()
    _connect_signals()
    _create_virtual_cursor()

func _process(_delta):
    if current_state == MonitorState.INTERACTING:
        _update_interaction()
    elif current_state == MonitorState.HOVERED:
        _check_for_interaction_start()

func _input(event):
    match current_state:
        MonitorState.INTERACTING:
            _handle_interaction_input(event)
        MonitorState.TRANSITIONING_OUT:
            _handle_cleanup_input(event)

# ========== INITIALIZATION ==========
func _initialize_monitor():
    # Configure mesh
    var quad = QuadMesh.new()
    quad.size = screen_physical_size
    screen_mesh.mesh = quad
    
    # Configure material for crisp text
    var material = StandardMaterial3D.new()
    material.albedo_texture = sub_viewport.get_texture()
    material.emission_enabled = true
    material.emission_texture = sub_viewport.get_texture()
    material.emission_energy = 1.0
    material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
    material.anisotropy_enabled = true
    material.anisotropy = 16
    material.params_cull_mode = BaseMaterial3D.CULL_BACK
    screen_mesh.material_override = material
    
    # Configure viewport
    sub_viewport.size = viewport_resolution
    sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    sub_viewport.transparent_bg = false
    sub_viewport.disable_3d = true
    sub_viewport.msaa_2d = SubViewport.MSAA_8X
    sub_viewport.msaa_3d = SubViewport.MSAA_8X
    sub_viewport.snap_2d_transforms_to_pixel = true
    sub_viewport.snap_2d_vertices_to_pixel = true
    
    # Load UI scene
    if viewport_ui_scene:
        var ui_instance = viewport_ui_scene.instantiate()
        sub_viewport.add_child(ui_instance)
        ui_root = ui_instance as Control
    
    # Configure collision
    if interaction_shape:
        var box = BoxShape3D.new()
        box.size = Vector3(screen_physical_size.x, screen_physical_size.y, 0.01)
        interaction_shape.shape = box

func _setup_physics_layers():
    interaction_area.collision_layer = 1 << (physics_layer - 1)  # Layer 20
    interaction_area.collision_mask = 0  # Don't respond to collisions
    interaction_area.input_ray_pickable = true

func _connect_signals():
    interaction_area.mouse_entered.connect(_on_mouse_entered_3d)
    interaction_area.mouse_exited.connect(_on_mouse_exited_3d)
    interaction_area.input_event.connect(_on_area_input_event)

func _create_virtual_cursor():
    var canvas_layer = CanvasLayer.new()
    canvas_layer.layer = 100
    canvas_layer.follow_viewport_enabled = false
    
    virtual_cursor = Sprite2D.new()
    virtual_cursor.texture = cursor_texture
    virtual_cursor.z_index = 2147483647
    virtual_cursor.z_as_relative = false
    virtual_cursor.top_level = true
    virtual_cursor.visible = false
    
    canvas_layer.add_child(virtual_cursor)
    sub_viewport.add_child(canvas_layer)

# ========== STATE MANAGEMENT ==========
func _on_mouse_entered_3d():
    if current_state == MonitorState.IDLE:
        current_state = MonitorState.HOVERED
        is_mouse_over = true

func _on_mouse_exited_3d():
    if current_state == MonitorState.HOVERED:
        current_state = MonitorState.IDLE
        is_mouse_over = false

func _on_area_input_event(_camera, event, _position, _normal, _shape_idx):
    if (event is InputEventMouseButton and 
        event.pressed and 
        event.button_index == MOUSE_BUTTON_LEFT and
        current_state == MonitorState.HOVERED):
        
        _start_interaction()

# ========== INTERACTION START ==========
func _start_interaction():
    if current_state != MonitorState.HOVERED:
        return
    
    # Save original state
    original_camera_transform = player_camera.global_transform
    original_mouse_mode = Input.mouse_mode
    
    # Prepare viewport BEFORE transition
    sub_viewport.gui_disable_input = false
    _force_viewport_focus()
    
    # Calculate initial mouse position
    var initial_uv = _raycast_to_uv(get_viewport().get_mouse_position())
    last_mouse_uv = initial_uv
    accumulated_mouse_pos = initial_uv * viewport_resolution
    
    # Inject immediate mouse presence
    _inject_mouse_enter_events(initial_uv)
    
    # Start camera transition
    current_state = MonitorState.INTERACTING
    _transition_camera_to_anchor()
    
    # Hide OS cursor
    Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
    accumulated_mouse_pos = get_viewport().get_mouse_position()

func _force_viewport_focus():
    if ui_root:
        # Wait one frame for UI to initialize
        await get_tree().process_frame
        ui_root.grab_focus()
        
        # Inject focus gained event
        var focus_event = InputEventMouseButton.new()
        focus_event.button_index = MOUSE_BUTTON_LEFT
        focus_event.pressed = true
        focus_event.position = Vector2(1, 1)  # Small position
        sub_viewport.push_input(focus_event)

func _inject_mouse_enter_events(uv: Vector2):
    var pixel_pos = uv * viewport_resolution
    
    # Motion event to set position
    var motion_event = InputEventMouseMotion.new()
    motion_event.position = pixel_pos
    motion_event.global_position = pixel_pos
    sub_viewport.push_input(motion_event)
    
    # Optional: Simulate hover state with button down/up
    await get_tree().process_frame
    var click_down = InputEventMouseButton.new()
    click_down.button_index = MOUSE_BUTTON_LEFT
    click_down.pressed = true
    click_down.position = pixel_pos
    sub_viewport.push_input(click_down)
    
    var click_up = InputEventMouseButton.new()
    click_up.button_index = MOUSE_BUTTON_LEFT
    click_up.pressed = false
    click_up.position = pixel_pos
    sub_viewport.push_input(click_up)

# ========== INTERACTION UPDATE ==========
func _update_interaction():
    # Update virtual cursor
    if virtual_cursor and virtual_cursor.visible:
        var pixel_pos = last_mouse_uv * viewport_resolution
        virtual_cursor.position = pixel_pos
    
    # Continuous raycast for mouse position
    var current_mouse_pos = _get_accumulated_mouse_position()
    var uv = _raycast_to_uv(current_mouse_pos)
    
    if uv != last_mouse_uv:
        last_mouse_uv = uv
        _forward_mouse_motion(uv)

func _get_accumulated_mouse_position() -> Vector2:
    if Input.mouse_mode == Input.MOUSE_MODE_HIDDEN:
        # Use our accumulated position
        return accumulated_mouse_pos.clamp(Vector2.ZERO, get_viewport().size)
    else:
        return get_viewport().get_mouse_position()

func _raycast_to_uv(screen_pos: Vector2) -> Vector2:
    var ray_origin = player_camera.project_ray_origin(screen_pos)
    var ray_dir = player_camera.project_ray_normal(screen_pos)
    
    var query = PhysicsRayQueryParameters3D.create(
        ray_origin,
        ray_origin + ray_dir * interaction_distance
    )
    
    query.collide_with_areas = true
    query.collide_with_bodies = false
    query.collision_mask = 1 << (physics_layer - 1)  # Only layer 20
    
    var space_state = get_world_3d().direct_space_state
    var result = space_state.intersect_ray(query)
    
    if result and result.collider == interaction_area:
        # Convert hit point to UV
        var local_point = global_transform.affine_inverse() * result.position
        var uv = Vector2(
            (local_point.x / screen_physical_size.x) + 0.5,
            1.0 - ((local_point.y / screen_physical_size.y) + 0.5)
        )
        return uv.clamp(Vector2.ZERO, Vector2.ONE)
    
    return last_mouse_uv  # Return last valid UV if ray misses

func _forward_mouse_motion(uv: Vector2):
    var pixel_pos = uv * viewport_resolution
    
    # Update virtual cursor
    if virtual_cursor:
        virtual_cursor.position = pixel_pos
        virtual_cursor.visible = true
    
    # Forward to viewport
    var motion_event = InputEventMouseMotion.new()
    motion_event.position = pixel_pos
    motion_event.global_position = pixel_pos
    sub_viewport.push_input(motion_event)

# ========== INPUT HANDLING ==========
func _handle_interaction_input(event):
    # Mouse motion with accumulation
    if event is InputEventMouseMotion:
        if Input.mouse_mode == Input.MOUSE_MODE_HIDDEN:
            accumulated_mouse_pos += event.relative
            accumulated_mouse_pos = accumulated_mouse_pos.clamp(
                Vector2.ZERO, 
                get_viewport().size
            )
        _forward_mouse_motion(_raycast_to_uv(_get_accumulated_mouse_position()))
    
    # Mouse buttons
    elif event is InputEventMouseButton:
        _handle_mouse_button(event)
    
    # Keyboard
    elif event is InputEventKey:
        _handle_keyboard(event)
    
    # Mouse wheel
    elif event is InputEventMouseWheel:
        _handle_mouse_wheel(event)
    
    # Exit interaction
    elif event.is_action_pressed("ui_cancel"):
        _end_interaction()

func _handle_mouse_button(event: InputEventMouseButton):
    var pixel_pos = last_mouse_uv * viewport_resolution
    
    var button_event = InputEventMouseButton.new()
    button_event.position = pixel_pos
    button_event.global_position = pixel_pos
    button_event.button_index = event.button_index
    button_event.pressed = event.pressed
    button_event.double_click = event.double_click
    
    # Track pressed state for cleanup
    if event.pressed:
        pressed_buttons[event.button_index] = true
    else:
        pressed_buttons.erase(event.button_index)
    
    sub_viewport.push_input(button_event)

func _handle_keyboard(event: InputEventKey):
    # Track pressed keys for cleanup
    if event.pressed:
        pressed_keys[event.keycode] = true
    else:
        pressed_keys.erase(event.keycode)
    
    sub_viewport.push_input(event)

func _handle_mouse_wheel(event: InputEventMouseWheel):
    var wheel_event = InputEventMouseWheel.new()
    wheel_event.position = last_mouse_uv * viewport_resolution
    wheel_event.global_position = wheel_event.position
    wheel_event.vertical = event.vertical
    wheel_event.horizontal = event.horizontal
    
    sub_viewport.push_input(wheel_event)

# ========== INTERACTION END ==========
func _end_interaction():
    if current_state != MonitorState.INTERACTING:
        return
    
    current_state = MonitorState.TRANSITIONING_OUT
    
    # Release all pressed inputs
    _release_all_pressed_inputs()
    
    # Flush input queue
    _flush_viewport_input()
    
    # Hide virtual cursor
    if virtual_cursor:
        virtual_cursor.visible = false
    
    # Transition camera back
    _transition_camera_back()
    
    # Restore mouse mode
    if original_mouse_mode != Input.MOUSE_MODE_HIDDEN:
        Input.set_mouse_mode(original_mouse_mode)
    
    # Reset state
    await get_tree().create_timer(transition_duration).timeout
    current_state = MonitorState.IDLE
    is_mouse_over = false
    accumulated_mouse_pos = Vector2.ZERO

func _release_all_pressed_inputs():
    # Release all keys
    for keycode in pressed_keys.keys():
        var event = InputEventKey.new()
        event.keycode = keycode
        event.pressed = false
        event.echo = false
        sub_viewport.push_input(event)
    
    # Release all mouse buttons
    var pixel_pos = last_mouse_uv * viewport_resolution
    for button in pressed_buttons.keys():
        var event = InputEventMouseButton.new()
        event.button_index = button
        event.pressed = false
        event.position = pixel_pos
        event.global_position = pixel_pos
        sub_viewport.push_input(event)
    
    pressed_keys.clear()
    pressed_buttons.clear()

func _flush_viewport_input():
    # Send an empty event to clear queue
    var empty_event = InputEvent.new()
    sub_viewport.push_input(empty_event)
    
    # Send mouse exit event
    var exit_event = InputEventMouseMotion.new()
    exit_event.position = Vector2(-10000, -10000)  # Far off-screen
    exit_event.global_position = exit_event.position
    sub_viewport.push_input(exit_event)

# ========== CAMERA TRANSITIONS ==========
func _transition_camera_to_anchor():
    if not camera_anchor:
        return
    
    var tween = create_tween()
    tween.set_trans(Tween.TRANS_CUBIC)
    tween.set_ease(Tween.EASE_IN_OUT)
    
    tween.tween_property(player_camera, "global_transform",
        camera_anchor.global_transform, transition_duration)

func _transition_camera_back():
    var tween = create_tween()
    tween.set_trans(Tween.TRANS_CUBIC)
    tween.set_ease(Tween.EASE_IN_OUT)
    
    tween.tween_property(player_camera, "global_transform",
        original_camera_transform, transition_duration)

# ========== CLEANUP ==========
func _handle_cleanup_input(event):
    # Block all input during transition out
    pass

func _exit_tree():
    # Emergency cleanup if node is removed while interacting
    if current_state == MonitorState.INTERACTING:
        _release_all_pressed_inputs()
        _flush_viewport_input()
        
        if virtual_cursor:
            virtual_cursor.visible = false
        
        Input.set_mouse_mode(original_mouse_mode)

# ========== PUBLIC API ==========
func is_currently_interactive() -> bool:
    return current_state == MonitorState.INTERACTING

func force_exit():
    _end_interaction()
```

## **Project Settings Additions:**

```ini
[input]
ui_cancel={
"deadzone": 0.5,
"events": [ Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"command_or_control_held":false,"pressed":false,"keycode":16777217,"physical_keycode":0,"unicode":0,"echo":false,"script":null)
 ]
}

[rendering]
viewport/snap_2d_transforms_to_pixel=true
viewport/snap_2d_vertices_to_pixel=true
textures/anisotropic_filter_level=16
textures/2d_textures/default_filter="linear_with_mipmaps_anisotropic"

[layer_names/3d_physics]
20="interactive_monitors"
```

This master implementation provides bulletproof solutions to all four verification questions while maintaining professional-grade reliability for your SOC simulator.