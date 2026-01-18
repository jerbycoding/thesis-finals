# Content Pack 1: The Mundane & The Malicious

This pack focuses on adding "background noise" to the SOC environment. High volume of generic content forces the player to filter through irrelevant data to find real threats.

## 📧 Generic Emails (Noise)

| ID | Sender | Subject | Description |
| :--- | :--- | :--- | :--- |
| `EMAIL-NOISE-001` | HR Dept | Cake in the breakroom! | Someone had a birthday. There is free cake. |
| `EMAIL-NOISE-002` | Facilities | Printer Jammed: Floor 2 | Warning about a malfunctioning printer. |
| `EMAIL-NOISE-003` | Admin | Quarterly Employee Survey | A reminder to fill out a mandatory survey. |
| `EMAIL-NOISE-004` | Security | Lost Badge Found | Someone left their badge in the parking lot. |
| `EMAIL-NOISE-005` | IT Operations | Free Pizza Friday | Announcement for team lunch. |
| `EMAIL-NOISE-006` | HR Dept | Update your employee profile | Standard administrative request. |
| `EMAIL-NOISE-007` | Facilities | Coffee machine maintenance | Out of order notice. |
| `EMAIL-NOISE-008` | Compliance | IT Policy Reminder | Yearly reminder of security policies. |

## 📋 Security Logs (System Noise)

| ID | Source | Category | Message |
| :--- | :--- | :--- | :--- |
| `LOG-NOISE-101` | UpdateAgent | System | Software update installed successfully: KB500123. |
| `LOG-NOISE-102` | Auth | Security | User 'm.smith' login success from 10.0.4.12. |
| `LOG-NOISE-103` | PrintServer | System | Document 'Project_A_Draft.pdf' printed on Floor 2. |
| `LOG-NOISE-104` | DHCP | Network | Lease renewed for client 10.0.5.88 (WORKSTATION-88). |
| `LOG-NOISE-105` | AV-Agent | Security | Scheduled quick scan completed. No threats found. |
| `LOG-NOISE-106` | BackupMgr | System | Incremental backup task initiated for FileServer-01. |
| `LOG-NOISE-107` | NTP | System | System clock successfully synchronized with time.nist.gov. |
| `LOG-NOISE-108` | Spooler | System | Print job 'Invoice_2025.xlsx' queued for USER-82. |

## 🎫 Optional "Noise" Tickets

| ID | Title | Severity | Tool |
| :--- | :--- | :--- | :--- |
| `TICKET-NOISE-001` | Account Lockout: Forgotten Password | Low | SIEM |
| `TICKET-NOISE-002` | New Hardware Request: Monitor | Low | Email |
