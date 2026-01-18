# System Documentation: Consequence Engine & Kill Chain

The **Consequence Engine** (`autoload/ConsequenceEngine.gd`) is the "Invisible Game Master" of *VERIFY.EXE*. It monitors player behavior, calculates systemic risk, and manages the progression of cyberattacks (The Kill Chain).

---

## 1. How Consequences Work
In *VERIFY.EXE*, every action has a ripple effect. Consequences are rarely immediate; they are usually "scheduled" to occur minutes or even days later, simulating the delayed nature of real-world security breaches.

### The Core Logic
When a player resolves a ticket, the engine evaluates:
1.  **Resolution Type:** Did you follow protocol (`Compliant`) or cut corners (`Efficient`/`Emergency`)?
2.  **Evidence Quality:** Did you attach the required logs?
3.  **Hidden Risks:** Did the ticket have indicators of a deeper threat that you ignored?

---

## 2. Kill Chain Escalation
The engine manages a 3-stage **Kill Chain**. Failures at an early stage lead to more catastrophic incidents later.

### Escalation Probabilities
Risk is determined by the **Resolution Protocol** used:

| Protocol | Risk Level | Description |
| :--- | :--- | :--- |
| **Compliant** | 0% | Threat fully contained. No escalation. |
| **Efficient** | 50% | Moderate risk. Threat might persist or pivot. |
| **Emergency** | 75% | High risk. Threat likely persists; immediate follow-up required. |
| **Timeout** | 100% | Critical failure. The attack proceeds to the next stage immediately. |

### The Stages
-   **Stage 1 (Delivery):** Initial entry (e.g., Phishing). Successful resolution stops the chain.
-   **Stage 2 (Persistence):** The threat has a foothold (e.g., Malware).
-   **Stage 3 (Impact):** Critical damage (e.g., Ransomware). Failure here leads to the "Redemption" or "Game Over" path.

---

## 3. Hidden Risks & Follow-up Tickets
Tickets can contain `hidden_risks`. If a player resolves a ticket using `Efficient` or `Emergency` mode without sufficient evidence, the engine scans these risks for keywords to generate specific follow-up tickets:

-   **"Malware" / "Clicked":** Triggers a `MALWARE-CLEANUP` ticket.
-   **"Breach" / "Data":** Triggers a `BREACH-REPORT` ticket.
-   **None Found:** Defaults to a standard `FOLLOWUP-001` audit.

---

## 4. NPC Relationship Behavior
The engine maintains a `npc_relationships` dictionary. Decision patterns shift NPC trust:

| NPC | Values... | Penalized By... |
| :--- | :--- | :--- |
| **CISO** | Security & Compliance | Ticket timeouts, Data loss, "Efficient" spamming. |
| **Senior Analyst** | Accuracy & Forensics | Missing "Compliant" evidence, "Emergency" spamming. |
| **IT Support** | System Uptime | Isolating critical servers, blocking legitimate emails. |

---

## 5. Summary of System Behavior
1.  **Choice Logging:** Every ticket resolution and email decision is stored in `choice_log`.
2.  **Periodic Evaluation:** Every 15 seconds, the engine evaluates the log for behavioral patterns.
3.  **Persistence:** Consequences survive scene changes but are cleared/re-evaluated when loading a saved game to prevent "unwinnable" loops.
4.  **Redemption:** If a player reaches Stage 3 of a Kill Chain, the engine spawns a **Black Ticket** (`TicketBlackRedemption.tres`)—a final, high-difficulty chance to save the organization.
