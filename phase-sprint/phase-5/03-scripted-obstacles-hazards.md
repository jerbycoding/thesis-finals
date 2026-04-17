# TASK 3: SCRIPTED OBSTACLES & HAZARDS (MECHANICS)

## Description
Implement the mechanical distinctions between scripted hazards and standard AI responses.

## Implementation Details

### A. Honeypot Rule
*   **[BLOCKER]** **Visual Identity:** [ ] Honeypots **must** render identically to legitimate hosts in all UI views (no color differences, no icon differences).
*   **[BLOCKER]** **Lockdown Override:** [ ] When a honeypot is exploited, it must trigger a 5-second `LOCKDOWN` override instead of the normal duration.

### B. Emergency Patch
*   **[BLOCKER]** **CLEAN Distinction:** [ ] Unlike Isolation (which marks a host as `"ISOLATED"`), an Emergency Patch **must** reset the host to `"CLEAN"` status, allowing the player to re-exploit it.
*   **Exfiltration Link:** [ ] If an Emergency Patch fires mid-exfiltration, it must emit `rival_ai_isolation_complete(hostname)` to trigger the interruption listener in `App_Exfiltrator`.

### C. Honeypot Reveal
*   **Logic:** [ ] Implement the `honeypot_reveal` scripted event, which allows a narrative beat to expose a specific honeypot to the player.

## Success Criteria
- [ ] **[BLOCKER]** Honeypots are visually indistinguishable from legitimate hosts in all UI views.
- [ ] **[BLOCKER]** Honeypot exploitation triggers the 5-second LOCKDOWN override.
- [ ] **[BLOCKER]** Emergency Patch resets the host to `"CLEAN"` status, distinct from isolation.
- [ ] Emergency Patch correctly interrupts any active exfiltration on the target host.
