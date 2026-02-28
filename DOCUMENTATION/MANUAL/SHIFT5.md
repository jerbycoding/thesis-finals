# Shift 5: Discovery-Style Investigation Manual (Refined with Soft Hints)

| Ticket ID | Discovery Style Description (Narrative Clue + [color=#006CFF]Search Anchor[/color]) | The Forensic Search Path (Discovery Logic) |
| :--- | :--- | :--- |
| **DATA-EXFIL-001** | "Massive outbound traffic spikes detected. Internal sensors indicate a potential [color=#006CFF]EXFILTRATION[/color] attempt in progress. Identify the source host and block the malicious stream." | **SIEM** (Search `EXFILTRATION`) -> Locate `LOG-EXFIL-001` -> Identify external IP `203.0.113.42` -> **Terminal** (`trace 203.0.113.42`). |
| **KILL-SWITCH-001** | "Extinction alert: Our server backups are being purged in real-time. Identify the remote session executing the [color=#006CFF]RM -RF[/color] command to preserve organizational history." | **SIEM** (Search `RM -RF`) -> Locate `LOG-KILL-SWITCH-001` -> Identify `{attacker_ip}` -> Enter IP in Root Cause box. |
| **RANSOM-002** | "Public services are failing. Multiple reports confirm the [color=#006CFF]WEB-SRV-01[/color] has been encrypted by a known ransomware strain. Isolate the server and initiate emergency restoration." | **SIEM** (Search `WEB-SRV-01`) -> Locate `LOG-RANSOM-002` -> **Terminal** (`isolate WEB-SRV-01`) -> **Decryption Tool**. |
| **CORE-MELTDOWN-001** | "HVAC cooling loops have been manually disabled. The server vault is reporting a [color=#006CFF]THERMAL CRITICAL[/color] status. Neutralize the compromised control sensor before hardware failure occurs." | **SIEM** (Search `THERMAL CRITICAL`) -> Locate `LOG-CORE-MELTDOWN-001` -> Identify Host `IOT-THERMOSTAT-01` -> **Terminal** (`isolate IOT-THERMOSTAT-01`). |
| **DDOS-MITIGATION-001** | "Multiple services are reporting extreme latency. The firewall is flagging a massive [color=#006CFF]UDP FLOOD[/color] targeting our gateways. Identify the external origin IP to mitigate the impact." | **SIEM** (Search `UDP FLOOD`) -> Locate `LogDDoSFlood` -> Identify `{attacker_ip}` -> Enter IP in Root Cause box. |

---

### Analysis of Shift 5 Discovery Strategy
*   **Maximum Urgency:** The anchors for Shift 5 (`EXFILTRATION`, `RM -RF`, `THERMAL CRITICAL`) are high-priority behavioral signatures. This forces the player to act as a crisis responder rather than a routine investigator.
*   **Infrastructure Triage:** By highlighting the `WEB-SRV-01` and `IOT-THERMOSTAT-01`, the player learns to prioritize "Physical" and "Public" assets during a wide-scale breach.
*   **Root Cause Mastery:** The player is now required to input IPs for multiple incidents (`KILL-SWITCH`, `DDOS`), signifying their growth into a Lead Analyst role by the end of Week 1.
