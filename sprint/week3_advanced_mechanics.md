# Sprint Week 3: Advanced Mechanics & Redemption

## 1. Objective
Finalize the gameplay loop with high-stakes decision-making and a path for player recovery.

## 2. Tasks
### 2.1 Risk and Reward: The Response Buffer
*   **Efficient Resolution Reward:** Implement "Noise Cancellation" (60s pause on procedural tickets).
*   **Emergency Resolution Reward:** Implement "System Lockdown" (120s pause on all new tickets).

### 2.2 Redemption: Post-Mortem Investigation
*   **The Black Ticket:** Implement a high-complexity, non-timed forensic task for Stage 3 failures.
*   **Evidence Gathering:** Require 5 specific log/email/terminal evidence points for completion.
*   **Career Reset:** Logic to reduce "Risks Taken" and reset CISO relationship on success.

### 2.3 Visual Clarity: The Evidence Flash
*   **Icon Glow:** Add a pulsing Magenta Glow to the SIEM desktop icon when escalation evidence is added.
*   **Log Tagging:** Automatically prefix revealed logs with `[REVEALED]` in the SIEM Viewer UI.

## 3. Technical Requirements
*   `DesktopWindowManager.gd` update to handle icon glow states.
*   `LogSystem.gd` update to handle tagging of previously missed logs.
*   `ArchetypeAnalyzer.gd` update to integrate with the "Risks Taken" reduction logic.
