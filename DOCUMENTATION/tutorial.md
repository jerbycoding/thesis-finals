# VERIFY.EXE - Tutorial Design: "The Shadow Shift" (v2.1)

## 1. Design Philosophy: "First Day on the Job"
The tutorial is an immersive, narrative-driven onboarding experience. The player is a new SOC hire shadowing a Senior Analyst (Rivera) who provides diegetic guidance via internal comms and the Runbook Sidebar.

**Core Goal:** Move from simple tool usage to the fundamental SOC philosophy: **Process > Speed.**

## 2. The Narrative Phases
1.  **Phase I: Forensic Foundations (Steps 1–11):** Discovery of SIEM, Email, and Ticket Queue. Focuses on "Compliant" evidence collection.
2.  **Phase II: Active Defense (Steps 12–21):** Introduction to the Terminal and Network Map. Focuses on containment protocols.
3.  **Phase III: Policy & Discipline (Steps 22–27):** Introduction to the SOC Handbook. Teaches players to verify assets before acting to avoid "False Positives."
4.  **Phase IV: The Shortcut (Step 28):** The mentor encourages a "quick win" on a phishing ticket (TRN-004), forcing the use of the **Efficient** shortcut.
5.  **Phase V: The Consequence (Steps 29–36):** The shortcut backfires. The ignored threat becomes a breach (TRN-005), requiring advanced hunting (`netstat`, `trace`) and recovery (`Decryption`).

## 3. Technical Guardrails

### A. Technical Lockout System (`TicketCard.gd`)
To prevent tutorial breaks and ensure players collect all evidence, the "Complete" button is contextually locked based on the current step:
- **TRN-001:** Locked until **Step 11** (Forces Email & SIEM investigation).
- **TRN-002:** Locked until **Step 21** (Forces containment verification).
- **TRN-003:** Locked until **Step 26** (Forces Policy verification).
- **TRN-005:** Locked until **Step 36** (Forces Root Cause & Decryption).

### B. Enforced Compliance (`ValidationManager.gd`)
The Completion Modal restricts resolution types to match the current lesson:
- **Certification Phase:** The "Efficient" button is disabled. Tooltip: *RESTRICTED: EMERGENCY SHORTCUTS NOT PERMITTED.*
- **The Shortcut (Step 28):** The "Compliant" button is disabled, forcing the player to take the "Efficient" route to trigger the story payoff.
- **Consequence Phase:** Shortcuts are again disabled to emphasize that thoroughness prevents regressions.

### C. Visual Guidance System
Guidance is provided via a multi-tiered visual feedback loop:
- **Icon Glows:** Critical desktop icons (SIEM, Terminal, etc.) pulse when they are the primary objective.
- **Item Highlights:** Specific list items (Tickets, Emails) use a glowing blue dashed border to indicate focus.
- **Runbook Sidebar:** Directives and educational context are displayed in the high-contrast Live Directive module.

## 4. Master Step Sequence

| #      | Phase        | Main Instruction (HUD/Sidebar)   | Mentor Dialogue (Analogy/Lesson)                                                                                                                                            |
|:-------|:-------------|:---------------------------------|:----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **1**  | Orientation  | **LOCATE OFFICE C**              | "Welcome aboard. Your physical location is part of the 'Insider Threat' security model. Head down the hall and find Office C—that's your assigned workstation."             |
| **2**  | Auth         | **LOG IN TO WORKSTATION**        | "Take a seat. Security starts with 'Identity and Access Management.' Use the credentials on the sticky note to log in to your secure environment."                          |
| **3**  | Triage       | **OPEN TICKET QUEUE**            | "In the SOC, we prioritize incidents through 'Triage.' We can't fix every alert at once, so we focus on the tickets that pose the highest risk to the company."             |
| **4**  | Selection    | **SELECT TICKET TRN-001**        | "Every incident tells a story. Selecting a ticket 'Owns' the investigation, assigning your ID as the primary analyst responsible for the resolution."                       |
| **5**  | Forensics    | **OPEN EMAIL ANALYZER**          | "Emails are the #1 'Attack Vector'—the door hackers use to get in. We use the Analyzer to safely pull apart a suspicious message without letting it touch our network."     |
| **6**  | Verification | **SELECT SUSPICIOUS EMAIL**      | "Click the email to load it. An analyst must look past the text and examine the 'Payload'—the links or files that actually carry the threat."                               |
| **7**  | Inspection   | **USE LINK CHECK TOOL**          | "Attackers use 'Masking' to hide dangerous links. The Link Check tool reveals the true destination of a URL before you accidentally invite a threat inside."                |
| **8**  | Logs         | **OPEN SIEM LOG VIEWER**         | "The SIEM is our 'Security Camera System.' Every action on the network leaves a 'Log'—an objective record we use to rebuild the timeline of a breach."                      |
| **9**  | Reading      | **SELECT MALICIOUS LOG**         | "Logs tell the truth. Look for the 'Inbound Connection' that matches the domain we found in the email. That's your technical proof of the attack."                          |
| **10** | Evidence     | **ATTACH LOG TO TICKET**         | "In cybersecurity, an opinion isn't proof. 'Attaching Evidence' creates a forensic audit trail that proves exactly how a threat occurred for the legal and recovery teams." |
| **11** | Closure      | **RESOLVE TICKET (COMPLIANT)**   | "Documentation closes the loop. Closing as 'Compliant' confirms that you followed the full protocol, ensuring the threat is neutralized and the evidence is archived."      |
| **12** | Defense      | **SELECT TICKET TRN-002**        | "This next alert is an 'Active Infection.' It’s no longer a potential threat—it's already inside and executing code on a workstation."                                      |
| **13** | Terminal     | **OPEN TERMINAL**                | "The Terminal is for 'Active Defense.' While the GUI is for analysis, the command line is where an analyst takes direct control of the network."                            |
| **14** | Scanning     | **RUN COMMAND: scan**            | "Malware often hides by pretending to be a normal system program. A 'Scan' looks for these 'Anomalies'—behavior that doesn't belong in a healthy environment."              |
| **15** | Containment  | **RUN COMMAND: isolate**         | "Malware spreads like a biological virus. By 'Isolating' the host, we sever its network connection and trap the threat in one room so it can't infect our databases."       |
| **16** | Topology     | **OPEN NETWORK MAP**             | "The Network Map shows us the 'Blast Radius.' It helps us see which other computers are close to the infected host and might be the attacker's next target."                |
| **17** | Verification | **VERIFY HOST ISOLATION (GRAY)** | "'Trust but Verify.' A gray node on the map confirms that the network-level block is active and the host is officially cut off from the world."                             |
| **18** | Persistence  | **OPEN SIEM LOG VIEWER**         | "Every defense action must be recorded. Return to the SIEM to find the 'Host Isolated' event. This proves to the auditors that you contained the threat."                   |
| **19** | Logs (2)     | **SELECT CONTAINMENT LOG**       | "Click the containment log. This is your 'Chain of Custody' for the defensive action, showing exactly when the threat was stopped."                                         |
| **20** | Evidence (2) | **ATTACH LOG TO TICKET**         | "Attach the proof. Documentation is the only thing that keeps a SOC from descending into chaos during a real breach."                                                       |
| **21** | Closure (2)  | **RESOLVE TICKET (COMPLIANT)**   | "Case closed. You've successfully performed a 'Detection and Response' loop. You're building the muscle memory needed for high-stress shifts."                              |
| **22** | Policy       | **SELECT TICKET TRN-003**        | "This is a 'High Priority' alert on a database server. It looks like a breach, but in the SOC, panic is the biggest vulnerability."                                         |
| **23** | Governance   | **OPEN SOC HANDBOOK**            | "Security is a balance. The Handbook ensures we don't accidentally cause a massive 'Outage' (unavailability) while trying to stop a minor threat."                          |
| **24** | Verification | **READ PROCEDURES POLICY**       | "Not all computers are equal. A database server is a 'Critical Asset.' We must follow stricter rules before acting on them to avoid breaking core services."                |
| **25** | Compliance   | **RUN COMMAND: scan**            | "Handbook confirmed. We 'Scan' the server first to verify if the alert is a real attack or just a scheduled system update. Accuracy beats speed."                           |
| **26** | Closure (3)  | **RESOLVE TICKET (COMPLIANT)**   | "It was a false alarm. By following the policy, you saved the company from an unnecessary outage. That's 'Operational Discipline.'"                                         |
| **27** | Milestone    | **CERTIFICATION COMPLETE**       | "Professional discipline is what makes a pro. You know the tools, and you know the rules. Now, let's see how you handle a real-world scenario."                             |
| **28** | The Shortcut | **RESOLVE TICKET (EFFICIENT)**   | "The queue is overflowing. Rivera says to take a 'Shortcut' on this phishing alert. Close it 'Efficiently'—it's probably nothing, right?"                                   |
| **29** | The Payoff   | **SELECT TICKET TRN-005**        | "The shortcut backfired. That ignored phishing email led to a 'Ransomware' infection on the same user's machine. The Kill Chain has reached the final stage."               |
| **30** | Containment  | **RUN COMMAND: isolate**         | "Emergency lockdown! We need an immediate 'Tourniquet' to stop the malware from encrypting the rest of the network."                                                        |
| **31** | Hunting      | **RUN COMMAND: netstat**         | "Malware 'Beacons' (calls home) to its owner. The `netstat` command shows us these active connections so we can find the exact IP address the attacker is using."           |
| **32** | Tracing      | **RUN COMMAND: trace**           | "Follow the wire. 'Tracing' the route shows us the path the data took across the internet, leading us directly back to the attacker's server."                              |
| **33** | Root Cause   | **SUBMIT ROOT CAUSE IP**         | "An IP address is like a fingerprint left at a crime scene. By identifying the 'Root Cause', we can block this specific attacker across our entire global firewall."        |
| **34** | Recovery     | **OPEN DECRYPTION TOOL**         | "The safe is locked. We need to pick the encryption lock to recover the user's files without paying the attacker's ransom."                                                 |
| **35** | Puzzle       | **SOLVE DECRYPTION PUZZLE**      | "Ransomware locks our files with a digital key. 'Decryption' is the process of picking that lock to restore our information safely."                                        |
| **36** | Final Close  | **RESOLVE TICKET (COMPLIANT)**   | "Congratulations. You've learned that in the SOC, shortcuts cost double. Thoroughness is the only thing that keeps the network standing."                                   |
