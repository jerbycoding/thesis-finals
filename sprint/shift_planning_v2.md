# Shift Progression Plan (v2): The 5-Day Campaign

This document outlines the redesigned gameplay arc for a 5-Shift structure (Monday - Friday). The goal is to smooth out the difficulty curve, introduce tools progressively, and tell a cohesive story of an escalating Advanced Persistent Threat (APT).

## 📅 Campaign Overview

| Shift | Theme | Primary Mechanic | Narrative Goal | Difficulty |
| :--- | :--- | :--- | :--- | :--- |
| **1. Monday** | *Onboarding* | Email Analysis | Establish baseline "Normal". Teach UI. | 🟢 Easy |
| **2. Tuesday** | *Noise* | SIEM Filtering | Introduce "False Flags" and log fatigue. | 🟡 Medium |
| **3. Wednesday** | *Incursion* | Terminal (Isolation) | The first major breach attempt. Kill Chain A. | 🟠 Hard |
| **4. Thursday** | *Betrayal* | Cross-Reference | Insider Threat. Kill Chain B (Stealth). | 🟠 Hard |
| **5. Friday** | *Burnout* | Crisis Management | All systems fail. Survive the shift. | 🔴 Critical |

---

## 📋 Shift Breakdown & Ticket Schedule

### Shift 1: Monday (The "Clean" Slate)
**Focus:** Learning the Desktop, Email Tool, and basic Ticket submission.
*   **Narrative:** CISO welcomes you. The network is quiet... too quiet.
*   **Tools:** Email Analyzer (Primary), Ticket Queue.
*   **Events:**
    *   `T+00:10`: **CISO Briefing** (Tutorial).
    *   `T+00:30`: **SYS-MAINT-GENERIC** (Low). Teaches "Compliant" resolution with zero risk.
    *   `T+01:30`: **PHISH-001** (Medium). First real threat. Simple email block.
    *   `T+03:00`: **AUTH-FAIL-GENERIC** (Low). Teaches checking logs for passwords.

### Shift 2: Tuesday (The Signal in the Noise)
**Focus:** Learning the SIEM and filtering logs. Introduction of "Efficient" temptation.
*   **Narrative:** IT Support reports glitchy servers. Volume increases.
*   **Tools:** SIEM Viewer (Primary).
*   **Events:**
    *   `T+00:30`: **SOCIAL-001** (Medium). "IT Support" calls. Requires checking VOIP logs.
    *   `T+01:30`: **World Event:** "False Flag" (Log Flood).
    *   `T+02:00`: **SPEAR-PHISH-001** (High). Hidden in the noise of the log flood.
    *   `T+04:00`: **SYS-MAINT-GENERIC** (Low). A distraction.

### Shift 3: Wednesday (The Outbreak)
**Focus:** Action. Using the Terminal to interact with the 3D world (Isolating hosts).
*   **Narrative:** The Phishing from Monday/Tuesday has matured into Malware.
*   **Tools:** Terminal (Primary).
*   **Events:**
    *   `T+00:15`: **MALWARE-CONTAIN-001** (Critical). **Kill Chain A (Stage 2)**. Needs immediate isolation.
    *   `T+01:00`: **PHISH-001** (Medium). A second wave trying to re-infect.
    *   `T+03:00`: **RANSOM-001** (Critical). **Kill Chain A (Stage 3)**. If Malware wasn't stopped, this is harder.

### Shift 4: Thursday (The Insider)
**Focus:** Deduction. Connecting separate data points (User X did Y at Time Z).
*   **Narrative:** The external attacks were a smokescreen for data theft.
*   **Tools:** All Tools (Synthesis).
*   **Events:**
    *   `T+00:30`: **AUTH-FAIL-GENERIC** (Low). Looks normal, but is actually a brute force.
    *   `T+02:00`: **INSIDER-001** (High). **Kill Chain B (Stage 2)**. Jane Doe accesses files.
    *   `T+03:30`: **SPEAR-PHISH-001** (High). CEO targeted again.

### Shift 5: Friday (Zero Day)
**Focus:** Survival. High volume, high consequences.
*   **Narrative:** Massive Exfiltration detected. The adversary is cashing out.
*   **Tools:** Panic Management (Emergency Button becomes viable).
*   **Events:**
    *   `T+00:10`: **DATA-EXFIL-001** (Critical). **Kill Chain B (Stage 3)**. The big one.
    *   `T+00:45`: **RANSOM-001** (Critical). Distraction attack.
    *   `T+01:30`: **MALWARE-CONTAIN-001** (Critical). Lateral movement.
    *   `T+02:00`: **BLACK-TICKET-REDEMPTION** (Critical). Only spawns if reputation is low.

---

## 🛠️ Logic Refinement (The "Clean Up")

To make this work, we need to reset the current `ShiftResource` files.

1.  **Orphan Check:** Ensure every ticket ID listed above exists in `ticketdata.md`.
2.  **Logic Update:**
    *   Modify `Shift1.tres` to remove the "Malware" jump (keep it simple).
    *   Modify `Shift2.tres` to introduce the "Noise" events.
    *   Create `Shift4.tres` and `Shift5.tres` (currently missing).
3.  **Consequence Carryover:**
    *   If `PHISH-001` (Monday) is failed -> Spawns extra `MALWARE` in Tuesday.
    *   If `MALWARE` (Wednesday) is failed -> Spawns extra `RANSOM` in Thursday.

## 📝 Next Steps for Implementation
1.  **Approve Plan:** Confirm this 5-day structure.
2.  **Reset Resources:** Overwrite `Shift1.tres`, `Shift2.tres`, `Shift3.tres` with new data.
3.  **Create New Resources:** Create `Shift4.tres` and `Shift5.tres`.
4.  **Verify:** Run the game and check the `NarrativeDirector` flow.
