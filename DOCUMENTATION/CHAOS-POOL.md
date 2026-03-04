# VERIFY.EXE: Chaos Engine Event Registry

This document details the random event pools for each shift. Use the **Debug HUD (F12)** to monitor the pool and **F9** to manually trigger an entry for testing.

---

## 📅 Shift 1: Monday (Active Monitoring)
*Focus: Low-impact disruptions to introduce the mechanic.*

| Debug Key (HUD)             | Technical ID        | Type   | Effect / Description                                         |
|:----------------------------|:--------------------|:-------|:-------------------------------------------------------------|
| **`random_login_fail`**     | `AUTH-FAIL-GENERIC` | Ticket | Spawns a standard authentication failure alert.              |
| **`account_lockout_noise`** | `TICKET-NOISE-001`  | Ticket | Spawns a routine account lockout/reset request.              |
| **`minor_siem_lag`**        | `SIEM_LAG`          | System | Increases SIEM log retrieval delay for 15 seconds.           |
| **`isp_blip`**              | `ISP_THROTTLING`    | System | Slows down Terminal network commands for 30 seconds.         |
| **`internal_gossip`**       | `GOSSIP_FLOOD`      | System | Spawns multiple non-malicious emails for 60 seconds.         |
| **`peer_checkin`**          | `senior_analyst`    | NPC    | Triggers a remote dialogue check-in from the Senior Analyst. |

---

## 📅 Shift 2: Tuesday (Noise)
*Focus: Tool disruptions and high-priority distractions.*

| Debug Key (HUD)                 | Technical ID        | Type   | Effect / Description                                          |
|:--------------------------------|:--------------------|:-------|:--------------------------------------------------------------|
| **`routine_patching`**          | `SYS-MAINT-GENERIC` | Ticket | Spawns a low-priority system maintenance notification.        |
| **`siem_bottleneck`**           | `SIEM_LAG`          | System | Increases SIEM log retrieval delay for 30 seconds.            |
| **`gossip_distraction`**        | `GOSSIP_FLOOD`      | System | Floods the inbox with non-malicious emails for 45 seconds.    |
| **`unstable_power`**            | `POWER_FLICKER`     | System | Blackout for 3 seconds; **Forces all open windows to close.** |
| **`unauthorized_script_noise`** | `MALWARE-002`       | Ticket | Spawns alert for PowerShell execution. **Requires 2 Evidence**: LOG-MAL-002-A (Heuristic) and LOG-MAL-002-B (C2 IP: 185.12.44.11). |
| **`it_complaint`**              | `it_support`        | NPC    | Triggers a dialogue session with the IT Support NPC.          |

> **💡 TACTICAL NOTE (SHIFT 2):** 
> Tuesday is about **Noise**. The `MALWARE-002` ticket requires identifying both the script execution and its network beacon. 
> **Evidence 1**: Search for "Polymorphic" or "Heuristic" in the SIEM to find the SysMon alert. 
> **Evidence 2**: Search for the C2 IP `185.12.44.11` to find the IDS connection log. Both must be attached to resolve the ticket.

---

## 📅 Shift 3: Wednesday (Outbreak)
*Focus: Lateral movement and hardware performance metrics.*

| Debug Key (HUD)             | Technical ID           | Type   | Effect / Description                                           |
|:----------------------------|:-----------------------|:-------|:---------------------------------------------------------------|
| **`crypto_outbreak`**       | `CRYPTOMINER-HUNT-001` | Ticket | Spawns alert for unauthorized cryptomining on the subnet.      |
| **`cpu_thermal_spike`**     | `CRYPTO_SPIKE`         | System | Triggers artificial load spikes in the **Task Manager** app.   |
| **`infrastructure_strain`** | `ISP_THROTTLING`       | System | Slows down network-dependent Terminal commands for 45 seconds. |
| **`db_query_lag`**          | `SIEM_LAG`             | System | Increases log retrieval delay for 20 seconds.                  |
| **`analyst_tip`**           | `senior_analyst`       | NPC    | Triggers a remote forensic hint from the Senior Analyst.       |

> **💡 TACTICAL NOTE (SHIFT 3):** 
> Wednesday introduces **Lateral Movement**. If a single infected host remains un-isolated during this 180s window, the malware will spread to clean hosts every 10 seconds. 
> **Priority 1**: Use the Terminal `isolate` command on the first red node you see to "Break the Chain" before the Ransomware arrives at 360s.

---

## 📅 Shift 4: Thursday (Betrayal)
*Focus: Insider threats, log obfuscation, and social pressure.*

| Debug Key (HUD)                | Technical ID       | Type   | Effect / Description                                          |
|:-------------------------------|:-------------------|:-------|:--------------------------------------------------------------|
| **`credentials_leak_noise`**   | `TICKET-NOISE-001` | Ticket | Spawns a routine password reset request to clog the queue.    |
| **`log_obfuscation`**          | `FALSE_FLAG`       | System | Floods the SIEM with thousands of fake logs for 45 seconds.   |
| **`rumor_mill`**               | `GOSSIP_FLOOD`     | System | Triggers an internal email surge about suspected leaks (60s). |
| **`unexplained_blackout`**     | `POWER_FLICKER`    | System | 3-second blackout; forces all open windows to close.          |
| **`senior_analyst_suspicion`** | `senior_analyst`   | NPC    | Triggers a dialogue hint regarding internal credential use.   |

> **💡 TACTICAL NOTE (SHIFT 4):** 
> Thursday is about **filtering**. The `FALSE_FLAG` event is designed to hide the "Insider" logs among thousands of routine system events. 
> **Strategy**: Use the SIEM's **Search Bar** immediately. If you search for specific keywords like `HR-PRIVATE` or `DATA-MOVE`, the "False Flag" logs will be hidden and the real evidence will surface.

---

## 📅 Shift 5: Friday (Zero Day)
*Focus: Maximum operational friction and crisis management.*

| Debug Key (HUD)            | Technical ID       | Type   | Effect / Description                                             |
|:---------------------------|:-------------------|:-------|:-----------------------------------------------------------------|
| **`system_panic_glitch`**  | `SIEM_LAG`         | System | Increases SIEM log retrieval delay for 20 seconds.               |
| **`packet_storm`**         | `DDOS_ATTACK`      | System | Slows down network operations and Terminal responsiveness (60s). |
| **`grid_instability`**     | `POWER_FLICKER`    | System | 3-second blackout; forces all open windows to close.             |
| **`global_latency_spike`** | `ISP_THROTTLING`   | System | Slows down network-dependent Terminal commands for 30 seconds.   |
| **`urgent_noise`**         | `TICKET-NOISE-002` | Ticket | Spawns a high-volume hardware request ticket to distract.        |

> **💡 TACTICAL NOTE (SHIFT 5):** 
> Friday is designed to break your workflow. The combination of `SIEM_LAG` and `DDOS_ATTACK` means your primary investigative tools will be at their slowest. 
> **Strategy**: Prioritize the **Ransomware** and **Exfiltration** tickets. Let the `urgent_noise` (Hardware Requests) time out if necessary; the integrity penalty for a low-priority hardware request is worth the time saved to stop a data breach.

---

## 🔍 How to Test
1.  Enter the desired shift via the Main Menu or **F1/F2**.
2.  Press **F12** to open the Debug HUD.
3.  Observe the **"Chaos Pool"** section to verify the keys above are present.
4.  Press **F9** repeatedly to verify that each event triggers its expected effect (e.g., verifying that `unstable_power` actually closes your windows).
