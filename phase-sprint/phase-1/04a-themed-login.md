# TASK 4a: THEMED LOGIN & ROLE FILTERS

## Description
[REVISED SCOPE] Modify the secure login sequence to reflect the current role and ensure core gameplay systems (like `IntegrityManager`) respect role boundaries.

## Implementation Details
*   **Transition Reskin:** Modify `TransitionManager.play_secure_login()` to accept a `role` parameter. Based on the role, it should display different flavor text.
    *   **Analyst Strings:** "Establishing Secure VPN...", "Syncing SIEM Logs..."
    *   **Hacker Strings:** "Bypassing Firewall...", "Injecting Kernel Rootkit...", "Establishing Foothold..."
*   **Metric Diversion:** `IntegrityManager.gd` must be guarded. Its logic that applies "Organization Damage" must be bypassed if `GameState.current_role == Role.HACKER`.

## Success Criteria
- [ ] The secure login screen displays hacker-specific strings and colors when the role is Hacker.
- [ ] No "Organization Damage" is applied when performing actions in Hacker mode.
