# NPC & Player Animation System

This document outlines the implementation of the character animation system using `Man.glb` for both NPCs and the First-Person Player body.

## 1. Asset Structure: `Man.glb`
The core character model uses a glTF (glB) format with a unified armature.

**Available Animations:**
- `HumanArmature|Man_Idle` (Standard standing)
- `HumanArmature|Man_Walk` (Walking gait)
- `HumanArmature|Man_Run` (Sprinting gait)
- `HumanArmature|Man_Clapping`
- `HumanArmature|Man_Sitting`
- `HumanArmature|Man_Standing`
- `HumanArmature|Man_Death`
- `HumanArmature|Man_Jump`

## 2. First-Person Player Body
Implemented in `Player3D.tscn` to provide visual grounding and "presence."

### Implementation Details:
- **Node Structure:** `Player3D` -> `CameraPivot` -> `BodyModel` (instanced `Man.glb`).
- **Positioning:** The model is offset to `(0, -0.15, 0.25)` to place the camera in front of the head while keeping the arms and chest visible.
- **Animation Logic:** Handled in `PlayerController.gd`. It uses `find_animation_player()` to locate the internal `AnimationPlayer` and switches between Idle, Walk, and Run based on `velocity.length()`.

### Technical Solution for Looping:
Since the `.glb` animations are read-only upon import, looping is enforced programmatically in `_ready()`:
```gdscript
anim_player.get_animation(anim_name).loop_mode = Animation.LOOP_LINEAR
```

## 3. NPC Base System (`NPC.gd`)
All NPCs (CISO, Senior Analyst, etc.) inherit from this base class.

### Planned: Organic Idle Logic
To prevent NPCs from moving in perfect unison (which looks robotic), the following "Organic Idle" logic is recommended:

1.  **Detection:** NPCs should automatically find their `AnimationPlayer` on `_ready()`.
2.  **Randomization:** Use `seek(randf_range(0, length))` to offset the start time of the idle animation.
3.  **States:** Use a simple state check to transition to `HumanArmature|Man_Clapping` or other animations during narrative events.

## 4. Known Issues & Debts
- **Animation Strings:** Current logic uses hardcoded strings. These should be moved to `GlobalConstants.gd`.
- **Head Clipping:** Looking straight down may show the character's neck/shoulders. This is mitigated by the 0.25m back-offset.
- **Shadows:** The player model's head may cast a shadow in front of the camera in high-contrast lighting.
