# Hacker Operational Commands

This document outlines the tactical commands available to the Hacker role within the **VERIFY.EXE** terminal.

## 1. Reconnaissance & Analysis

### `list`
*   **Purpose:** Map the local network segment.
*   **Output:** Displays hostnames, current status (ONLINE, THREAT, ISOLATED), and **Vulnerability Score**.
*   **Mechanic:** Hosts that have detected and blocked your previous attacks will show as **[HARDENED]**.

### `scan [hostname]`
*   **Purpose:** Perform deep vulnerability research.
*   **Benefit:** Reveals the Target OS and exact vulnerability percentage.
*   **Trace Cost:** Very Low. Essential for planning before a "Loud" action.

## 2. Infiltration (Initial Access)

### `exploit [hostname]`
*   **Purpose:** Technical force-entry via known software vulnerabilities.
*   **Benefit:** Immediate access (Foothold) upon success.
*   **Risk:** High Trace cost. 
*   **Hardening:** Failing 3 times on the same host results in a **Permanent Lockout** for that host.

### `phish [hostname]`
*   **Purpose:** Social Engineering attack targeting users on the node.
*   **Benefit:** Much lower Trace cost than `exploit`. Higher success rate on "Hardened" servers.
*   **Risk:** Takes time to execute (simulated delivery and user interaction).

## 3. Maneuvering & Stealth

### `pivot [hostname]`
*   **Purpose:** Lateral Movement. Use a compromised host to jump into a protected subnet.
*   **Requirement:** Must already have a Foothold on a node in the same segment.
*   **Benefit:** Bypasses external firewalls.

### `spoof`
*   **Purpose:** Identity Masking.
*   **Benefit:** Reduces the Trace cost of the **very next** offensive action. 
*   **Tactical Advice:** Always `spoof` before running `exploit` or `ransomware`.

## 4. Operational Control

### `submit`
*   **Purpose:** Mission Completion.
*   **Function:** Encrypts the final report and uploads it to the Broker.
*   **Result:** Ends the shift and triggers the **Forensic Correlation (Mirror Mode)** report.

### `help`
*   **Purpose:** System Documentation.
*   **Function:** Lists all commands currently authorized for your session role.
