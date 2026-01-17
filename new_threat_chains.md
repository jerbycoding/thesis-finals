# New Threat Chain Expansions

This document details three new threat types that can be implemented using the **current codebase** (SIEM, Email, Terminal) without requiring new mechanics. These expand the game's variety beyond Ransomware and Exfiltration.

---

## 🌊 Chain 3: The Service Siege (DDoS)
*Theme: Overwhelming Force vs. Strategic Sacrifice*

**Concept:** The attacker isn't trying to steal data; they are trying to break the infrastructure. The player must choose between "keeping the site up" (risking a crash) or "taking it offline" (guaranteed outage).

### Stage 1: The Botnet Wake-Up (SIEM)
*   **Ticket:** `DDoS-PING-001` (High Latency)
*   **Evidence:** SIEM logs showing `PING` requests from 50 different countries in 1 second.
*   **Player Action:** Identify it's a botnet check, not normal traffic.
*   **Failure Consequence:** The botnet receives the "Attack" command.

### Stage 2: The Flood (Terminal)
*   **Ticket:** `DDoS-FLOOD-001` (Service Degradation)
*   **Narrative:** `WEB-SRV-01` CPU is at 100%. Customers are complaining.
*   **Tool:** Terminal `status` and `scan`.
*   **Player Action:** Realize you cannot block 50,000 IPs one by one.
*   **Resolution:** You must use `isolate WEB-SRV-01`.
*   **The Twist:** Isolating the server **saves the hardware** but **kills the service**. It feels like a loss, but it's the only way to survive.
*   **Failure Consequence:** The physical server hardware overheats/crashes. Permanent damage.

---

## 👔 Chain 4: Business Email Compromise (BEC)
*Theme: Social Engineering / The "Human" Hack*

**Concept:** A text-based puzzle. No malware, no viruses. Just lies. The scanners will report "Clean" because the email contains no code.

### Stage 1: The Setup (Email)
*   **Ticket:** `FRAUD-001` (Urgent Wire Transfer)
*   **The Email:** From `CFO <accounts@partner-vendor.com>`.
    *   *Body:* "Hey, we changed our bank. Wire the Q4 payment here ASAP or we stop shipping."
*   **The Trap:** Clicking "Scan Links" or "Scan Attachments" returns **SAFE**.
*   **Player Action:** Player must read the headers and notice the domain `partner-vendor.com` was registered **yesterday** (in the clues).
*   **Resolution:** Quarantine.
*   **Failure Consequence:** Money is wired to a thief.

### Stage 2: The Cover-Up (SIEM)
*   **Ticket:** `LOG-DELETION-001` (Suspicious Admin Activity)
*   **Narrative:** The attacker (who has the CFO's password from a previous breach) logs in to delete the email trail.
*   **Evidence:** `SecurityLog Cleared` event in SIEM.
*   **Player Action:** Detect the deletion event.
*   **Failure Consequence:** The company loses the money AND the proof. Insurance won't pay.

---

## 💉 Chain 5: SQL Injection (The Web Hack)
*Theme: Technical Precision*

**Concept:** Attacks hidden inside legitimate-looking text requests. Requires reading the "Message" field of logs closely.

### Stage 1: The Probe (SIEM)
*   **Ticket:** `WEB-ERROR-001` (404 Spikes)
*   **Evidence:** Logs showing `GET /login?user=' OR '1'='1`.
*   **The Trap:** It looks like a normal "User Login Failed" event at a glance.
*   **Player Action:** Recognize the SQL syntax (`' OR`) in the log message.
*   **Failure Consequence:** The probe succeeds. They find a vulnerable table.

### Stage 2: The Dump (Terminal/SIEM)
*   **Ticket:** `DB-LEAK-001` (High Database Load)
*   **Narrative:** The database is sending thousands of rows of text to an external IP.
*   **Player Action:**
    1.  Use `scan DB-SRV-01` to confirm it's running a rogue query.
    2.  Use `isolate DB-SRV-01` to kill the connection.
*   **Failure Consequence:** User passwords leaked. Reputation destroyed.

---

## 🧩 Summary of New Mechanics (Using Old Tools)

| Chain | The "Skill Check" |
| :--- | :--- |
| **DDoS** | **Decision Making.** Realizing you can't "win", you can only minimize damage. |
| **BEC** | **Reading Comprehension.** Ignoring the "Green/Safe" indicators and trusting your gut. |
| **SQLi** | **Pattern Recognition.** Spotting code syntax inside text logs. |
