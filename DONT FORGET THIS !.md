# 📋 Phase 4: Expansion Execution Plan (ON HOLD - POLISH PHASE)

**CURRENT STATUS:** The Expansion Plan is currently **ON HOLD**. The focus has shifted to **Phase 5/6: Visual Polish, UX, and Bug Triage**. 

This document remains the source of truth for when we return to content expansion.

---

## ✨ Current Polish Priorities (Phase 5/6)
*   **3D Environment Uplift:** Upgrading rooms from graybox to high-fidelity (Executive Suite, SOC Office, Briefing Room).
*   **UI/UX Redesign:** Implementing the "Enterprise-Clean" aesthetic across all apps (SIEM, Terminal, Handbook, etc.).
*   **Audio Atmosphere:** Improving ambient sound and feedback cues.
*   **Bug Triage:** Fixing critical narrative triggers (e.g., Shift transitions).

---

## 🛑 Step 1: Kill Chain "Deepening" (Future Task)
**Goal:** Create multi-stage incidents that tell a cohesive story of a breach.
*   **Why First?** This is the highest-value content. It turns single "whack-a-mole" tickets into persistent threats that punish mistakes.
*   **Actions:**
    1.  **Map Real-World Scenarios:** Define 3 new chains based on `CYBERTHREATS.md`:
        *   **Chain A (Ransomware):** Phishing -> Lateral Movement -> Server Encryption.
        *   **Chain B (Insider):** Policy Violation -> Privilege Escalation -> Data Exfiltration.
        *   **Chain C (Supply Chain):** Vendor Email -> Backdoor Beacon -> Subnet Outbreak.
    2.  **Create Resources:** Create Stage 1, 2, and 3 tickets and link them.
    3.  **Generate Evidence:** matching logs and emails for every stage.

---

## 📧 Step 2: The "Noise" Layer (Future Task)
**Goal:** Prevent players from assuming "every email is a threat."
*   **Actions:**
    1.  **Benign Emails:** 10-15 "Noise" emails (Office birthday, HR updates).
    2.  **False Flags:** 5-10 "Suspicious but Safe" logs.
    3.  **Populate Pools:** Add to ambient pools.

---

## 📆 Step 3: Shift Architecture (Future Task)
**Goal:** Define the rhythm of the game week.
*   **Actions:**
    1.  **Refine Weekdays:** Update `Shift1.tres` through `Shift5.tres` with new chain beats.
    2.  **Event Integration:** Inject `system_events` (SIEM Lag, Power Flicker).

---

## 👥 Step 4: Social Consequence (Future Task)
**Goal:** Make the player care about their choices beyond just the score.
*   **Actions:**
    1.  **Contextual Dialogue:** New `DialogueDataResource` files for failure states.
    2.  **Relationship Perks:** Define specific perks for high status.

---

## 🛠️ Step 5: Environmental Storytelling (Future Task)
**Goal:** Make the world feel lived-in and reactive.
*   **Actions:**
    1.  **Prop Variety:** Clutter randomization on desks.
    2.  **lore Building:** Email reply chains and gossip.

---

## 🚀 Future Execution Checklist (Post-Polish)
- [ ] **Chain A:** Ransomware Path (3 Tickets, 6 Logs, 2 Emails)
- [ ] **Chain B:** Insider Path (3 Tickets, 4 Logs, 1 Email)
- [ ] **Chain C:** Supply Chain Path (3 Tickets, 5 Logs, 1 Email)
- [ ] **Noise Pack:** 10 Benign Emails, 10 Safe Logs
- [ ] **Shift Updates:** Re-balance Mon-Fri using new content
- [ ] **Dialogue:** Add "Crisis" responses for Stage 3 failures