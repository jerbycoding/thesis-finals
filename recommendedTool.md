# Recommended Tool Expansions

This document outlines potential new tools and mechanics to expand the existing Kill Chains, adding depth and interactivity to the resolution process.

---

## 1. Decryption Tool (Ransomware Expansion)
**Goal:** Transform the "Ransomware" finale from a simple "Isolate" button into a tense recovery puzzle.

*   **Current Chain:** `Malware` ➡️ `Ransomware (Isolate)` ➡️ *End*.
*   **Expanded Chain:** `Malware` ➡️ `Ransomware (Isolate)` ➡️ **`Decryption (Puzzle)`** ➡️ *End*.
*   **Mechanic:**
    *   After isolating the server, the screen remains locked.
    *   Player opens the **Decryption App**.
    *   **Activity:** Match a rolling key sequence or solving a hex-grid puzzle before a secondary timer (Data Wipe) hits zero.
    *   **Risk:** Failing the puzzle corrupts 20% of the data permanently.

## 2. Traceroute / Network Graph (Data Breach Expansion)
**Goal:** Make "Blocking an IP" require investigation rather than just reading a log.

*   **Current Chain:** `Insider` ➡️ `Exfil (Block IP)` ➡️ *End*.
*   **Expanded Chain:** `Insider` ➡️ **`Trace Route (Terminal)`** ➡️ `Exfil (Block IP)`.
*   **Mechanic:**
    *   The SIEM shows an attacker IP, but it's a Proxy (e.g., a generic cloud provider).
    *   Blocking the Proxy does nothing (attacker switches proxies).
    *   **Activity:** Use `trace [proxy_ip]` in the Terminal to find the **Origin IP**.
    *   **Risk:** Blocking the wrong proxy causes a "Service Outage" for legitimate traffic.

## 3. Hash Analyzer / Sandbox (Phishing Expansion)
**Goal:** Add a "Forensics" step to identifying malicious files, moving beyond simple header checks.

*   **Current Chain:** `Phishing` ➡️ *Block Domain*.
*   **Expanded Chain:** `Phishing` ➡️ **`Sandbox Analysis`** ➡️ *Block Domain*.
*   **Mechanic:**
    *   Email contains a file (e.g., `invoice.pdf`) that passes basic scans.
    *   Player must "Detonate" the file in a Sandbox Tool.
    *   **Activity:** Watch a behavior report (e.g., "File attempted to modify Registry").
    *   **Risk:** Detonating a real file causes a privacy violation penalty.

## 4. Active Directory Admin (Insider Threat Expansion)
**Goal:** Make "Revoking Access" a tactical decision.

*   **Current Chain:** `Auth Fail` ➡️ `Insider` ➡️ *Account Locked*.
*   **Expanded Chain:** `Auth Fail` ➡️ **`User Behavior Analytics (UBA)`** ➡️ `Insider` ➡️ *Lock Account*.
*   **Mechanic:**
    *   The "Insider" looks like a normal user working late.
    *   **Activity:** Compare the user's current access patterns against their "Baseline" in the AD Tool.
    *   **Risk:** Locking a legitimate CEO working late results in an immediate "Angry Call" event.
