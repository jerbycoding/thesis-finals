**Proposal 1: The Double Agent**  
You are the same SOC analyst character the player already knows — but in “Night Shift” mode the game flips the singleton flags (`GameMode.Attacker = true`, `KillChain.Inverted = true`). The Heat Manager now tracks *SOC suspicion* instead of defender pressure; past “successful” analyst shifts become vulnerability inheritance that *helps* you because the AI trusts your old patterns.

**1. Mirror Loop**  
- **SIEM Log Viewer**: “Analyze” button becomes “Spoof Entry”. You craft and inject forensic-grade logs (reusing the Procedural Truth System’s Asset Identity generator) so the SOC AI sees normal maintenance during your exfil window.  
- **Email Forensic Analyzer**: Reverse mode lets you pull real internal templates, then forge perfect replies from the CISO’s address (same forensic hash-checking engine, just writing instead of reading).  
- **Terminal**: `scan` now enumerates internal assets for exfil priority; `isolate` becomes “quarantine cover” — you isolate *your own* staging folder so the AI thinks it’s cleaning up a false positive you just created.  
- **Network Topology Mapper**: Shows the defender’s view of the network — perfect for choosing the exact pivot that will look like routine traffic.

**2. 3D Integration**  
Physical navigation *is* privilege escalation. Walk to the server room (now unlocked for you at night), physically reseat a cable → singleton `PhysicalAccessToken` granted → Terminal gains root on that segment without log noise. Sit at another analyst’s empty workstation → shoulder-surf their 2D screen (Godot raycast + UI texture copy) to steal a live session cookie that auto-populates your SIEM queries. Every meter you walk raises or lowers the suspicion Heat in real time based on camera blind spots the Procedural Truth System randomly generates each shift.

**3. Narrative Twist**  
You discovered the company is selling customer data to a foreign buyer. The “AI co-pilot” the SOC trusts is actually the cover-up mechanism. You are fighting the very system you built — using its own forensic tools to prove its corruption.

**4. Win/Loss Condition**  
Your **Truth Packet** is a single encrypted RAR (procedurally generated from the company’s most sensitive asset identities). You stage it inside a legitimate “weekly backup” folder, then exfil via the Email Analyzer as an “encrypted incident archive” to an external dead-drop address you control. Success = packet leaves the network with Heat < 40 %. Loss = Heat hits 100 % and the AI locks every tool with your username, triggering the “Integrity Manager: Employee Terminated” cutscene.

**Proposal 2: The Red Team Auditor**  
A visiting contractor with a time-limited “Audit Badge”. The entire Toolset UI is identical, but the singleton `AuditMode` re-labels every button and routes data through the attacker side of the Kill Chain Engine.

**1. Mirror Loop**  
- **SIEM**: You see *exactly* what the real SOC AI is seeing in real time. You time your actions for moments the defender Heat is already high (e.g., during a simulated incident).  
- **Email Forensic Analyzer**: Used to harvest legitimate vendor emails, then spoof “urgent firmware update” messages that the real SOC analysts will click — giving you their session tokens.  
- **Terminal**: `scan` and `isolate` are whitelisted “authorized pentest commands”; you chain them to move laterally while the logs are auto-tagged “Red-Team-Exercise” — until you flip the tag to hide the real exfil.  
- **Network Topology Mapper**: Drag-and-drop “inject test payload” on any node; the payload reuses the same vulnerability inheritance logic the defender normally fears.

**2. 3D Integration**  
Your badge only opens certain doors. To escalate, you must physically follow a real SOC employee to the break room, “accidentally” bump their desk (Godot physics + interaction prompt), and plant a USB that auto-runs a persistence script (reusing the Procedural Truth System to generate a fake “Asset Firmware Update”). The longer you stay in the 3D office, the more the AI starts correlating your badge movements with network anomalies — forcing you to balance physical stealth with digital timing.

**3. Narrative Twist**  
The board hired you to “prove the SOC is perfect.” Halfway through you discover the board is the actual threat actor. You go rogue mid-audit, turning the red-team exercise into real data theft — fighting the AI the company thinks is protecting them.

**4. Win/Loss Condition**  
Your **Truth Packet** is the “Final Audit Report” (a compiled JSON of every hidden vulnerability + board corruption evidence). You exfil it by submitting it through the official SIEM “Close Incident” workflow, but with an extra encrypted blob the AI cannot parse. Success = packet reaches your external C2 with Heat never exceeding “Exercise Normal”. Loss = the SOC AI flags the report as anomalous and triggers an automated “Red Team Containment” lockdown.

**Proposal 3: The Ghost Contractor**  
You are the “IT Vendor Technician” who has been on-site for three weeks. No new tools — just a different starting singleton `AccessLevel = Vendor` that changes every tool’s default context menu.

**1. Mirror Loop**  
- **SIEM Log Viewer**: You never “analyze” — you “acknowledge & archive” your own artifacts so the AI thinks they were already handled by “Vendor Maintenance #47”.  
- **Email Forensic Analyzer**: You pull old vendor tickets, then reply-all from your contractor address with perfect forensic signatures, social-engineering the SOC team into running your “diagnostic script”.  
- **Terminal**: The `scan`/`isolate` commands are vendor-signed; you use them to push firmware updates that contain your exfil beacon (reusing the Procedural Truth System’s MAC/Firmware fields).  
- **Network Topology Mapper**: You literally drag your contractor laptop icon onto any node in 3D space — the mapper treats it as “authorized hardware swap”.

**2. 3D Integration**  
Your entire power comes from physical presence. Walk into the cable closet → swap a switch port → Topology Mapper instantly shows new paths. Sit at the SOC workstation while the real analyst is at lunch (you “borrow” their chair via 3D interaction) → the game hands you full SIEM access for 90 seconds before the session timeout. Every physical action writes to the same Heat Manager the defender fears, but your Vendor badge adds a massive “maintenance window” multiplier that decays if you stay too long in one spot.

**3. Narrative Twist**  
You were hired to “upgrade the firmware” after last month’s incident. The SOC AI now treats you as trusted hardware. You are the ghost inside the machine the player (as SOC) spent the whole game trying to find — and now you are using their own tools to finish the job.

**4. Win/Loss Condition**  
Your **Truth Packet** is the complete Asset Identity database (every MAC, firmware version, and exfil target generated by the Procedural Truth System). You copy it to your physical contractor laptop (a carryable 3D prop), then walk out the front door during the “scheduled fire drill” you triggered via Terminal. Success = you reach the parking lot with Heat < 25 %. Loss = security cameras (now procedurally correlated with your badge movements) flag you and the Integrity Manager broadcasts “Vendor Breach — Full Lockdown”.

All three proposals reuse the *exact same* Godot singletons (KillChainEngine, HeatManager, ProceduralTruth, ToolUIManager, IntegrityManager) with only boolean/resource flags and context-menu overrides — zero new scenes required. The 3D office becomes the new “physical attack surface” that directly mutates the digital systems the player already knows, creating the perfect mirror-loop subversion. The SOC AI the defender trusts is now the enemy the hacker must outsmart with the same interface.