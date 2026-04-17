# TASK 4a: THEMED LOGIN & ROLE FILTERS

## Description
Modify the secure login sequence to reflect the current role and ensure core gameplay systems (like `IntegrityManager`) respect role boundaries.

## Implementation Details
*   **Transition Reskin:** [x] Modify `TransitionManager.play_secure_login()` to accept a `role` parameter. Based on the role, it should display different flavor text.
    *   **Analyst Strings:** [x] "Establishing Secure VPN...", "Syncing SIEM Logs..."
    *   **Hacker Strings:** [x] "Bypassing Firewall...", "Injecting Kernel Rootkit...", "Establishing Foothold..."
*   **Metric Diversion:** [x] `IntegrityManager.gd` must be guarded. Its logic that applies "Organization Damage" must be bypassed if `GameState.current_role == Role.HACKER`.

## Success Criteria
- [x] The secure login screen displays hacker-specific strings and colors when the role is Hacker.
- [x] No "Organization Damage" is applied when performing actions in Hacker mode.
