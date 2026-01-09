# Playtester Checklist & Consequence Guide

## 1. Introduction

This document is a guide for testing the various gameplay mechanics and consequence systems in "Incident Response: SOC Simulator". Its purpose is to verify that player choices lead to the correct and expected outcomes, both positive and negative.

**Your Goal:** Follow the scenarios below for each ticket. Pay close attention to in-game notifications, the terminal output, and whether new tickets appear in your queue after a delay.

---

## 2. Ticket: `PHISH-001` (Phishing Campaign)

This ticket tests the log attachment and evidence-gathering mechanic.

### ✔️ Scenario A: The Compliant Path

1.  **Action:** Open the **SIEM Log Viewer**.
2.  **Action:** Find and select the two required logs:
    *   `LOG-PHISH-001` (Blocked phishing email...)
    *   `LOG-EMAIL-002` (Blocked connection to malicious IP...)
3.  **Action:** From the "Attach to Ticket" section, select the `PHISH-001` ticket and attach **both** logs.
4.  **Action:** Open the **Ticket Queue** app, select `PHISH-001`, and complete it using the "Compliant" option.
5.  **Expected Outcome:** The ticket should be completed successfully. You should receive a positive notification about your compliant resolution. No negative consequences should occur.

### ❌ Scenario B: The Efficient (Non-Compliant) Path

1.  **Action:** Open the **SIEM Log Viewer**.
2.  **Action:** Attach only **one** (or none) of the required logs to the ticket.
3.  **Action:** Open the **Ticket Queue** app, select `PHISH-001`, and complete it using the "Efficient" option.
4.  **Expected Outcome:** The ticket will be marked as complete. However, after a delay (approx. 30-60 seconds), a new, more severe ticket related to a **Malware Outbreak** should appear in your queue. This is because you failed to identify the full scope of the phishing attack.

---

## 3. Ticket: `SPEAR-PHISH-001` (Email Investigation)

This ticket tests the decision-making process within the Email Analyzer and its direct consequences.

### ✔️ Scenario A: The Correct Decision

1.  **Action:** Open the **Email Analyzer**.
2.  **Action:** Find the email with the subject "Confidential: Q4 Financial Review".
3.  **Action:** Use the "Scan Attachments" tool. Verify that it identifies `financial_report.exe` as a **HIGH RISK** file.
4.  **Action:** Click the **"Quarantine"** or **"Escalate"** button.
5.  **Expected Outcome:** You should receive a positive notification ("Malicious email quarantined" or "Email escalated"). No new negative tickets should be generated.

### ❌ Scenario B: The Disastrous Decision

1.  **Action:** Open the **Email Analyzer** and find the "Confidential: Q4 Financial Review" email.
2.  **Action:** Click the **"Approve"** button without performing any investigation.
3.  **Expected Outcome:** A critical notification should appear immediately. After a significant delay (approx. 120 seconds), a new, critical ticket related to a **Data Breach** (`DATA-EXFIL-001`) should appear in your queue.

### ⚠️ Scenario C: The Overly Cautious Decision

1.  **Action:** Open the **Email Analyzer**.
2.  **Action:** Find the legitimate email with the subject "Urgent: Project Update".
3.  **Action:** Click the **"Quarantine"** button on this legitimate email.
4.  **Expected Outcome:** A warning notification should appear. After a delay (approx. 60 seconds), a new, low-priority ticket related to a **User Complaint** should appear in your queue.

---

## 4. Ticket: `MALWARE-CONTAIN-001` (Terminal Operations)

This ticket tests the use of the terminal and the consequences of targeting the wrong host.

### ✔️ Scenario A: The Surgical Strike

1.  **Action:** Open the **Terminal**.
2.  **Action:** Type the command `scan WORKSTATION-45`. Verify the output shows the host is "INFECTED".
3.  **Action:** Type the command `isolate WORKSTATION-45`.
4.  **Expected Outcome:** The `MALWARE-CONTAIN-001` ticket should **automatically complete** as soon as you run the command. You should see a success message in the terminal.

### ❌ Scenario B: The Reckless Mistake

1.  **Action:** Open the **Terminal**.
2.  **Action:** Instead of the correct host, type the command to isolate a critical server, for example: `isolate FINANCE-SRV-01`.
3.  **Expected Outcome:** The terminal output should show a **CRITICAL ALERT** that a production server has been taken offline. After a short delay (approx. 20 seconds), a new, high-priority ticket related to a **Service Outage** should appear in your queue.
