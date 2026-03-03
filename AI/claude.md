Here's a comprehensive upgrade for your splash screen, broken into the three areas you requested.

---

## 1. Shaders (Godot 4 CanvasItem)

### CRT Scanlines + Chromatic Aberration + Vignette
Save as `res://shaders/crt_screen.gdshader` and apply to a full-screen `ColorRect` overlay:

```glsl
shader_type canvas_item;

uniform float scan_line_count : hint_range(100.0, 600.0) = 300.0;
uniform float scan_intensity : hint_range(0.0, 1.0) = 0.15;
uniform float aberration_amount : hint_range(0.0, 0.02) = 0.004;
uniform float vignette_strength : hint_range(0.0, 2.0) = 0.8;
uniform float flicker_speed : hint_range(0.0, 20.0) = 8.0;
uniform float time_offset : hint_range(0.0, 100.0) = 0.0; // drive from GDScript

void fragment() {
    vec2 uv = UV;

    // Chromatic aberration
    float r = texture(TEXTURE, uv + vec2(aberration_amount, 0.0)).r;
    float g = texture(TEXTURE, uv).g;
    float b = texture(TEXTURE, uv - vec2(aberration_amount, 0.0)).b;
    vec4 col = vec4(r, g, b, 1.0);

    // Scanlines
    float scanline = sin(uv.y * scan_line_count * PI) * 0.5 + 0.5;
    col.rgb *= 1.0 - (scan_intensity * (1.0 - scanline));

    // Screen flicker
    float flicker = 1.0 - (sin(time_offset * flicker_speed) * 0.015);
    col.rgb *= flicker;

    // Vignette
    vec2 vig_uv = uv * (1.0 - uv.yx);
    float vignette = pow(vig_uv.x * vig_uv.y * 15.0, vignette_strength);
    col.rgb *= vignette;

    COLOR = col;
}
```

**In GDScript**, update the shader each frame:
```gdscript
@onready var crt_overlay: ColorRect = $CRTOverlay
var _time := 0.0

func _process(delta: float) -> void:
    _time += delta
    crt_overlay.material.set_shader_parameter("time_offset", _time)
```

---

### Digital Glitch Shader
Save as `res://shaders/glitch.gdshader` — apply to a `SubViewportContainer` wrapping the whole UI, or directly to the `VBoxContainer` via a `ShaderMaterial`:

```glsl
shader_type canvas_item;

uniform float glitch_intensity : hint_range(0.0, 1.0) = 0.0; // 0 = off, drive from code
uniform float time_offset : hint_range(0.0, 100.0) = 0.0;

float rand(vec2 co) {
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    vec2 uv = UV;

    if (glitch_intensity > 0.01) {
        // Horizontal slice displacement
        float slice_y = floor(uv.y * 20.0) / 20.0;
        float noise = rand(vec2(slice_y, floor(time_offset * 15.0)));
        if (noise > (1.0 - glitch_intensity * 0.6)) {
            uv.x += (rand(vec2(slice_y + 0.1, time_offset)) - 0.5) * glitch_intensity * 0.3;
        }

        // RGB split on glitch
        float split = glitch_intensity * 0.012;
        float r = texture(TEXTURE, uv + vec2(split, 0.0)).r;
        float g = texture(TEXTURE, uv).g;
        float b = texture(TEXTURE, uv - vec2(split, 0.0)).b;
        COLOR = vec4(r, g, b, texture(TEXTURE, uv).a);
    } else {
        COLOR = texture(TEXTURE, uv);
    }
}
```

Trigger the exit glitch from GDScript:
```gdscript
func _play_crt_poweroff() -> void:
    var mat = $VBoxContainer.material as ShaderMaterial
    var tween = create_tween()
    # Ramp up chaos
    tween.tween_method(func(v): mat.set_shader_parameter("glitch_intensity", v), 0.0, 1.0, 0.4)
    # Collapse Y (existing CRT power-off)
    tween.parallel().tween_property($VBoxContainer, "scale:y", 0.0, 0.35).set_ease(Tween.EASE_IN)
    tween.tween_callback(func(): get_tree().change_scene_to_file("res://scenes/MainMenu.tscn"))
```

---

### Scrolling Data Background
Save as `res://shaders/data_rain.gdshader` — apply to the background `ColorRect`:

```glsl
shader_type canvas_item;
uniform float scroll_speed : hint_range(0.1, 5.0) = 1.2;
uniform float time_offset : hint_range(0.0, 100.0) = 0.0;
uniform vec4 data_color : source_color = vec4(0.0, 0.8, 0.2, 1.0);
uniform float density : hint_range(0.01, 0.3) = 0.08;

float rand(vec2 co) { return fract(sin(dot(co, vec2(127.1, 311.7))) * 43758.5453); }

void fragment() {
    vec2 uv = UV;
    float col_id = floor(uv.x * 60.0);
    float col_rand = rand(vec2(col_id, 0.0));
    
    // Each column scrolls at a different speed
    float scroll = fract(uv.y + time_offset * scroll_speed * (0.5 + col_rand * 0.8));
    float row = floor(scroll * 40.0);
    float char_rand = rand(vec2(col_id, row));
    
    // Sparse character "pixels"
    float brightness = step(1.0 - density, char_rand);
    brightness *= smoothstep(0.0, 0.15, scroll) * smoothstep(1.0, 0.85, scroll);
    
    // Fade to black base
    vec3 final = data_color.rgb * brightness * (0.3 + char_rand * 0.7);
    COLOR = vec4(final, 1.0);
}
```

---

## 2. UI Enhancements

### Scene Tree Additions

Add these nodes under your root `Control`:

```
Control (root)
├── ColorRect                    ← black base
├── DataRainBG (ColorRect)       ← data_rain.gdshader, modulate alpha ~0.35
├── CRTOverlay (ColorRect)       ← crt_screen.gdshader, mouse_filter=IGNORE, full size
├── CornerDecorations (Control)  ← purely decorative, see code below
│   ├── TopLeft (Label)
│   ├── TopRight (Label)
│   ├── BottomLeft (Label)
│   └── BottomRight (Label)
├── StatusBar (HBoxContainer)    ← anchored bottom
│   ├── StatusLabel (Label)      ← "SYS: NOMINAL  MEM: 4096MB  ENC: AES-256"
│   └── BlinkDot (Label)         ← "●" that blinks
├── CenterContainer
│   └── VBoxContainer            ← existing, add ShaderMaterial = glitch.gdshader
│       ├── LogoText (Label)
│       ├── Subtitle (Label)
│       └── ProgressBar          ← new "boot" loading bar
└── HexStream (RichTextLabel)    ← scrolling hex codes, top-right, see code
```

### Corner Brackets (GDScript)
```gdscript
# In _ready(), set corner label text:
%TopLeft.text     = "┌─[ VERIFY.EXE v2.4.1 ]"
%TopRight.text    = "[ SYS_BOOT: OK ]─┐"
%BottomLeft.text  = "└─[ CLEARANCE: ALPHA ]"
%BottomRight.text = "[ ENC: ACTIVE ]─┘"

# Anchoring in the editor:
# TopLeft:     anchor left=0, top=0, set offset
# TopRight:    anchor right=1, top=0
# BottomLeft:  anchor left=0, bottom=1
# BottomRight: anchor right=1, bottom=1
```

### Hex Stream (scrolling sidebar noise)
```gdscript
# Attach to a RichTextLabel, ~120px wide, right side, BBCode enabled
func _generate_hex_line() -> String:
    var line := ""
    for i in range(8):
        line += "%02X " % randi_range(0, 255)
    return line.strip_edges()

func _populate_hex_stream() -> void:
    var rtl: RichTextLabel = $HexStream
    rtl.clear()
    for _i in range(30):
        rtl.append_text("[color=#1a5c1a]%s[/color]\n" % _generate_hex_line())

# Call in _ready(), then refresh every ~0.3s with a Timer
```

### Boot Progress Bar
```gdscript
@onready var boot_bar: ProgressBar = %ProgressBar

func _animate_boot_bar() -> void:
    boot_bar.value = 0
    var tween = create_tween()
    # Stutter to 73%, pause, then slam to 100%
    tween.tween_property(boot_bar, "value", 73.0, 0.9).set_trans(Tween.TRANS_EXPO)
    tween.tween_interval(0.4)
    tween.tween_property(boot_bar, "value", 100.0, 0.25).set_trans(Tween.TRANS_BOUNCE)
    tween.tween_callback(_on_boot_complete)
```

---

## 3. Animation Improvements

### Typing Effect for LogoText
Replace the fade-in tween with character-by-character reveal:

```gdscript
const LOGO_FULL := " VERIFY.EXE "
const TYPE_SPEED := 0.07  # seconds per character

func _type_label(label: Label, text: String) -> void:
    label.text = ""
    for i in range(text.length()):
        label.text = text.substr(0, i + 1)
        # Optional: add cursor blink artifact
        if i % 3 == 0:
            label.text += "█"
            await get_tree().create_timer(TYPE_SPEED * 0.3).timeout
            label.text = text.substr(0, i + 1)
        AudioManager.play_sfx("key_click")  # short tick sound
        await get_tree().create_timer(TYPE_SPEED).timeout
    label.text = text  # ensure final clean state
```

### Staggered Boot Sequence (replaces simple fade)
```gdscript
func _run_boot_sequence() -> void:
    # 1. Data rain and corners fade in
    var tween = create_tween().set_parallel(true)
    tween.tween_property($DataRainBG, "modulate:a", 0.35, 0.6)
    tween.tween_property($CornerDecorations, "modulate:a", 1.0, 0.4)
    await tween.finished

    # 2. Type the logo
    await _type_label(%LogoText, LOGO_FULL)
    AudioManager.play_sfx("terminal_beep")

    # 3. Subtitle appears with glitch burst
    var mat = $VBoxContainer.material as ShaderMaterial
    mat.set_shader_parameter("glitch_intensity", 0.4)
    await get_tree().create_timer(0.08).timeout
    mat.set_shader_parameter("glitch_intensity", 0.0)
    %Subtitle.modulate.a = 1.0

    # 4. Status bar slides up
    var bar_tween = create_tween()
    bar_tween.tween_property($StatusBar, "position:y", 0.0, 0.3).set_trans(Tween.TRANS_BACK)

    # 5. Boot bar
    _animate_boot_bar()
```

### Violent Digital Disintegration Exit
Replace the current CRT power-off:

```gdscript
func _exit_sequence() -> void:
    set_process_input(false)  # block skip during exit
    var mat = $VBoxContainer.material as ShaderMaterial
    var tween = create_tween()

    # Phase 1: Rapid glitch bursts (0.6s of chaos)
    for i in range(6):
        tween.tween_callback(func():
            mat.set_shader_parameter("glitch_intensity", randf_range(0.3, 1.0))
        )
        tween.tween_interval(0.08 + randf() * 0.06)

    # Phase 2: Freeze glitch high, collapse Y fast
    tween.tween_callback(func(): mat.set_shader_parameter("glitch_intensity", 1.0))
    tween.parallel().tween_property($CenterContainer, "scale:y", 0.0, 0.18).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)

    # Phase 3: Full screen flash white then black
    tween.tween_property($CRTOverlay, "modulate", Color.WHITE, 0.05)
    tween.tween_property($CRTOverlay, "modulate", Color.BLACK, 0.12)

    # Phase 4: Transition
    tween.tween_callback(func(): get_tree().change_scene_to_file("res://scenes/MainMenu.tscn"))
```

---

## Integration Checklist

1. **Shaders**: Create three `.gdshader` files, assign via `ShaderMaterial` in the Inspector — no editor scripting needed.
2. **DataRainBG**: Full-rect `ColorRect`, `mouse_filter = IGNORE`, modulate alpha = 0 initially (animated in).
3. **CRTOverlay**: Full-rect `ColorRect`, `mouse_filter = IGNORE`, `ShaderMaterial` using crt_screen shader, sits on top of everything.
4. **VBoxContainer** gets the glitch shader; `glitch_intensity` starts at `0.0` and is only ramped up during transitions.
5. Call `_run_boot_sequence()` from `_ready()` instead of the old tween.
6. Hook `_exit_sequence()` wherever you currently call the CRT power-off.

The result: a staggered, typed boot sequence with matrix rain behind it, corner-bracket UI framing, a stuttering progress bar, CRT grain overlay the whole time, and a violent glitch-collapse on exit.