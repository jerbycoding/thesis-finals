# Shift Campaign Documentation

This document outlines the **5-Day Narrative Campaign** for VERIFY.EXE. The game is structured as a single work week (Monday to Friday), with each day introducing new mechanics, threats, and escalating difficulty.

---

## 📅 Weekly Schedule Overview

| Shift | Theme | Focus | Narrative Goal | Difficulty |
| :--- | :--- | :--- | :--- | :--- |
| **Monday** | *Onboarding* | Email Analysis | Establish baseline "Normal". Teach UI & Protocol. | 🟢 Easy |
| **Tuesday** | *Noise* | SIEM Filtering | Introduce "False Flags" and log fatigue. | 🟡 Medium |
| **Wednesday** | *Incursion* | Terminal (Isolation) | The first major breach attempt (Malware). | 🟠 Hard |
| **Thursday** | *Betrayal* | Cross-Reference | Insider Threat. Connecting separate data points. | 🟠 Hard |
| **Friday** | *Zero Day* | Crisis Management | All systems fail. Survive the shift. | 🔴 Critical |

---

## 📋 Daily Breakdown

### **Shift 1: Monday (Onboarding)**
*The calm before the storm. The player learns to use the Email Analyzer and handle low-level tickets.*
*   **Events:**
    *   `T+00:30`: **SYS-MAINT-GENERIC** (Low). *Tutorial Ticket: Teaching Compliant Resolution.*
    *   `T+01:30`: **PHISH-001** (Medium). *First Real Threat: Simple email block.*
    *   `T+03:00`: **AUTH-FAIL-GENERIC** (Low). *Introduction to SIEM logs.*

### **Shift 2: Tuesday (Noise)**
*Volume increases. The system introduces "False Flag" events that flood the logs, forcing the player to filter noise.*
*   **Events:**
    *   `T+00:30`: **SOCIAL-001** (Medium). *Fake IT Calls.*
    *   `T+01:30`: **EVENT: FALSE_FLAG**. *Log Flood begins.*
    *   `T+02:00`: **SPEAR-PHISH-001** (High). *The Trap: A dangerous email hidden in the flood.*
    *   `T+04:00`: **SYS-MAINT-GENERIC** (Low). *Distraction.*

### **Shift 3: Wednesday (Outbreak)**
*Action day. The phishing attempts from Monday/Tuesday have matured into a Malware beacon. The Terminal is required.*
*   **Events:**
    *   `T+00:15`: **MALWARE-CONTAIN-001** (Critical). *Kill Chain A (Stage 2).*
    *   `T+01:00`: **PHISH-001** (Medium). *Second Wave.*
    *   `T+03:00`: **RANSOM-001** (Critical). *Kill Chain A (Stage 3) / Boss Fight.*

### **Shift 4: Thursday (Betrayal)**
*Deduction day. A trusted user turns rogue. The player must connect Auth logs with File Access logs.*
*   **Events:**
    *   `T+00:30`: **AUTH-FAIL-GENERIC** (Low). *Brute Force attempt.*
    *   `T+02:00`: **INSIDER-001** (High). *Kill Chain B (Stage 2).*
    *   `T+03:30`: **SPEAR-PHISH-001** (High). *Targeting the CEO.*

### **Shift 5: Friday (Zero Day)**
*Survival mode. The consequences of the week culminate in a massive coordinated attack.*
*   **Events:**
    *   `T+00:10`: **DATA-EXFIL-001** (Critical). *Kill Chain B (Stage 3).*
    *   `T+00:45`: **RANSOM-001** (Critical). *Distraction.*
    *   `T+01:30`: **MALWARE-CONTAIN-001** (Critical). *Lateral Movement.*
    *   `T+02:00`: **BLACK-TICKET-REDEMPTION**. *If Reputation is Low.*

---

## ⚡ Consequence Carryover Logic
*How failure on one day affects the next.*

1.  **Monday Failure:** Ignoring `PHISH-001` -> Spawns an **extra** `MALWARE-CONTAIN-001` in Tuesday or Wednesday.
2.  **Wednesday Failure:** Ignoring `MALWARE-CONTAIN-001` -> Spawns an **extra** `RANSOM-001` in Thursday.
3.  **Thursday Failure:** Ignoring `INSIDER-001` -> Accelerates the `DATA-EXFIL-001` in Friday (starts at T+0s instead of T+10s).
