# VERIFY.EXE: Shift-by-Shift Evidence Guide

This document maps every Incident Ticket to its specific shift, required logs, and mandatory tools for a **Compliant** resolution.

---



---

## 📅 Shift 1: Monday (Focus: Data Correlation)
| Ticket ID               | SIEM Logs (Evidence)             | Email Analyzer? | SOC Terminal      | Decrypt? |
|:------------------------|:---------------------------------|:---------------:|:------------------|:--------:|
| **`PHISH-001`**         | `LOG-PHISH-001`, `LOG-EMAIL-002` |     **YES**     | NO                |    NO    |
| **`AUTH-FAIL-GENERIC`** | `LOG-AUTH-003`                   |       NO        | NO                |    NO    |
| **`PHISH-INTERNAL-001`**| `LOG-PHISH-CLICK`                |     **YES**     | NO                |    NO    |
| **`SPEAR-PHISH-001`**   | `LOG-SPEAR-001`                  |     **YES**     | NO                |    NO    |

---

## 📅 Shift 2: Tuesday (Focus: Terminal Action)
| Ticket ID              | SIEM Logs (Evidence)              | Email Analyzer? | SOC Terminal      | Decrypt? |
|:-----------------------|:----------------------------------|:---------------:|:------------------|:--------:|
| **`SOCIAL-001`**       | `LOG-VOIP-001`                    |     **YES**     | NO                |    NO    |
| **`AUTH-BRUTE-LOCAL`** | `LOG-BRUTE-LOCAL`                 |       NO        | **YES** (isolate) |    NO    |
| **`SUPPLY-CHAIN-001`** | `LogAVScan`                       |     **YES**     | **YES** (scan)    |    NO    |
| **`SPEAR-PHISH-002`**  | `LOG-SPEAR-002`                   |     **YES**     | NO                |    NO    |

---

## 📅 Shift 3: Wednesday (Focus: Forensic Logic)
| Ticket ID                 | SIEM Logs (Evidence)       | Email Analyzer? | SOC Terminal      | Decrypt? |
|:--------------------------|:---------------------------|:---------------:|:------------------|:--------:|
| **`MALWARE-CONTAIN-001`** | `LOG-MALWARE-001`          |       NO        | **YES** (isolate) |    NO    |
| **`MALWARE-POLY-001`**    | `LOG-MAL-002-A`            |       NO        | **YES** (scan/iso)|    NO    |
| **`VPN-ANOMALY-001`**     | `LOG-VPN-001`, `002`       |       NO        | NO                |    NO    |
| **`DDOS-MITIGATION-001`** | `LOG-DDOS-002`             |       NO        | **YES** (trace)   |    NO    |
| **`RANSOM-001`**          | `LOG-RANSOM-FILE-ACTIVITY` |       NO        | **YES** (isolate) | **YES**  |

> **Note:** `MALWARE-POLY-001` requires entering `{victim_host}` as the Root Cause. `DDOS-MITIGATION-001` requires `{attacker_ip}`. `VPN-ANOMALY-001` requires `{ip}`.

---

## 📅 Shift 4: Thursday (Focus: Insider Threats)
| Ticket ID             | SIEM Logs (Evidence)               | Email Analyzer? | SOC Terminal | Decrypt? |
|:----------------------|:-----------------------------------|:---------------:|:-------------|:--------:|
| **`MOLE-HUNT-001`**   | `LOG-MOLE-ADMIN-01`                |       NO        | NO           |    NO    |
| **`INSIDER-001`**     | `LOG-JANE-DOE-ACCESS`, `LOG-EXFIL-JANE-DOE` |       NO        | NO           |    NO    |
| **`SHADOW-IT-001`**   | `LOG-SHADOW-001`                   |       NO        | NO           |    NO    |
| **`SHADOW-IT-002`**   | `LOG-SHADOW-002`                   |       NO        | **YES** (iso)|    NO    |
| **`SPEAR-PHISH-003`** | `LOG-SPEAR-003`                    |     **YES**     | NO           |    NO    |

> **Note:** `MOLE-HUNT-001` requires entering `{ip}` as the Root Cause to confirm the compromised admin account.

---

## 📅 Shift 5: Friday (Zero Day)
| Ticket ID                 | SIEM Logs (Evidence)               | Email Analyzer? | SOC Terminal            | Decrypt? |
|:--------------------------|:-----------------------------------|:---------------:|:------------------------|:--------:|
| **`DATA-EXFIL-001`**      | `LOG-EXFIL-001`, `LOG-NETWORK-001` |     **YES**     | **YES** (trace)         |    NO    |
| **`KILL-SWITCH-001`**     | `LOG-KILL-SWITCH-001`              |       NO        | **YES** (trace)         |    NO    |
| **`RANSOM-002`**          | `LOG-RANSOM-002`                   |       NO        | **YES** (isolate)       | **YES**  |
| **`CORE-MELTDOWN-001`**   | `LOG-CORE-MELTDOWN-001`            |       NO        | **YES** (scan/iso)      |    NO    |
| **`DDOS-MITIGATION-001`** | `LOG-DDOS-002`                     |       NO        | **YES** (trace/isolate) |    NO    |

> **Note:** `KILL-SWITCH-001` requires entering `{attacker_ip}` as the Root Cause to terminate the malicious SSH session. `CORE-MELTDOWN-001` requires isolating the IoT controller.

---

## 📅 Shift 8: Monday (Inheritance)
| Ticket ID              | SIEM Logs (Evidence)      | Email Analyzer? | SOC Terminal           | Decrypt? |
|:-----------------------|:--------------------------|:---------------:|:-----------------------|:--------:|
| **`PHISH-LEGACY-001`** | `LOG-PHISH-001` (Legacy)  |     **YES**     | NO                     |    NO    |
| **`AUTH-SPIKE-001`**   | `LOG-AUTH-SPIKE-01`, `02` |       NO        | NO                     |    NO    |
| **`MALWARE-POLY-001`** | `LOG-MAL-002-A`           |       NO        | **YES** (scan/isolate) |    NO    |
| **`RANSOM-ECHO-001`**  | `LOG-RANSOM-002`          |       NO        | **YES** (isolate)      | **YES**  |

---

## 📅 Shift 9: Tuesday (System Instability)
| Ticket ID              | SIEM Logs (Evidence) | Email Analyzer? | SOC Terminal            | Decrypt? |
|:-----------------------|:---------------------|:---------------:|:------------------------|:--------:|
| **`SUPPLY-CHAIN-004`** | `LOG-SYS-004`        |     **YES**     | NO                      |    NO    |
| **`DNS-SPOOF-001`**    | `LOG-DNS-SPOOF-01`   |       NO        | **YES** (trace/isolate) |    NO    |
| **`SERVICE-FLAP-001`** | **MANDATORY ISOLATION** |       NO        | NO                      |    NO    |

---

## 📅 Shift 10: Wednesday (Executive Targets)
| Ticket ID            | SIEM Logs (Evidence) | Email Analyzer? | SOC Terminal      | Decrypt? |
|:---------------------|:---------------------|:---------------:|:------------------|:--------:|
| **`WHALING-001`**    | `LOG-VIP-BEACON-01`  |     **YES**     | NO                |    NO    |
| **`VIP-LAPTOP-001`** | `LOG-VIP-BEACON-01`  |       NO        | **YES** (isolate) |    NO    |
| **`ESP-023`**        | `LOG-O365-001`       |     **YES**     | NO                |    NO    |
| **`ESPIONAGE-002`**  | `LOG-ESP-002A`, `B`  |       NO        | NO                |    NO    |
| **`RANSOM-VIP-001`** | `LOG-RANSOM-VIP-001` |       NO        | **YES** (isolate) | **YES**  |

---

## 📅 Shift 11: Thursday (Paranoia)
| Ticket ID           | SIEM Logs (Evidence)  | Email Analyzer? | SOC Terminal      | Decrypt? |
|:--------------------|:----------------------|:---------------:|:------------------|:--------:|
| **`MOLE-HUNT-001`** | `LOG-MOLE-ADMIN-01`   |       NO        | NO                |    NO    |
| **`ESPIONAGE-001`** | `LOG-ESP-001A`, `B`   |     **YES**     | **YES** (scan)    |    NO    |
| **`LOG-WIPER-001`** | `LOG-WIPER-DELETE-01` |       NO        | **YES** (isolate) |    NO    |
| **`ESPIONAGE-003`** | `LOG-ESP-03A`         |     **YES**     | NO                |    NO    |
| **`SABOTAGE-001`**  | `LOG-SABOTAGE-001`    |       NO        | **YES** (trace)   |    NO    |
| **`ESPIONAGE-004`** | `LOG-ESP-004A`, `B`   |     **YES**     | **YES** (isolate) |    NO    |

---

## 📅 Shift 12: Friday (Total War)
| Ticket ID                     | SIEM Logs (Evidence) | Email Analyzer? | SOC Terminal         | Decrypt? |
|:------------------------------|:---------------------|:---------------:|:---------------------|:--------:|
| **`ZERODAY-001`**             | `LOG-ZD-001A`, `B`   |     **YES**     | **YES** (scan/iso)   |    NO    |
| **`KILL-SWITCH-001`**         | `LOG-KILL-SWITCH-001` |       NO        | **YES** (trace/term) |    NO    |
| **`ZERODAY-004`**             | `LOG-ZD-02B`         |     **YES**     | NO                   |    NO    |
| **`ZERODAY-002`**             | `LOG-ZD-01A`         |     **YES**     | **YES** (term)       |    NO    |
| **`CORE-MELTDOWN-001`**       | `LOG-CORE-MELTDOWN-001` |       NO        | **YES** (isolate)    |    NO    |
| **`ZERODAY-003`**             | `LOG-ZD-002A`, `B`   |     **YES**     | **YES** (isolate)    |    NO    |
| **`ADMIN-LOCKOUT-001`**       | N/A                  |       NO        | NO                   | **YES**  |
| **`ZERODAY-005`**             | `LOG-ZD-03C`         |     **YES**     | **YES** (isolate)    |    NO    |
| **`BLACK-TICKET-REDEMPTION`** | All Indicators       |       NO        | NO                   |    NO    |

---

## 🚩 Dynamic Consequence Tickets (Error Recovery)
These tickets spawn automatically when the player makes a procedural or technical error.

| Ticket ID | Context | SIEM Evidence | Terminal Command |
| :--- | :--- | :--- | :--- |
| **`SERVICE-OUTAGE-FOLLOWUP`** | Isolated a critical server | N/A | `restore [hostname]` |
| **`AUDIT-PROC-001`** | Isolated without scanning | Original Threat Log | `scan` (post-facto) |
| **`MALWARE-CLEANUP-FOLLOWUP`**| Approved malicious email | Malware Beacon | `scan` then `isolate` |
| **`DATA-BREACH-CRITICAL`** | Approved spear-phishing | Exfil Logs | `trace` then `isolate` |
