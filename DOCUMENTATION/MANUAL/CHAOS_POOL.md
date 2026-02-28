# Chaos & Ambient Noise: Discovery-Style Investigation Manual

This manual covers incidents found in the **Random Event Pool** or spawned via the **Ambient Spawner**. These incidents simulate the "Noise" of a real SOC environment.

| Ticket ID             | Discovery Style Description (Narrative Clue + [color=#006CFF]Search Anchor[/color])                                                                                                         | The Forensic Search Path (Discovery Logic)                                                                            |
|:----------------------|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:----------------------------------------------------------------------------------------------------------------------|
| **TICKET-NOISE-001**  | "Standard administrative request: User needs an [color=#006CFF]ACCOUNT RESET[/color]. Verify the employee identity and finalize the credential update to clear the queue."                  | **Administrative** (No Tools) -> Acknowledge identity -> Resolve as Compliant.                                        |
| **TICKET-NOISE-002**  | "Hardware procurement request: A user is requesting a [color=#006CFF]SECONDARY MONITOR[/color]. Verify the request details and forward to the facilities department."                       | **Email Analyzer** -> Locate procurement request -> Forward/Resolve.                                                  |
| **SYS-MAINT-GENERIC** | "Routine operational task: A [color=#006CFF]SYSTEM PATCH[/color] was recently deployed to the file servers. Verify the success of the update cycle to ensure service availability."         | **SIEM** (Search `SYSTEM PATCH`) -> Locate `LOG-SYS-004` -> Verify 'OPERATIONAL' status.                              |
| **CRYPTOMINER-HUNT**  | "System performance anomaly: Multiple workstations are reporting abnormal [color=#006CFF]CPU LOAD[/color]. Investigate the process list to identify unauthorized mining software."          | **Task Manager** (Verify spike) -> **SIEM** (Search `CPU LOAD`) -> Find `LOG-MINER-001` -> Identify and Isolate host. |
| **USER-COMPLAINT**    | "Stakeholder feedback: A user has filed a [color=#006CFF]COMPLAINT[/color] regarding a recent security action. Review the report and justify the procedural deviation."                     | **Email Analyzer** -> Locate complaint -> Cross-reference with past tickets -> Resolve.                               |
| **MALWARE-002**       | "Unauthorized activity detected: An encoded [color=#006CFF]POWERSHELL[/color] script was executed on a production host. Identify the Command & Control (C2) origin and contain the threat." | **SIEM** (Search `POWERSHELL`) -> Locate `LOG-MAL-002-A` -> Identify Host -> **Terminal** (`isolate`).                |

---

### Analysis of the Chaos Strategy
*   **The "Paperwork" Loop:** `TICKET-NOISE-001` and `002` are designed to be "brain breaks." They use the same visual language but require minimal technical effort, simulating the administrative side of the job.
*   **Performance Monitoring:** `CRYPTOMINER-HUNT` is the only chaos ticket that encourages the use of the **Task Manager** app, helping the player understand that system "slowness" is often a security indicator.
*   **Operational Adherence:** `SYS-MAINT-GENERIC` teaches the player that not every log is an "Alert." Some logs are simply "Confirmations" of success, which are equally important for a Compliant SOC.
