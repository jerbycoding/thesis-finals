# 📋 Phase 4: Expansion Execution Plan

This document outlines the step-by-step roadmap for expanding content in **VERIFY.EXE**, focusing on maximizing gameplay variety using existing systems.

---

## 🛑 Step 1: Kill Chain "Deepening" (The Narrative Core)
**Goal:** Create multi-stage incidents that tell a cohesive story of a breach.
*   **Why First?** This is the highest-value content. It turns single "whack-a-mole" tickets into persistent threats that punish mistakes (the core theme of the game).
*   **Actions:**
    1.  **Map Real-World Scenarios:** Define 3 new chains based on `CYBERTHREATS.md`:
        *   **Chain A (Ransomware):** Phishing -> Lateral Movement -> Server Encryption.
        *   **Chain B (Insider):** Policy Violation -> Privilege Escalation -> Data Exfiltration.
        *   **Chain C (Supply Chain):** Vendor Email -> Backdoor Beacon -> Subnet Outbreak.
    2.  **Create Resources:**
        *   Create `TicketResource` files for Stage 1, 2, and 3 of each chain.
        *   Link them using the `escalation_ticket` property.
    3.  **Generate Evidence:**
        *   Create matching `LogResource` and `EmailResource` files for every stage.
        *   Ensure "Truth Packets" (IPs/Hostnames) align across the chain.

---

## 📧 Step 2: The "Noise" Layer (Anti-Gaming)
**Goal:** Prevent players from assuming "every email is a threat."
*   **Why Second?** Once you have deadly Kill Chains, players will become paranoid. You need "safe" content to force them to actually *verify* data rather than just reacting.
*   **Actions:**
    1.  **Benign Emails:** Create 10-15 "Noise" emails (Office birthday, Lost items, HR updates).
    2.  **False Flags:** Create 5-10 "Suspicious but Safe" logs (e.g., an admin logging in at night for legitimate maintenance).
    3.  **Populate Pools:** Add these to the `TicketManager` and `EmailSystem` ambient pools so they appear randomly during shifts.

---

## 📆 Step 3: Shift Architecture (The Pacing)
**Goal:** Define the rhythm of the game week.
*   **Why Third?** You now have the "blocks" (Kill Chains + Noise). Now you need to build the "level structure."
*   **Actions:**
    1.  **Refine Weekdays:** Update `Shift1.tres` through `Shift5.tres`.
        *   **Monday:** Tutorial + Chain A (Stage 1). Low noise.
        *   **Wednesday:** Chain B starts. Chain A escalates if missed. Medium noise.
        *   **Friday:** Chain C (Zero Day) + Total Chaos (High noise).
    2.  **Event Integration:** Inject `system_events` (SIEM Lag, Power Flicker) into the shifts to match the narrative intensity.

---

## 👥 Step 4: Social Consequence (The Emotional Layer)
**Goal:** Make the player care about their choices beyond just the score.
*   **Why Fourth?** Mechanics are dry without context. NPCs add weight to the "Efficient vs. Compliant" choice.
*   **Actions:**
    1.  **Contextual Dialogue:** Create new `DialogueDataResource` files triggered by specific Kill Chain stages.
        *   *Example:* If Chain A hits Stage 3 (Ransomware), the CISO summons you for a reprimand.
    2.  **Relationship Perks:** Define specific perks for "Admired" status with IT Support or Senior Analyst (e.g., auto-closing false flag tickets).

---

## 🛠️ Step 5: Environmental Storytelling (The Vibe)
**Goal:** Make the world feel lived-in and reactive.
*   **Why Last?** This is "polish" expansion. It doesn't change mechanics but improves immersion.
*   **Actions:**
    1.  **Prop Variety:** Create variants of the `Prop_Desk` clutter (different mug colors, stacks of paper).
    2.  **Email Fluff:** Add "Reply chains" or internal gossip to the noise emails to build world-building lore.
    3.  **Dynamic Screens:** Create simple texture variants for the office monitors so they don't all show the same static image.

---

## 🚀 Execution Checklist
- [ ] **Chain A:** Ransomware Path (3 Tickets, 6 Logs, 2 Emails)
- [ ] **Chain B:** Insider Path (3 Tickets, 4 Logs, 1 Email)
- [ ] **Chain C:** Supply Chain Path (3 Tickets, 5 Logs, 1 Email)
- [ ] **Noise Pack:** 10 Benign Emails, 10 Safe Logs
- [ ] **Shift Updates:** Re-balance Mon-Fri using new content
- [ ] **Dialogue:** Add "Crisis" responses for Stage 3 failures
