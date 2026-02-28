# VERIFY.EXE: Analyst Field Manual (Full Shift Roster)

This manual provides the full technical specifications for every Incident Ticket in Week 1. Follow this guide to ensure 100% Compliant resolutions.

---

## 📅 Shift 1: Monday (Focus: Data Correlation)

### [PHISH-001] Phishing Campaign Alert
*   **Description:** Alert: Multiple users report a suspicious email with the subject 'URGENT: Verify Your Account'.
*   **Instruction:** Open the Email Analyzer. Use the **Link Check** tool to reveal the hidden Malicious IP (`94.156.12.11`). Search the SIEM for that IP to see if anyone clicked it. 
*   **Evidence Required:** `LOG-PHISH-001`
*   **Terminal:** N/A

### [AUTH-FAIL-GENERIC] Routine Check: Multiple Failed Logins
*   **Description:** ROUTINE ALERT: A series of failed login attempts was detected for user 'jsmith' earlier this morning.
*   **Instruction:** Search the SIEM Viewer for '**smith**'. Find the cluster of historical logs from 08:15 AM.
*   **Evidence Required:** `LOG-AUTH-003`
*   **Terminal:** N/A

### [PHISH-INTERNAL-001] Investigation: Reported Deceptive Internal Email
*   **Description:** ALERT: Internal Spoofing Detected. Someone is sending emails that look like they come from IT, but the domain is wrong.
*   **Instruction:** Use Email Analyzer to find the fake domain (`verify-corp.support`). Search SIEM for that domain to find the 'User Clicked' log.
*   **Evidence Required:** `LOG-PHISH-CLICK`
*   **Terminal:** N/A

---

## 📅 Shift 2: Tuesday (Focus: Terminal Action)

### [SOCIAL-001] Verify Potential Phone Scam
*   **Description:** Alert: A user reported a call from someone claiming to be 'IT Support' asking for their password.
*   **Instruction:** Search SIEM for user '**jsmith**'. Look for any **Success** login logs that happened during the time of the call.
*   **Evidence Required:** `LOG-VOIP-001`
*   **Terminal:** N/A

### [AUTH-BRUTE-LOCAL] Critical Alert: Internal Account Brute-Force
*   **Description:** CRITICAL: Internal Brute-Force Attack. A computer inside our office is trying to guess passwords.
*   **Instruction:** The ticket identifies `MARKETING-WS-02` as the source. Open the Terminal and cut its access immediately.
*   **Evidence Required:** `LOG-BRUTE-LOCAL`
*   **Terminal Command:** `isolate MARKETING-WS-02`

### [SUPPLY-CHAIN-001] Suspicious Software Update
*   **Description:** Alert: An employee received a link to update their browser from a non-corporate site.
*   **Instruction:** Run a forensic scan on the victim's machine to see if the malicious patch was installed.
*   **Evidence Required:** `LogAVScan`
*   **Terminal Command:** `scan MARKETING-WS-02`

---

## 📅 Shift 3: Wednesday (Focus: Forensic Logic)

### [VPN-ANOMALY-001] Impossible Travel Alert
*   **Description:** CRITICAL: Credential Theft Suspected. Account logged in from NY and Tokyo within minutes.
*   **Instruction:** Use the SIEM to find the **Tokyo** IP address.
*   **Root Cause Required:** `{ip}` (The Tokyo IP found in the log).
*   **Evidence Required:** `LOG-VPN-001`, `LOG-VPN-002`

### [MALWARE-POLY-001] Polymorphic Beacon Detected
*   **Description:** CRITICAL: Infection Spreading. A second workstation has been hit by the malware outbreak.
*   **Instruction:** Use SIEM to identify which Hostname is sending the 'Polymorphic Beacon.'
*   **Root Cause Required:** `{victim_host}` (The hostname of the infected machine).
*   **Terminal Command:** `isolate [hostname]`

### [DDOS-MITIGATION-001] Emergency: Network Slowness
*   **Description:** The network is lagging. One of our servers is being flooded with traffic.
*   **Instruction:** Run `netstat` on the gateway to find the high-volume attacker IP.
*   **Root Cause Required:** `{attacker_ip}`
*   **Terminal Command:** `netstat GATEWAY-01`

---

## 📅 Shift 4: Thursday (Focus: Insider Threats)

### [MOLE-HUNT-001] Conflicting Access Logs
*   **Description:** ALERT: Admin Login Anomaly. Reboot triggered via 'admin' account from an unusual IP.
*   **Instruction:** Search SIEM for '**admin**'. Identify the IP address used for the 02:00 AM login.
*   **Root Cause Required:** `{ip}` (The malicious login IP).

### [SHADOW-IT-002] Critical: Live Data Leak
*   **Description:** CRITICAL: A workstation is uploading gigabytes of data to a personal cloud account.
*   **Instruction:** Open the Terminal and stop the upload immediately.
*   **Terminal Command:** `isolate MARKETING-WS-02`

---

## 📅 Shift 5: Friday (Focus: Zero Day)

### [KILL-SWITCH-001] CRITICAL: Backup Wipe Initiated
*   **Description:** EXTINCTION ALERT: Attackers are deleting our server backups.
*   **Instruction:** Find the attacker's IP in the logs and type it in to save the data. **TIME LIMIT: 90s**.
*   **Root Cause Required:** `{attacker_ip}`

### [CORE-MELTDOWN-001] HVAC Override: Thermal Critical
*   **Description:** THERMAL CRITICAL: Server cooling hacked. hardware damage imminent.
*   **Instruction:** Use the Terminal to kill the attacker's control over the cooling system.
*   **Terminal Command:** `isolate IOT-THERMOSTAT-01`
