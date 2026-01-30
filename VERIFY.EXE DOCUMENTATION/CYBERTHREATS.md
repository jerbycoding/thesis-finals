# 🌐 Real-World Cyber Threats in VERIFY.EXE

**VERIFY.EXE** gamifies real-world cybersecurity concepts. This document maps the in-game incidents to their real-world counterparts, providing context on the threats players are simulating.

---

## 1. Phishing & Spear Phishing
**In-Game ID:** `PHISH-00X`, `SPEAR-PHISH-00X`
*   **Real-World Threat:** **Social Engineering.** Attackers send fraudulent communications that appear to come from a reputable source (like a CEO or Vendor).
*   **Game Mechanic:** Players use the **Email Analyzer** to inspect SPF/DKIM headers (email authentication protocols) and check link domains against a blacklist.
*   **Real-World Parallel:** SOC analysts analyze email headers to verify sender identity and sandbox attachments to detect malicious payloads.

## 2. Ransomware
**In-Game ID:** `RANSOM-00X`
*   **Real-World Threat:** **Data Encryption.** Malware that encrypts a victim's files, rendering them inaccessible until a ransom is paid.
*   **Game Mechanic:** Players must `isolate` the infected server immediately to stop the spread and use a specific **Decryption Tool** (simulating a private key retrieval) to restore data.
*   **Real-World Parallel:** Incident responders rush to disconnect infected machines from the network to prevent the ransomware from moving laterally to backups or critical servers.

## 3. Lateral Movement
**In-Game ID:** `MALWARE-CONTAIN-00X`, `LATERAL_MOVEMENT` (Event)
*   **Real-World Threat:** **Network Propagation.** Once an attacker gains initial access (e.g., via Phishing), they move through the network to find high-value targets.
*   **Game Mechanic:** The **Network Map** visualizes the infection spreading from host to host. Players must identify the "Patient Zero" and cut off the path.
*   **Real-World Parallel:** Analysts use SIEM logs to track user authentication anomalies (e.g., a receptionist logging into a database server) to spot an attacker moving sideways.

## 4. DDoS (Distributed Denial of Service)
**In-Game ID:** `DDOS-MITIGATION-00X`
*   **Real-World Threat:** **Service Disruption.** Flooding a target with traffic to overwhelm it and take it offline.
*   **Game Mechanic:** The **Terminal** is used to `trace` the source of the flood. In-game, this is often an internal botnet (compromised devices inside the building).
*   **Real-World Parallel:** Security teams monitor traffic volume and use firewalls or sinkholing to block malicious IP ranges during an attack.

## 5. Shadow IT
**In-Game ID:** `SHADOW-IT-00X`
*   **Real-World Threat:** **Unauthorized Software.** Employees using unapproved applications (e.g., personal Dropbox, unauthorized VPNs) which bypass corporate security controls.
*   **Game Mechanic:** Players detect large outbound data transfers to non-corporate domains via the **SIEM**.
*   **Real-World Parallel:** IT departments audit installed software and network traffic to ensure compliance and prevent data leaks through unsecure channels.

## 6. Supply Chain Attack
**In-Game ID:** `SUPPLY-CHAIN-00X`
*   **Real-World Threat:** **Third-Party Compromise.** Attacking an organization by compromising a trusted vendor or software provider.
*   **Game Mechanic:** An update from a "Trusted Vendor" contains a hidden backdoor. The player must realize that the source, while trusted, is behaving maliciously.
*   **Real-World Parallel:** Famous incidents like SolarWinds, where attackers inserted malware into a legitimate software update, compromising thousands of organizations who trusted the vendor.

## 7. Insider Threat
**In-Game ID:** `INSIDER-00X`
*   **Real-World Threat:** **Malicious Employee.** A current or former employee abusing their authorized access to harm the organization.
*   **Game Mechanic:** Players must investigate logs of users accessing files they shouldn't, or accessing systems at unusual hours (e.g., 3 AM login).
*   **Real-World Parallel:** User Behavior Analytics (UBA) are used to detect anomalies in standard user patterns that indicate data theft or sabotage.

---

## 🛡️ The "Kill Chain" Concept
The game's progression system is based on the **Cyber Kill Chain** framework developed by Lockheed Martin.
1.  **Reconnaissance** (Scanning logs)
2.  **Weaponization** (Phishing email creation)
3.  **Delivery** (Sending the email)
4.  **Exploitation** (User clicks link)
5.  **Installation** (Malware installs)
6.  **Command & Control** (Beaconing to attacker)
7.  **Actions on Objectives** (Data Exfiltration/Ransomware)

**VERIFY.EXE** challenges the player to break this chain at the earliest possible stage.
