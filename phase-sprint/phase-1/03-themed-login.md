# TASK 3: THEMED LOGIN SEQUENCE

## Description
[SOLO DEV SCOPE] Reskin the secure login to reflect Hacker role. Text strings only — no new animations.

## Implementation Details

### A. TransitionManager Extension
*   Modify `play_secure_login()` to accept `role` parameter
*   **Analyst Strings:** Keep existing ("Establishing Secure VPN...", "Syncing SIEM Logs...")
*   **Hacker Strings:** Add new array:
    ```gdscript
    ["Bypassing Firewall...", "Injecting Kernel Rootkit...", "Establishing Foothold..."]
    ```

### B. Color Theme
*   Use `GlobalConstants.COLOR_HACKER_GREEN` for progress bar
*   Analyst uses `COLOR_CORPORATE_BLUE`

### C. IntegrityManager Guard
*   Add role check: `if GameState.current_role == Role.HACKER: return`
*   Prevents "Organization Damage" during Hacker shifts

## Success Criteria
- [ ] **[BLOCKER]** Hacker login displays different strings than Analyst
- [ ] **[BLOCKER]** Progress bar is green for Hacker, blue for Analyst
- [ ] No Organization Damage applied in Hacker mode

## OUT OF SCOPE (Cut for Solo Dev)
- ❌ Matrix rain animation (static color ok)
- ❌ Sound effects during login
- ❌ Custom hacker animations
