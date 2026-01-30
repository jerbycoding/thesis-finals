# 👥 NPC & Dialogue Documentation

The social layer in **VERIFY.EXE** makes choices technically consequential. Player interactions with NPCs determine relationship ranks, which unlock operational perks or technical penalties.

## The Approval Matrix
Relationships are tracked by `ConsequenceEngine.gd` using numerical scores mapped to ranks defined in `GlobalConstants.gd`:
*   **Admired (+1.5):** Maximum synergy. Significant operational perks.
*   **Respected (+0.5):** Positive standing. Occasional technical assistance.
*   **Neutral (0.0):** Standard operational status.
*   **Distrusted (-1.5):** Low trust. Minor operational friction.
*   **Hated (-2.5):** Active hostility. Technical sabotage or negligence.

---

## 👨‍💻 Senior Analyst (The Mentor/Rival)
The player's primary point of contact. Values thoroughness and adherence to forensic proof.
*   **Role:** Provides morning briefings and check-ins during outbreaks.
*   **Perk (Admired):** Periodically reveals required logs for active tickets automatically.
*   **Key Interaction:** Values asking for tips early on, but rewards confidence if the player is technically correct during crises.

## 👔 CISO (The Authority)
The Chief Information Security Officer. Values results, metrics, and organizational loyalty.
*   **Role:** Oversees major shift transitions and "Betrayal" investigations.
*   **Relationship Impact:** Relationship with the CISO is the primary driver for the "Fired" failure state if the player consistently chooses "Cowboy" or "Negligent" paths.
*   **Key Interaction:** Decides if the player is authorized to "Clock Out" early based on queue status.

## 🔧 IT Support Lead (The Gatekeeper)
The technical manager responsible for hardware and network stability.
*   **Role:** Approaches the player after multiple host isolations.
*   **Penalty (Hated):** Periodically locks the player's Terminal for 10s ("Terminal Glitch") to simulate the burden of re-imaging hosts.
*   **Key Interaction:** Player must balance "Containment Speed" vs "IT Workload." Apologizing for isolations restores status.

## 🧐 Compliance Auditor (The Scrutinizer)
A strict, protocol-oriented NPC who appears during specialized "Audit" shifts.
*   **Role:** Challenges the player's past strategy. 
*   **Dialogue Theme:** Asks for justification of "Efficient" closures.
*   **Impact:** Failing dialogue with the Auditor can trigger follow-up `AUDIT-PROC-001` tickets.

---

## 🤖 Global Dialogue System
*   **Data-Driven:** All branching conversations are stored in `res://resources/dialogue/`.
*   **Naming Convention:** `[npc_id]_[dialogue_id].tres` (e.g., `senior_analyst_monday_morning.tres`).
*   **Choice Effects:** Choices use an `effect` dictionary to:
    *   `relationship_change`: Modify NPC scores.
    *   `change_scene`: Teleport player to new rooms (Briefing Room, Vault).
    *   `trigger_shift_end`: Finish the day early.
