# 💻 SOC Desktop Applications

The 2D desktop workstation is the primary interface for investigating and resolving security incidents. Each application is managed by `DesktopWindowManager.gd` using a data-driven registry in `res://resources/apps/`.

---

## 1. Ticket Queue
*   **Purpose:** Lifecycle management of security incidents.
*   **Function:** Displays active alerts, required evidence (logs), and resolution strategy options.
*   **Key Mechanic:** "Evidence Drop Zone." Players must drag logs from the SIEM onto a ticket to justify a "Compliant" closure.

## 2. SIEM Log Viewer
*   **Purpose:** Forensic evidence gathering.
*   **Function:** Aggregates time-stamped system, network, and security logs.
*   **Phase 4 Mechanic:** **SIEM_LAG.** Under certain event conditions or low NPC approval, selecting a log for analysis triggers an artificial retrieval delay.

## 3. Email Analyzer
*   **Purpose:** Investigation of phishing and communication-based threats.
*   **Function:** Inspects headers (SPF/DKIM/DMARC), scans attachments for malware, and analyzes link reputation.
*   **Key Mechanic:** "Decision Logic." Players must perform at least one forensic check before the "Approve/Quarantine" buttons are authorized.

## 4. Terminal
*   **Purpose:** Active network response and containment.
*   **Function:** Command-line tool for `scan` (host analysis), `trace` (IP routing), and `isolate` (disconnecting infected hosts).
*   **Phase 4 Mechanic:** **Legacy Protocol Error.** Legacy hosts (like `XP-PAYROLL`) cannot be scanned and return a protocol error, forcing manual SIEM investigation.

## 5. Network Topology
*   **Purpose:** Real-time situational awareness.
*   **Function:** Visual map of organizational hosts and their current status (Clean, Suspicious, Infected, Isolated).
*   **Key Mechanic:** Displays active "Lateral Movement" spread visually across the subnet.

## 6. Decryption Tool
*   **Purpose:** Ransomware data recovery.
*   **Function:** Hex-code matching puzzle to restore files on encrypted servers.
*   **Restriction:** Only authorized when an active Ransomware incident is in the Ticket Queue.

## 7. SOC Handbook
*   **Purpose:** Documentation and protocol reference.
*   **Function:** Provides standard operating procedures (SOP), tool guides, and incident catalogs.
*   **Data-Driven:** Content is populated from `res://resources/handbook/` resources.

## 8. Task Manager
*   **Purpose:** Real-time performance monitoring.
*   **Function:** Visualizes CPU and Network load.
*   **Narrative Clue:** CPU spikes on specific cores can act as an early warning for hidden Cryptominer infections before a ticket is spawned.

---

## 🛠️ Field Tablet & Maintenance Minigames

Used primarily during weekend shifts, these tools facilitate physical infrastructure maintenance and hardware verification.

### 9. Field Tablet (Forensic Tablet)
*   **Purpose:** Handheld interface for field operations.
*   **Function:** Provides a mobile topology map and checklist for physical maintenance tasks. Launches specialized sync utilities once hardware objectives are met.

### 10. Calibration Minigame
*   **Context:** Saturday Infrastructure Audit.
*   **Mechanic:** A two-phase process triggered by physical router node inspection.
    *   **Phase 1 (Signal Lock):** Player must time a spacebar press to lock a moving needle within a target zone.
    *   **Phase 2 (Handshake):** A high-speed typing sequence to verify the protocol handshake via a procedurally generated hex code.

### 11. RAID Sync Minigame
*   **Context:** Sunday Hardware Recovery.
*   **Mechanic:** Triggered via the Field Tablet once all physical server blades are correctly slotted.
*   **Function:** A grid-based verification puzzle where players must confirm parity on all disk nodes before initiating the master backplane sync.
