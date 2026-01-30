# ⛓️ Kill Chain Narrative Documentation

In **VERIFY.EXE**, security incidents are not isolated events. They are part of persistent campaigns known as **Kill Chains**. These chains progress through stages, and player failure or "Efficient" (risky) resolutions increase the probability of escalation to the next, more severe stage.

## Core Kill Chain Logic
*   **Probability:** Managed by `ConsequenceEngine.gd`. 'Efficient' closures have a 50% risk, 'Emergency' 75%, and 'Timeout' 100% risk of triggering the next stage.
*   **Procedural Inheritance:** `HeatManager.gd` caches vulnerabilities from rushed closures. Escalated tickets inherit technical context (Attacker IP, Victim Host) from the original incident.
*   **Evidence Flash:** When a chain escalates, missing logs from the previous stage are marked as `is_revealed`, allowing the player to see exactly what they missed.

---

## 1. Malware Outbreak (Primary External Threat)
The most common path involving external delivery of malicious payloads.
*   **Stage 1: Initial Access**
    *   *Tickets:* `PHISH-001`, `PHISH-002`, `PHISH-003`, `SPEAR-PHISH-001`, `SPEAR-PHISH-002`.
    *   *Evidence:* Malicious links, spoofed headers, executable attachments.
*   **Stage 2: Execution & Persistence**
    *   *Tickets:* `MALWARE-CONTAIN-001` (Active Beaconing), `MALWARE-002` (Script Analysis).
    *   *Action:* Terminal `scan` and `isolate` required.
*   **Stage 3: Impact**
    *   *Tickets:* `RANSOM-001` (Finance Server), `RANSOM-002` (Web Server).
    *   *Action:* `Decryption Tool` required to recover encrypted data.

## 2. Account Takeover (Privilege Escalation)
Focuses on an attacker gaining and abusing internal credentials.
*   **Stage 1: Recon/Brute Force**
    *   *Tickets:* `AUTH-FAIL-GENERIC`.
    *   *Evidence:* High volume of failed login logs in SIEM.
*   **Stage 2: Privilege Escalation**
    *   *Tickets:* `VPN-ANOMALY-001` (Impossible Travel), `AUTH-002` (Admin Compromise).
    *   *Evidence:* Successful logins from external IPs following brute force.
*   **Stage 3: Impact**
    *   *Tickets:* `DATA-EXFIL-001`.
    *   *Action:* Identify outbound connections and block at firewall.

## 3. The Data Breach (Internal Misuse)
Focuses on the human element and insider threats.
*   **Stage 1: Social Engineering**
    *   *Tickets:* `SOCIAL-001`, `AUTH-003`, `SPEAR-PHISH-003`.
    *   *Evidence:* User reports of suspicious calls/emails.
*   **Stage 2: Internal Abuse**
    *   *Tickets:* `INSIDER-001` (Jane Doe Incident).
    *   *Evidence:* Unusual file access by terminated employees.
*   **Stage 3: Impact**
    *   *Shares Stage 3 with Account Takeover (Data Exfiltration).*

## 4. Shadow IT (Policy Violation)
A new path introduced in Phase 4 focusing on unauthorized internal behavior.
*   **Stage 1: Unauthorized App Use**
    *   *Tickets:* `SHADOW-IT-001` (`TICKET-UNAUTH-APP`).
    *   *Evidence:* Traffic to personal cloud storage (Dropbox/MediaFire).
*   **Stage 2: Large Data Transfer**
    *   *Tickets:* `SHADOW-IT-002` (`TICKET-DATA-MOVE`).
    *   *Action:* Terminal isolation of Marketing workstation.
*   **Stage 3: Legal Hold**
    *   *Tickets:* `SHADOW-IT-003` (`TICKET-LEGAL-HOLD`).
    *   *Action:* Forensic timeline building to prove intent for Legal.

## 5. Supply Chain (Partner Compromise)
A high-difficulty path introduced in Phase 4.
*   **Stage 1: Compromised Partner**
    *   *Tickets:* `SUPPLY-CHAIN-001`.
    *   *Evidence:* Spoofed "Security Patch" from trusted vendor.
*   **Stage 2: Backdoor Installation**
    *   *Tickets:* `SUPPLY-CHAIN-002`.
    *   *Evidence:* Server beaconing to external IP via the backdoored patch.
*   **Stage 3: Subnet Outbreak**
    *   *Tickets:* `SUPPLY-CHAIN-003`.
    *   *Action:* Massive lateral movement event requiring multi-host isolation.

---

## Special Path: Redemption
*   **Trigger:** Triggered by `BLACK-TICKET-REDEMPTION` (Stage 99).
*   **Condition:** Only appears if the player has suffered significant Integrity loss due to Procedural Violations.
*   **Outcome:** Successful completion purges the player's history of past deviations and resets archetype metrics.
