# PHASE 4: HIGH-IMPACT PAYLOADS (THE WIN CONDITIONS)

## 1. Objective
Establish technical "Win Conditions" for the hacker. This phase implements specific payloads (Ransomware, Exfiltration, Wiper) that earn rewards and progress the narrative.

## 2. Key Task: The "Ransomware" App (Encryption Puzzle)
Create a specialized app for locking down hosts.

*   **Scene:** `App_Ransomware.tscn`.
*   **Inheritance:** Inherits from `MinigameBase.gd`.
*   **Logic:** Repurpose the `CalibrationMinigame.gd` signal-matching mechanic to represent "Encrypting Host Sectors."
*   **Outcome:** Sets host state to `RANSOMED` in `NetworkState`. Grants `Bounty` points.

## 3. Key Task: Data Exfiltration (The Steal Mechanic)
Implement a progress-based data theft system.

*   **Scene:** `App_Exfiltrator.tscn`.
*   **Inheritance:** Inherits from `MinigameBase.gd`.
*   **Logic:** Repurpose the `RaidSyncMinigame.gd` multi-bar progress logic to represent "Data Transfer Streams."
*   **Mechanic:** The transfer speed is throttled by `isp_multiplier`. The player must keep all streams "Active" to reach 100%.
*   **Outcome:** Grants `IntelligenceResource` items for the Hacker inventory.

## 4. Key Task: "Wiper" Scripts (Evidence Destruction)
Provide a tool for trace reduction and forensic cleaning.

*   **Scene:** `App_Wiper.tscn`.
*   **Inheritance:** Inherits from `MinigameBase.gd`.
*   **Logic:** Use the `RuleSliderMinigame.gd` mechanic to represent "Overwrite/Defrag."
*   **Outcome:** Calls `LogSystem.prune_logs_for_host()` and directly reduces the current `TraceLevelManager` value.

## 5. Technical Strategy: "The Inversion Pattern"
Offensive apps will use the existing minigame logic but invert the result:
*   **Analyst:** Result = "Repair Successful."
*   **Hacker:** Result = "System Compromised."
This ensures the "Feel" of technical interaction remains consistent across both roles while saving development time.

## 6. Phase 4 Success Criteria (Verification Checklist)
1.  [ ] **Ransomware Success:** Completing the puzzle sets host status to `RANSOMED`.
2.  [ ] **Exfiltration Sync:** Finish 100% transfer and verify the new resource is in the inventory.
3.  [ ] **Wiper Cleanup:** Verify that using the Wiper app successfully removes offensive logs from the SIEM view.
4.  [ ] **Trace Spikes:** Verify that using "Loud" payloads (Ransomware) spikes the Trace Level immediately.
