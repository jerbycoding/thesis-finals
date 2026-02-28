# 📄 WEEK 1: "The Infiltration" (Content Audit)

**Theme:** Onboarding -> Escalation -> Crisis -> Recovery.
**Goal:** Teach the player the tools, introduce the 3 Kill Chains, and survive the Friday "Zero Day."

---

#### 📅 **MONDAY: "Data Correlation"** (Shift 1)
*   **Narrative Arc:** The player arrives. The CISO demands compliance. Focus is on learning the relationship between Email and SIEM data.
*   **Key Tickets:**
    *   `PHISH-001` (Stage 1): Simple triage.
    *   `PHISH-INTERNAL-001`: **Simplified Investigation.** Spoofed IT email; requires SIEM correlation to find the 'Click' log.
    *   `SPEAR-PHISH-001`: CEO target.
*   **Mechanic Focus:** **Correlation.** Finding SIEM proof for Email indicators.

#### 📅 **TUESDAY: "Terminal Action"** (Shift 2)
*   **Narrative Arc:** Technical anomalies escalate. Focus moves from just watching to taking active defense measures.
*   **Key Tickets:**
    *   `SOCIAL-001`: Intro to Social Engineering reports.
    *   `AUTH-BRUTE-LOCAL`: **Educational Action.** First time using Terminal `isolate` to stop an internal attacker.
    *   `SUPPLY-CHAIN-001`: Intro to third-party risk.
*   **Mechanic Focus:** **Containment.** Mastering the SOC Terminal commands (`scan`, `isolate`).

#### 📅 **WEDNESDAY: "Forensic Logic"** (Shift 3)
*   **Narrative Arc:** The malware outbreak goes live. The player must move beyond simple actions and start identifying technical sources.
*   **Key Tickets:**
    *   `MALWARE-POLY-001`: **Root Cause (Hostname).** Find the second victim by identifying their specific machine name.
    *   `DDOS-MITIGATION-001`: **Root Cause (IP).** Find the botnet controller's external IP address.
    *   `RANSOM-001`: Climax of the Malware Chain.
*   **Mechanic Focus:** **Attribution.** Using the 'Root Cause' box to validate technical findings before closure.

#### 📅 **THURSDAY: "Internal Betrayal"** (Shift 4)
*   **Narrative Arc:** Paranoia. Attacker credentials suggest IT Support may be compromised.
*   **Key Tickets:**
    *   `MOLE-HUNT-001`: **Investigation.** Trace an admin login back to a specific IP to confirm account takeover.
    *   `SHADOW-IT-002`: **Containment.** A live 5GB data leak; requires immediate isolation of the Marketing workstation.
*   **Mechanic Focus:** **Account Forensics.** Validating user alibis against IP geolocations.

#### 📅 **FRIDAY: "Zero Day"** (Shift 5)
*   **Narrative Arc:** Total Siege. co-ordinated attacks on data, infrastructure, and physical cooling.
*   **Key Tickets:**
    *   `KILL-SWITCH-001`: **Emergency Logic.** Trace and terminate an active SSH session within 90s to save the backups.
    *   `CORE-MELTDOWN-001`: **Physical Threat.** Isolate a compromised IoT thermostat to prevent server hardware from melting.
*   **Mechanic Focus:** **Crisis Triage.** Juggling concurrent Critical alerts while environmental effects (shake/lag) are active.

---

#### 🛠️ **WEEKEND: "Recovery"** (Shift 6 & 7)
*   **SATURDAY (Audit):** Physical navigation in Network Hub (Floor -2). `AUDIT` tasks linked to `SaturdayAudit.tres`. Requires walking to 3 specific racks to perform technical signal handshakes.
*   **SUNDAY (Recovery):** Physical navigation in Server Vault (Floor -1). `RECOVERY` tasks linked to `SundayRecovery.tres`. Requires picking up physical blades, slotting them into racks, and performing a 'RAID Sync' on the tablet.
*   **Audit / Polish Notes:**
    *   *System:* Minigame config system is now fully data-driven.
    *   *Reward:* Saturday Audit halts Integrity decay; Sunday Recovery restores 15% Integrity.

---

### 🚦 Kill Chain Integrity Check

| Chain Name | Stage 1 (Mon/Tue) | Stage 2 (Wed/Thu) | Stage 3 (Fri) | Status |
| :--- | :--- | :--- | :--- | :--- |
| **Malware** | `PHISH-001` | `MALWARE-CONTAIN-001` | `RANSOM-001` | **COMPLETE** |
| **Insider** | `SOCIAL-001` | `INSIDER-001` | `DATA-EXFIL-001` | **COMPLETE** |
| **Account** | `AUTH-FAIL-GENERIC` | `VPN-ANOMALY-001` | `DATA-EXFIL-001` | **COMPLETE** |
| **Supply** | `SUPPLY-CHAIN-001` | `SUPPLY-CHAIN-002` | `SUPPLY-CHAIN-003` | **COMPLETE** |

**Conclusion:**
Your Week 1 content is **structurally sound**. The Kill Chains are fully implemented, and the narrative arc flows logically from "Quiet" to "Chaos."
