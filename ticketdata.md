# Ticket Analysis Data

This document outlines the configuration of all active tickets in the `resources/tickets/` directory, including their ID, Title, the tool required to solve them, and the specific Log IDs required for a "Compliant" resolution.

## Ticket Catalog

| Ticket ID                   | Title                                     | Required Tool |     | Required Logs (Evidence)                                                                           |
| :-------------------------- | :---------------------------------------- | :------------ | --- | :------------------------------------------------------------------------------------------------- |
| **AUTH-FAIL-GENERIC**       | Multiple Authentication Failures          | `siem`        |     | `LOG-AUTH-003`                                                                                     |
| **BLACK-TICKET-REDEMPTION** | REDEMPTION: Full Forensic Post-Mortem     | `siem`        |     | `LOG-PHISH-001`<br>`LOG-MALWARE-001`<br>`LOG-EXFIL-001`<br>`LOG-AUTH-FAILURE`<br>`LOG-NETWORK-001` |
| **DATA-EXFIL-001**          | Data Exfiltration Alert                   | `siem`        |     | `LOG-EXFIL-001`<br>`LOG-NETWORK-001`                                                               |
| **INSIDER-001**             | Suspicious Data Access: Ex-Employee       | `siem`        |     | `LOG-JANE-DOE-ACCESS`<br>`LOG-EXFIL-JANE-DOE`                                                      |
| **MALWARE-CONTAIN-001**     | Malware Containment Request               | `terminal`    |     | `LOG-MALWARE-001`                                                                                  |
| **PHISH-001**               | Phishing Campaign Alert                   | `siem`        |     | `LOG-PHISH-001`<br>`LOG-EMAIL-002`                                                                 |
| **RANSOM-001**              | Ransomware Alert: Critical Server Locked! | `terminal`    |     | `LOG-RANSOM-FILE-ACTIVITY`                                                                         |
| **SOCIAL-001**              | Social Engineering Attempt Reported       | `none`        |     | `LOG-VOIP-001`                                                                                     |
| **SPEAR-PHISH-001**         | Spear Phishing Investigation              | `email`       |     | `LOG-SPEAR-001`                                                                                    |
| **SYS-MAINT-GENERIC**       | Scheduled System Maintenance              | `siem`        |     | `LOG-SYS-004`                                                                                      |

## Tool Usage Summary

*   **SIEM:** Used for the majority of investigations (6 tickets). Primary source of evidence logs.
*   **Terminal:** Used for active containment and response (2 tickets: Malware & Ransomware).
*   **Email:** Used for deep inspection of specific threats (1 ticket: Spear Phishing).
*   **None:** Used for tickets that rely on external reporting or manual synthesis (1 ticket: Social Engineering).

## Data Integrity Notes

*   **AUTH-FAIL-GENERIC:** Mismatch fixed. Now correctly requires `LOG-AUTH-003`.
*   **SPEAR-PHISH-001:** Loophole closed. Now requires `LOG-SPEAR-001` (newly created).
*   **SOCIAL-001:** Dependency conflict fixed. Now requires `LOG-VOIP-001` (newly created).
*   **DATA-EXFIL-001:** UX issue fixed. Required tool updated to `siem` for critical alert visibility.
