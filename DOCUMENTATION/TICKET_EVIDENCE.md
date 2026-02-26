# VERIFY.EXE: Shift-by-Shift Evidence Guide

This document maps every Incident Ticket to its specific shift, required logs, and mandatory tools for a **Compliant** resolution.

---



---

## 📅 Shift 1: Monday (Active Monitoring)
| Ticket ID               | SIEM Logs (Evidence)             | Email Analyzer? | SOC Terminal | Decrypt? |
|:------------------------|:---------------------------------|:---------------:|:-------------|:--------:|
| **`PHISH-001`**         | `LOG-PHISH-001`, `LOG-EMAIL-002` |     **YES**     | NO           |    NO    |
| **`AUTH-FAIL-GENERIC`** | `LOG-AUTH-003`                   |       NO        | NO           |    NO    |
| **`SYS-MAINT-GENERIC`** | `LOG-SYS-004`                    |       NO        | NO           |    NO    |
| **`SPEAR-PHISH-001`**   | `LOG-SPEAR-001`                  |     **YES**     | NO           |    NO    |

---

## 📅 Shift 2: Tuesday (Noise)
| Ticket ID              | SIEM Logs (Evidence)              | Email Analyzer? | SOC Terminal | Decrypt? |
|:-----------------------|:----------------------------------|:---------------:|:-------------|:--------:|
| **`SOCIAL-001`**       | `LOG-VOIP-001`                    |     **YES**     | NO           |    NO    |
| **`SUPPLY-CHAIN-001`** | `LOG-SUPPLY-001`, `LOG-EMAIL-002` |     **YES**     | NO           |    NO    |
| **`SPEAR-PHISH-002`**  | `LOG-SPEAR-002`                   |     **YES**     | NO           |    NO    |

---

## 📅 Shift 3: Wednesday (Outbreak)
| Ticket ID                 | SIEM Logs (Evidence)       | Email Analyzer? | SOC Terminal      | Decrypt? |
|:--------------------------|:---------------------------|:---------------:|:------------------|:--------:|
| **`MALWARE-CONTAIN-001`** | `LOG-MALWARE-001`          |       NO        | **YES** (isolate) |    NO    |
| **`PHISH-003`**           | `LOG-PHISH-003`            |     **YES**     | NO                |    NO    |
| **`RANSOM-001`**          | `LOG-RANSOM-FILE-ACTIVITY` |       NO        | **YES** (isolate) | **YES**  |

---

## 📅 Shift 4: Thursday (Betrayal)
| Ticket ID             | SIEM Logs (Evidence)               | Email Analyzer? | SOC Terminal | Decrypt? |
|:----------------------|:-----------------------------------|:---------------:|:-------------|:--------:|
| **`AUTH-003`**        | `LOG-AUTH-004`                     |       NO        | NO           |    NO    |
| **`INSIDER-001`**     | `LOG-JANE-DOE-A`, `LOG-EXFIL-JANE` |       NO        | NO           |    NO    |
| **`SHADOW-IT-001`**   | `LOG-SHADOW-001`                   |       NO        | NO           |    NO    |
| **`SPEAR-PHISH-003`** | `LOG-SPEAR-003`                    |     **YES**     | NO           |    NO    |

---

## 📅 Shift 5: Friday (Zero Day)
| Ticket ID                 | SIEM Logs (Evidence)               | Email Analyzer? | SOC Terminal            | Decrypt? |
|:--------------------------|:-----------------------------------|:---------------:|:------------------------|:--------:|
| **`DATA-EXFIL-001`**      | `LOG-EXFIL-001`, `LOG-NETWORK-001` |     **YES**     | **YES** (trace)         |    NO    |
| **`RANSOM-002`**          | `LOG-RANSOM-002`                   |       NO        | **YES** (isolate)       | **YES**  |
| **`DDOS-MITIGATION-001`** | `LOG-DDOS-002`                     |       NO        | **YES** (trace/isolate) |    NO    |

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
| **`SERVICE-FLAP-001`** | N/A                  |       NO        | NO                      |    NO    |

---

## 📅 Shift 10: Wednesday (Executive Targets)
| Ticket ID            | SIEM Logs (Evidence) | Email Analyzer? | SOC Terminal      | Decrypt? |
|:---------------------|:---------------------|:---------------:|:------------------|:--------:|
| **`WHALING-001`**    | `LOG-VIP-BEACON-01`  |     **YES**     | NO                |    NO    |
| **`VIP-LAPTOP-001`** | `LOG-VIP-BEACON-01`  |       NO        | **YES** (isolate) |    NO    |
| **`ESP-023`**        | `LOG-O365-001`       |     **YES**     | NO                |    NO    |
| **`ESPIONAGE-002`**  | `LOG-ESP-002A`, `B`  |       NO        | NO                |    NO    |
| **`RANSOM-VIP-001`** | N/A                  |       NO        | **YES** (isolate) | **YES**  |

---

## 📅 Shift 11: Thursday (Paranoia)
| Ticket ID           | SIEM Logs (Evidence)  | Email Analyzer? | SOC Terminal      | Decrypt? |
|:--------------------|:----------------------|:---------------:|:------------------|:--------:|
| **`MOLE-HUNT-001`** | `LOG-MOLE-ADMIN-01`   |       NO        | NO                |    NO    |
| **`ESPIONAGE-001`** | `LOG-ESP-001A`, `B`   |     **YES**     | **YES** (scan)    |    NO    |
| **`LOG-WIPER-001`** | `LOG-WIPER-DELETE-01` |       NO        | **YES** (isolate) |    NO    |
| **`ESPIONAGE-003`** | `LOG-ESP-03A`         |     **YES**     | NO                |    NO    |
| **`SABOTAGE-001`**  | N/A                   |       NO        | **YES** (trace)   |    NO    |
| **`ESPIONAGE-004`** | `LOG-ESP-004A`, `B`   |     **YES**     | **YES** (isolate) |    NO    |

---

## 📅 Shift 12: Friday (Total War)
| Ticket ID                     | SIEM Logs (Evidence) | Email Analyzer? | SOC Terminal         | Decrypt? |
|:------------------------------|:---------------------|:---------------:|:---------------------|:--------:|
| **`ZERODAY-001`**             | `LOG-ZD-001A`, `B`   |     **YES**     | **YES** (scan/iso)   |    NO    |
| **`KILL-SWITCH-001`**         | N/A                  |       NO        | **YES** (trace/term) |    NO    |
| **`ZERODAY-004`**             | `LOG-ZD-02B`         |     **YES**     | NO                   |    NO    |
| **`ZERODAY-002`**             | `LOG-ZD-01A`         |     **YES**     | **YES** (term)       |    NO    |
| **`CORE-MELTDOWN-001`**       | N/A                  |       NO        | **YES** (isolate)    |    NO    |
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
