# VERIFY.EXE - Technical Documentation

## 1. Core Architecture: The Event Bus
The project utilizes a **Signal-Driven Architecture** centralized through `autoload/EventBus.gd`. Systems no longer talk to each other directly; they broadcast events to the Bus.

### Key Global Signals
- `ticket_added(ticket)`: Triggered when a new incident enters the queue.
- `ticket_completed(ticket, type, time)`: Triggered on resolution (Compliant, Efficient, Emergency).
- `consequence_triggered(type, details)`: Triggered when a hidden risk or kill-chain escalation occurs.
- `shift_started(id)` / `shift_ended(results)`: Manages the narrative work-day cycle.
- `world_event_triggered(id, active, duration)`: Triggers systemic modifiers like `SIEM_LAG` or `ZERO_DAY`.

---

## 2. The Ticket System
Tickets are the primary gameplay unit, defined by `resources/tickets/TicketResource.gd`.

### Ticket Template Fields
| Field | Type | Description |
| :--- | :--- | :--- |
| `ticket_id` | String | Unique ID (e.g., PHISH-001). |
| `severity` | String | Low, Medium, High, Critical. Affects relationship penalties. |
| `required_tool` | String | The primary app used to solve the ticket (siem, email, terminal). |
| `steps` | Array[String] | Guided instructions shown in the UI (Max 3). |
| `required_log_ids` | Array[String] | List of specific Log IDs required for a "Compliant" closure. |
| `base_time` | Float | Timer duration in seconds. |
| `kill_chain_path` | String | Identifier for narrative branches (e.g., "Malware Outbreak"). |
| `escalation_ticket` | Resource | The next Ticket to spawn if the player fails this stage. |

### Resolution Protocols
1.  **Compliant:** Requires all `required_log_ids` to be attached. Zero risk of hidden consequences.
2.  **Efficient:** Closes immediately. 50% base risk of triggering the `escalation_ticket`.
3.  **Emergency:** Force-closes the ticket. 75% base risk of escalation.
4.  **Timeout:** Automatic failure. 100% risk of escalation.

---

## 3. Consequence Engine & Kill Chain
Managed by `autoload/ConsequenceEngine.gd`. It tracks player choices and handles the "Kill Chain" (delayed systemic failures).

### Kill Chain Stages
- **Stage 1 (Delivery):** Usually a Phishing or Social Engineering ticket.
- **Stage 2 (Exploitation):** Malware installation or data access.
- **Stage 3 (Impact):** Ransomware, Data Exfiltration, or Organizational Collapse.

### NPC Relationships
Player decisions impact trust scores with key NPCs:
- **CISO:** Penalizes for timeouts and data loss. High score leads to "Promotion" ending.
- **Senior Analyst:** Penalizes for "Cowboy" behavior (Efficient/Emergency spamming).
- **IT Support:** Penalizes for isolation of critical servers without scanning.

---

## 4. Threat Catalog (Incidents)
| ID | Category | Description | Tool |
| :--- | :--- | :--- | :--- |
| **PHISH-001** | Phishing | Basic mass phishing campaign. | Email/SIEM |
| **SPEAR-PHISH-001** | Phishing | Targeted attack against the CEO. | Email |
| **MALWARE-CONTAIN-001** | Malware | Active beaconing on a workstation. | Terminal |
| **RANSOM-001** | Ransomware | FINANCE-SRV-01 files encrypted. | Decryptor |
| **DATA-EXFIL-001** | Data Breach | High-volume outbound traffic to external IP. | Terminal |
| **SOCIAL-001** | Social Eng. | Impersonation of IT support via phone/voip. | SIEM |
| **INSIDER-001** | Insider Threat | Terminated employee still accessing files. | SIEM |
| **VPN-ANOMALY-001** | Auth | "Impossible Travel" (Login from NY and Tokyo). | SIEM |
| **DDoS-PING-001** | DDoS | Global botnet latency check. | SIEM |
| **FRAUD-001** | BEC | Targeted wire transfer fraud (Social Eng). | Email |
| **WEB-ERROR-001** | SQLi | Probing attacks hidden in 404 spikes. | SIEM |
| **CRYPTOMINER-HUNT-001** | Malware | High CPU spikes across multiple hosts. | TaskMgr |

---

## 5. Shift Structure (Narrative Director)
Shifts are defined by `resources/shifts/ShiftResource.gd`.

- **Tutorial (Training Simulation):** Guided walkthrough of the ticket lifecycle.
- **Monday (Active Monitoring):** Introduction to standard threats.
- **Tuesday (Noise):** Introduction to `SIEM_LAG` and log floods.
- **Wednesday (Outbreak):** Lateral movement and malware containment.
- **Thursday (Betrayal):** Focus on Insider Threats and VPN anomalies.
- **Friday (Zero Day):** High-intensity chaos leading to the campaign conclusion.

---

## 6. System Registry & Hosts
The network is resource-driven. Every host is a `.tres` file in `res://resources/hosts/`.

### Critical Assets
- **FINANCE-SRV-01:** Critical. Disconnecting triggers a Service Outage.
- **WEB-SRV-01:** Critical. Production server.
- **DB-SRV-01:** Critical. Organizational data.
- **WORKSTATION-45:** Common. Initial infection vector for malware.

---

## 7. Performance Systems
- **UI Object Pooling:** `scripts/ui/UIObjectPool.gd` reuses UI nodes for Logs and Tickets to prevent lag.
- **Ring Buffer Logs:** `LogSystem.gd` prunes non-essential logs to maintain a high-performance stream.
- **Config Manager:** Persistent settings stored in `user://settings.cfg`.
