# 📄 WEEK 1: "The Infiltration" (Content Audit)

**Theme:** Onboarding -> Escalation -> Crisis -> Recovery.
**Goal:** Teach the player the tools, introduce the 3 Kill Chains, and survive the Friday "Zero Day."

---

#### 📅 **MONDAY: "Active Monitoring"** (Shift 1)
*   **Narrative Arc:** The player arrives. The CISO demands compliance. A known Phishing campaign is active.
*   **Key Tickets:**
    *   `PHISH-001` (Stage 1): The "Starter" Phish. Sets up the Malware Chain.
    *   `AUTH-FAIL-GENERIC` (Stage 1): Brute force noise. Sets up Account Takeover.
    *   `SPEAR-PHISH-001`: High-priority CEO target.
*   **Mechanic Focus:** Email Analyzer & SIEM.
*   **Audit / Polish Notes:**
    *   *Pacing:* Good intro speed.
    *   *Polish:* `SPEAR-PHISH-001` feels isolated. **Suggestion:** Make the CEO mention this email in a dialogue later if you save him.

#### 📅 **TUESDAY: "Noise & Distraction"** (Shift 2)
*   **Narrative Arc:** Users are complaining. IT Support is overwhelmed. The "Social Engineering" threat begins.
*   **Key Tickets:**
    *   `SOCIAL-001` (Stage 1): Phone scam report. Sets up Insider Threat.
    *   `SUPPLY-CHAIN-001` (Stage 1): The "Fake Patch" email.
*   **Mechanic Focus:** **Distraction.** The `FALSE_FLAG` event spawns fake noise logs to hide the real threats.
*   **Audit / Polish Notes:**
    *   *Logic:* `FALSE_FLAG` duration is 90 seconds. **Suggestion:** Ensure this doesn't overlap with a Critical ticket, or it becomes frustratingly hard for Week 1.

#### 📅 **WEDNESDAY: "The Outbreak"** (Shift 3)
*   **Narrative Arc:** The threats from Mon/Tue mature. The first Malware/Ransomware appears.
*   **Key Tickets:**
    *   `MALWARE-CONTAIN-001` (Stage 2): The result of Monday's Phish. Active Beaconing.
    *   `RANSOM-001` (Stage 3): Critical Finance Server encryption.
*   **Mechanic Focus:** **Terminal (Isolation)** & **Decryption Tool**.
*   **Audit / Polish Notes:**
    *   *Intensity:* This is the first "Spike" in difficulty.
    *   *Polish:* The `LATERAL_MOVEMENT` event runs for 120s. Ensure `NetworkState` actually shows infection spreading visually on the Map during this time.

#### 📅 **THURSDAY: "Internal Betrayal"** (Shift 4)
*   **Narrative Arc:** Paranoia. The threat is coming from inside. CISO suspects a leak.
*   **Key Tickets:**
    *   `INSIDER-001` (Stage 2): Result of Tuesday's Social Eng. Jane Doe accessing files.
    *   `SHADOW-IT-001` (Stage 1): Marketing using Dropbox.
*   **Mechanic Focus:** **Network Map** & **SIEM (User Analysis)**.
*   **Audit / Polish Notes:**
    *   *Narrative:* The CISO dialogue here ("Thursday Betrayal") is strong.
    *   *Polish:* `SHADOW-IT-001` is "Low" severity. **Suggestion:** Bump to "Medium" or make it escalate faster to `DATA-EXFIL` to heighten the paranoia.

#### 📅 **FRIDAY: "Zero Day"** (Shift 5)
*   **Narrative Arc:** Total Chaos. The "Big One" hits. All systems fail.
*   **Key Tickets:**
    *   `DATA-EXFIL-001` (Stage 3): The Insider/Auth threat succeeds. Massive data loss.
    *   `RANSOM-002` (Stage 3): Web Server down.
    *   `DDOS-MITIGATION-001` (Stage 3): Infrastructure collapse.
*   **Mechanic Focus:** **Survival.** The `ZERO_DAY` event forces all scan times to 1.5x.
*   **Audit / Polish Notes:**
    *   *Performance:* Heavy load on the EventBus.
    *   *Polish:* Ensure the `WarWall` turns RED immediately when the shift starts. The atmosphere should feel oppressive.

---

#### 🛠️ **WEEKEND: "Recovery"** (Shift 6 & 7)
*   **SATURDAY (Audit):** Physical navigation in Network Hub. `AUDIT` Minigame (Signal Slider).
*   **SUNDAY (Recovery):** Physical navigation in Server Vault. `RECOVERY` Minigame (Hardware Slotting).
*   **Audit / Polish Notes:**
    *   *Transition:* Currently, `ShiftSunday.tres` points `next_shift_id` to `"shift_monday"`. **CRITICAL FIX:** This creates an infinite loop of Week 1. We need to intercept this transition to generate "Week 2."

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
