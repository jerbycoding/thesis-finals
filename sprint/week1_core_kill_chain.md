# Sprint Week 1: Core Kill Chain & Consequence Engine

## 1. Objective
Establish the foundational "Kill Chain" logic and the `ConsequenceEngine` to manage ticket interconnectedness.

## 2. Tasks
### 2.1 The Three Stages of Attack
*   **Stage 1: Delivery:** Implement Phishing and Social Engineering ticket types.
*   **Stage 2: Execution & Persistence:** Implement Malware Beacons and Unauthorized Access alerts.
*   **Stage 3: Impact:** Implement Ransomware and Data Exfiltration critical alerts.

### 2.2 Escalation Logic
*   Implement the probability-based escalation system in `TicketManager`:
    *   **Compliant Resolution:** 0% escalation.
    *   **Efficient Resolution:** 50% escalation risk.
    *   **Emergency Resolution:** 75% escalation risk.
    *   **Ignored / Timeout:** 100% escalation.

### 2.3 ConsequenceEngine Foundation
*   Develop the tracking system for active attack chains.
*   Implement a timer-based scheduler for spawning the next stage of an escalated threat.

### 2.4 Content Implementation: Path A (The Malware Outbreak)
*   Define `PHISH-001` resource.
*   Define `MALWARE-CONTAIN-001` resource.
*   Define `RANSOM-001` resource.

## 3. Technical Requirements
*   `ConsequenceEngine.gd` singleton must maintain a dictionary of `active_chains`.
*   `TicketResource.gd` needs an `escalation_path` property.
