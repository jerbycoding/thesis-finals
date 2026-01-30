# 🏎️ Sprint 06 — Expansion Readiness & Foundation

**Goal:** Refactor internal resource logic to eliminate "string-matching" fragile code and implement the infrastructure required for the Phase 4 Content Expansion.

---

## 🎯 Objectives
1.  **System Robustness:** Transition from string-based identification (e.g., searching for "spear" in IDs) to Enum-based categorization in `TicketResource` and `EmailResource`.
2.  **Data-Driven Depth:** Expand `VariableRegistry` to support more complex technical truths (Vendors, Ports, Internal Services).
3.  **Narrative Triggers:** Implement a bridge between `ConsequenceEngine` and `DialogueManager` to allow technical failures to trigger NPC interactions.
4.  **Chain A Deployment:** Implement the first full 3-stage **Ransomware Kill Chain**.

---

## 🛠️ Task Breakdown

### 1. Resource Logic Refactor (Safety First)
*   [ ] **TicketResource.gd:** Add `@export var is_ambient_noise: bool`.
*   [ ] **EmailResource.gd:** Add `ThreatCategory` Enum (`BENIGN`, `PHISHING`, `SPEAR_PHISH`, `MALWARE`).
*   [ ] **Manager Updates:** Update `TicketManager.gd` and `EmailSystem.gd` to use these new properties for filtering instead of `contains()` logic.

### 2. Variable Registry Expansion
*   [ ] **VariablePool.gd:** Add arrays for `trusted_vendors`, `internal_services`, and `ports`.
*   [ ] **VariableRegistry.gd:** Implement `generate_partner_packet()` to support Supply Chain incidents.

### 3. Narrative/Consequence Bridge
*   [ ] **ConsequenceEngine.gd:** Add `trigger_emergency_dialogue(npc_id, dialogue_id)`.
*   [ ] **NarrativeDirector.gd:** Create a handler for "Interruption" events that pause the current shift timer for critical NPC dialogue.

### 4. Chain A Implementation (Content)
*   [ ] **Resources:** Create `PHISH-004` (Stage 1), `MALWARE-003` (Stage 2), and `RANSOM-003` (Stage 3).
*   [ ] **Evidence:** Generate 6 new matching `LogResource` files.
*   [ ] **Shift Integration:** Inject this chain into `Shift1.tres` and `Shift2.tres` for testing.

---

## ⚠️ Risk Mitigation Plan
*   **Navigation Safety:** After any prop or architectural changes in Step 5 of the plan, a **NavMesh Rebake** is mandatory.
*   **ID Collisions:** Use the `ResourceAuditManager` at every startup to ensure the new 3-stage chains don't have broken links.
*   **Save Compatibility:** Increasing the number of resources may invalidate old JSON save files. **Action:** Perform a `SaveSystem.new_game_setup()` during testing.

---

## ✅ Exit Criteria
1.  A player can ignore a Stage 1 phishing ticket and have a Stage 3 Ransomware ticket appear 2 minutes later with the **exact same Attacker IP**.
2.  The `Email Analyzer` correctly identifies "Spear Phishing" based on the Enum flag, not the filename.
3.  `ResourceAuditManager` reports 0 critical errors.
