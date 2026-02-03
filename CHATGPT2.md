Great — I’ll be strict and practical: below is a **bulletproof architecture** for each of your four challenges, with clear rationale, concrete Godot 4 settings, and copy-pasteable GDScript snippets. I also call out engine caveats and workarounds you **must** apply (with sources). Use these as the canonical patterns for every workstation monitor in your SOC.

---

# 1) Input Occlusion & Layers — *don’t let NPCs or hands steal the ray*

**Goal:** visually allow objects in front of the monitor but make the *interaction ray* only hit the monitor collider.

**Pattern (recommended):**

1. Put the *monitor’s interaction collider* on its own physics layer (e.g. layer 20 — call it `UI_SCREEN`).
2. Put player hands, NPC colliders, environmental colliders on other layers.
3. When you raycast for UI interaction, **use a collision_mask that only includes `UI_SCREEN`** (and any auxiliary screen colliders). This guarantees the ray ignores everything else (hand/NPC) *without changing visuals*.
4. Optional: if you want some objects to *block* interaction (e.g., a physical curtain), give them a special `UI_BLOCKER` layer and dynamically toggle the ray’s collision_mask to include that layer when you want occlusion to count.
5. Maintain an `exclude` array for physics queries as a second safety net (e.g. exclude local camera or the camera’s collision objects).

**Why:** raycast mask is fast, explicit, and avoids fiddly enable/disable logic on many objects.

**Raycast example (copy/paste):**

```gdscript
# ScreenBridge.gd (part)
var RAY_LEN: float = 2000.0
const LAYER_UI_SCREEN: int = 1 << 19   # example: layer 20 (0-indexed)

func raycast_screen(world_mouse_pos: Vector2) -> Dictionary:
    var from = camera.project_ray_origin(world_mouse_pos)
    var dir = camera.project_ray_normal(world_mouse_pos)
    var to = from + dir * RAY_LEN
    var state = get_world_3d().direct_space_state
    var mask = LAYER_UI_SCREEN
    # use 'exclude' if needed
    var res = state.intersect_ray(from, to, [], collision_mask=mask)
    return res  # {} if no hit, otherwise hit dict
```

**Extra safeguards:**

* Keep the `Area3D` on the same `UI_SCREEN` layer for quick "is mouse over?"

---

# 2) Professional text legibility — exact settings & tradeoffs

**Goal:** 10–12pt UI text should look *as crisp as a native 2D overlay*, no shimmering at glancing angles.

Short answer: **render the SubViewport at a higher pixel density than your quad’s displayed size, use emission on the material, MSAA at viewport level, and rely on 1:1 (or >1) texel mapping when soft-locked.** Crucial engine caveat: *Viewport textures don’t get mipmaps*, so the usual mipmap-based filtering remedies at grazing angles are not available — design to avoid dependence on mipmaps. ([godotforums.org][1])

**Concrete project settings (start here and tune):**

* **SubViewport size (render target):** set to at least your UI resolution *×2* for small-font readability. If UI is 1280×720 target, use 2560×1440 while interacting (or 1920×1080 minimum). This gives more texels for text; then scale the quad in world so soft-lock maps pixels closely.
* **Viewport.msaa:** `MSAA 4x` (good balance). If target GPUs are high-end and you need absolutely crisp edges, `8x` can help. Set this on the **Viewport** node (`msaa` property). ([Godot Engine documentation][2])
* **StandardMaterial3D:** assign the `ViewportTexture` to **albedo** and **emission** (emission = 1.0) so the GPU treats the UI as self-lit — reduces postprocessing/lighting variance. Also disable material-based color modulation or alpha scissor changes. See material tips. ([Godot Engine documentation][3])
* **Filtering & Mipmaps:** Viewport textures currently cannot have engine-generated mipmaps; therefore:

  * **Avoid relying on minification via mipmaps.**
  * Disable any texture *smooth* filtering if it blurs text; alternatively leave filtering on but increase viewport resolution so text is sampled near native size.
  * Increase **anisotropic filtering** in Project Settings (Rendering → Quality → `anisotropic` or GPU driver setting) if text is viewed at oblique angles (helps a little for sampled textures).
* **Font & GUI:** use a high-quality raster/TTF font and choose **DynamicFont** with proper point size (in Godot terms, give it a slightly larger size than 10–12pt because viewport DPI differs). Test at runtime with the intended viewport size.
* **Postprocess:** while soft-locked, **disable Depth-of-Field** and any temporal antialiasing / motion blur; they cause shimmer and blur. Set these toggles in your camera/postprocess environment when interaction begins.
* **Quad scale & soft-lock:** the soft-lock must place the camera so the viewport-to-screen mapping is pixel-aligned (or very close). The UX rule: **rendered viewport pixel density on the mesh should be ≥ 1 texel per display pixel** when interacting.

**Why not mipmaps?** Because the engine’s Viewport -> texture does not produce mipmaps, you cannot rely on them to smooth minified text. The engine/communities recommend higher render targets + emission + MSAA instead. ([godotforums.org][1])

---

# 3) Double cursor & virtualization — hide OS cursor + render software cursor *inside* the SubViewport

**Goal:** OS cursor hidden while over monitor; visual cursor drawn inside SubViewport (no ghosting, perfectly synced).

**Pattern (robust):**

1. **When the mouse enters the monitor interaction area:**

   * `Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)` — hides OS cursor but preserves motion. (Use HIDDEN, not CONFINED.) ([Godot Forum][4])
   * Set a boolean `interacting = true`.
2. **Every frame (or on every mouse event) while `interacting`:**

   * Raycast to the screen and compute the pixel coordinates in the SubViewport (exact UV→pixel mapping).
   * Immediately `viewport.push_input(InputEventMouseMotion)` with the computed `position` (in local viewport pixel coords). Also push button events when click happens (see code).
   * Inside the SubViewport UI, draw the **virtual cursor** as a Control node (e.g., `TextureRect`) and set its position to the `position` you compute. Because you push InputEventMouseMotion *and* update the virtual cursor every frame, the visual cursor and events are locked together with zero perceptible lag.
3. On exit: `Input.set_mouse_mode(previous_mode)` and hide the virtual cursor.

**Important engine caveat:** `viewport.push_input()` is the correct API to deliver events; however, there are engine regressions/behaviour changes where pushed `MouseMotion` may not trigger `_gui_input` unless `mouse_in_viewport` is set/handled. Workaround: trigger the viewport's mouse-enter notification (or ensure GUI input is not disabled) before aggressively pushing motion/button events. See the engine issue and workaround. ([Godot Forum][5])

**Implementation (abridged, robust):**

```gdscript
# Soft: ScreenBridge.gd
var interacting: bool = false
var prev_mouse_mode = Input.MOUSE_MODE_VISIBLE

func begin_interaction():
    prev_mouse_mode = Input.get_mouse_mode()
    Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)  # hide OS cursor
    interacting = true
    # If needed, trigger viewport's mouse-enter notification:
    screen_viewport._notification(NOTIFICATION_VP_MOUSE_ENTER) # workaround for push_input issues

func end_interaction():
    interacting = false
    Input.set_mouse_mode(prev_mouse_mode)
    screen_viewport._notification(NOTIFICATION_VP_MOUSE_EXIT)

func _process(delta):
    if not interacting:
        return
    var global_mouse = Input.get_mouse_position()
    var hit = raycast_screen(global_mouse)  # returns hit dict if over screen; use collision_mask approach above
    if hit.empty():
        # optional: still hide OS cursor but do not push events
        return
    var pixel = hit_to_pixel(hit)  # UV->pixel conversion
    # 1) Push motion event every frame for perfect sync
    var mm := InputEventMouseMotion.new()
    mm.position = pixel
    mm.global_position = pixel
    mm.relative = Vector2.ZERO  # or compute delta
    screen_viewport.push_input(mm)
    # 2) Update virtual cursor node inside SubViewport (expose API or send signal)
    # e.g. emit_signal("virtual_cursor_move", pixel)
```

**Button & wheel events:**

* On `InputEventMouseButton` in `_unhandled_input` forward real button presses to the viewport with `InputEventMouseButton` constructed with `pixel` and correct `button_index` and `pressed` flags, then `screen_viewport.push_input(evb)`.
* Wheel events are `InputEventMouseButton` with `button_index` = `MOUSE_BUTTON_WHEEL_UP / DOWN` (instantaneous presses). Forward them the same way. ([Reddit][6])

**Result:** OS cursor hidden, UI cursor drawn inside texture, motion events and button events are pushed synchronously every frame or on event — no ghosting.

---

# 4) Input state & “stuck keys” — explicit key-tracking + synthetic releases on exit

**Problem:** When the player holds a key, the SubViewport receives key-down but may miss the key-up when you abruptly exit the UI → stuck characters.

**Pattern (reliable):**

* **Track pressed keys** inside the SubViewport: on every `InputEventKey` where `pressed == true` add `event.physical_scancode` (or `keycode`) to a `pressed_keys` `Set`.
* On `InputEventKey` where `pressed == false` remove from the set.
* **On exit (unlock / teleport / Escape / stand up):**

  * Iterate `pressed_keys` and for each scancode build a synthetic `InputEventKey` with `pressed = false` and push it into the SubViewport using `screen_viewport.push_input(...)`.
  * Also call `Input.action_release(action)` for any action names you map, and/or use `Input.parse_input_event()` for global state if needed.
  * Clear `pressed_keys` after pushing releases.
* Also call `Input.flush_buffered_events()` or `Input.flush_buffered_events()` equivalents to make sure buffers are processed (see Input docs). ([Godot Engine documentation][7])

**Why this is safe:** you explicitly simulate the missing releases to the UI that owns the keyboard focus. Pushing `pressed=false` events into the **SubViewport** returns it to a clean state.

**Code snippet:**

```gdscript
# KeyboardState.gd - attach to a controller or the SubViewport root
var pressed_keys: = {}  # Set of scancodes

func _input(event):
    if event is InputEventKey:
        var sc = event.physical_scancode
        if event.pressed:
            pressed_keys.insert(sc)
        else:
            pressed_keys.erase(sc)

func flush_key_state_to_viewport(viewport: Viewport) -> void:
    # send synthetic key releases
    for sc in pressed_keys.duplicate():
        var ev := InputEventKey.new()
        ev.physical_scancode = sc
        ev.pressed = false
        ev.echo = false
        # Optionally set keycode/unicode fields
        viewport.push_input(ev)
    pressed_keys.clear()
    # extra global cleanup:
    Input.flush_buffered_events()
```

**Call `flush_key_state_to_viewport()` whenever you exit interaction** (escape, move camera, unlock, etc.). This will stop repeating characters/toggles, even if the engine missed physical key-up.

**Extra tip:** also synthetic-release important modifier keys explicitly (`Shift`, `Ctrl`, `Alt`) by action name with `Input.action_release("ui_accept")` if you track actions instead of raw keys.

---

# Extra essential engine caveats (read-before-you-ship)

* `push_input()` is the correct approach to inject events into a SubViewport, but there are known regressions where `InputEventMouseMotion` pushed may not reach `_gui_input` unless the viewport’s `mouse_in_viewport` flag/notification is set — the practical workaround is to trigger `NOTIFICATION_VP_MOUSE_ENTER` on the viewport before pushing many events. **Do that when beginning interaction.** ([GitHub][8])
* Viewport textures can be quirky with mipmaps / filtering — **do not rely on mipmaps** for small glyph legibility. Instead use higher render target resolution + emission + MSAA. ([godotforums.org][1])
* If controls inside the SubViewport still miss events: verify `Viewport.gui_disable_input` is `false` and that your event coordinates are in the viewport’s local pixel space (the docs show `push_input` accepts events in embedder coords or local coords depending on flags). Always use viewport pixel coordinates when creating the InputEvent for the SubViewport. ([Godot Engine documentation][2])

---

# Short checklist to integrate (do this in order)

1. Create a dedicated `UI_SCREEN` physics layer & assign screen collider / Area3D to it.
2. Raycast with `collision_mask = UI_SCREEN` and use `quad_mesh.to_local()` → UV → pixel conversion as in your original spec.
3. When `enter_interaction`:

   * call `screen_viewport._notification(NOTIFICATION_VP_MOUSE_ENTER)` (workaround), `Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)`, and `camera_soft_lock.lock()`.
   * start pushing `InputEventMouseMotion` each frame and forward button events.
   * show virtual cursor inside SubViewport via signal `virtual_cursor_move`.
4. When `exit_interaction`:

   * call `flush_key_state_to_viewport(screen_viewport)`, `screen_viewport._notification(NOTIFICATION_VP_MOUSE_EXIT)`, `Input.set_mouse_mode(prev_mode)`, `camera_soft_lock.unlock()`.
5. Fine tune: viewport resolution, MSAA, disable DOF, increase anisotropy.

---

# Citations / docs (most important references)

* Viewport docs, properties (MSAA, size, render target). ([Godot Engine documentation][2])
* ViewportTexture / SubViewport usage (how to get texture and push input). ([Godot Engine documentation][9])
* Viewport textures / mipmap limitation and community workarounds (important for text legibility). ([godotforums.org][1])
* `push_input()` usage & community examples (passing input to SubViewport). ([Godot Forum][5])
* Engine issue & workaround about pushed events and `mouse_in_viewport` — trigger `NOTIFICATION_VP_MOUSE_ENTER` when you begin. ([GitHub][8])
* Input docs for programmatic events, `parse_input_event()` / `action_release()` / `flush_buffered_events()`. ([Godot Engine documentation][7])

---

If you want, I’ll now:

* produce a single **plug-and-play** `ScreenTerminal.tscn` with `ScreenBridge.gd` + `CameraSoftLock.gd` + virtual cursor demo and signals (ready to drop into your SOC), or
* give a small debug overlay script that prints pixel coordinates / draws UV lines for mapping verification.

Pick one and I’ll deliver the ready-to-drop-in node (one reply — no questions).

[1]: https://godotforums.org/d/22430-mipmap-for-viewport-node?utm_source=chatgpt.com "Mipmap for Viewport Node - Godot Forums"
[2]: https://docs.godotengine.org/en/stable/classes/class_viewport.html?utm_source=chatgpt.com "Viewport — Godot Engine (stable) documentation in English"
[3]: https://docs.godotengine.org/en/latest/tutorials/3d/standard_material_3d.html?utm_source=chatgpt.com "Standard Material 3D and ORM Material 3D - Godot Docs"
[4]: https://forum.godotengine.org/t/how-to-hide-or-disable-the-mouse-cursor/24707?utm_source=chatgpt.com "How to hide or disable the mouse cursor?"
[5]: https://forum.godotengine.org/t/passing-input-through-a-viewport-to-area2ds/37918?utm_source=chatgpt.com "Passing input through a Viewport to Area2Ds - UI - Godot Forum"
[6]: https://www.reddit.com/r/godot/comments/o9tw9a/how_to_use_mouse_wheel_updown_as_input/?utm_source=chatgpt.com "How To Use Mouse Wheel Up/Down as Input? : r/godot"
[7]: https://docs.godotengine.org/en/stable/classes/class_input.html?utm_source=chatgpt.com "Input — Godot Engine (stable) documentation in English"
[8]: https://github.com/godotengine/godot/issues/89757?utm_source=chatgpt.com "Pushing events to Viewports no longer triggers ` ..."
[9]: https://docs.godotengine.org/en/stable/classes/class_viewporttexture.html?utm_source=chatgpt.com "ViewportTexture — Godot Engine (stable) documentation in ..."
