    Here are three high-fidelity, architecturally sound proposals for the "Hacker Role" that subvert the existing systems rather than replacing them. Each design leverages Godot’s Singleton (Autoload) and Resource architecture to ensure modularity.

### Proposal 1: "The Insider" (The Night Shift)

This design focuses on the tension of having physical access. The player is an employee by day, a threat by night.

**1. The "Mirror Loop": The "Quiet" Operator**
- **SIEM Subversion:** The Hacker doesn't attack the network; they attack the *integrity of the data*. Using a laptop plugged into a physical jack in the server room, they inject "Noise" (Benign Resources) into the SIEM. The goal isn't to hide, but to dilute the analyst's Signal-to-Noise ratio, forcing them to waste time on false positives while the Hacker slowly bleeds data.
- **Email Forensics:** They utilize spear-phishing *against their own organization* (IT Support requests) to harvest high-level credentials. They then use these credentials to access restricted Network Topology maps, looking for "Shadow IT" devices to exploit.
- **Terminal (The "Sleep" Command):** Instead of `scan` or `isolate`, the hacker uses a `sleep` command on local agents. This delays telemetry reporting to the SOC, creating a blind spot for the analyst.

**2. The 3D Integration: "The Physical Key"**
The 3D space becomes a stealth puzzle. The Hacker must navigate the office at night, avoiding motion sensors and security cameras (visible in 3D). To execute a specific digital attack (like injecting the SIEM noise), they must physically reach a specific access point (e.g., a data port in the CEO's office or a wiring closet). The physical location in 3D dictates the digital payload they can deploy.

**3. The Narrative Twist: "The Crusader"**
They are not a criminal; they are a high-level employee (e.g., a Compliance Officer) who has discovered the company is illegally selling user data or performing unethical practices. Their goal is to exfiltrate the "Proof Packet" (incriminating emails, hidden databases) to a journalist *without* triggering the Integrity Manager (which represents the company's "Public Facing" health). If they trigger a high alert, the company locks down the data, and they lose.

**4. Win/Loss Condition: The "Truth Packet"**
- **Win:** They must assemble a "Dossier" (a Resource file) by extracting specific emails (via Email Tool) and database entries (via SIEM) that prove malfeasance. They upload this via a physical drop (USB drive) located in the 3D world.
- **Loss:** The Integrity Manager hits zero. In this mode, "Integrity" represents *Stealth*. If it hits zero, Security (the Night Guard) tackles them, or the system locks them out permanently.

---

### Proposal 2: "The Ghost" (The Red Teamer)

This design treats the Hacker as a systemic "Stress Test." They are hired to break in, and the analyst must catch them.

**1. The "Mirror Loop": The "Living" Payload**
- **SIEM Subversion:** The Hacker deploys a "Sleeper Agent" (a benign-looking process) that lives in the SIEM's log aggregation service. When the Analyst runs a query to look for a specific IOC (Indicator of Compromise), the "Ghost" intercepts the query and retroactively edits the logs *as they are being read*, showing the analyst a "clean" version while the exfiltration happens in the background.
- **Network Topology Mapper:** The Ghost injects false nodes into the mapper (Phantom Switches, Fake IoT devices). The Analyst must waste time scanning these dead ends while the Ghost pings the real target.
- **Terminal (The "Echo" Command):** The Ghost uses a command to replay old, legitimate network traffic (like a recorded backup session) to mask their current exfiltration.

**2. The 3D Integration: "The Signal Jam"**
The 3D world contains "Physical Interference Zones." If the Hacker can navigate their 3D avatar to stand near a specific electrical closet or microwave tower, they create a localized "Faraday Cage" effect in that zone of the digital network. This prevents the Analyst from running `isolate` commands on machines in that specific subnet, buying the Hacker precious seconds to dump data.

**3. The Narrative Twist: "The Auditor"**
The Hacker is a former SOC analyst (a rival firm) hired by the Board to test the new "VERIFY.EXE" system. The irony is they are using the same tools the Analyst uses, but with "Red" flags. They are trying to hit the "Kill Chain" stages faster than the Analyst can stop them. The Heat Manager (Vulnerability Inheritance) works in their favor here—if the Analyst missed something in a previous shift, the Ghost knows about it and exploits it immediately.

**4. Win/Loss Condition: The "Rootkit"**
- **Win:** The Ghost must maintain a persistent foothold. They win by having a specific "Rootkit" Resource running on the Domain Controller for a set amount of time (simulating data mapping). They don't need to exfiltrate; they just need to prove they *could* have.
- **Loss:** The Analyst detects and isolates the Ghost's primary C2 (Command & Control) channel before the timer runs out, forcing them to reboot their attack.

---

### Proposal 3: "The Machine" (The Saboteur / Logic Bomb)

This design moves away from "data theft" to "systemic collapse." The Hacker is trying to break the *tools*, not steal the data.

**1. The "Mirror Loop": The "Griefing" Engine**
- **SIEM Subversion:** The Hacker doesn't hide; they flood. They perform a "Log4j" style attack on the SIEM *application itself*. They cause the SIEM to index corrupted log files, causing the Analyst's UI to glitch, display ASCII garbage, or crash specific views, blinding them.
- **Email Forensics:** They inject malicious `Subject:` headers that trigger infinite parsing loops in the Email Analyzer tool, freezing it.
- **Terminal (The "Fork Bomb"):** They target the Analyst's workstation via a vulnerability, causing the `scan` command to return random results or the `isolate` command to target the wrong machine, creating chaos.

**2. The 3D Integration: "The Sniper"**
The 3D space is used for line-of-sight sabotage. The Hacker is located in a building across the street (visible from the office window in 3D). Using a high-powered antenna, they must maintain a clear digital "line of sight" to the target building's Wi-Fi emitter to execute their most powerful exploits. If the Analyst (in the 3D office) walks to the window and pulls the blinds (a physical action), they break the line of sight and disrupt the Hacker's attack.

**3. The Narrative Twist: "The Revolutionary"**
They are an activist targeting a defense contractor or a surveillance firm. They don't want the data; they want to destroy the company's ability to *process* data. They are trying to trigger the "Impact" stage of the Kill Chain not by encrypting data (ransomware), but by corrupting the forensic integrity of the systems so thoroughly that the company's contracts are voided due to non-compliance.

**4. Win/Loss Condition: The "Blackout"**
- **Win:** The Hacker must cause the "Integrity Manager" to deplete by crashing the four core Analyst tools (SIEM, Email, Terminal, Mapper) simultaneously. Once all four are down, the "Impact" stage is triggered, and the company is declared non-operational.
- **Loss:** The Analyst manages to keep at least two tools online long enough to trace the source of the "Griefing" attack and alert federal authorities, forcing the Hacker to disconnect.