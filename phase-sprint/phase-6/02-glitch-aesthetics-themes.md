# TASK 2: GLITCH AESTHETICS & THEMES

## Description
[REVISED] Define the visual/audio identity for the Hacker role, ensuring high performance on Android and immersive transitions.

## Implementation Details

### A. Hacker Shader Scope & Polling
*   **[BLOCKER]** **2D-Only Scope:** The chromatic aberration shader **must** be applied only to the 2D desktop `CanvasLayer`. It must **not** be applied to the 3D viewport.
*   **[BLOCKER]** **Polling:** Shader intensity uniforms must be updated via a `TimeManager` polling timer at 0.25s intervals (NOT `_process`).

### B. Android Fallback & Watchdog
*   **[BLOCKER]** **30fps Watchdog:** If the framerate drops below 30fps with the shader active, the system must automatically disable the shader and switch to a `CanvasModulate` tint.

### C. Hacker Theme & UI
*   **Resource:** Create `HackerTheme.tres` as a dedicated theme file for all Hacker UI elements, explicitly setting all properties (do not rely on Analyst defaults).
*   **Registration:** Register `use_shader_effects` and `hacker_music_volume` in `ConfigManager`.

### D. Audio Identity
*   **Crossfade:** Implement a 1.5s crossfade between Analyst and Hacker ambient loops via `AudioManager`.
*   **State Layers:** 
    *   SEARCHING: Add a low scan pulse loop.
    *   LOCKDOWN: Trigger a high-urgency alert SFX.

## Success Criteria
- [ ] **[BLOCKER]** Shader is applied only to the 2D desktop CanvasLayer.
- [ ] **[BLOCKER]** Android fallback (CanvasModulate) triggers if FPS < 30.
- [ ] **[BLOCKER]** `HackerTheme.tres` is created and used for all Hacker UI.
- [ ] **[BLOCKER]** Shader uniforms are updated via 0.25s polling.
- [ ] Ambient crossfade is smooth (1.5s).
- [ ] Final audio assets replace all Phase 1-5 placeholders.
