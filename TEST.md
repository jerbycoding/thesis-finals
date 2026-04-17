# VERIFY.EXE — Hacker Campaign Master Test Suite
> This document provides the end-to-end verification sequence for the Full Hacker Campaign.

## 🏁 Phase 1: Infrastructure & Transition
- [ ] **Ambiance Check:** Start a new Hacker game. Verify the background hum is the "Underground" version.
- [ ] **Mode Check:** Move the mouse. Verify the **Virtual Cursor** is visible on the 3D computer screen and the **OS Cursor** is hidden.
- [ ] **Command Discovery:** Open the terminal and type `help`. Verify `exploit`, `pivot`, `phish`, and `spoof` are listed.

## 🔫 Phase 2: Tactical Footholds
- [ ] **OSINT Phishing:** Type `phish [hostname]` (e.g., `FIN-WKSTN-01`). Verify the OSINT simulation prints and wait for result.
- [ ] **Technical Exploit:** Type `exploit [hostname]`. Verify the **Trace Level** meter increases.
- [ ] **Lateral Movement:** Once compromised, type `pivot [new_hostname]`. Verify your active foothold changes.
- [ ] **Identity Masking:** Type `spoof mask_01`. Verify subsequent `exploit` commands add 50% less trace.

## 📦 Phase 3: Payload Execution
- [ ] **Data Theft:** Open **Data Exfiltrator**. Start a transfer. Verify **multi-stream progress bars**. Verify a new item appears in the **Intelligence Inventory** (Check `inventory` in console or logic).
- [ ] **Ransomware:** Open **Ransomware**. Complete the calibration. Verify the host is listed as `[RANSOMED]` in the terminal `list`.
- [ ] **Forensic Cleanup:** Wait for Trace to reach >50%. Open **Evidence Wiper**. Complete the overwriting minigame. Verify **Trace Level drops** and logs are pruned from the SIEM.

## 🗣️ Phase 4: Mission Loop
- [ ] **Contract Board:** Verify the active contract reflects your current day's objective.
- [ ] **Verification:** Complete the objective (Ransom or Exfil). Verify the contract status changes to **READY TO SUBMIT** (Green).
- [ ] **Submission:** Click **SUBMIT**. Verify the Broker dialogue triggers.

## 📜 Phase 5: Thesis Validation (Mirror Mode)
- [ ] **Day Advance:** Type `submit` in the terminal to advance the day.
- [ ] **Interaction:** Verify **Mirror Mode Dashboard** appears. Verify the **OS Cursor** is now visible and interactive.
- [ ] **Correlation:** Check the dashboard. Verify **Connector Lines** connect your hacker actions (left) to the analyst logs (right).
- [ ] **Continuation:** Click **[DISMISS REPORT]**. Verify the game returns to the 3D desk and the **OS Cursor is hidden** (switching back to Virtual Cursor).

## 🎭 Phase 6: Narrative Conclusion
- [ ] **Day 7 Finale:** Progress to Day 7. Complete the final exfiltration.
- [ ] **The Reveal:** Submit the final contract. Verify the dialogue reveals the Broker's identity.
- [ ] **End State:** Verify the campaign conclusion triggers successfully.
