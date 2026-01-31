# 🎥 Immersive UI (Option B) - Implementation Plan

**Goal:** Eliminate the "Fade to Black" transition when using the computer. Create a seamless flow where the player sits down, and the UI appears "diegetically" on the screen while the 3D office remains visible in the periphery.

## 📂 File Impact Audit

| File | Type | Impact | Description of Change |
| :--- | :--- | :--- | :--- |
| `scenes/InteractableComputer.tscn` | **Scene** | 🟡 Medium | Add a `Marker3D` node named `ViewAnchor`. This defines exactly where the camera sits when "using" the PC. |
| `scripts/PlayerController.gd` | **Script** | 🔴 High | Add `sit_down(target_transform)` and `stand_up()` functions. Implement `Tween` logic to smooth-move the camera. |
| `autoload/TransitionManager.gd` | **Script** | 🔴 High | Remove `overlay_instance.fade_in()`. Replace with calls to `player.sit_down()`. |
| `scenes/2d/ComputerDesktop.tscn` | **Scene** | 🟡 Medium | **CRITICAL:** Set the `Background` ColorRect to transparent (Alpha 0). Adjust margins so UI elements fit inside the 3D monitor frame. |
| `scripts/2d/ComputerDesktop.gd` | **Script** | 🟢 Low | Ensure the background stays transparent even if power flickers or events happen. |

---

## 🏃 Sprint 08: Immersive Transition

**Objective:** Implement the "Camera Lock" transition system.

### Step 1: The Anchor (Setup)
*   **Task:** Open `InteractableComputer.tscn`.
*   **Action:** Create a `Marker3D` placed exactly in front of the monitor mesh (approx (0, 1.2, 0.6) relative to desk).
*   **Reason:** The camera needs a target destination to zoom into.

### Step 2: The Camera Logic (PlayerController)
*   **Task:** Modify `PlayerController.gd`.
*   **Action:** Add a `tween_camera_to(target_transform)` function.
*   **Logic:**
    *   Store the "Standing Position" (so we can stand up later).
    *   Disable movement input.
    *   Tween the `Camera3D` global transform to the `ViewAnchor` over 0.8 seconds (Cubic Ease).

### Step 3: The Transition Logic (TransitionManager)
*   **Task:** Rewrite `enter_desktop_mode`.
*   **Old Flow:** Fade Out -> Switch Mode -> Fade In.
*   **New Flow:**
    1.  Call `Player.sit_down()`.
    2.  Wait for animation to finish.
    3.  Instantiate `ComputerDesktop` (No fade).
    4.  Switch Input Mode.

### Step 4: The Transparency (UI)
*   **Task:** Edit `ComputerDesktop.tscn`.
*   **Action:** Set the `Background` ColorRect visibility to `false` or modulation alpha to `0`.
*   **Result:** When the UI loads, you see the buttons, but "behind" them is the 3D world (the monitor you are looking at).

---

## ⚠️ Potential Edge Cases (Prevention)
1.  **"Clipping":** If the camera zooms too close, it might clip into the monitor mesh.
    *   *Fix:* We will adjust the `ViewAnchor` position slightly back during Step 1.
2.  **Mouse Alignment:** The UI buttons might not line up perfectly with the 3D monitor frame.
    *   *Fix:* We will use `Control` margins in Step 4 to "letterbox" the UI so it looks like it's inside the screen bezels.
