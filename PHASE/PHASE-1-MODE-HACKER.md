# PHASE 1: FOUNDATION & STATE ISOLATION (THE MASTER SWITCH)

## 1. Objective
Establish "Hacker Mode" as a clean parallel track that reuses existing systems without corrupting the original SOC Analyst logic. This phase focuses on global state authority and physical environment scaffolding.

## 2. Key Task: GameState Extension (Role Authority)
Add a permanent `Role` axis to the global state to distinguish between "Defender" and "Attacker."

*   **File:** `autoload/GameState.gd`
*   **Action:** Add `enum Role { ANALYST, HACKER }` and `var current_role = Role.ANALYST`.
*   **Logic:** Standardize logic checks to `if GameState.current_role == Role.HACKER`. Do NOT repurpose `GameMode` (which handles 2D/3D interaction).

## 3. Key Task: 3D "Remote Office" Scaffolding
Create the physical "Safe House" environment for the hacker.

*   **Scene:** `scenes/3d/HackerRoom.tscn`
*   **Assets:** Use `InteractableComputer.tscn` with a standard `ViewAnchor` for camera alignment.
*   **Transition:** Verify `TransitionManager.gd` sitting animation anchors correctly in the smaller room.

## 4. Key Task: State Isolation & UI Context
Ensure that data from one role does not "leak" into the other.

*   **Network Isolation:** `NetworkState.gd` must reset or switch "Contexts" when loading a Hacker vs Analyst save.
*   **UI Safety:** Explicitly call `UIObjectPool.flush()` during role transitions to clear SIEM log entries and ticket lists.
*   **Save System:** `SaveSystem.gd` must support separate directory paths for Analyst and Hacker career progress.

## 5. Technical Strategy: "Themed Auth" & Role Filters
Maintain immersion by reskinning the "Secure Login" sequence.

*   **Transition Reskin:** Modify `TransitionManager.play_secure_login()` to accept a `role` parameter.
    *   **Analyst Strings:** "Establishing Secure VPN...", "Syncing SIEM Logs..."
    *   **Hacker Strings:** "Bypassing Firewall...", "Injecting Kernel Rootkit...", "Establishing Foothold..."
*   **Metric Diversion:** `IntegrityManager.gd` must bypass "Organization Damage" if `current_role == Role.HACKER`.

## 6. Phase 1 Success Criteria (Verification Checklist)
1.  [x] **Role Persistance:** Starting a "Hacker Campaign" correctly sets `GameState.current_role`.
2.  [x] **Themed Login:** The secure login screen displays hacker-specific strings and "Matrix Green" colors.
3.  [x] **Anchor Validation:** The player camera correctly "sits" at the hacker desk.
4.  [x] **State Separation:** Loading a Hacker save does not show the Analyst's current tickets or organization health. (Partial: Basic separation working).
