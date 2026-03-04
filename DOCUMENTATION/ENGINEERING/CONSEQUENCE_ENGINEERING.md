# Consequence Engineering: Risk & Scripted Triggers

This document explains how to trigger dynamic consequences and scripted narrative events based on player behavior. Use this to create "Reactive" gameplay.

---

## 1. Hidden Risk Logic (Email App)

The `EmailAnalyzer` tracks whether specific forensic tools were used before an email was actioned (Archived/Quarantined).

### **Usage: `quarantine_hidden_risks`**
In an `EmailResource`, you can map a tool to a consequence ID.
```json
@export var quarantine_hidden_risks = {
  "links": "backdoor_persistence",
  "attachments": "missed_c2_payload",
  "headers": "spoofing_ignored"
}
```
*   **How it works:** If the player archives the email **WITHOUT** clicking the "Link Check" button, the system will trigger the `backdoor_persistence` consequence 30-60 seconds later.
*   **Benefit:** This punishes "Lazy" efficient closures where the player identifies the phish but doesn't perform the forensics.

---

## 2. Scripted Ticket Reactions (`on_complete_event`)

Tickets can trigger immediate narrative shifts when they are resolved.

### **Usage: `on_complete_event`**
In a `TicketResource`, set the `on_complete_event` string to any valid `GlobalConstants.EVENTS` or a custom string handled by `NarrativeDirector`.

*   **Example**: Completing a "Ransomware" ticket can have `on_complete_event = "BOSS_APPROACHING"`.
*   **Result**: The moment the ticket is closed, the CISO will physically walk to the player's desk to deliver a briefing.

---

## 3. The Consequence Pool (`GlobalConstants.CONSEQUENCE_ID`)

When an `EMERGENCY` or `TIMEOUT` occurs, the `ConsequenceEngine` selects a follow-up ticket from this library:

| ID | Narrative Result |
| :--- | :--- |
| `MAJOR_BREACH` | Spawns a high-severity forensic investigation. |
| `SERVICE_OUTAGE` | Triggered if a **Critical Host** is isolated without a scan. |
| `PROCEDURAL_VIOLATION` | Spawns an audit ticket from the Compliance Auditor NPC. |
| `DATA_LOSS` | **GAME OVER**: Triggered if exfiltration is ignored for > 5 minutes. |

---

## 4. Engineering "Karma" (Heat vs Integrity)
*   **Integrity (HP)**: A flat resource. 0% = Bankrupt ending.
*   **Heat (Difficulty)**: A technical debt buffer. High heat forces future tickets to use "Inherited" malicious IPs, making them harder to ignore (since you've seen them before).
