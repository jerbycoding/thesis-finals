# Professional SOC Simulator: 3D Monitor Interaction Architecture

I'll provide a production-grade solution for your security operations center simulator, addressing each challenge with concrete implementations.

---

## 1. Input Occlusion & Physics Layer Architecture

### **Layer Strategy**

```gdscript
# ProjectSettings → Layer Names (Configure these first)
# Layer 1: World (walls, floors)
# Layer 2: Props (desks, chairs)
# Layer 3: NPCs
# Layer 4: Player Body Parts
# Layer 20: Interactive Monitors (UI Surfaces)

# MonitorInteractable.gd
extends MeshInstance3D
class_name MonitorInteractable

@export var viewport_path: NodePath
@onready var subviewport: SubViewport = get_node(viewport_path)

func _ready():
    # Create collision shape for raycast detection
    var static_body = StaticBody3D.new()
    add_child(static_body)
    
    var collision_shape = CollisionShape3D.new()
    var shape = BoxShape3D.new()
    
    # Match your QuadMesh dimensions (adjust to your screen size)
    shape.size = Vector3(1.28, 0.72, 0.01)  # 16:9 ratio, thin hitbox
    collision_shape.shape = shape
    static_body.add_child(collision_shape)
    
    # CRITICAL: Isolate to layer 20 only
    static_body.collision_layer = 0  # Don't collide with anything
    static_body.set_collision_layer_value(20, true)  # Only exist on layer 20
    static_body.collision_mask = 0  # Don't detect anything
    
    # Store reference for interaction system
    static_body.set_meta("monitor_interface", self)
```

### **Player Raycast System**

```gdscript
# PlayerMonitorInteraction.gd
extends Node3D

@onready var camera: Camera3D = $Camera3D
@onready var ui_raycast: RayCast3D = $Camera3D/UIRaycast
@onready var interaction_raycast: RayCast3D = $Camera3D/InteractionRaycast

var active_monitor: MonitorInteractable = null
var is_using_monitor: bool = false

func _ready():
    setup_raycasts()

func setup_raycasts():
    # UI Raycast: ONLY detects monitors (layer 20)
    ui_raycast.enabled = true
    ui_raycast.collision_mask = 0
    ui_raycast.set_collision_mask_value(20, true)
    ui_raycast.target_position = Vector3(0, 0, -10)  # 10m range
    ui_raycast.hit_from_inside = true  # Prevent clipping issues
    
    # Interaction Raycast: Detects everything except monitors
    # (for detecting NPCs, doors, etc.)
    interaction_raycast.enabled = true
    interaction_raycast.collision_mask = 0
    interaction_raycast.set_collision_mask_value(1, true)  # World
    interaction_raycast.set_collision_mask_value(2, true)  # Props
    interaction_raycast.set_collision_mask_value(3, true)  # NPCs
    # Explicitly exclude layer 20 (monitors handled separately)
    interaction_raycast.target_position = Vector3(0, 0, -3)

func _physics_process(delta):
    if is_using_monitor:
        process_monitor_input()
    else:
        check_monitor_interaction()

func check_monitor_interaction():
    if ui_raycast.is_colliding():
        var collider = ui_raycast.get_collider()
        if collider.has_meta("monitor_interface"):
            var monitor = collider.get_meta("monitor_interface")
            
            # Show interaction prompt
            show_interaction_hint("Press [E] to use workstation")
            
            if Input.is_action_just_pressed("interact"):
                start_monitor_interaction(monitor)

func start_monitor_interaction(monitor: MonitorInteractable):
    active_monitor = monitor
    is_using_monitor = true
    
    # Disable player movement
    get_parent().set_physics_process(false)
    
    # Tween camera to viewing position
    var tween = create_tween()
    tween.set_parallel(true)
    tween.tween_property(camera, "global_position", 
        monitor.get_view_anchor_position(), 0.5).set_trans(Tween.TRANS_CUBIC)
    tween.tween_property(camera, "global_rotation", 
        monitor.get_view_anchor_rotation(), 0.5).set_trans(Tween.TRANS_CUBIC)
    
    await tween.finished
    
    # Enable virtual cursor system
    Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
    monitor.enable_virtual_cursor()
```

### **NPC Configuration (Ensure they don't block monitors)**

```gdscript
# NPCCharacter.gd
func _ready():
    # NPCs should only exist on layer 3
    $CollisionShape3D.collision_layer = 0
    $CollisionShape3D.set_collision_layer_value(3, true)
    
    # They can collide with world and other NPCs, but NOT monitors
    $CollisionShape3D.collision_mask = 0
    $CollisionShape3D.set_collision_mask_value(1, true)  # World
    $CollisionShape3D.set_collision_mask_value(3, true)  # Other NPCs
    # Layer 20 is NOT in their mask
```

---

## 2. Professional Text Legibility Configuration

### **Project Settings (Project → Rendering)**

```
Rendering/Anti Aliasing/Quality/MSAA 3D: 4x (or 8x if performance allows)
Rendering/Anti Aliasing/Quality/Screen Space AA: FXAA
Rendering/Textures/Default Filters/Use Nearest: OFF
Rendering/Textures/Default Filters/Anisotropic Filtering Level: 16x
Rendering/Scaling 3D/Mode: Disabled (do not use FSR/bilinear)
```

### **SubViewport Configuration**

```gdscript
# MonitorViewport.gd
extends SubViewport

func _ready():
    # CRITICAL: Use native resolution matching your QuadMesh
    size = Vector2i(1920, 1080)  # Higher than 1280x720 for crispness
    
    # Anti-aliasing
    msaa_3d = Viewport.MSAA_4X
    screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
    
    # Disable 3D scaling (we're rendering 2D UI)
    scaling_3d_mode = Viewport.SCALING_3D_MODE_OFF
    
    # HDR for better contrast
    use_hdr_2d = true
    
    # Disable unnecessary features
    audio_listener_enable_2d = false
    audio_listener_enable_3d = false
    
    # CRITICAL: Transparent background for proper emission
    transparent_bg = false  # Set to true if you want CRT-style transparency
    
    # Update mode
    render_target_update_mode = SubViewport.UPDATE_ALWAYS
```

### **Monitor Material Configuration**

```gdscript
# MonitorInteractable.gd (continued)
func setup_monitor_material():
    var material = StandardMaterial3D.new()
    
    # Get viewport texture
    var viewport_texture = subviewport.get_texture()
    
    # Base texture
    material.albedo_texture = viewport_texture
    
    # CRITICAL: Emission for "glowing monitor" effect
    material.emission_enabled = true
    material.emission_texture = viewport_texture
    material.emission_energy_multiplier = 1.5  # Adjust for brightness
    
    # Unshaded (monitors emit light, don't receive it)
    material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    
    # CRITICAL TEXTURE SETTINGS FOR TEXT CLARITY
    material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
    material.texture_repeat = false
    
    # Anisotropic filtering (essential for viewing at angles)
    material.anisotropy_enabled = true
    material.anisotropy_strength = 16.0
    
    # No transparency (solid screen)
    material.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
    
    # Backface culling
    material.cull_mode = BaseMaterial3D.CULL_BACK
    
    # Disable features we don't need
    material.billboard_mode = BaseMaterial3D.BILLBOARD_DISABLED
    
    # Apply material
    material_override = material
```

### **Font Configuration for SIEM Logs**

```gdscript
# SIEMLogViewer.gd (your terminal/log UI inside SubViewport)
extends RichTextLabel

func _ready():
    # Load a high-quality monospace font
    var font = load("res://fonts/JetBrainsMono-Regular.ttf")
    
    # CRITICAL: Font rendering settings
    var font_variation = FontVariation.new()
    font_variation.base_font = font
    font_variation.antialiasing = TextServer.FONT_ANTIALIASING_LCD  # Best for monitors
    font_variation.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_AUTO
    
    # Use larger font size than you'd think (scales down nicely)
    add_theme_font_override("normal_font", font_variation)
    add_theme_font_size_override("normal_font_size", 18)  # Will look like 12pt at distance
    add_theme_font_override("mono_font", font_variation)
    add_theme_font_size_override("mono_font_size", 18)
    
    # Ensure text contrast
    add_theme_color_override("default_color", Color.WHITE)
    add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
    add_theme_constant_override("shadow_offset_x", 1)
    add_theme_constant_override("shadow_offset_y", 1)
```

### **Optional: Supersampling for Maximum Clarity**

```gdscript
# If performance allows, render at 2x resolution and downsample
func _ready():
    subviewport.size = Vector2i(3840, 2160)  # 4K resolution
    # The automatic texture filtering will make this look incredibly sharp
```

---

## 3. Virtual Cursor System (Zero Lag, No Ghosting)

### **Virtual Cursor Implementation**

```gdscript
# VirtualCursor.gd (attach to a Control node in your SubViewport)
extends Control

@onready var cursor_sprite: TextureRect = $CursorSprite

var cursor_textures = {
    "default": preload("res://ui/cursors/arrow.png"),
    "pointer": preload("res://ui/cursors/hand.png"),
    "text": preload("res://ui/cursors/ibeam.png"),
    "wait": preload("res://ui/cursors/loading.png")
}

var current_cursor = "default"

func _ready():
    cursor_sprite.texture = cursor_textures["default"]
    cursor_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    cursor_sprite.custom_minimum_size = Vector2(32, 32)
    cursor_sprite.pivot_offset = Vector2(0, 0)  # Top-left pivot
    visible = false

func show_cursor():
    visible = true

func hide_cursor():
    visible = false

func set_cursor_type(type: String):
    if cursor_textures.has(type):
        current_cursor = type
        cursor_sprite.texture = cursor_textures[type]

func update_position(viewport_pos: Vector2):
    global_position = viewport_pos
```

### **Perfect Cursor Synchronization**

```gdscript
# PlayerMonitorInteraction.gd (continued)

var mouse_smoothing: bool = false  # Set to true if you want interpolation
var last_viewport_pos: Vector2 = Vector2.ZERO

func process_monitor_input():
    if not active_monitor:
        return
    
    # Calculate UV coordinates from raycast
    var uv = get_monitor_uv_coordinates()
    
    if uv.x < 0 or uv.y < 0:  # Mouse left monitor bounds
        return
    
    # Convert UV to viewport pixel coordinates
    var viewport_size = active_monitor.subviewport.size
    var viewport_pos = Vector2(
        uv.x * viewport_size.x,
        uv.y * viewport_size.y
    )
    
    # Optional smoothing (usually not needed, can introduce lag)
    if mouse_smoothing:
        viewport_pos = last_viewport_pos.lerp(viewport_pos, 0.3)
        last_viewport_pos = viewport_pos
    
    # Update virtual cursor (happens INSTANTLY in same frame)
    active_monitor.update_virtual_cursor(viewport_pos)
    
    # Create synthetic mouse motion event
    var motion_event = InputEventMouseMotion.new()
    motion_event.position = viewport_pos
    motion_event.relative = viewport_pos - last_viewport_pos
    motion_event.velocity = motion_event.relative / get_process_delta_time()
    
    # Push to SubViewport (processed immediately)
    active_monitor.subviewport.push_input(motion_event)
    
    last_viewport_pos = viewport_pos
    
    # Handle mouse buttons
    if Input.is_action_just_pressed("left_click"):
        send_mouse_button(viewport_pos, MOUSE_BUTTON_LEFT, true)
    elif Input.is_action_just_released("left_click"):
        send_mouse_button(viewport_pos, MOUSE_BUTTON_LEFT, false)
    
    if Input.is_action_just_pressed("right_click"):
        send_mouse_button(viewport_pos, MOUSE_BUTTON_RIGHT, true)
    elif Input.is_action_just_released("right_click"):
        send_mouse_button(viewport_pos, MOUSE_BUTTON_RIGHT, false)
    
    # Exit interaction
    if Input.is_action_just_pressed("ui_cancel"):
        exit_monitor_interaction()

func get_monitor_uv_coordinates() -> Vector2:
    if not ui_raycast.is_colliding():
        return Vector2(-1, -1)
    
    var collision_point = ui_raycast.get_collision_point()
    var collider = ui_raycast.get_collider()
    
    # Transform to local space of the monitor mesh
    var local_point = active_monitor.to_local(collision_point)
    
    # Assuming QuadMesh centered at origin with size (1.28, 0.72)
    # Adjust these values to match your actual mesh dimensions
    var half_width = 0.64  # 1.28 / 2
    var half_height = 0.36  # 0.72 / 2
    
    var uv = Vector2(
        (local_point.x + half_width) / (half_width * 2),
        1.0 - ((local_point.y + half_height) / (half_height * 2))  # Flip Y
    )
    
    return uv.clamp(Vector2.ZERO, Vector2.ONE)

func send_mouse_button(pos: Vector2, button: int, pressed: bool):
    var click_event = InputEventMouseButton.new()
    click_event.position = pos
    click_event.button_index = button
    click_event.pressed = pressed
    
    active_monitor.subviewport.push_input(click_event)
```

### **Monitor Interface Updates**

```gdscript
# MonitorInteractable.gd (continued)

@onready var virtual_cursor: Control = $SubViewport/UI/VirtualCursor

func enable_virtual_cursor():
    if virtual_cursor:
        virtual_cursor.show_cursor()

func disable_virtual_cursor():
    if virtual_cursor:
        virtual_cursor.hide_cursor()

func update_virtual_cursor(viewport_pos: Vector2):
    if virtual_cursor:
        virtual_cursor.update_position(viewport_pos)
        
        # Automatic cursor type detection based on hovered control
        var hovered = get_hovered_control(viewport_pos)
        if hovered is Button or hovered is LinkButton:
            virtual_cursor.set_cursor_type("pointer")
        elif hovered is LineEdit or hovered is TextEdit:
            virtual_cursor.set_cursor_type("text")
        else:
            virtual_cursor.set_cursor_type("default")

func get_hovered_control(pos: Vector2) -> Control:
    # Use Viewport's GUI to find what's under the cursor
    var root = subviewport.get_child(0)  # Your UI root
    if root and root is Control:
        return root.get_rect().has_point(pos) and root or null
    return null
```

---

## 4. Input State Flushing & Stuck Key Prevention

### **Comprehensive Input State Manager**

```gdscript
# InputStateManager.gd
extends Node
class_name InputStateManager

signal all_keys_released

var pressed_keys: Dictionary = {}  # keycode -> true
var pressed_mouse_buttons: Dictionary = {}  # button_index -> true
var target_viewport: SubViewport

func set_viewport(viewport: SubViewport):
    target_viewport = viewport

func track_key(event: InputEventKey):
    if event.pressed and not event.echo:
        pressed_keys[event.keycode] = true
    elif not event.pressed:
        pressed_keys.erase(event.keycode)

func track_mouse_button(event: InputEventMouseButton):
    if event.pressed:
        pressed_mouse_buttons[event.button_index] = true
    else:
        pressed_mouse_buttons.erase(event.button_index)

func release_all_inputs():
    # Release all keys
    for keycode in pressed_keys.keys():
        var release_event = InputEventKey.new()
        release_event.keycode = keycode
        release_event.pressed = false
        release_event.echo = false
        
        if target_viewport:
            target_viewport.push_input(release_event)
    
    # Release all mouse buttons
    for button in pressed_mouse_buttons.keys():
        var release_event = InputEventMouseButton.new()
        release_event.button_index = button
        release_event.pressed = false
        
        if target_viewport:
            target_viewport.push_input(release_event)
    
    pressed_keys.clear()
    pressed_mouse_buttons.clear()
    all_keys_released.emit()

func get_pressed_keys() -> Array:
    return pressed_keys.keys()

func is_any_key_pressed() -> bool:
    return pressed_keys.size() > 0 or pressed_mouse_buttons.size() > 0
```

### **Integration with Monitor Interaction**

```gdscript
# PlayerMonitorInteraction.gd (continued)

var input_state_manager: InputStateManager

func _ready():
    setup_raycasts()
    input_state_manager = InputStateManager.new()
    add_child(input_state_manager)

func start_monitor_interaction(monitor: MonitorInteractable):
    active_monitor = monitor
    is_using_monitor = true
    
    # Set viewport for input tracking
    input_state_manager.set_viewport(monitor.subviewport)
    
    # ... camera tween code ...
    
    await tween.finished
    
    Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
    monitor.enable_virtual_cursor()

func _input(event):
    if not is_using_monitor or not active_monitor:
        return
    
    # Track all keyboard input
    if event is InputEventKey:
        input_state_manager.track_key(event)
        active_monitor.subviewport.push_input(event)
        get_viewport().set_input_as_handled()
    
    # Track mouse buttons
    elif event is InputEventMouseButton:
        # Don't track these through input manager (handled separately)
        pass

func exit_monitor_interaction():
    if not active_monitor:
        return
    
    # CRITICAL: Release all held inputs BEFORE transitioning
    input_state_manager.release_all_inputs()
    
    # Small delay to ensure release events are processed
    await get_tree().create_timer(0.05).timeout
    
    # Disable virtual cursor
    active_monitor.disable_virtual_cursor()
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    
    # Tween camera back
    var tween = create_tween()
    tween.set_parallel(true)
    tween.tween_property(camera, "global_position", 
        original_camera_position, 0.5).set_trans(Tween.TRANS_CUBIC)
    tween.tween_property(camera, "global_rotation", 
        original_camera_rotation, 0.5).set_trans(Tween.TRANS_CUBIC)
    
    await tween.finished
    
    # Re-enable player movement
    get_parent().set_physics_process(true)
    
    is_using_monitor = false
    active_monitor = null

# FAILSAFE: Detect forced interruptions
func _notification(what):
    if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
        if is_using_monitor:
            input_state_manager.release_all_inputs()
    
    elif what == NOTIFICATION_APPLICATION_PAUSED:
        if is_using_monitor:
            input_state_manager.release_all_inputs()
```

### **Terminal-Specific Input Handling**

```gdscript
# SIEMTerminal.gd (your command-line interface in SubViewport)
extends Control

@onready var input_line: LineEdit = $InputLine
var command_history: Array[String] = []

func _ready():
    input_line.focus_mode = Control.FOCUS_ALL
    input_line.grab_focus()

# Override to detect when focus is lost during interaction
func _notification(what):
    if what == NOTIFICATION_FOCUS_EXIT:
        # Clear any partial input state
        input_line.clear()
        
        # Reset modifiers
        Input.action_release("ui_shift")
        Input.action_release("ui_ctrl")
        Input.action_release("ui_alt")

func _input(event):
    if not input_line.has_focus():
        return
    
    # Additional safety: detect abnormal key combinations
    if event is InputEventKey and event.pressed:
        if event.keycode == KEY_ESCAPE:
            # Player is trying to exit, clear input
            input_line.clear()
            get_viewport().set_input_as_handled()
```

---

## Complete Architectural Integration

```gdscript
# MonitorWorkstation.gd (main scene node)
extends Node3D

@export var view_anchor: Node3D
@export var subviewport: SubViewport
@onready var monitor_mesh: MeshInstance3D = $MonitorMesh

var monitor_interactable: MonitorInteractable

func _ready():
    # Initialize monitor system
    monitor_interactable = MonitorInteractable.new()
    monitor_interactable.viewport_path = subviewport.get_path()
    monitor_mesh.add_child(monitor_interactable)
    
    # Setup everything
    monitor_interactable.setup_monitor_material()

func get_view_anchor_position() -> Vector3:
    return view_anchor.global_position

func get_view_anchor_rotation() -> Vector3:
    return view_anchor.global_rotation
```

---

## Performance Optimization Tips

1. **Viewport Update Mode**: Set to `UPDATE_WHEN_VISIBLE` if the monitor is off-screen:
```gdscript
func _on_monitor_visibility_changed(is_visible: bool):
    if is_visible:
        subviewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    else:
        subviewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
```

2. **LOD System for Multiple Monitors**:
```gdscript
func _process(delta):
    var distance = global_position.distance_to(player.global_position)
    
    if distance < 5.0:
        subviewport.size = Vector2i(1920, 1080)  # Full res
    elif distance < 10.0:
        subviewport.size = Vector2i(1280, 720)   # Medium res
    else:
        subviewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
```

This architecture provides production-grade reliability for your SOC simulator with zero input lag, perfect occlusion handling, professional text rendering, and bulletproof input state management.