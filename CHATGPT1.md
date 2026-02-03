

Nice brief — this is exactly the kind of practical spec I like. Below I give a ready-to-drop-in Godot 4 GDScript implementation (two scripts + setup notes) that:

* raycasts from the 3D camera to a QuadMesh screen,
* converts the hit into UV → pixel coordinates,
* creates and forwards `InputEventMouseMotion` / `InputEventMouseButton` (including mouse wheel) to the SubViewport via `viewport.push_input()`,
* includes a camera **soft-lock** tween (ViewAnchor) to align the camera perpendicular to the screen for pixel-perfect interaction,
* and includes tips for mipmaps, DoF, and text legibility.

I’m strict: follow the Setup Checklist exactly. If something is off (mesh orientation, Quad size, viewport resolution), the mapping will be wrong — fix that first.

---

# Setup Checklist (do this first)

1. Add a `Viewport` node (your “SubViewport”) and design your 2D UI inside it. Set its **size** (e.g. 1280×720) in the Viewport node.
2. Create a `MeshInstance3D` with a `QuadMesh` (use QuadMesh, not CSG). Ensure the QuadMesh is centered at origin and sized to the QuadMesh `size` (e.g. `Vector2(1, 0.5625)` or any world scale — we’ll read actual size at runtime). The Quad should face +Z or -Z consistently; I assume the Quad’s front faces the camera.
3. Create a `StandardMaterial3D` on the Quad and assign the Viewport’s texture to the material’s `albedo_texture` (and emission) for crisp display.
4. Add an `Area3D` with a `CollisionShape3D` (Box) sized precisely to the quad (optional but recommended for quick overlap checks).
5. Create a `Marker3D` (or `Node3D`) as the **ViewAnchor** — position/orient it so that when the camera snaps to it, it’s perfectly perpendicular and centered on the Quad (this is your “soft lock” pose).
6. Make sure camera’s mouse mode is `MOUSE_MODE_VISIBLE` when you want world-UI interaction.

---

# Script A — `screen_input_bridge.gd`

Attach to a Node3D (e.g., `ScreenBridge`) placed near your monitor in the scene.

```gdscript
# screen_input_bridge.gd
# Attach to Node3D. Exposes nodes to connect in the editor.
# Godot 4 GDScript

extends Node3D

@export_node_path("Camera3D")
var camera_path: NodePath

@export_node_path("MeshInstance3D")
var screen_mesh_path: NodePath

@export_node_path("Viewport")
var screen_viewport_path: NodePath

# Optional: an Area3D for faster checks
@export_node_path("Area3D")
var area_path: NodePath

# Maximum ray distance
@export var ray_len: float = 2000.0

# Only forward input when mouse is visible
func _ready():
	assert(camera_path != null, "Assign a Camera3D to camera_path")
	assert(screen_mesh_path != null, "Assign a MeshInstance3D (QuadMesh) to screen_mesh_path")
	assert(screen_viewport_path != null, "Assign the Viewport (SubViewport) used as screen texture")
	
	camera = get_node(camera_path) as Camera3D
	screen_mesh = get_node(screen_mesh_path) as MeshInstance3D
	screen_viewport = get_node(screen_viewport_path) as Viewport
	area = null
	if area_path and has_node(area_path):
		area = get_node(area_path) as Area3D

	# Try to inspect QuadMesh size or fallback to AABB
	var mesh_res = screen_mesh.mesh
	if typeof(mesh_res) == TYPE_OBJECT and mesh_res is QuadMesh:
		quad_size = mesh_res.size
	else:
		# fallback: use local AABB size
		var aabb = screen_mesh.get_aabb()
		quad_size = Vector2(aabb.size.x, aabb.size.y)
	
	# Cache viewport resolution
	_viewport_size = Vector2(screen_viewport.size.x, screen_viewport.size.y)

# ---------- utility: test whether the ray hit the screen mesh ----------
func _raycast_to_screen(screen_pos: Vector2) -> Dictionary:
	# screen_pos: global (window) mouse position (e.g. Input.get_mouse_position())
	var from = camera.project_ray_origin(screen_pos)
	var dir = camera.project_ray_normal(screen_pos)
	var to = from + dir * ray_len
	var space = get_world_3d().direct_space_state
	var exclude := [camera]  # avoid hitting camera itself
	var res = space.intersect_ray(from, to, exclude)
	if res.empty():
		return {}
	# ensure we hit the targeted mesh (or the area's collider)
	if res.has("collider") and (res.collider == screen_mesh or (area and res.collider == area)):
		return res
	return {}

# ---------- map 3D hit position -> UV (0..1) -> pixel coords ----------
func _hit_to_pixel(res: Dictionary) -> Vector2:
	# res.position is global hit point
	var local = screen_mesh.to_local(res.position)
	# QuadMesh is usually centered at origin: x in [-size.x/2, size.x/2], y in [-size.y/2, size.y/2]
	var u = (local.x / quad_size.x) + 0.5
	# UI top-left is y=0, but local.y is usually +up. Flip y.
	var v = 1.0 - ((local.y / quad_size.y) + 0.5)
	# clamp safety
	u = clamp(u, 0.0, 1.0)
	v = clamp(v, 0.0, 1.0)
	return Vector2(u * _viewport_size.x, v * _viewport_size.y)

# ---------- Input forwarding ----------
func _unhandled_input(event: InputEvent) -> void:
	# Only when mouse visible (user intent to interact)
	if Input.get_mouse_mode() != Input.MOUSE_MODE_VISIBLE:
		return

	# Use the window mouse position to raycast
	var mouse_pos = Input.get_mouse_position()
	var hit = _raycast_to_screen(mouse_pos)
	if hit.empty():
		return

	var pixel = _hit_to_pixel(hit)

	# Motion: forward as InputEventMouseMotion
	if event is InputEventMouseMotion:
		var ev := InputEventMouseMotion.new()
		ev.position = pixel
		# Optionally set relative: event.relative (best-effort)
		ev.relative = event.relative
		# device and global_position not strictly needed, but set for robustness:
		ev.device = event.device
		ev.global_position = pixel
		screen_viewport.push_input(ev)
		return

	# Button (clicks and wheel)
	if event is InputEventMouseButton:
		var evb := InputEventMouseButton.new()
		evb.position = pixel
		evb.global_position = pixel
		evb.button_index = event.button_index
		evb.pressed = event.pressed
		evb.doubleclick = event.doubleclick
		evb.device = event.device
		# For wheel events: pressed is true for instant events (wheel has no release)
		screen_viewport.push_input(evb)
		return

	# (If you want to forward other input types like key modifiers combined, add more here.)
```

---

# Script B — `camera_soft_lock.gd`

Attach to the same `Camera3D` or to a controller node that manages the camera. Use it to smoothly tween to a perpendicular ViewAnchor.

```gdscript
# camera_soft_lock.gd
# Controls camera tween to/from a ViewAnchor (Marker3D).
# Attach to your camera controller or Camera3D.

extends Node3D

@export_node_path("Camera3D")
var camera_path: NodePath

# The Marker3D or Node3D that is positioned perpendicular to the screen
@export_node_path("Node3D")
var anchor_path: NodePath

@export var tween_time: float = 0.35
@export var tween_trans_type := Tween.TRANS_QUAD
@export var tween_ease_type := Tween.EASE_OUT

var camera: Camera3D
var anchor: Node3D
var _orig_transform: Transform3D
var _tween: SceneTreeTween = null

func _ready():
	assert(camera_path != null)
	assert(anchor_path != null)
	camera = get_node(camera_path) as Camera3D
	anchor = get_node(anchor_path) as Node3D
	_orig_transform = camera.global_transform

func lock():
	# Save original transform (if you want to restore later)
	_orig_transform = camera.global_transform
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(camera, "global_transform", anchor.global_transform, tween_time).set_trans(tween_trans_type).set_ease(tween_ease_type)

func unlock():
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(camera, "global_transform", _orig_transform, tween_time).set_trans(tween_trans_type).set_ease(tween_ease_type)
```

Usage example:

* When you detect the player starts interacting (e.g., click in the world-screen), call `camera_soft_lock.lock()`.
* When they stop (escape, close UI, move away), call `camera_soft_lock.unlock()`.

---

# Important implementation notes & gotchas (read these)

1. **Mesh orientation & local axes** — the mapping assumes the QuadMesh is centered at origin and spans `[-size/2, +size/2]` in X and Y. If your Quad is rotated or scaled by a parent, `to_local()` handles that — but ensure you used the real Quad size (the script tries to read `QuadMesh.size` or falls back to `get_aabb()`).

2. **Viewport coordinate origin** — Godot UI origin is top-left. We flip the Y when converting from local to viewport pixel coordinates.

3. **Wheel events** — scroll wheel events are `InputEventMouseButton` with `button_index` values for wheel up/down (they are treated as buttons). In Godot the wheel constants exist (e.g. `MOUSE_BUTTON_WHEEL_UP / BUTTON_WHEEL_UP`), with the wheel up/down indices reported as 4 and 5 in common builds. See Godot docs for `InputEventMouseButton` and notes about wheel being a button event. ([Godot Engine documentation][1])

4. **Push vs. already-handled input** — `viewport.push_input()` injects an event into the target Viewport’s event queue. You may also want to stop global propagation of the original event (e.g., call `get_tree().set_input_as_handled()` in specific cases) if you do not want global UI/game input to react to the same clicks.

5. **Text legibility** — use a **high-resolution** Viewport (>= 1280×720, preferably 1920×1080 for small text), and set the material to use `emission` so it’s bright. Also disable MipMaps on the Viewport texture if you see blurring — or configure your texture import so small text remains crisp.

6. **Depth of Field** — when the player is soft-locked, temporarily **disable DOF** post-processing or move the focal distance to the screen distance so the UI remains sharp.

7. **Precision & floating error** — mouse precision can still suffer slightly because of perspective, floating point errors, or extremely small UI elements. The **soft-lock** reduces this by making the camera perpendicular to the screen (1 px ↔ 1 px mapping as closely as possible).

---

# Troubleshooting checklist (if clicks are offset)

* Confirm the QuadMesh `size` used by the script matches the actual mesh size.
* Confirm the Quad is not culled or flipped (normals facing the camera).
* Confirm Viewport size (pixel resolution) in the Viewport node matches what you expect.
* Print `pixel` coordinates from `_hit_to_pixel()` to verify mapping region (should be inside `[0..width-1]x[0..height-1]`).
* If buttons respond but wheel doesn’t, print `event.button_index` in `_unhandled_input` to see what values your mouse reports (wheel commonly yields 4/5). Godot docs discuss wheel events being `InputEventMouseButton`. ([Godot Engine documentation][1])

---

# Final tips & strong opinions (short)

* Use **QuadMesh** — no compromises. CSG = headache for UVs.
* Keep UI scale large in the viewport; let the 3D quad be the in-world scale — text is for humans, not for micro-font heroics.
* When interaction begins, **soft-lock** immediately — small offsets are the number-one UX complaint otherwise.
* Add a tiny interaction reticle (pixel enlargement) for micro-buttons; don't make users pixel-peck.

---

If you want, I’ll:

* show a tiny debug utility script to draw the UV overlay and print pixel coordinates, or
* convert these GDScripts into a single reusable `ScreenTerminal` node with signals (opened/closed/clicked) and editor exports so it’s plug-and-play.

Pick one and I’ll generate that exact, ready-to-use node. No questions — I’ll just deliver it.

[1]: https://docs.godotengine.org/en/stable/classes/class_inputeventmousebutton.html?utm_source=chatgpt.com "InputEventMouseButton - Godot Docs"
