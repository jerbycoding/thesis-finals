### 1. Input Occlusion & Layers

**Architectural Solution**: Use **collision layers and masks** for bulletproof raycast filtering. Assign a **unique physics layer** (e.g., Layer 10: "InteractionScreens") exclusively to the `CollisionShape3D` child of your `Area3D`. Place all occluders (NPCs, player hands/models, furniture) on separate layers (e.g., Layer 1: "WorldStatic", Layer 2: "Characters"). In your raycast query, set `collision_mask` to **only** the InteractionScreens layer and `collide_with_areas = true`. This ignores everything else, even if an NPC walks in front.

**Project Settings**:
- Project > Physics > 3D > Default Gravity: Standard.
- No changes needed; layers are per-node.

**GDScript Example** (extends previous script):
```gdscript
# In _ready():
interaction_area.collision_layer = 1 << 9  # Layer 10 (bit 9)
interaction_area.collision_mask = 0  # Area doesn't need to detect others

# In raycast query:
var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
query.collide_with_areas = true
query.collision_mask = 1 << 9  # ONLY Layer 10
var result = space_state.intersect_ray(query)
```

**Why Bulletproof?**
| Aspect | Benefit |
|--------|---------|
| **Occlusion Immunity** | NPCs/hands on other layers are completely ignored—no "stealing" focus. |
| **Performance** | Mask filters before intersection tests. |
| **Multi-Screen** | Assign unique layers per screen (e.g., 10,11,12). |
| **Fallback** | If needed, add `query.exclude = [npc_body, player_hand]` array. |

### 2. Professional Text Legibility

**Architectural Solution**: Combine **high-res SubViewport**, **MSAA**, **perpendicular soft-lock** (your existing tween), and **material tweaks** for 1:1 pixel mapping. Use 1920x1080 resolution for 10-12pt fonts (SIEM logs). Disable mipmaps and use low-anisotropy linear filtering to eliminate shimmering/aliasing when locked. Fonts render as crisp as 2D overlays.

**Project Settings**:
```
Rendering > Anti Aliasing:
  - MSAA 2D: 4X (or 8X for ultra)
  - MSAA 3D: 4X
Rendering > Textures > Canvas Textures:
  - Default Texture Filter: Linear Mipmap Anisotropic
Rendering > Textures > Default Texture Filter: Anisotropic, 16x
```

**Node Settings** (Inspector or code):
- **SubViewport**:
  ```gdscript
  sub_viewport.size = Vector2(1920, 1080)
  sub_viewport.msaa_2d = SubViewport.MSAA_4X
  sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
  sub_viewport.transparent_bg = true  # If UI has alpha
  ```
- **StandardMaterial3D** (on MeshInstance3D):
  ```gdscript
  var mat = StandardMaterial3D.new()
  mat.albedo_texture = sub_viewport.get_texture()
  mat.emission_enabled = true
  mat.emission = Color(1,1,1,1)
  mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR  # Crisp + smooth text
  mat.anisotropic_filter = true
  mat.anisotropy_strength = 1.0  # Low to prevent over-sharpening
  mat.cull_mode = BaseMaterial3D.CULL_DISABLED
  mat.no_depth_test = true  # Screen always on top
  mat.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_NEVER
  screen_mesh.material_override = mat
  ```

**Why Bulletproof?**
| Issue | Fix | Result |
|-------|-----|--------|
| **Shimmering** | Perp. tween + low anisotropy + MSAA | 1px:1px mapping |
| **Aliasing** | MSAA 4X + LINEAR filter | Smooth edges on logs |
| **Blur** | High-res + no_depth_test | Native sharpness |
| **Perf** | UPDATE_ALWAYS only during interact: toggle in soft-lock |

**Font Tip**: Theme > default_font_size = 14+, use Bitmap fonts for terminals.

### 3. The "Double Cursor" & Virtualization

**Architectural Solution**: **Hide OS cursor** via `Input.mouse_mode = Input.MOUSE_MODE_HIDDEN` during interaction (still get precise events). Render a **virtual cursor** (TextureRect) as a child of the SubViewport's root Control—update its `position` directly from raycast `pixel_pos` on every motion. Perfect sync: raycast → push_input (for GUI hover/click) → virtual pos update (visual). No lag/ghosting since single-frame computation.

**GDScript Example** (add to script):
```gdscript
@export var virtual_cursor: TextureRect  # Child of SubViewport root, e.g., arrow.png

# In _ready():
virtual_cursor.visible = false

# In _handle_mouse_event(), after pixel_pos calc:
virtual_cursor.position = pixel_pos - virtual_cursor.size / 2  # Center
virtual_cursor.visible = true  # Show only on hit

# In _start_soft_lock():
Input.mouse_mode = Input.MOUSE_MODE_HIDDEN  # Hide OS

# In _end_soft_lock():
Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
virtual_cursor.visible = false

# Outside hit: hide virtual
if not result or result.collider != interaction_area:
    virtual_cursor.visible = false
```

**Why Bulletproof?**
| Issue | Fix | Result |
|-------|-----|--------|
| **Double/Ghosting** | HIDDEN mode + direct pos update | Single cursor, zero offset |
| **Sync Lag** | Raycast in _input (immediate) | 60fps perfect |
| **Confine** | Optional: MOUSE_MODE_CONFINED pre-interact | Stays over screen |
| **Custom** | virtual_cursor.modulate = Color.WHITE; scale for DPI |

### 4. Input State & "Stuck Keys"

**Architectural Solution**: **Track pressed keys** in a `Dictionary` during interaction. Forward **all inputs** (mouse + key) via `push_input()`. On abrupt exit (Esc/stand), **flush** by pushing synthetic `KEY_UP` events for tracked keys. Resets TextEdit/Terminal state instantly—no repeats. Handles OS key-repeat too (echo=false on flush).

**GDScript Example**:
```gdscript
var pressed_keys: Dictionary = {}  # keycode: true

func _input(event):
    if is_interacting:
        sub_viewport.push_input(event, true)
        if event is InputEventKey:
            if event.pressed:
                pressed_keys[event.keycode] = true
            else:
                pressed_keys.erase(event.keycode)
        get_viewport().set_input_as_handled()
    elif event is InputEventKey and event.is_action_pressed("ui_cancel"):  # Esc
        _flush_inputs()
        _end_soft_lock()

func _flush_inputs():
    for keycode in pressed_keys:
        var up_event = InputEventKey.new()
        up_event.keycode = keycode
        up_event.pressed = false
        up_event.echo = false
        sub_viewport.push_input(up_event, true)
    pressed_keys.clear()

# In _end_soft_lock():
_flush_inputs()
Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
```

**Why Bulletproof?**
| Scenario | Fix | Result |
|----------|-----|--------|
| **Held Key Exit** | Synthetic UP events | Instant reset, no 'aaa' |
| **Key Repeat** | Track + echo=false | Ignores OS repeats post-flush |
| **Typing** | Forward all keys | Full terminal support |
| **Perf** | Dict max 512 keys, negligible |

**Integration**: Call `_flush_inputs()` in tween complete callback too. Test with held 'A' + Esc.

This full setup is production-grade: Modular, performant (event-driven), and immersive for SOC sim. Test in Forward+ renderer for best AA.