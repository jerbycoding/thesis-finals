### Incident 1: Week 3 - Corporate Espionage (Phishing Spearhead)

#### A. The Ticket (TicketResource)
- **Ticket ID**: ESPIONAGE-001
- **Title**: Suspicious Executive Impersonation and Data Leak
- **Description**: {victim} reported receiving a targeted email mimicking the CEO, urging immediate review of a confidential merger document via {malicious_url}. Subsequent network logs indicate outbound connections from {host} to {ip}, suggesting potential credential harvesting and exfiltration of proprietary files. Immediate investigation is required to contain the breach and assess stolen intellectual property.
- **Severity**: High
- **Category**: Phishing
- **Analysis Steps**:
  - 1. Inspect email headers for spoofing indicators.
  - 2. Correlate user click events with anomalous outbound traffic.
  - 3. Trace C2 callbacks to confirm actor attribution.
- **Required Tool**: email
- **Required Log IDs**: LOG-EXFIL-01, LOG-C2-01

#### B. The Evidence Log (LogResource)
- **Log ID**: LOG-EXFIL-01
- **Source**: Firewall
- **Message**: Outbound exfiltration attempt detected: {host} transferring encrypted archives to {ip} over HTTPS, volume exceeding 500MB.
- **Severity**: 4

- **Log ID**: LOG-C2-01
- **Source**: IDS
- **Message**: C2 heartbeat from {host} to {malicious_url} observed, with obfuscated PowerShell payload injection.
- **Severity**: 5

#### C. The Email (EmailResource)
- **Subject**: Urgent: Review Attached Merger Proposal Before Board Meeting
- **Body**: Dear {victim},  
As discussed in our last call, please review the attached confidential merger details immediately via this secure link: {malicious_url}. Your input is critical for tomorrow's decision. Best, CEO Johnathan Hale.
- **Headers (SPF/DKIM/DMARC)**: SPF: FAIL, DKIM: PASS, DMARC: FAIL
- **Hidden Risk**: missed_exfil_trigger

### Incident 2: Week 3 - Corporate Espionage (Insider-Assisted Malware)

#### A. The Ticket (TicketResource)
- **Ticket ID**: ESPIONAGE-002
- **Title**: Internal Compromise via Malicious Insider Payload
- **Description**: Anomalous activity on {host} points to an insider threat where {victim} unwittingly executed a trojanized update from {malicious_url}, enabling lateral movement. Logs show unauthorized access to R&D servers from {ip}, risking theft of trade secrets. Containment must prioritize isolating the vector to prevent further espionage.
- **Severity**: Critical
- **Category**: Insider Threat
- **Analysis Steps**:
  - 1. Scan for persistence mechanisms like scheduled tasks.
  - 2. Identify lateral pivots using SysMon process chains.
  - 3. Block C2 domains and monitor for callback flares.
- **Required Tool**: terminal
- **Required Log IDs**: LOG-PERSIST-02

#### B. The Evidence Log (LogResource)
- **Log ID**: LOG-PERSIST-02
- **Source**: SysMon
- **Message**: Persistence established on {host}: Malicious executable from {malicious_url} spawned by {victim}, connecting to {ip} for command retrieval.
- **Severity**: 5

#### C. The Email (EmailResource)
- **Subject**: Critical Software Patch for Your Workstation
- **Body**: Hi {victim},  
IT has identified a vulnerability on {host}. Download and run the patch from {malicious_url} ASAP to avoid downtime. Thanks, IT Support Team.
- **Headers (SPF/DKIM/DMARC)**: SPF: PASS, DKIM: FAIL, DMARC: PASS
- **Hidden Risk**: overlooked_lateral_hop

### Incident 3: Week 3 - Corporate Espionage (Unauthorized Access Chain)

#### A. The Ticket (TicketResource)
- **Ticket ID**: ESPIONAGE-003
- **Title**: Credential Theft and Shadow IT Infiltration
- **Description**: {victim}'s credentials were compromised via a phishing lure from {malicious_url}, leading to unauthorized access on {host} and queries to sensitive databases from {ip}. This appears part of a broader espionage campaign targeting competitor intelligence. Rapid response is essential to revoke access and audit exposed data.
- **Severity**: High
- **Category**: Unauthorized Access
- **Analysis Steps**:
  - 1. Query SIEM for failed login spikes.
  - 2. Analyze CloudTrail for anomalous API calls.
  - 3. Isolate {host} to halt ongoing sessions.
- **Required Tool**: siem
- **Required Log IDs**: LOG-AUTH-03, LOG-API-03

#### B. The Evidence Log (LogResource)
- **Log ID**: LOG-AUTH-03
- **Source**: Office365
- **Message**: Unauthorized authentication success: {victim}'s account from {ip} accessing {host} post-phish click on {malicious_url}.
- **Severity**: 4

- **Log ID**: LOG-API-03
- **Source**: CloudTrail
- **Message**: Anomalous API exfiltration: {host} querying proprietary datasets to {ip}, bypassing standard MFA.
- **Severity**: 5

#### C. The Email (EmailResource)
- **Subject**: Account Verification Required - Action Needed
- **Body**: Hello {victim},  
Your account on {host} requires immediate verification. Click here to confirm: {malicious_url}. Failure to do so may lock you out. Regards, Security Team.
- **Headers (SPF/DKIM/DMARC)**: SPF: FAIL, DKIM: FAIL, DMARC: FAIL
- **Hidden Risk**: ignored_cred_dump

### Incident 4: Week 4 - Zero-Day Apocalypse (Ransomware Outbreak)

#### A. The Ticket (TicketResource)
- **Ticket ID**: ZERO-001
- **Title**: Zero-Day Exploit Triggering Widespread Encryption
- **Description**: A zero-day vulnerability in core software allowed entry via {malicious_url}, encrypting files on {host} and demanding ransom from {ip}. {victim} is the initial vector in what could cascade into a full network lockdown. Urgent decryption analysis and isolation are needed to avert total data loss.
- **Severity**: Critical
- **Category**: Ransomware
- **Analysis Steps**:
  - 1. Identify exploit signatures in IDS logs.
  - 2. Scan for encrypted file patterns on {host}.
  - 3. Block ransom C2 channels to prevent propagation.
- **Required Tool**: terminal
- **Required Log IDs**: LOG-ENCRYPT-04

#### B. The Evidence Log (LogResource)
- **Log ID**: LOG-ENCRYPT-04
- **Source**: IDS
- **Message**: Zero-day exploit detected: {host} vulnerable to CVE-pending, leading to ransomware deployment from {ip} via {malicious_url} accessed by {victim}.
- **Severity**: 5

#### C. The Email (EmailResource)
- **Subject**: Emergency Update: Install Now to Prevent Data Loss
- **Body**: {victim},  
A critical zero-day threat is active. Install this emergency patch from {malicious_url} on {host} immediately. IT Department.
- **Headers (SPF/DKIM/DMARC)**: SPF: PASS, DKIM: PASS, DMARC: FAIL
- **Hidden Risk**: premature_quarantine_loss

### Incident 5: Week 4 - Zero-Day Apocalypse (Malware Pandemic)

#### A. The Ticket (TicketResource)
- **Ticket ID**: ZERO-002
- **Title**: Cascading Zero-Day Malware Infection
- **Description**: {victim} triggered a zero-day malware chain from {malicious_url} on {host}, resulting in self-replicating code contacting {ip} for updates. This could lead to an apocalyptic network overload if not contained. Focus on tracing the infection tree to eradicate the threat.
- **Severity**: Critical
- **Category**: Malware
- **Analysis Steps**:
  - 1. Filter SIEM for PowerShell obfuscation events.
  - 2. Map propagation paths from initial compromise.
  - 3. Quarantine C2 beacons to starve the worm.
- **Required Tool**: siem
- **Required Log IDs**: LOG-PROPAGATE-05, LOG-OBFUSCATE-05

#### B. The Evidence Log (LogResource)
- **Log ID**: LOG-PROPAGATE-05
- **Source**: Firewall
- **Message**: Malware propagation: {host} spreading zero-day payload to internal peers, sourced from {ip} after {victim}'s interaction with {malicious_url}.
- **Severity**: 5

- **Log ID**: LOG-OBFUSCATE-05
- **Source**: SysMon
- **Message**: Obfuscated PowerShell execution on {host}: Command from {malicious_url} evading AV, beaconing to {ip}.
- **Severity**: 4

#### C. The Email (EmailResource)
- **Subject**: Alert: New Vulnerability Discovered - Update Required
- **Body**: Dear {victim},  
We've detected a zero-day issue on {host}. Click {malicious_url} to apply the fix before it spreads. Urgent action needed. Security Ops.
- **Headers (SPF/DKIM/DMARC)**: SPF: FAIL, DKIM: PASS, DMARC: PASS
- **Hidden Risk**: missed_worm_vector