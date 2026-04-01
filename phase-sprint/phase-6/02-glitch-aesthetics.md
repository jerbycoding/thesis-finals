# TASK 2: GLITCH AESTHETICS (VISUAL IDENTITY)

## Description
[SOLO DEV SCOPE] Add green theme and simple shader effect for Hacker role.

## Implementation Details

### A. HackerTheme Creation
Create `resources/themes/HackerTheme.tres`:
```gdscript
# Theme resource with:
- default_font_color: COLOR_HACKER_GREEN
- background_color: Color("#0a0a0a")
- accent_color: COLOR_HACKER_AMBER
```

### B. DesktopWindowManager Extension
```gdscript
func set_theme(role: GameState.Role):
    if role == Role.HACKER:
        var theme = load("res://resources/themes/HackerTheme.tres")
        GameState.desktop_instance.theme = theme
```

### C. Simple Shader Effect (2D Only)
```gdscript
# In ComputerDesktop.gd:
@export var glitch_shader: ShaderMaterial

func _process(_delta):
    if GameState.current_role == Role.HACKER:
        var trace = TraceLevelManager.get_trace_level()
        if glitch_shader:
            glitch_shader.set_shader_parameter("intensity", trace / 100.0)
```

### D. Android Fallback (If Performance Issues)
```gdscript
if FPSManager.get_fps() < 30:
    glitch_shader = null  # Disable shader
    modulate = COLOR_HACKER_GREEN  # Simple tint instead
```

## Success Criteria
- [ ] **[BLOCKER]** Hacker desktop uses green theme
- [ ] **[BLOCKER]** Shader intensity scales with Trace
- [ ] Analyst desktop uses blue theme (no regression)

## OUT OF SCOPE (Cut for Solo Dev)
- ❌ Chromatic aberration (simple color shift ok)
- ❌ FPS watchdog (add if performance issues arise)
- ❌ Audio state layers (SEARCHING/LOCKDOWN)
