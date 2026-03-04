# Shift 1: Discovery-Style Investigation Manual (Refined with Soft Hints)

| Ticket ID          | Discovery Style Description (Narrative Clue + [color=#006CFF]Anchor[/color])                                                                                                              | The Forensic Search Path (Discovery Logic)                                                                                                |
|:-------------------|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:------------------------------------------------------------------------------------------------------------------------------------------|
| **PHISH-001**      | "Multiple users report a credential harvesting [color=#006CFF]EMAIL[/color]. Find the malicious link indicators to identify any employee who successfully engaged with the landing page." | **Email Analyzer** ([b]Link Check[/b]) -> Discover IP `94.156.12.11` -> **SIEM** (Search IP) -> Find `LOG-PHISH-001`.                     |
| **PHISH-INTERNAL** | "A deceptive [color=#006CFF]INTERNAL MEMO[/color] is circulating. It claims to be from IT, but the sender data is suspect. Verify if users interacted with the spoofed domain."           | **Email Analyzer** ([b]Headers[/b]) -> Discover domain `verify-corp.support` -> **SIEM** (Search domain) -> Find `LOG-PHISH-CLICK`.       |
| **AUTH-GENERIC**   | "A user named Smith reported issues during [color=#006CFF]LOGIN[/color]. Search the historical logs to verify if this was a standard forgotten password or a targeted lockout attempt."   | **SIEM** (Search `smith`) -> Locate `LOG-AUTH-003` -> Verify 'Multiple failed login' pattern.                                             |
| **AUTH-BRUTE**     | "An internal [color=#006CFF]MARKETING[/color] workstation is hammering our servers with unauthorized access attempts. Identify the specific host and neutralize its connection."          | **SIEM** (Search `MARKETING`) -> Identify Host `MARKETING-WS-02` -> **Terminal** (`isolate MARKETING-WS-02`).                             |
| **SPEAR-PHISH**    | "The CEO was targeted with a suspicious [color=#006CFF]ATTACHMENT[/color]. Confirm if our automated gateway filters successfully neutralized the malicious payload."                      | **Email Analyzer** ([b]Scan Attachment[/b]) -> Get filename `financial_report.exe` -> **SIEM** (Search filename) -> Find `LOG-SPEAR-001`. |

---

### Analysis of the "Soft Anchor" Strategy
*   **Visual Guidance:** The blue words act as a "breadcrumb" for newbies. If they see [color=#006CFF]EMAIL[/color], they know to click the blue Email app icon.
*   **Cognitive Load:** By highlighting the *type* of data (e.g., [color=#006CFF]ATTACHMENT[/color]) instead of the *name* of the data (e.g., `financial_report.exe`), we force the player to perform the investigation step to get the answer.
*   **Consistency:** Every ticket follows the same visual language, which is easy for educators to teach: "Look for the blue keyword to find your starting point."
