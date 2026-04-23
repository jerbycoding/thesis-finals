# Trace Mechanics Redesign & Physical Breach Implementation

## Background & Motivation
The current `TraceLevelManager` uses a linear, constant decay of 1.0 trace per second. This allows hackers to easily circumvent detection by "stutter-stepping" (waiting a few seconds between commands). Additionally, reaching 100% trace currently only triggers a placeholder countdown without any tangible "Lose Event". To satisfy the "Mirror Mode" thesis and increase tension, we are overhauling the trace decay mechanics (Dynamic Friction) and implementing a high-stakes, narrative-driven physical breach sequence.

## Scope & Impact
*   **Target Files:** `autoload/TraceLevelManager.gd`, `autoload/RivalAI.gd`, `scripts/2d/apps/App_Wiper.gd`, `autoload/EventBus.gd`, and the relevant 3D scene/transition scripts.
*   **Affected Systems:** Hacker trace calculations, AI state evaluation, Tool execution permissions, and 2D-to-3D visual transitions.

## Proposed Solution

### 1. Dynamic Friction (Trace Adjustments)
*   **Post-Action Cooldown:** Introduce a 3.0-second delay after any offensive action before the trace begins to decay naturally.
*   **State-Based Decay:** The decay rate is dynamically scaled by the `RivalAI`'s current alert state:
    *   `IDLE`: 1.0 / sec (100% speed)
    *   `SEARCHING`: 0.5 / sec (50% speed)
    *   `LOCKDOWN`: 0.2 / sec (20% speed)
*   **Accumulated Debt (Static Heat):** Whenever an action generates trace, 25% of that cost is added to a hidden `static_heat` pool. The `trace_level` cannot decay below the current `static_heat`. The only way to lower `static_heat` is by successfully using the Evidence Wiper tool.

### 2. The "Lose Event" (Physical Breach)
*   **Strict Lockdown:** When `trace_level` hits 100%, `RivalAI` enters the `ISOLATING` state, beginning a 20-second countdown. During this time, the player is under "Strict Lockdown"—offensive tools cannot be launched, and running tools are paused/killed. Only defensive tools (Wiper) or attempting to pivot to a new host are permitted.
*   **Connection Terminated:** If the 20-second timer expires, `RivalAI` emits the `connection_lost` signal.
*   **The Breach Sequence:** `GameState`/`TransitionManager` intercepts `connection_lost`. The 2D screen goes to static, control input is locked, audio cuts out, and a 3D animation plays (banging on the door, police lights flashing outside the window).
*   **Mirror Mode Report:** Following the breach, the shift ends in failure. The player is presented with a side-by-side Forensic Report (Hacker Actions vs. AI Detection Timeline) detailing exactly what caused the breach.

## Alternatives Considered
*   *Desperation Mode during Isolation:* Allowing offensive actions at double trace cost during the final countdown was rejected in favor of "Strict Lockdown" to emphasize survival and panic rather than risking "suicide plays".
*   *State-Based Floor:* Tying the minimum trace level to the AI's highest alert state was rejected in favor of "Accumulated Debt" to specifically force the player to engage with the Evidence Wiper minigame, fulfilling the "Mirror Mode" mandate of generating forensic cleanup data.

## Implementation Steps

1.  **EventBus & Signals:**
    *   Add `trace_cooldown_started` and `trace_cooldown_ended` signals.
    *   Verify `connection_lost` exists and ensure all offensive tools listen for a `lockdown_initiated` signal.
2.  **TraceLevelManager Update:**
    *   Add `static_heat` variable and `cooldown_timer`.
    *   Modify `_on_decay_tick` to respect the AI's state multipliers and the `static_heat` floor.
    *   Update `_on_offensive_action` to add 25% of `cost` to `static_heat` and restart the cooldown timer.
    *   Expose a `reduce_static_heat(amount)` function.
3.  **App_Wiper Updates:**
    *   Modify the Wiper's success logic to call `TraceLevelManager.reduce_static_heat()` alongside regular trace reduction.
4.  **RivalAI & Lockdown Logic:**
    *   Emit a global "Strict Lockdown" signal when entering the `ISOLATING` state.
    *   Ensure all offensive apps (like Exfiltrator, Ransomware) have a role guard that checks `RivalAI.is_isolation_active` before launching or continuing.
5.  **Breach Transition & Report:**
    *   Wire the `connection_lost` signal to a new `trigger_breach_sequence()` in `TransitionManager` (or equivalent scene handler).
    *   Create the UI panel for the "Mirror Mode" report that reads from `HackerHistory` and `LogSystem` upon failure.

## Verification & Testing
*   **Unit Test:** Fire `exploit` (trace cost 20). Verify trace jumps to 20, `static_heat` jumps to 5. Wait 10 seconds. Verify trace decays but stops exactly at 5.0.
*   **Cooldown Test:** Fire an action, verify decay does not start for exactly 3 seconds.
*   **Lockdown Test:** Force trace to 100%. Verify offensive tools cannot be started. Verify the Evidence Wiper can still be started.
*   **Breach Test:** Let the 20-second timer expire. Verify the shift ends, input is locked, and the Forensic Report is displayed.
