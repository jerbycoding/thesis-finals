# VERIFY.EXE - New Tutorial Design: "The Shadow Shift"

## 1. Design Philosophy: "First Day on the Job"
The tutorial is no longer a separate "certification mode." It is woven directly into the player's first day as a new hire in the SOC. They are "shadowing" a Senior Analyst (Rivera/Jordan) who guides them via internal comms.

**Core Goal:** Move from a checklist-style tutorial to a **narrative arc** that teaches the most important lesson in cybersecurity: **Action = Consequence.**

## 2. The Narrative Arc
1.  **Certification (Steps 1-20):** The player learns the tools in a safe, guided environment. They make a small mistake (Isolating a server) to learn about "Integrity" penalties.
2.  **The Shortcut (Step 21):** The mentor encourages a "quick win" on a phishing ticket, tempting the player to skip deep analysis.
3.  **The Consequence (Step 22):** That shortcut immediately backfires. The ignored phishing email leads to a malware infection.
4.  **The Kill Chain (Steps 23-29):** The player must clean up their own mess using advanced tools (`netstat`, `trace-route`, `Decryption`), reinforcing that thoroughness prevents disaster.

## 3. The Master Step Sequence

| Step | Phase | Human Instruction | Real-World Explanation (Analogy) | The "Aha!" Moment (Logic) |
| :--- | :--- | :--- | :--- | :--- |
| **PART 1** | **BASICS** | | | |
| 1 | Orientation | **Find Office C.** Rivera: "Welcome aboard. Head to your desk." | First day orientation. | Immersion: You are physically "at work." |
| 2 | Auth | **Log in.** Rivera: "Credentials are on the sticky note." | Unlocking your toolbox. | Security starts with identity (Authentication). |
| 3 | Triage | **Open Ticket Queue.** Rivera: "This is the firehose. Open it up." | The dispatcher's radio or inbox. | Triage: You can't fix everything at once. |
| 4 | Selection | **Select TRN-001.** Rivera: "Grab the top file." | Picking the first case. | Every incident tells a story. |
| 5 | Forensics | **Open Email Analyzer.** Rivera: "Let's see what they sent." | Forensic lab for digital mail. | Emails are the #1 attack vector. |
| 6 | Verification | **Use Link Check.** Rivera: "Don't click it—scan it." | Checking a suspicious package before opening. | Hovering/Scanning > Clicking. |
| 7 | Logs | **Open SIEM.** Rivera: "Check the cameras (Logs)." | Reviewing security footage. | Logs are the objective truth of what happened. |
| 8 | Evidence | **Attach Evidence.** Rivera: "Bag and tag that log." | Police adding a photo to the case file. | An opinion isn't proof; data is proof. |
| 9 | Closure | **Close Compliant.** Rivera: "Clean kill. Close it out." | Filing the paperwork. | Documentation closes the loop. |
| 10 | Escalation | **Select TRN-002.** Rivera: "Next up. Possible infection." | A new patient with worse symptoms. | Shifting from analysis to active defense. |
| 11 | Tooling | **Open Terminal.** Rivera: "Time to go under the hood." | Using the mechanic's diagnostic tool. | GUI is for looking; Terminal is for acting. |
| 12 | Scan | **`scan WORKSTATION-T`.** Rivera: "Check for a pulse." | Metal detector scanning a person. | Finding hidden threats (Processes/Malware). |
| 13 | Containment | **`isolate WORKSTATION-T`.** Rivera: "Lock them in the room." | Quarantine. | Stop the spread (Containment) immediately. |
| 14 | Awareness | **Open Network Map.** Rivera: "Visual confirmation." | Checking the building blueprint. | Visualizing the "Blast Radius." |
| 15 | Verify | **Confirm 'Gray'.** Rivera: "Door is locked. Good." | Verifying the lock held. | Trust but verify your own actions. |
| 16 | Closure | **Close Case.** Rivera: "Another one down." | Routine procedure. | Building muscle memory. |
| 17 | Crisis | **Select TRN-003.** Rivera: "Code Red. Server issue." | High-pressure emergency. | Stress tests your judgment. |
| 18 | Mistake | **Isolate Server immediately.** (Forced Failure) | Cutting power to the hospital to stop a leak. | **Consequence:** Panic leads to bad decisions. |
| 19 | Lesson | **Integrity Penalty.** Rivera: "You just broke the website!" | The boss yelling at you. | Availability is as important as Security. |
| 20 | Milestone | **Certification Complete.** Rivera: "You know the tools. Now for real work." | Passing the driving test. | You know *how* to drive, but not *where*. |
| **PART 2** | **KILL CHAIN** | | | |
| 21 | Trap | **Close Phishing TRN-004 fast.** Rivera: "Just spam. Clear it." | Sweeping broken glass under the rug. | **The Trap:** Efficiency is rewarded... until it isn't. |
| 22 | Payoff | **Open Malware TRN-005.** Rivera: "Wait... that's the same user." | The glass cut someone's foot. | **Kill Chain:** The ignored email became a breach. |
| 23 | Reaction | **`isolate WORKSTATION-T`.** Rivera: "Stop the bleeding!" | Emergency tourniquet. | Reacting to a crisis you helped create. |
| 24 | Lock | **Investigation:** Ticket requires **Root Cause IP**. Run `netstat`. | Dusting for fingerprints. | Finding the active connection to the attacker. |
| 25 | Hunt | **Tracing:** Run `trace-route [IP]`. Rivera: "Follow the wire." | Tracking the getaway car. | **Aha!** Mapping the attack back to the source. |
| 26 | Key | **Enter IP into Root Cause field.** Field unlocks. | Solving the detective's riddle. | **Lock & Key:** Investigation unlocks Documentation. |
| 27 | Recovery | **Files Encrypted. Open Decryption Tool.** | The thief locked the safe. Pick it. | **New Tool:** Recovering from disaster. |
| 28 | Puzzle | **Solve the Hex Match (Guided).** Rivera: "I'll guide your hand." | Digital locksmithing. | **Redemption:** You fixed the mess. |
| 29 | Synthesis | **Final Debrief.** Rivera: "Shortcuts cost double. Welcome to the SOC." | The final lesson. | **Synthesis:** Thoroughness > Speed. |

## 4. Technical Requirements

### A. Narrative & Scripting
- **`TutorialManager` Update:** Needs to support a branched flow (Certification -> Trap -> Consequence).
- **NPC Dialogue System:** "Rivera" needs to deliver lines via:
    - **Comms Strip:** Persistent bottom bar for instructions ("Open Ticket Queue").
    - **In-App Annotations:** Contextual notes inside tools (e.g., a sticky note on the SIEM log).
    - **Debrief Modal:** For the final "Kill Chain" lesson.

### B. New Mechanics
- **Ticket Locking ("Root Cause"):**
    - `TicketResource` needs a `locked_field` property (e.g., "root_cause_ip").
    - The Ticket UI must disable the "Close Ticket" button until this field matches a specific string.
- **Terminal Upgrades:**
    - `netstat`: Displays active connections (must show the malicious IP for TRN-005).
    - `trace-route`: Visualizes the path to the attacker (must confirm the IP).

### C. Decryption Tool
- **Introduction:** The tool remains accessible but "dormant" or unexplained until Step 27.
- **Guided Puzzle:** The first puzzle must be simple (3-4 matches) with specific hints from Rivera.

## 5. Implementation Plan
1.  **Terminal System:** Implement `netstat` and `trace-route` commands.
2.  **Ticket System:** Implement the "Root Cause" locking mechanic.
3.  **Tutorial Logic:** Script the 29-step sequence in `TutorialManager`.
4.  **UI/Narrative:** Add the "Comms Strip" and Rivera's dialogue.
