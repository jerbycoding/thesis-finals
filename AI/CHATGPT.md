Here are 5 high-fidelity Incident Packages designed for *VERIFY.EXE*. They are meticulously formatted to match your Godot Variable Registry constraints, utilizing authentic SOC terminology to ensure your simulation feels like a genuine, high-stakes Incident Response environment.

---

## Theme: Week 3 - Corporate Espionage

### Incident 1: The Phantom Sync

This incident introduces the player to insider threats and data exfiltration, requiring them to correlate network traffic with compromised internal communications.

**A. The Ticket (TicketResource)**

* **Ticket ID**: ESPIONAGE-001
* **Title**: Unauthorized Encrypted Data Exfiltration Detected
* **Description**: DLP sensors have flagged anomalous outbound traffic originating from `{host}`, assigned to `{victim}`. Massive volumes of encrypted archives are being routed to a drop-server at `{ip}` following a suspicious redirect from `{malicious_url}`.
* **Severity**: High
* **Category**: Insider Threat
* **Analysis Steps**:
* 1. Analyze firewall telemetry for sustained outbound connections.


* 2. Verify the reputation of the external drop-server.


* 3. Isolate the workstation to halt the active data sync.




* **Required Tool**: siem
* **Required Log IDs**: LOG-ESP-01A

**B. The Evidence Log (LogResource)**

* **Log ID**: LOG-ESP-01A
* **Source**: SysMon
* **Message**: `Event ID 3: Network connection detected. Process svchost.exe on {host} spawned curl.exe for sustained bulk upload to destination {ip}.`
* **Severity**: 4

**C. The Email (EmailResource)**

* **Subject**: Project Chimera - Final Specs & NDA
* **Body**: Hey `{victim}`, the external contractors finally approved the design docs. Grab the encrypted specs here before the meeting: `{malicious_url}`. Password is in the secure vault.
* **Headers**: SPF (PASS), DKIM (PASS), DMARC (PASS) *(Note: Sent from a compromised internal account)*
* **Hidden Risk**: `data_loss_critical` (Triggered if the player isolates the host without blacklisting the destination IP, allowing the script to failover to a secondary network).

---

### Incident 2: The C-Suite Proxy

A highly targeted spear-phishing campaign designed to steal executive credentials for lateral movement toward the Domain Controller.

**A. The Ticket (TicketResource)**

* **Ticket ID**: ESPIONAGE-002
* **Title**: Impossible Travel & Suspicious Lateral Movement
* **Description**: An identity protection anomaly was flagged for the account belonging to `{victim}`. Following a visit to `{malicious_url}`, logs show lateral movement originating from `{host}` targeting the corporate Domain Controller via `{ip}`.
* **Severity**: Critical
* **Category**: Unauthorized Access
* **Analysis Steps**:
* 1. Review Office365 logs for MFA bypass or session token theft.


* 2. Track lateral movement attempts using Windows Event Logs.


* 3. Scrutinize the original email payload for credential harvesting domains.




* **Required Tool**: email
* **Required Log IDs**: LOG-ESP-02B

**B. The Evidence Log (LogResource)**

* **Log ID**: LOG-ESP-02B
* **Source**: Office365
* **Message**: `Azure AD Risk Detection: Multiple failed login attempts followed by anomalous Session Cookie reuse for {victim} from external proxy {ip} targeting {host}.`
* **Severity**: 5

**C. The Email (EmailResource)**

* **Subject**: URGENT: Q3 Board Deck Revision Needed
* **Body**: `{victim}`, the board needs these financial changes applied to the deck immediately. Review the redline markup on the secure portal: `{malicious_url}`. Do not forward this.
* **Headers**: SPF (FAIL), DKIM (FAIL), DMARC (FAIL)
* **Hidden Risk**: `lateral_movement_dc` (Triggered if the player deletes the email without revoking the user's active session tokens).

---

## Theme: Week 4 - Zero-Day Apocalypse

### Incident 3: The Gateway Breach

The player must react to an actively exploited zero-day vulnerability in the corporate VPN client, leading directly to a ransomware precursor.

**A. The Ticket (TicketResource)**

* **Ticket ID**: ZERODAY-001
* **Title**: Unauthenticated RCE via VPN Client Exploit
* **Description**: A newly disclosed zero-day vulnerability in our VPN architecture is actively being exploited against `{victim}`. We are observing reverse shell beacons from `{host}` establishing a C2 heartbeat with `{ip}` after a drive-by payload delivery from `{malicious_url}`.
* **Severity**: Critical
* **Category**: Ransomware
* **Analysis Steps**:
* 1. Identify the malicious heartbeat frequency in IDS logs.


* 2. Trace the parent process of the reverse shell.


* 3. Terminate the active C2 connection via terminal commands.




* **Required Tool**: terminal
* **Required Log IDs**: LOG-ZD-01A

**B. The Evidence Log (LogResource)**

* **Log ID**: LOG-ZD-01A
* **Source**: IDS
* **Message**: `ET EXPLOIT VPN Gateway Buffer Overflow RCE detected originating from {ip} targeting {host}, resulting in anomalous outbound traffic.`
* **Severity**: 5

**C. The Email (EmailResource)**

* **Subject**: IT Advisory: Mandatory VPN Client Patch
* **Body**: `{victim}`, please apply the urgent zero-day patch using the silent installer hosted on our emergency CDN: `{malicious_url}`. Failure to comply will result in network quarantine by EOD.
* **Headers**: SPF (PASS), DKIM (FAIL), DMARC (FAIL)
* **Hidden Risk**: `ransomware_encryption_start` (Triggered if the player isolates the host without killing the malicious process first, allowing the ransomware to execute offline).

---

### Incident 4: Poisoned Dependencies

A complex supply-chain attack where developers are targeted via malicious NPM packages, executing obfuscated fileless malware.

**A. The Ticket (TicketResource)**

* **Ticket ID**: ZERODAY-002
* **Title**: Obfuscated Payload Executing in Memory
* **Description**: EDR caught an obfuscated PowerShell payload executing dynamically in memory on `{host}`, assigned to `{victim}`. Threat intel suggests a compromised Node.js package from `{malicious_url}` is downloading a secondary stager to communicate with `{ip}`.
* **Severity**: High
* **Category**: Malware
* **Analysis Steps**:
* 1. Query SysMon for encoded PowerShell execution strings.


* 2. Identify the compromised dependency repository.


* 3. Block the outbound C2 communication at the firewall level.




* **Required Tool**: siem
* **Required Log IDs**: LOG-ZD-02B

**B. The Evidence Log (LogResource)**

* **Log ID**: LOG-ZD-02B
* **Source**: SysMon
* **Message**: `Event ID 1: powershell.exe -NoProfile -ExecutionPolicy Bypass -EncodedCommand executed on {host} establishing connection to {ip}.`
* **Severity**: 4

**C. The Email (EmailResource)**

* **Subject**: Automated Build Failure Alert
* **Body**: CI/CD Pipeline build failed for `{victim}`. Please review the build logs and update the deprecated dependencies listed in the repository documentation at `{malicious_url}` to resolve the conflict.
* **Headers**: SPF (PASS), DKIM (PASS), DMARC (PASS) *(Note: Spoofed automated system notification)*
* **Hidden Risk**: `backdoor_persistence` (Triggered if the player flags the email as spam but fails to comb the SIEM logs for the scheduled task persistence mechanism).

---

### Incident 5: The Zero-Click Web Shell

The climax of the week, simulating an aggressive Exchange Server vulnerability that requires zero user interaction.

**A. The Ticket (TicketResource)**

* **Ticket ID**: ZERODAY-003
* **Title**: Anomalous Web Shell Activity on Exchange Server
* **Description**: The mail server `{host}` is exhibiting severe post-exploitation behavior linked to an inbox belonging to `{victim}`. An unauthenticated zero-click exploit delivered via `{malicious_url}` dropped a web shell, staging internal infrastructure data for exfiltration to `{ip}`.
* **Severity**: Critical
* **Category**: Unauthorized Access
* **Analysis Steps**:
* 1. Scan firewall logs for non-standard port exfiltration.


* 2. Review IIS/Exchange logs for abnormal POST requests.


* 3. Quarantine the web shell directory and block the threat actor IP.




* **Required Tool**: terminal
* **Required Log IDs**: LOG-ZD-03C

**B. The Evidence Log (LogResource)**

* **Log ID**: LOG-ZD-03C
* **Source**: Firewall
* **Message**: `Outbound data exfiltration to {ip} detected from {host} via non-standard port 4444. Payload signature matches known web shell behavior.`
* **Severity**: 5

**C. The Email (EmailResource)**

* **Subject**: Quarantined Messages Release Notification
* **Body**: Hello `{victim}`, our security filters have held 3 unread messages in quarantine. To review and release these legitimate communications, authenticate via the secure mail portal: `{malicious_url}`.
* **Headers**: SPF (FAIL), DKIM (FAIL), DMARC (PASS)
* **Hidden Risk**: `server_root_compromise` (Triggered if the player attempts to delete the email without using the terminal to sever the active reverse shell connection, granting the attacker root privileges).

---

Would you like me to generate a corresponding `GDScript` dictionary or array structure containing these exact variables, so you can easily copy-paste them directly into your Godot project's script files?