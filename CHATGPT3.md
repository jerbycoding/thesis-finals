Nice — you’ve nailed the architecture. Below I give a compact, **bullet-proof Master Script** that ties everything together and also answers your 4 verification questions exactly and practically.

Read the four answers first (short), then the script and call flow.

---

# Short answers (precise)

1. **Mouse Mode (hidden) & positions:**
   `Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)` hides the OS cursor but **`Input.get_mouse_position()` still returns the absolute cursor position** inside the window. Use that for raycasts. Only use an internal accumulator of `event.relative` when you set `MOUSE_MODE_CAPTURED` (grabbed) or if you intentionally stop using absolute coords.

2. **SubViewport focus after push_input():**
   `viewport.push_input()` injects events but **does not reliably give GUI focus** to Controls. You should explicitly `grab_focus()` the Control that should receive keyboard input (e.g., the active `LineEdit` or your container root) immediately after starting interaction.

3. **Handover frame gap (1-frame lag):**
   There is a real risk. Force immediate “mouse-enter” and first motion into the viewport **before or at the same frame** you switch modes: call `viewport._notification(NOTIFICATION_VP_MOUSE_ENTER)` (practical workaround), immediately `push_input()` a mouse-motion and any button press, then `grab_focus()` the Control. Doing this eliminates the typical 1-frame gap.

4. **Virtual cursor always on top:**
   Put the virtual cursor inside the SubViewport scene **under a CanvasLayer** with a high layer index (or the highest `z_index` on a top-level `CanvasLayer`). Make the cursor `mouse_filter = MOUSE_FILTER_IGNORE` so it never steals clicks. A CanvasLayer guarantees it renders above regular UI without repetitive `move_to_front()`.

---

# Master Script — single node, drop-in

Attach this to a `Node3D` called `ScreenBridge` placed near each monitor. Exports let you wire Camera, QuadMesh, SubViewport, ViewAnchor, and the first focusable Control.

```gdscript
# ScreenBridge.gd — Master implementation
extends Node3D

@export_node_path("Camera3D")
var camera_path: NodePath
@export_node_path("MeshInstance3D")
var screen_mesh_path: NodePath
@export_node_path("Viewport")
var screen_viewport_path: NodePath
@export_node_path("Node3D")  # your perpendicular anchor (Marker3D)
var view_anchor_path: NodePath
@export_node_path("NodePath")  # Control inside the Viewport to grab focus on enter
var initial_focus_control_path: NodePath

# physics layer mask for UI screen (example: layer 20)
const LAYER_UI_SCREEN := 1 << 19
const RAY_LEN := 2000.0

# runtime refs
var camera: Camera3D
var screen_mesh: MeshInstance3D
var screen_viewport: Viewport
var view_anchor: Node3D
var initial_focus_control: Control

# quad size (in local space)
var quad_size := Vector2.ONE
var viewport_size := Vector2(1280, 720) # fallback

# Input tracker (flush stuck keys)
var pressed_physical_scancodes := {} # Set (Dictionary keyed by scancode)

# Interaction state
var interacting := false
var prev_mouse_mode = Input.MOUSE_MODE_VISIBLE
var softlock_tween: SceneTreeTween = null

func _ready():
    camera = get_node(camera_path) as Camera3D
    screen_mesh = get_node(screen_mesh_path) as MeshInstance3D
    screen_viewport = get_node(screen_viewport_path) as Viewport
    view_anchor = get_node(view_anchor_path) as Node3D
    if initial_focus_control_path != null and screen_viewport.get_node_or_null(initial_focus_control_path) != null:
        # Because the Control is inside the Viewport, we need to get it from the viewport's scene:
        initial_focus_control = screen_viewport.get_node(initial_focus_control_path) as Control

    # get QuadMesh size if possible
    if screen_mesh.mesh and screen_mesh.mesh is QuadMesh:
        quad_size = (screen_mesh.mesh as QuadMesh).size
    else:
        var aabb = screen_mesh.get_aabb()
        quad_size = Vector2(aabb.size.x, aabb.size.y)

    viewport_size = Vector2(screen_viewport.size.x, screen_viewport.size.y)

    # ensure viewport will accept injected input
    screen_viewport.gui_disable_input = false

# --- Raycast that only hits UI layer (occlusion handled by mask) ---
func _raycast_hit_from_mouse(window_mouse_pos: Vector2) -> Dictionary:
    var from = camera.project_ray_origin(window_mouse_pos)
    var dir = camera.project_ray_normal(window_mouse_pos)
    var to = from + dir * RAY_LEN
    var state = get_world_3d().direct_space_state
    # explicit collision_mask ensures NPCs/hands don't steal hits
    var exclude = []  # optionally exclude camera, player body, etc.
    var hit = state.intersect_ray(from, to, exclude, collision_mask=LAYER_UI_SCREEN)
    if hit.empty():
        return {}
    # verify collider is the mesh (optional)
    if hit.has("collider") and hit.collider == screen_mesh:
        return hit
    return {}

# --- convert hit to viewport pixel coords (0..viewport_size) ---
func _hit_to_pixel(hit: Dictionary) -> Vector2:
    var local = screen_mesh.to_local(hit.position)
    # quad centered at origin: map [-size/2, +size/2] -> [0..1]
    var u = (local.x / quad_size.x) + 0.5
    var v = 1.0 - ((local.y / quad_size.y) + 0.5)  # flip Y for viewport top-left origin
    u = clamp(u, 0.0, 1.0)
    v = clamp(v, 0.0, 1.0)
    return Vector2(u * viewport_size.x, v * viewport_size.y)

# --- Input forwarding: push motion, buttons, wheel ---
func _unhandled_input(event: InputEvent) -> void:
    # handle keyboard tracking for SubViewport (we capture key events too)
    if event is InputEventKey:
        var sc = event.physical_scancode
        if event.pressed:
            pressed_physical_scancodes[sc] = true
        else:
            pressed_physical_scancodes.erase(sc)
        # If interacting, forward the key to viewport
        if interacting:
            screen_viewport.push_input(event)
        return

    # mouse events: only forward if interacting (and when over screen)
    if not interacting:
        return

    var mouse_pos = Input.get_mouse_position()  # absolute inside window even when hidden
    var hit = _raycast_hit_from_mouse(mouse_pos)
    if hit.empty():
        return

    var pixel = _hit_to_pixel(hit)

    if event is InputEventMouseMotion:
        var mm := InputEventMouseMotion.new()
        mm.position = pixel
        mm.global_position = pixel
        mm.relative = event.relative
        mm.device = event.device
        screen_viewport.push_input(mm)
        # update virtual cursor via signal (fast)
        emit_signal("virtual_cursor_move", pixel)
        return

    if event is InputEventMouseButton:
        var evb := InputEventMouseButton.new()
        evb.position = pixel
        evb.global_position = pixel
        evb.button_index = event.button_index
        evb.pressed = event.pressed
        evb.doubleclick = event.doubleclick
        evb.device = event.device
        screen_viewport.push_input(evb)
        return

# --- Start interaction: hide OS cursor, notify viewport, grab focus, push initial motion/button, tween camera ---
func begin_interaction(initial_click_screen_pos: Vector2 = null) -> void:
    if interacting:
        return
    interacting = true
    prev_mouse_mode = Input.get_mouse_mode()
    Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)  # hides OS cursor but absolute pos remains available

    # Immediately tell viewport mouse is entering (workaround for handover gap)
    screen_viewport._notification(NOTIFICATION_VP_MOUSE_ENTER)

    # push a synthetic mouse motion to place viewport's mouse at the correct pixel
    var window_mouse_pos = Input.get_mouse_position()
    var hit = _raycast_hit_from_mouse(window_mouse_pos)
    if hit.empty() and initial_click_screen_pos != null:
        # fallback: use last known click position converted manually (optional)
        hit = _raycast_hit_from_mouse(initial_click_screen_pos)

    if not hit.empty():
        var pixel = _hit_to_pixel(hit)
        var mm := InputEventMouseMotion.new()
        mm.position = pixel
        mm.global_position = pixel
        mm.relative = Vector2.ZERO
        screen_viewport.push_input(mm)
        emit_signal("virtual_cursor_move", pixel)

    # ensure keyboard goes to the intended control inside the SubViewport
    if initial_focus_control:
        # make sure the control exists in the viewport scene and then grab focus
        initial_focus_control.grab_focus()

    # soft lock camera (tween)
    if softlock_tween:
        softlock_tween.kill()
    softlock_tween = create_tween()
    softlock_tween.tween_property(camera, "global_transform", view_anchor.global_transform, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

# --- End interaction: flush key releases, notify viewport exit, restore mouse mode, tween back ---
func end_interaction(restore_transform: Transform3D = Transform3D.IDENTITY) -> void:
    if not interacting:
        return
    interacting = false

    # flush all pressed keys to viewport as releases
    _flush_pressed_keys_to_viewport()

    # force viewport mouse exit
    screen_viewport._notification(NOTIFICATION_VP_MOUSE_EXIT)

    # restore OS mouse mode
    Input.set_mouse_mode(prev_mouse_mode)

    # soft unlock camera: restore a provided transform, or just move away a bit
    if softlock_tween:
        softlock_tween.kill()
    softlock_tween = create_tween()
    # prefer to restore original camera transform (you can store it before locking)
    # Here we assume caller supplies transform; otherwise set one you saved earlier.
    softlock_tween.tween_property(camera, "global_transform", restore_transform, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

# --- flush pressed keys to viewport as synthetic releases ---
func _flush_pressed_keys_to_viewport() -> void:
    for sc in pressed_physical_scancodes.keys():
        var ev := InputEventKey.new()
        ev.physical_scancode = int(sc)
        ev.pressed = false
        ev.echo = false
        screen_viewport.push_input(ev)
    pressed_physical_scancodes.clear()
    Input.flush_buffered_events()  # best-effort global cleanup

# optional signal to allow an external UI node to set the virtual cursor position
signal virtual_cursor_move(pixel: Vector2)
```

---

# Wiring & SubViewport scene notes (very important)

1. **Virtual cursor:** inside the SubViewport scene add a `CanvasLayer` (layer = big number; e.g., 10) as root for the cursor. Put `TextureRect` or `Sprite2D` there. `CanvasLayer` ensures topmost rendering. Set `mouse_filter = MOUSE_FILTER_IGNORE` on the cursor so it doesn't steal GUI input.

2. **Focus control:** set `initial_focus_control_path` to e.g. `"Root/TerminalContainer/LineEdit"` relative to the viewport scene root. When `grab_focus()` is called, LineEdit receives keyboard.

3. **Viewport settings:**

   * `size` = high resolution while interacting (e.g., 1920×1080 or 2560×1440 if text small).
   * `msaa` = 4 (or 8 on high-end).
   * `gui_disable_input` = false.
   * Ensure the ViewportTexture is used in Mesh material's `albedo` & `emission`.

4. **Physics layer:** set the screen collider and Area3D on the dedicated `UI_SCREEN` layer so the raycast mask picks only it.

5. **Virtual cursor sync:** connect the `virtual_cursor_move` signal from `ScreenBridge` to a small script inside the Viewport scene that sets the cursor Control position immediately.

Example inside the SubViewport root:

```gdscript
func _on_bridge_virtual_cursor_move(pixel):
    var cursor = $CanvasLayer/Cursor
    cursor.position = pixel
```

---

# Recommended usage flow (sequence to avoid gaps)

1. Player clicks monitor in world → `ScreenBridge` detects click via its raycast.
2. Call `begin_interaction()` and pass the click position if desired. That:

   * hides OS cursor,
   * fires `NOTIFICATION_VP_MOUSE_ENTER`,
   * immediately pushes a mouse motion event at the correct pixel,
   * `grab_focus()` on the intended control,
   * begins soft-lock tween of camera.
3. While interacting, every `InputEventMouseMotion`/`Button` that reaches the game is converted to viewport pixel coords and forwarded (frame-by-frame). Virtual cursor is updated via signal.
4. On exit (`Escape`, stand-up), call `end_interaction(original_camera_transform)` which pushes synthetic key releases, notifies exit, and restores mouse mode.

---

# Final hard recommendations (ship-ready)

* **Use `MOUSE_MODE_HIDDEN`** for this UX. It keeps absolute mouse coords and hides OS cursor. Only use `CAPTURED` if you want infinite-mouse style controls (not needed here).
* Always **grab_focus()** the Control inside the viewport after your initial synthetic motion event. That guarantees keyboard targets (LineEdit, TextEdit) get input.
* Use `viewport._notification(NOTIFICATION_VP_MOUSE_ENTER)` + immediate `push_input(mouse_motion)` to eliminate 1-frame handover.
* Make virtual cursor a `CanvasLayer` child with `MOUSE_FILTER_IGNORE`. No more `move_to_front()` calls needed.
* Always flush key state on exit using the explicit scancode set technique.

---

If you want, I’ll now convert this into a ready-to-drop `ScreenTerminal.tscn` (scene) — with the `CanvasLayer` virtual cursor, `LineEdit` demo, and wiring between the scene and the bridge (signals connected). Say “build the scene” and I’ll produce it.
