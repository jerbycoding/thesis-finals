# Gameplay Scenarios & Consequence Logic

This document illustrates specific gameplay scenarios to help visualize the **Risk/Reward** mechanics of the Ticket System. It explains exactly what happens when a player chooses to follow protocol versus when they cut corners.

## ⚙️ How Consequences Work

The **Consequence Engine** runs a check every time a ticket is closed or times out.

1.  **The Trigger:** You submit a ticket (Compliant, Efficient, or Emergency).
2.  **The Calculation:**
    *   **Compliant:** Risk = 0%.
    *   **Efficient:** Risk = ~50% (Coin flip).
    *   **Emergency / Timeout:** Risk = 100% (Guaranteed).
3.  **The Result:**
    *   **Safe:** Ticket closes normally.
    *   **Escalation:** The engine schedules a **Follow-up Ticket** (Next stage of Kill Chain) to spawn in 15-45 seconds.
4.  **The "Ghost" Evidence:** If an escalation occurs, the specific logs you *should* have found earlier are flagged. When the new ticket spawns, those old logs in the SIEM turn **Magenta (Glowing)** to mock you.

---

## 📽️ Scenario 1: The "Lazy" Analyst (Malware Outbreak)
*The player tries to speed-run the game by clicking "Efficient" to save time, but gets bad RNG.*

| Time | Event | Player Action | Internal Logic | Consequence |
| :--- | :--- | :--- | :--- | :--- |
| **00:10** | **PHISH-001** spawns. | Opens ticket. Doesn't check logs. Clicks **Efficient**. | **Roll: FAIL.** Risk triggered. | Noise paused for 60s (Player feels smart). |
| **00:45** | *System Quiet* | Player is relaxing. | `ConsequenceEngine` timer hits 0. | **MALWARE-CONTAIN-001** force-spawns. |
| **00:46** | **New Alert** | Player sees "Malware Beacon". | "Why is this happening?" | Player must now use **Terminal** (harder tool). |
| **00:50** | **Investigation** | Player checks SIEM. | **Evidence Flash:** The old Phishing logs are now **Magenta**. | Player realizes the Phishing email caused this. |
| **01:20** | **Panic** | Timer running low. Clicks **Emergency**. | **Risk: 100%.** | Noise paused for 120s. |
| **02:00** | **Disaster** | *System Quiet* | `ConsequenceEngine` timer hits 0. | **RANSOM-001** spawns. Server Encrypted. |
| **End** | **Result** | **GAME OVER** (Critical Asset Lost). | | |

---

## 📽️ Scenario 2: The "Panic" Button (Data Breach)
*The player is overwhelmed by volume and uses "Emergency" to clear the board, accepting the cost.*

| Time | Event | Player Action | Internal Logic | Consequence |
| :--- | :--- | :--- | :--- | :--- |
| **03:00** | **High Load** | 4 tickets active. Noise is loud. | Stress is maximum. | |
| **03:05** | **SOCIAL-001** spawns. | "I can't deal with this!" Clicks **Emergency**. | **Risk: 100%.** Guaranteed Escalation. | Ticket closes instantly. Noise stops. |
| **03:10** | **Recovery** | Player uses the silence to fix the other 3 tickets properly. | Player gains some reputation back. | The "Social Engineering" threat is effectively "queued." |
| **04:00** | **Retribution** | `ConsequenceEngine` wakes up. | Escalation triggers. | **INSIDER-001** spawns (Jane Doe Access). |
| **04:05** | **Defense** | Player is now ready. Checks SIEM. | Finds `LOG-JANE-DOE-ACCESS`. | |
| **04:30** | **Resolution** | Clicks **Compliant**. | **Risk: 0%.** Chain Broken. | The breach is stopped before Exfiltration. |
| **End** | **Result** | **Survival.** (Sacrificed reputation early to survive the rush). | | |

---

## 📽️ Scenario 3: The "Fast Track" Trap (Spear Phishing)
*The player underestimates a standalone ticket that links to a Stage 2 threat.*

| Time | Event | Player Action | Internal Logic | Consequence |
| :--- | :--- | :--- | :--- | :--- |
| **01:00** | **SPEAR-PHISH-001** | "Just another email ticket." Clicks **Efficient**. | **Roll: FAIL.** | CEO clicks the link. |
| **01:30** | **Escalation** | **MALWARE-CONTAIN-001** spawns immediately. | **Severity: CRITICAL.** | Unlike normal Phishing (Stage 1), this skips straight to heavy malware. |
| **01:35** | **Confusion** | "I thought I closed the email ticket!" | **Evidence Flash:** `LOG-SPEAR-001` glows. | The malware is deep in the network. |
| **02:00** | **Resolution** | Player struggles with Terminal commands. **Timeout.** | **Risk: 100%.** | **RANSOM-001** spawns. |
| **End** | **Result** | **Rapid Spiral.** (Went from email to Ransomware in < 2 minutes). | | |

---

## 📽️ Scenario 4: The "Perfect" Shift (By-The-Book)
*The player plays the way the tutorial taught them.*

| Time | Event | Player Action | Internal Logic | Consequence |
| :--- | :--- | :--- | :--- | :--- |
| **00:10** | **PHISH-001** | checks Headers. Finds spoofing. Clicks **Compliant**. | **Risk: 0%.** | Ticket Closed. No follow-up. |
| **00:20** | **Noise** | Random logs appear. | Player ignores noise. | |
| **01:00** | **SOCIAL-001** | Checks Call Logs. Finds spam calls. Clicks **Compliant**. | **Risk: 0%.** | Ticket Closed. No follow-up. |
| **02:00** | **Shift End** | Queue is empty. | | |
| **End** | **Result** | **Archetype: "By-The-Book".** (High Score, Low Drama). | | |

---

## 🧠 Strategic Takeaways for Testing

1.  **Efficient Spamming:** If you spam "Efficient", the game will seem easy for the first 2 minutes, then impossible for the last 5.
2.  **Emergency usage:** Use "Emergency" as a strategic pause button, but *know* that the enemy is coming back stronger in 60-120 seconds. Be ready for it.
3.  **Visual Cues:** If you see **Magenta/Purple logs** in the SIEM, it means you messed up a previous ticket. Those logs are your hint for the current problem.
