# Tool Integration & Gameplay Flow Checklist

This document outlines the intended gameplay flow for each major ticket, ensuring that the software tools (SIEM, Email, Terminal) are useful and their context is connected.

---

## 1. Phishing Campaign Alert

- **Ticket File:** `ticket_phishing_01.gd`
- **Objective:** Investigate a report of a phishing campaign and determine its impact.
- **Primary Tool:** SIEM Log Viewer

#### Gameplay Flow & Clue Trail:

1.  ➡️ **Start (Ticket Queue):** The `PHISH-001` ticket appears. Its description mentions users reporting suspicious emails. The steps require checking SIEM logs.
2.  ➡️ **Tool (SIEM):** The player opens the SIEM Viewer. They need to find evidence related to the phishing campaign.
3.  ➡️ **Clues:** The player can find two important logs:
    *   `log_phishing_attempt.gd` ("Blocked phishing email from suspicious domain.")
    *   `log_email_blocked.gd` ("Blocked connection to malicious IP...")
4.  ➡️ **Action:** The player attaches these two logs to the ticket as evidence.
5.  ➡️ **Conclusion:** With the required evidence attached, the player can mark the ticket as "Compliant" and complete it. If they miss a log and choose "Efficient", the `ConsequenceEngine` will trigger a follow-up ticket later.

#### Verification Checklist:
- [/ ] Does the `PHISH-001` ticket appear correctly in the queue?
- [ /] Are `log_phishing_attempt` and `log_email_blocked` available in the SIEM?
- [ /] Can the player successfully attach both logs as evidence?
- [ /] Does completing the ticket with full evidence work as expected?

---

## 2. Spear Phishing Investigation

- **Ticket File:** `ticket_spear_phish.gd`
- **Objective:** Investigate a suspicious email reported by the CEO that contains a dangerous attachment.
- **Primary Tool:** Email Analyzer

#### Gameplay Flow & Clue Trail:

1.  ➡️ **Start (Ticket Queue):** The `SPEAR-PHISH-001` ticket appears. The description specifically mentions an email with an executable attachment.
2.  ➡️ **Tool (Email Analyzer):** The player opens the Email Analyzer to find the email mentioned in the ticket (Subject: "Confidential: Q4 Financial Review").
3.  ➡️ **Action (Inspections):**
    *   The player uses the **"Scan Attachments"** tool. This reveals that `financial_report.exe` is a "HIGH RISK executable file".
    *   The player uses the **"Check Links"** tool. This reveals the `suspicious_ip` (`203.0.113.42`) associated with the email's metadata.
4.  ➡️ **Clue:** The IP address `203.0.113.42` is a critical piece of information that can be used in other tools for further investigation.
5.  ➡️ **Conclusion:** Based on the high-risk attachment, the player should decide to **"Quarantine"** or **"Escalate"** the email. Approving it would trigger a severe consequence.

#### Verification Checklist:
- [ /] Does the `SPEAR-PHISH-001` ticket appear?
- [ /] Is the corresponding email from the "CEO" visible in the Email Analyzer?
- [ /] Does "Scan Attachments" correctly identify the `.exe` as high risk?
- [ /] Does "Check Links" correctly reveal the suspicious IP address?
- [ /] Do the decision buttons (Approve, Quarantine) work?

---

## 3. Malware Containment

- **Ticket File:** `ticket_malware_containment.gd`
- **Objective:** Use the terminal to find and isolate a host that the SIEM has identified as infected.
- **Primary Tools:** Terminal

#### Gameplay Flow & Clue Trail:

1.  ➡️ **Start (Ticket Queue):** The `MALWARE-CONTAIN-001` ticket appears. The description explicitly states that malware was detected on `WORKSTATION-45` and that the terminal must be used.
2.  ➡️ **Tool (Terminal):** The player opens the Terminal.
3.  ➡️ **Action (Commands):**
    *   Player can use `scan WORKSTATION-45` to confirm the host is "INFECTED".
    *   Player must use the command `isolate WORKSTATION-45`.
4.  ➡️ **System Integration:** When the `isolate` command is run, the `TerminalSystem` emits a `command_run` signal. The `TicketManager` is listening for this signal.
5.  ➡️ **Conclusion:** Upon receiving the signal for `isolate` with the correct host (`WORKSTATION-45`), the `TicketManager` automatically marks the `MALWARE-CONTAIN-001` ticket as complete.
6.  ➡️ **Negative Consequence:** If the player isolates the wrong host (e.g., a critical server), the `TerminalSystem` will trigger a "SERVICE OUTAGE" consequence.

#### Verification Checklist:
- [ ] Does the `MALWARE-CONTAIN-001` ticket appear?
- [ ] Does the `scan` command work on `WORKSTATION-45`?
- [ ] Does running `isolate WORKSTATION-45` automatically complete the ticket?
- [ ] Does isolating a different, critical host trigger a negative consequence?

---

## 4. Data Exfiltration (Multi-Tool)

- **Ticket File:** `ticket_data_exfiltration.gd`
- **Objective:** Connect clues from multiple sources to understand a full attack chain involving a data breach.
- **Primary Tools:** SIEM & Email Analyzer (and potentially Terminal)

#### Gameplay Flow & Clue Trail:

This is a more advanced ticket that demonstrates how tools are connected.

1.  ➡️ **Start (Ticket Queue):** The `DATA-EXFIL-001` ticket appears, mentioning a critical data exfiltration alert.
2.  ➡️ **Tool 1 (SIEM):** The player opens the SIEM and finds the `log_exfil_001` log, which states that data was transferred to the external IP `203.0.113.42`.
3.  ➡️ **Clue:** The IP address `203.0.113.42`.
4.  ➡️ **Connecting the Dots:** The player should recognize this IP address.
5.  ➡️ **Tool 2 (Email Analyzer):** The player opens the Email Analyzer and recalls or finds the "Spear Phishing" email. Using the "Check Links" tool on that email reveals the same suspicious IP: `203.0.113.42`.
6.  ➡️ **Conclusion:** The player has now successfully connected two tools. They understand that the spear phishing email led to a system compromise, which in turn led to the data exfiltration event seen in the SIEM. This demonstrates a full understanding of the attack chain.

#### Verification Checklist:
- [ ] Does the `DATA-EXFIL-001` ticket appear?
- [ ] Does the `log_exfil_001` log in the SIEM clearly show the IP address?
- [ ] Does the spear phishing email in the Email Analyzer clearly show the same IP address upon inspection?
- [ ] Is the player able to piece together the narrative from these two distinct tool outputs?
