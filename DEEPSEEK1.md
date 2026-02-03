I'll provide a complete Godot 4 implementation for your 3D-in-world computer interaction system. This includes the bridge script, camera soft-lock system, and input forwarding logic.

## 1. **Main Interaction Script (`WorldComputerInteraction.gd`)**

```gdscript
extends Node3D

@export var screen_viewport: SubViewport
@export var screen_surface: MeshInstance3D
@export var interaction_area: Area3D
@export var camera_anchor: Marker3D
@export var player_camera: Camera3D

# Camera soft-lock settings
@export var lock_transition_speed: float = 5.0
@export var unlock_transition_speed: float = 8.0
@export_range(0.5, 2.0) var fov_when_locked: float = 75.0

# Viewport settings
@export var viewport_resolution: Vector2 = Vector2(1280, 720)

# State tracking
var is_interacting: bool = false
var was_mouse_captured: bool = false
var original_camera_transform: Transform3D
var original_fov: float
var current_uv: Vector2 = Vector2.ZERO

# Mouse smoothing (optional, for better UX)
var smoothed_mouse_pos: Vector2 = Vector2.ZERO
const MOUSE_SMOOTHING: float = 0.15

func _ready():
    # Connect area signals
    interaction_area.input_event.connect(_on_area_input_event)
    interaction_area.mouse_entered.connect(_on_area_mouse_entered)
    interaction_area.mouse_exited.connect(_on_area_mouse_exited)
    
    # Set viewport size
    screen_viewport.size = viewport_resolution
    
    # Disable viewport input by default (we'll forward manually)
    screen_viewport.disable_input = true

func _input(event):
    # Only process input when interacting
    if !is_interacting:
        return
    
    # Forward mouse events to viewport
    if event is InputEventMouseMotion:
        _handle_mouse_motion(event)
    elif event is InputEventMouseButton:
        _handle_mouse_button(event)
    elif event is InputEventMouseWheel:
        _handle_mouse_wheel(event)
    
    # Exit interaction on ESC
    if event.is_action_pressed("ui_cancel"):
        _exit_interaction()

func _physics_process(delta):
    # Smooth camera transitions
    if is_interacting:
        _transition_camera_to_anchor(delta)
    else:
        _transition_camera_back(delta)
    
    # Smooth mouse position (optional)
    smoothed_mouse_pos = smoothed_mouse_pos.lerp(current_uv, MOUSE_SMOOTHING)

func _handle_mouse_motion(event: InputEventMouseMotion):
    if !interaction_area.has_overlapping_bodies():
        return
    
    # Raycast from camera to screen
    var ray_length = 1000.0
    var mouse_pos = get_viewport().get_mouse_position()
    var from = player_camera.project_ray_origin(mouse_pos)
    var to = from + player_camera.project_ray_normal(mouse_pos) * ray_length
    
    var space_state = get_world_3d().direct_space_state
    var query = PhysicsRayQueryParameters3D.create(from, to)
    query.collide_with_areas = true
    query.collide_with_bodies = false
    query.exclude = []
    
    var result = space_state.intersect_ray(query)
    
    if result and result.collider == interaction_area:
        # Convert collision point to UV coordinates
        var local_point = screen_surface.global_transform.affine_inverse() * result.position
        current_uv = Vector2(
            local_point.x + 0.5,  # QuadMesh UV: 0-1
            1.0 - (local_point.y + 0.5)  # Flip Y for screen coordinates
        )
        
        # Clamp UV to 0-1 range
        current_uv = current_uv.clamp(Vector2.ZERO, Vector2.ONE)
        
        # Convert to pixel coordinates
        var pixel_pos = current_uv * viewport_resolution
        
        # Create and forward mouse motion event
        var motion_event = InputEventMouseMotion.new()
        motion_event.position = pixel_pos
        motion_event.global_position = pixel_pos
        motion_event.relative = event.relative
        
        screen_viewport.push_input(motion_event)

func _handle_mouse_button(event: InputEventMouseButton):
    if !interaction_area.has_overlapping_bodies():
        return
    
    # Convert UV to pixel coordinates
    var pixel_pos = smoothed_mouse_pos * viewport_resolution
    
    # Create and forward mouse button event
    var button_event = InputEventMouseButton.new()
    button_event.position = pixel_pos
    button_event.global_position = pixel_pos
    button_event.button_index = event.button_index
    button_event.pressed = event.pressed
    button_event.double_click = event.double_click
    
    screen_viewport.push_input(button_event)
    
    # Enter interaction on first click
    if event.pressed and event.button_index == MOUSE_BUTTON_LEFT and !is_interacting:
        _enter_interaction()

func _handle_mouse_wheel(event: InputEventMouseWheel):
    if !interaction_area.has_overlapping_bodies():
        return
    
    # Convert UV to pixel coordinates
    var pixel_pos = smoothed_mouse_pos * viewport_resolution
    
    # Create and forward mouse wheel event
    var wheel_event = InputEventMouseWheel.new()
    wheel_event.position = pixel_pos
    wheel_event.global_position = pixel_pos
    wheel_event.vertical = event.vertical
    wheel_event.horizontal = event.horizontal
    
    screen_viewport.push_input(wheel_event)

func _on_area_input_event(camera: Camera3D, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int):
    # This ensures we can detect clicks even without mouse focus
    if event is InputEventMouseButton and event.pressed:
        _enter_interaction()

func _on_area_mouse_entered():
    # Optional: Show cursor or highlight effect
    Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _on_area_mouse_exited():
    if !is_interacting:
        Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _enter_interaction():
    if is_interacting:
        return
    
    # Save original state
    was_mouse_captured = Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
    original_camera_transform = player_camera.global_transform
    original_fov = player_camera.fov
    
    # Set interaction state
    is_interacting = true
    
    # Set mouse mode
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    
    # Enable viewport for rendering if needed
    screen_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS

func _exit_interaction():
    if !is_interacting:
        return
    
    is_interacting = false
    
    # Restore mouse mode
    if was_mouse_captured:
        Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    else:
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    
    # Reset cursor
    Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _transition_camera_to_anchor(delta: float):
    if !camera_anchor:
        return
    
    # Smoothly interpolate camera position and rotation
    var target_transform = camera_anchor.global_transform
    var current_transform = player_camera.global_transform
    
    # Interpolate position
    var new_position = current_transform.origin.lerp(
        target_transform.origin, 
        lock_transition_speed * delta
    )
    
    # Interpolate rotation using quaternions for smooth rotation
    var current_quat = current_transform.basis.get_rotation_quaternion()
    var target_quat = target_transform.basis.get_rotation_quaternion()
    var new_quat = current_quat.slerp(target_quat, lock_transition_speed * delta)
    
    # Apply new transform
    player_camera.global_transform = Transform3D(
        Basis(new_quat),
        new_position
    )
    
    # Smoothly adjust FOV
    player_camera.fov = lerp(player_camera.fov, fov_when_locked, lock_transition_speed * delta)

func _transition_camera_back(delta: float):
    if player_camera.global_transform.is_equal_approx(original_camera_transform):
        return
    
    # Smoothly return to original position
    var current_transform = player_camera.global_transform
    
    # Interpolate position
    var new_position = current_transform.origin.lerp(
        original_camera_transform.origin, 
        unlock_transition_speed * delta
    )
    
    # Interpolate rotation
    var current_quat = current_transform.basis.get_rotation_quaternion()
    var target_quat = original_camera_transform.basis.get_rotation_quaternion()
    var new_quat = current_quat.slerp(target_quat, unlock_transition_speed * delta)
    
    # Apply new transform
    player_camera.global_transform = Transform3D(
        Basis(new_quat),
        new_position
    )
    
    # Return to original FOV
    player_camera.fov = lerp(player_camera.fov, original_fov, unlock_transition_speed * delta)
```

## 2. **Scene Setup Script (`ComputerSetup.gd`)**

This script should be attached to your monitor scene root to auto-configure everything:

```gdscript
extends Node3D

@export var screen_resolution: Vector2 = Vector2(1280, 720)
@export var screen_size: Vector2 = Vector2(1.0, 0.5625)  # 16:9 ratio for 1m width

func _ready():
    setup_screen()

func setup_screen():
    # Get or create nodes
    var mesh_instance = $ScreenMesh as MeshInstance3D
    var area = $InteractionArea as Area3D
    var viewport = $SubViewport as SubViewport
    
    # Setup QuadMesh for screen
    var quad_mesh = QuadMesh.new()
    quad_mesh.size = screen_size
    mesh_instance.mesh = quad_mesh
    
    # Create material with Viewport Texture
    var material = StandardMaterial3D.new()
    material.albedo_texture = viewport.get_texture()
    material.emission_enabled = true
    material.emission_texture = viewport.get_texture()
    material.emission_energy = 1.0
    material.cull_mode = BaseMaterial3D.CULL_BACK
    mesh_instance.material_override = material
    
    # Setup CollisionShape
    var collision_shape = CollisionShape3D.new()
    var box_shape = BoxShape3D.new()
    box_shape.size = Vector3(screen_size.x, screen_size.y, 0.05)
    collision_shape.shape = box_shape
    
    if area.get_child_count() == 0:
        area.add_child(collision_shape)
    
    # Position collision shape
    collision_shape.position = Vector3(0, 0, 0.01)  # Slightly in front of screen
    
    # Configure viewport
    viewport.size = screen_resolution
    viewport.render_target_update_mode = SubViewport.UPDATE_WHEN_PARENT_VISIBLE
    viewport.transparent_bg = true
    
    # Add 2D UI scene to viewport (replace with your UI scene)
    # var ui_scene = preload("res://ui/desktop_ui.tscn").instantiate()
    # viewport.add_child(ui_scene)
    
    # Configure anti-aliasing for better text quality
    viewport.msaa_3d = Viewport.MSAA_4X
    viewport.msaa_2d = Viewport.MSAA_4X
    
    # Disable 3D effects that might blur the screen
    if get_viewport():
        get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR
        get_viewport().fsr_sharpness = 1.0
```

## 3. **ViewAnchor Helper Script (`ViewAnchor.gd`)**

```gdscript
extends Marker3D

# This script helps position the camera anchor correctly
@export var screen_target: MeshInstance3D
@export var ideal_distance: float = 1.0
@export var auto_position: bool = true

func _ready():
    if auto_position and screen_target:
        position_anchor()

func position_anchor():
    if !screen_target:
        return
    
    # Position anchor perpendicular to screen center
    global_position = screen_target.global_position
    global_position.z += ideal_distance
    
    # Make anchor look at screen center
    look_at(screen_target.global_position, Vector3.UP)
    
    print("ViewAnchor positioned at: ", global_position)
```

## 4. **Project Settings (Add to `project.godot`)**

```ini
[input]
ui_cancel={
"deadzone": 0.5,
"events": [ Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"command_or_control_held":false,"pressed":false,"keycode":16777217,"physical_keycode":0,"unicode":0,"echo":false,"script":null)
 ]
}

[rendering]
anti_aliasing/quality/msaa_2d=2
anti_aliasing/quality/msaa_3d=2
rendering/mesh_system/software_skinning_fallback=false

[display]
window/stretch/mode="canvas_items"
window/stretch/aspect="keep"
```

## 5. **Scene Structure Example**

```
MonitorScene (Node3D)
├─ ScreenMesh (MeshInstance3D) - QuadMesh
├─ InteractionArea (Area3D)
│  └─ CollisionShape3D (BoxShape3D)
├─ SubViewport (1280x720)
│  └─ DesktopUI (Control node with your 2D UI)
├─ ViewAnchor (Marker3D)
└─ WorldComputerInteraction (Node - with script attached)
```

## 6. **Usage Instructions**

1. **Setup Monitor Scene:**
   - Create a QuadMesh with your desired screen size
   - Add an Area3D with matching BoxShape3D
   - Add a SubViewport with your 2D UI
   - Add a Marker3D as the camera anchor

2. **Configure Materials:**
   - Assign the SubViewport's texture to both Albedo and Emission
   - Set Emission energy to 1.0 for proper lighting

3. **Camera Setup:**
   - Ensure your player camera has `process_mode = PROCESS_ALWAYS`
   - Position the ViewAnchor perpendicular to the screen center
   - Adjust `ideal_distance` for comfortable viewing

4. **Optimization Tips:**

   ```gdscript
   # In your main scene script, add:
   func _ready():
       # Improve text rendering
       get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_OFF
       get_viewport().msaa_3d = Viewport.MSAA_8X
       
       # Disable effects that blur the screen
       var environment = WorldEnvironment.new()
       environment.environment = Environment.new()
       environment.environment.dof_blur_far_enabled = false
       add_child(environment)
   ```

## **Key Features Implemented:**

1. **Accurate Input Forwarding:** Converts 3D raycast hits to precise UV coordinates and pixel positions
2. **Camera Soft Lock:** Smoothly tweens camera to perpendicular viewing angle
3. **Seamless Interaction:** No scene transitions needed
4. **Text Legibility:** Proper UV mapping and high-resolution viewports
5. **Input Propagation:** Handles clicks, motion, and scroll events
6. **Clean Exit:** ESC key returns camera to original position

The system maintains 1:1 pixel correspondence when locked, eliminating text shimmering. The camera transition provides a natural "leaning in" effect while maintaining immersion.