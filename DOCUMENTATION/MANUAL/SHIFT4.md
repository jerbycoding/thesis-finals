# Shift 4: Discovery-Style Investigation Manual (Refined with Soft Hints)

| Ticket ID | Discovery Style Description (Narrative Clue + [color=#006CFF]Search Anchor[/color]) | The Forensic Search Path (Discovery Logic) |
| :--- | :--- | :--- |
| **MOLE-HUNT-001** | "System logs recorded a high-level [color=#006CFF]ADMIN[/color] session during off-hours, but the primary account holder was unavailable. Identify the IP origin of the 02:00 AM login to verify if the session was hijacked." | **SIEM** (Search `ADMIN`) -> Locate `LOG-MOLE-ADMIN-01` -> Identify external IP origin `{ip}` -> Enter IP in Root Cause box. |
| **INSIDER-001** | "Automated monitoring has flagged user [color=#006CFF]JSMITH[/color] for accessing restricted directories that fall outside his standard role permissions. Locate the unauthorized folder access event to document the anomaly." | **SIEM** (Search `JSMITH`) -> Locate `LOG-JSMITH-ACCESS` -> Verify unauthorized access to 'HR-PRIVATE' folder. |
| **SHADOW-IT-001** | "Network telemetry indicates persistent outbound traffic to [color=#006CFF]DROPBOX[/color] from the Marketing subnet. Investigate the source workstation to identify the unsanctioned cloud storage usage." | **SIEM** (Search `DROPBOX`) -> Locate `LOG-SHADOW-001` -> Identify Host `MARKETING-WS-02`. |
| **SHADOW-IT-002** | "A data exfiltration threshold has been exceeded on [color=#006CFF]MARKETING-WS-02[/color]. Massive volumes of data are being synced to an external account. Terminate the active session immediately." | **SIEM** (Search `MARKETING-WS-02`) -> Locate `LOG-SHADOW-002` -> **Terminal** (`isolate MARKETING-WS-02`). |
| **SPEAR-PHISH-003** | "Internal communications appear to be compromised. An employee reported a suspicious thread originating from the domain [color=#006CFF]CORP-MAIL.IO[/color]. Verify the legitimacy of the conversation." | **Email Analyzer** ([b]Headers[/b]) -> Discover domain `corp-mail.io` -> **SIEM** (Search `CORP-MAIL.IO`) -> Find `LOG-SPEAR-003`. |

---

### Analysis of Shift 4 Discovery Strategy
*   **Identity-Centric Investigation:** Shift 4 emphasizes that internal threats are tied to specific users (`JSMITH`, `ADMIN`) and specific internal hosts (`MARKETING-WS-02`). The anchors guide the player to focus on identity and location.
*   **Credential Verification:** The `MOLE-HUNT-001` path teaches players to look past the username and scrutinize the IP metadata, reinforcing the "Zero-Trust" principle.
*   **Shadow IT Escalation:** The search for `DROPBOX` leads directly to the host that eventually requires isolation in the follow-up ticket, creating a narrative thread that the player "discovers" through search.
