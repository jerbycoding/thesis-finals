# Threat Escalation & Kill Chain Logic

This document details the "Kill Chain" mechanics: how simple, low-severity threats escalate into critical disasters if ignored or mishandled.

## 🔗 The Golden Rule
**"A ignored ticket doesn't go away; it comes back stronger."**

---

## 📈 Escalation Table

| Initial Threat          | Severity     | Player Action (Failure) | Escalation (Consequence)     | Severity       | Narrative Logic                                                |
| :---------------------- | :----------- | :---------------------- | :--------------------------- | :------------- | :------------------------------------------------------------- |
| **PHISH-001**           | 🟡 Medium   | **Ignore / Bypass**     | ➡️ **MALWARE-CONTAIN-001** | 🔴 Critical   | User clicked the phishing link. Malware is now installed.      |
| **MALWARE-CONTAIN-001** | 🔴 Critical | **Ignore / Bypass**     | ➡️ **RANSOM-001**          | ☠️ GAME OVER | Malware spread laterally to the server. Data encrypted.        |
| **SOCIAL-001**          | 🟡 Medium   | **Ignore / Bypass**     | ➡️ **INSIDER-001**         | 🟠 High       | Attacker got a password from the fake IT call. Now logging in. |
| **INSIDER-001**         | 🟠 High     | **Ignore / Bypass**     | ➡️ **DATA-EXFIL-001**      | 🔴 Critical   | Attacker found the files. Now uploading them to the dark web.  |
| **SPEAR-PHISH-001**     | 🟠 High     | **Ignore / Bypass**     | ➡️ **MALWARE-CONTAIN-001** | 🔴 Critical   | CEO compromised. "Fast Track" to malware infection.            |
| **AUTH-FAIL-GENERIC**   | 🟢 Low      | **Ignore / Bypass**     | ➡️ **INSIDER-001**         | 🟠 High       | Brute force succeeded. "Fast Track" to intruder access.        |

---

## 📖 Detailed Chain Breakdown

### 1. The Ransomware Chain (The Loud Path)
*Goal: Disruption & Destruction*

1.  **Stage 1: Delivery (`PHISH-001` / `SPEAR-PHISH-001`)**
    *   **The Threat:** An email with a malicious link or attachment.
    *   **The Fix:** Block the domain/quarantine email.
    *   **If Failed:** The payload downloads. Escalate to Stage 2.

2.  **Stage 2: Installation (`MALWARE-CONTAIN-001`)**
    *   **The Threat:** A "Beacon" signal. The virus is phoning home.
    *   **The Fix:** Isolate the workstation (`WORKSTATION-45`) to cut the cord.
    *   **If Failed:** The virus scans the network for servers. Escalate to Stage 3.

3.  **Stage 3: Action (`RANSOM-001`)**
    *   **The Threat:** The Finance Server locks up. Red screen.
    *   **The Fix:** Isolate Server + Solve Decryption Puzzle.
    *   **If Failed:** All backups are lost. **Game Over.**

### 2. The Data Breach Chain (The Silent Path)
*Goal: Theft & Espionage*

1.  **Stage 1: Reconnaissance (`SOCIAL-001`)**
    *   **The Threat:** Attackers calling employees to get passwords.
    *   **The Fix:** Warn users to hang up.
    *   **If Failed:** Attackers get a valid username/password. Escalate to Stage 2.

2.  **Stage 2: Lateral Movement (`INSIDER-001` / `AUTH-FAIL-GENERIC`)**
    *   **The Threat:** A valid user ("Jane Doe") logs in at 3 AM.
    *   **The Fix:** Lock the account.
    *   **If Failed:** The attacker browses shared folders. Escalate to Stage 3.

3.  **Stage 3: Exfiltration (`DATA-EXFIL-001`)**
    *   **The Threat:** A massive file upload starts.
    *   **The Fix:** Trace IP origin + Block address.
    *   **If Failed:** Secrets leaked. Stock price crashes. **Reputation -50.**

---

## 🛡️ "Fast Track" Vulnerabilities
*Shortcuts that skip Stage 1.*

*   **Weak Passwords (`AUTH-FAIL-GENERIC`)**: If you ignore brute force attempts, the attacker skips "Social Engineering" and goes straight to **Stage 2 (Insider)**.
*   **CEO Whaling (`SPEAR-PHISH-001`)**: If the CEO gets hacked, they have admin rights. The attacker skips "Delivery" and goes straight to **Stage 2 (Malware)** with higher privileges.