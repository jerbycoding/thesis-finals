# VERIFY.EXE: Official Playtest Walkthrough & System Guide

Welcome to the **"VERIFY.EXE"** Security Operations Center (SOC) Simulation. This document is designed to guide you through your 7-day tenure as a SOC Analyst.

---

## 🖥️ System Overview (HUD)

### 1. **System Integrity (Organizational HP)**
Located at the top of your workstation and HUD.
*   **100%:** Stable operations.
*   **< 50%:** Warnings triggered.
*   **< 20%:** **CRITICAL STATE.** Screen will pulse red, heartbeats will sound.
*   **0%:** **ORGANIZATIONAL COLLAPSE.** Game Over.

### 2. **Analyst Archetypes (Your Reputation)**
Your decisions determine your career path:
*   **By-the-Book:** High compliance, perfect evidence collection. Slow but safe.
*   **Cowboy:** High speed, skips evidence, accepts risk. Fast but dangerous.
*   **Negligent:** Letting tickets time out. Leads to termination.
*   **Pragmatic:** The balanced path.

---

## 🛠️ Debugger Manager (Tester Shortcuts)
Use these keys to quickly navigate shifts or manipulate the game state during testing:
*   **F1 - F5:** Jump to Weekday shifts (Monday through Friday).
*   **F6 - F7:** Jump to Weekend shifts (Saturday and Sunday).
*   **F8:** **Toggle Integrity Freeze.** Stops the health decay (useful for long investigations).
*   **F9:** **Force Ticket Spawn.** Instantly adds a random incident to your queue.
*   **F10:** **Reveal All Evidence.** Marks every log in the SIEM as "Revealed" (Magenta border).

---

## 🧰 Tools & Workstation Behavior

### 1. **SIEM Log Viewer** (Forensics)
*   **How to use:** Scroll through the log stream. Click a log to open the **Inspector Pane**.
*   **Attaching Evidence:** In the Inspector, select the target ticket from the dropdown and click **"ATTACH TO CASE"**.
*   **Filtering:** Use the top buttons to hide "Noise" logs. "Security" shows alerts; "Critical" shows high-severity threats.

### 2. **Email Analyzer** (Vulnerability Assessment)
*   **Investigation:** Select an email and use the **Inspection Tools** (Headers, Attachments, Links).
*   **Decision:** You must use at least one tool before the Approve/Quarantine buttons unlock.
*   **Impact:** Approving a malicious email or quarantining a CEO's email will trigger immediate Integrity penalties.

### 3. **Terminal** (Active Response)
*   **`scan [hostname]`:** Confirm if a host is infected before taking action.
*   **`isolate [hostname]`:** Disconnects a host. **WARNING:** Isolating a critical server (e.g., FINANCE-SRV-01) without a valid reason will lock your terminal.
*   **`trace [IP]`:** Identifies which internal computer is communicating with a suspicious external IP.
*   **`list`:** Shows all known hostnames in the network.

### 4. **Network Map** (Visual Topology)
*   **Cyan:** Clean | **Orange:** Suspicious | **Red:** Infected | **Gray:** Isolated.
*   **Usage:** Right-click any node to quickly run Terminal commands without typing.

### 5. **Decryption Tool** (Recovery)
*   **Restriction:** Locked by default. Requires an active Ransomware ticket to unlock.
*   **The Puzzle:** Match the 4-code sequence at the top by clicking buttons in the grid. Incorrect clicks reduce your remaining time.

---

## 🏗️ Elevator & Navigation
The elevator is your primary way to reach 3D physical objectives.
*   **Floor 2: EXECUTIVE SUITE:** Talk to the CISO for shift briefings or to request a "Career Reset" via the Black Ticket.
*   **Floor 1: MAIN SOC OFFICE:** Your primary workstation location.
*   **Floor -1: SERVER VAULT:** Sunday's objective. Locate and replace physical server drives.
*   **Floor -2: NETWORK HUB:** Saturday's objective. Audit physical router nodes.

**Interaction:** Walk into the elevator area and press **[E]** to open the floor selector UI.

---

## ⛓️ The Kill Chain (Escalation Logic)
Every ticket has a **Hidden Risk**. 
*   **Compliant Resolution (All evidence attached):** 0% chance of escalation.
*   **Efficient Resolution (No evidence attached):** 50% chance of the attack progressing.
*   **Emergency Override:** 75% chance of escalation.
*   **Timeout:** 100% chance of a severe followup breach.

---

## 📅 Shift Walkthroughs

### **Shift 1: Monday (Active Monitoring)**
*Focus: Learning the investigate-and-attach loop.*
*   **PHISH-001:** Phishing Campaign Alert.
    *   *Task:* Inspect "Verify Your Account" email headers.
    *   *Evidence:* Attach `LOG-PHISH-001` & `LOG-EMAIL-002` from SIEM.
*   **AUTH-FAIL-GENERIC:** Multiple login failures for 'jsmith'.
    *   *Evidence:* Attach `LOG-AUTH-003`.
*   **SPEAR-PHISH-001:** Targeted attack on the CEO.
    *   *Task:* MUST scan the attachment in Email Analyzer.
    *   *Evidence:* Attach `LOG-SPEAR-001`.

### **Shift 2: Tuesday (Noise)**
*Focus: Managing distractions and "False Flag" events.*
*   **SOCIAL-001:** Social Engineering call report.
    *   *Evidence:* Attach `LOG-VOIP-001`.
*   **PHISH-002:** Credential harvesting attempt.
    *   *Evidence:* Attach `LOG-PHISH-002-A` & `LOG-PHISH-002-B`.
*   **SYSTEM EVENT: FALSE_FLAG:** SIEM will flood with fake logs. Filter for "Security" to find real threats.

### **Shift 3: Wednesday (Outbreak)**
*Focus: Active containment using the Terminal.*
*   **MALWARE-CONTAIN-001:** Active beacon from WORKSTATION-45.
    *   *Task:* Open Terminal. `scan WORKSTATION-45`, then `isolate WORKSTATION-45`.
    *   *Evidence:* Attach `LOG-MALWARE-001`.
*   **RANSOM-001:** Ransomware deployment.
    *   *Task:* Isolate FINANCE-SRV-01 immediately.
*   **SYSTEM EVENT: LATERAL_MOVEMENT:** Infections will spread to clean hosts if you don't isolate them fast.

### **Shift 4: Thursday (Betrayal)**
*Focus: Internal threats and anomalies.*
*   **INSIDER-001:** Suspicious access by 'Jane Doe'.
    *   *Task:* Search for "Jane Doe" in SIEM.
    *   *Evidence:* Attach `LOG-JANE-DOE-ACCESS` & `LOG-EXFIL-JANE-DOE`.
*   **VPN-ANOMALY-001:** Impossible travel detected.
    *   *Evidence:* Attach `LOG-VPN-001` & `LOG-VPN-002`.

### **Shift 5: Friday (Zero Day)**
*Focus: Total organizational defense.*
*   **DATA-EXFIL-001:** Massive outbound traffic.
    *   *Task:* Use `trace [Attacker_IP]` in Terminal to find the mole.
*   **DDOS-MITIGATION-001:** Network flood.
    *   *Task:* SIEM will lag. Use Task Manager to see which process is hogging bandwidth.
*   **BLACK-TICKET-REDEMPTION:** Final post-mortem.
    *   *Task:* Requires 5 specific pieces of evidence from across the week.

### **Shift 6: Saturday (Infrastructure Audit)**
*Focus: Physical 3D world navigation.*
*   **Objective:** Head to Floor -2 (Network Hub).
*   **Gameplay:** Use the **Forensic Tablet [TAB]** to identify router anomalies. Physically walk to Routers A-F and perform "Technical Handshakes" (Needle-Lock & Typing minigames).

### **Shift 7: Sunday (Hardware Recovery)**
*Focus: Maintenance and restoration.*
*   **Objective:** Head to Floor -1 (Server Vault).
*   **Gameplay:** Locate "Dead" server drives. Find "Replacement" drives (NVMe or SATA) scattered in the vault. **Pick them up [E]** and **Slot them into the correct Rack [E]**. Sync the hardware using your Tablet.

---

## 🎲 Random Event Pool
These events can happen at any time during a shift:
*   **SIEM_LAG:** SIEM UI becomes sluggish and flickers.
*   **NPC_APPROACH:** CISO or Senior Analyst walks to your desk to talk.
*   **CRYPTO_SPIKE:** CPU usage hits 99%. All 3D monitors in the office flicker orange.
*   **ACCOUNT_LOCKOUT:** Generic noise ticket to clutter your queue.

---

## 🛠️ Pro Tips for Success
1.  **Always use filters:** In the SIEM, click "Security" or "Critical" to save time.
2.  **Right-click is your friend:** You can scan and isolate hosts directly from the **Network Map** by right-clicking their nodes.
3.  **Watch the clock:** If a ticket is nearing 0, use **Emergency Override** to save your Integrity, even if it hurts your reputation.
4.  **Read the Handbook:** Every terminal command and procedure is detailed in the **SOC Handbook** on your desktop.

**End of Guide. Good luck, analyst.**
