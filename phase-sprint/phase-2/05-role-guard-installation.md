# TASK 5: ROLE GUARD INSTALLATION (SIGNAL HYGIENE)

## Description
[NEW] Add explicit role guard comments to four key Analyst singletons. This is a critical safety measure to prevent "Kill Chain bleed," where offensive hacker actions could accidentally advance the Analyst's narrative state.

## Implementation Details
The `offensive_action_performed` signal is declared in this phase. Before it can be emitted, we **must** ensure the following systems are guarded against consuming it. Add a comment at the top of each script's `_ready()` or signal connection function.

*   **File:** `autoload/ConsequenceEngine.gd`
    *   **Guard Comment:** `# ROLE GUARD: This engine must NOT consume hacker signals like 'offensive_action_performed'.`
*   **File:** `autoload/ValidationManager.gd`
    *   **Guard Comment:** `# ROLE GUARD: This manager's rules apply only to the Analyst. Hacker commands bypass it.`
*   **File:** `autoload/IntegrityManager.gd`
    *   **Guard Comment:** `# ROLE GUARD: Organization Damage is handled by the Analyst campaign. This is bypassed for Hacker role in Phase 1.`
*   **File:** `autoload/TicketManager.gd`
    *   **Guard Comment:** `# ROLE GUARD: This manager must not attach hacker actions to Analyst tickets.`

## Success Criteria
- [ ] **[BLOCKER]** `ConsequenceEngine.gd` contains the specified role guard comment.
- [ ] **[BLOCKER]** `ValidationManager.gd` contains the specified role guard comment.
- [ ] **[BLOCKER]** `IntegrityManager.gd` contains the specified role guard comment.
- [ ] **[BLOCKCER]** `TicketManager.gd` contains the specified role guard comment.
