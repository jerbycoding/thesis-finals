# Ticket Analysis & Resolution Logic

This document details the specific outcomes for every resolution strategy ("Compliant", "Efficient", "Emergency") for each active ticket. Use this to analyze the risk/reward structure of the game's **Kill Chain** system.

## 🔑 Resolution Strategy Legend

| Strategy | Action | Evidence Req? | Reward (Immediate) | Risk (Consequence) |
| :--- | :--- | :--- | :--- | :--- |
| **✓ COMPLIANT** | Thorough Investigation | **YES** (All Logs) | Max Reputation Gain | **0% Risk.** The incident is closed permanently. |
| **⚡ EFFICIENT** | Rapid Closure | **NO** | +60s Silence (Noise Paused) | **~50% Risk.** Hidden threats may escalate to the next Kill Chain stage. |
| **🚨 EMERGENCY** | Panic Button | **NO** | +120s Lockdown (Noise Paused) | **100% Risk.** Guaranteed escalation to the next Kill Chain stage. |

---

## 🔗 Kill Chain 1: Malware Outbreak
*A coordinated attack starting with Phishing, moving to Malware, and ending in Ransomware.*

### Stage 1: Phishing Campaign (`PHISH-001`)
*   **Scenario:** Users report suspicious emails.
*   **Compliant:** You identify and block the phishing domain. **Chain Broken.**
*   **Efficient/Emergency:** You close the ticket without verifying blocks. One user clicks the link. **Spawns `MALWARE-CONTAIN-001`.**

### Stage 2: Malware Containment (`MALWARE-CONTAIN-001`)
*   **Scenario:** A workstation (WORKSTATION-45) is beaconing to a C2 server.
*   **Compliant:** You scan and isolate the host. **Chain Broken.**
*   **Efficient/Emergency:** You close the alert but don't isolate the host. The malware spreads laterally to the server. **Spawns `RANSOM-001`.**

### Stage 3: Ransomware (`RANSOM-001`)
*   **Scenario:** Critical Finance Server is encrypted.
*   **Compliant:** You isolate the server immediately, preventing data loss. **Crisis Averted.**
*   **Efficient/Emergency:** You panic. The ransomware encrypts backups. **GAME OVER / Massive Reputation Loss.**

---

## 🔗 Kill Chain 2: The Data Breach
*A stealthy attack starting with Social Engineering, moving to Insider Access, and ending in Exfiltration.*

### Stage 1: Social Engineering (`SOCIAL-001`)
*   **Scenario:** Fake IT Support calls reported.
*   **Compliant:** You verify call logs and warn users. **Chain Broken.**
*   **Efficient/Emergency:** You ignore the report. The attacker gets a password. **Spawns `INSIDER-001`.**

### Stage 2: Insider Threat (`INSIDER-001`)
*   **Scenario:** Jane Doe's credentials used after hours.
*   **Compliant:** You flag the account and revoke access. **Chain Broken.**
*   **Efficient/Emergency:** You dismiss it as a glitch. The attacker accesses sensitive files. **Spawns `DATA-EXFIL-001`.**

### Stage 3: Data Exfiltration (`DATA-EXFIL-001`)
*   **Scenario:** Massive data upload detected.
*   **Compliant:** You block the IP and stop the transfer. **Crisis Averted.**
*   **Efficient/Emergency:** You hesitate. Customer data is leaked online. **Major Reputation Loss.**

---

## 🔀 Alternate Entry Points (Hidden Kill Chain Links)
*These tickets appear mundane but serve as "Fast Track" entry points into advanced Kill Chain stages if mishandled.*

### Spear Phishing (`SPEAR-PHISH-001`)
*   **Scenario:** Targeted attack on the CEO.
*   **Compliant:** Logs attached. Attack blocked.
*   **Efficient/Emergency:** 50% chance CEO executes the payload.
*   **Escalation:** Bypasses Phishing detection. Jumps directly to **Stage 2: Malware Containment (`MALWARE-CONTAIN-001`)** with **CRITICAL** urgency.

### Auth Failures (`AUTH-FAIL-GENERIC`)
*   **Scenario:** Brute force attack masked as "user forgot password".
*   **Compliant:** Account verified and secured.
*   **Efficient/Emergency:** 50% chance attacker guesses credentials.
*   **Escalation:** Bypasses Social Engineering. Jumps directly to **Stage 2: Insider Threat (`INSIDER-001`)**.

### System Maintenance (`SYS-MAINT-GENERIC`)
*   **Scenario:** Routine backup & patch verification.
*   **Compliant:** Backups verified successfully.
*   **Efficient/Emergency:** Maintenance skipped. Vulnerability remains open.
*   **Consequence:** **Critical Modifier.** If **Ransomware (`RANSOM-001`)** occurs later in the shift, recovery is impossible. **Guaranteed GAME OVER.**

---

## 🛠️ Tool & Log Reference

| Ticket ID | Required Tool | Required Logs (Evidence) |
| :--- | :--- | :--- |
| **AUTH-FAIL-GENERIC** | `siem` | `LOG-AUTH-003` |
| **DATA-EXFIL-001** | `siem` | `LOG-EXFIL-001`, `LOG-NETWORK-001` |
| **INSIDER-001** | `siem` | `LOG-JANE-DOE-ACCESS`, `LOG-EXFIL-JANE-DOE` |
| **MALWARE-CONTAIN-001** | `terminal` | `LOG-MALWARE-001` |
| **PHISH-001** | `siem` | `LOG-PHISH-001`, `LOG-EMAIL-002` |
| **RANSOM-001** | `terminal` | `LOG-RANSOM-FILE-ACTIVITY` |
| **SOCIAL-001** | `none` | `LOG-VOIP-001` |
| **SPEAR-PHISH-001** | `email` | `LOG-SPEAR-001` |
| **SYS-MAINT-GENERIC** | `siem` | `LOG-SYS-004` |

---

## 📅 Shift Schedule Breakdown (Baseline)
*This is the standard ticket schedule for the 5-Day Campaign. If you trigger consequences, **EXTRA** tickets will spawn on top of these.*

### Shift 1: Monday (Onboarding)
| Time | Ticket ID | Type | Note |
| :--- | :--- | :--- | :--- |
| **00:30** | `SYS-MAINT-GENERIC` | **Low** | Tutorial: Compliant Resolution. |
| **01:30** | `PHISH-001` | **Medium** | First Real Threat. |
| **03:00** | `AUTH-FAIL-GENERIC` | **Low** | Log Analysis Intro. |

### Shift 2: Tuesday (Noise)
| Time | Ticket ID | Type | Note |
| :--- | :--- | :--- | :--- |
| **00:30** | `SOCIAL-001` | **Medium** | Social Engineering. |
| **02:00** | `SPEAR-PHISH-001` | **High** | Hidden in Log Flood. |
| **04:00** | `SYS-MAINT-GENERIC` | **Low** | Distraction. |

### Shift 3: Wednesday (Outbreak)
| Time | Ticket ID | Type | Note |
| :--- | :--- | :--- | :--- |
| **00:15** | `MALWARE-CONTAIN-001` | **Critical** | Malware Chain Stage 2. |
| **01:00** | `PHISH-001` | **Medium** | Second Wave. |
| **03:00** | `RANSOM-001` | **Critical** | Malware Chain Stage 3 (Finale). |

### Shift 4: Thursday (Betrayal)
| Time | Ticket ID | Type | Note |
| :--- | :--- | :--- | :--- |
| **00:30** | `AUTH-FAIL-GENERIC` | **Low** | Brute Force. |
| **02:00** | `INSIDER-001` | **High** | Data Chain Stage 2. |
| **03:30** | `SPEAR-PHISH-001` | **High** | CEO Targeting. |

### Shift 5: Friday (Zero Day)
| Time | Ticket ID | Type | Note |
| :--- | :--- | :--- | :--- |
| **00:10** | `DATA-EXFIL-001` | **Critical** | Data Chain Stage 3 (Finale). |
| **00:45** | `RANSOM-001` | **Critical** | Distraction. |
| **01:30** | `MALWARE-CONTAIN-001` | **Critical** | Lateral Movement. |