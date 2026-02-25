This is a fantastic project concept, and the technical infrastructure you've built (Signal-based, decoupled `TutorialManager`, `FocusOverlay`, etc.) is the perfect foundation for a polished and immersive onboarding experience. The challenge now is to layer the *experience design* on top of that solid architecture.

Here are best practices and creative UX solutions tailored for "VERIFY.EXE."

---

### A. Onboarding Flow: Bridging the 3D/2D Gap

The core challenge is the transition from the physical space (body) to the digital space (mind). Abruptly shifting control schemes or visual languages will break immersion.

**Best Practice: The "Guided Immersion" Approach**

The onboarding should feel like the player's first day on the job, with the CISO acting as their remote supervisor. The tutorial HUD should be 100% diegetic, existing within the game world to preserve the high-fidelity simulation feel.

**Actionable Design Pattern: The "Desk Pop" Tutorial**

1.  **The First Objective (Physical):** The game starts with the player standing in the office. The 3D `TutorialWaypoint` appears on their assigned desk chair. The CISO (via Comms) says, *"Agent, have a seat. Your station is ready."*
    - **Interaction:** Player walks to the chair. A "Press E to Sit" prompt appears, but it's a subtle, low-opacity world-space UI near the chair, not a massive screen-center overlay.
2.  **The Transition (Physical -> Digital):** Upon sitting, the camera smoothly transitions to the workstation view. The player is now looking at their monitors. The mouse unlocks from looking around and instead becomes a cursor on the screen.
3.  **The Second Objective (Digital):** The `FocusOverlay` shader activates, dimming the peripheral monitors and the 3D room. A sharp, glowing highlight appears on the "Email Client" icon on the main monitor's taskbar.
    - **CISO:** *"We've got a new ticket in the queue. Open your mail client to review the initial report."*
    - **Interaction:** The player clicks the icon. This is their first action in the 2D space. The `EventBus` fires `APP_OPENED` with the argument `email`, advancing the tutorial.

**Why this works:** It uses the 3D space for gross motor skills (navigation) and the 2D space for fine motor skills (UI interaction). The CISO's dialogue provides the narrative glue, and the FocusOverlay provides the visual cue, all without a single "meta" tutorial pop-up.

---

### B. Instructional Style: Corporate SOP vs. Meta UI

Given the "Corporate/High-Tech" tone, any instruction that feels like a generic video game tutorial ("Press X to win") will immediately shatter the illusion.

**Best Practice: 100% Diegetic Instruction**

Instructions should be framed as Standard Operating Procedures (SOPs), directives from the CISO, or tooltips within the operating system itself.

- **Diegetic "Press E to sit":** Instead of a grey box, have a small, backlit sticker on the edge of the desk that reads: **"WORKSTATION - ACTIVATE"** with a subtle `[E]` next to it. Or, have the CISO say, *"Go ahead, activate your terminal."* while a subtle pulse highlights the chair.
- **Diegetic "Click the SIEM icon":** The `FocusOverlay` highlight is the primary cue. The CISO can add context: *"Pull up the SIEM. I need you to correlate the log source from that phishing email."*
- **Diegetic "Command Syntax":** The in-game `Terminal` app itself is the best teacher.
    - **Bad (Meta):** A pop-up says "Type `scan_host 192.168.1.45`".
    - **Good (Diegetic):** The player opens the Ticket. In the ticket details, an "Attached Notes" section contains a message from a senior analyst: *"Initial triage suggests host 192.168.1.45 is beaconing. Use the `scan_host` utility to confirm."* The player must read the ticket, extract the IP and the command, and type it themselves.

**Key Takeaway:** The game's UI should be the player's *portal* to the world, not the *instructor* for it. All teaching should be filtered through the lens of the job itself.

---

### C. Handling Failure during Training: "After-Action Review" not "Game Over"

In a professional simulator, failure is a learning opportunity, not a dead end. The game should simulate the consequences and the correction, not the frustration of a "Mission Failed" screen.

**Best Practice: The "CISO Correction" Loop**

If the player isolates the wrong host, don't stop the game. Instead, simulate the workflow of a mistake in a SOC.

1.  **Immediate Consequence (Simulated):** The CISO's comms activate, but with a tone of concern, not reprimand. *"Hold on, Agent. I'm seeing the isolation alert, but the telemetry from host 192.168.1.67 doesn't match the beaconing pattern. Re-check your ticket. Did we have the right IP?"*
2.  **Visual Cue:** The Ticket UI could have a subtle, non-intrusive red pulsing border, or a small "Discrepancy Detected" flag appears on the ticket.
3.  **Guided Correction:** The `FocusOverlay` could gently highlight the "Ticket Details" panel again, specifically the IP address field. The CISO then gives a nudge: *"Cross-reference the source IP in the email headers with the ticket. Let's make sure we have the right target."*
4.  **The Fix:** The player re-opens the email, checks the headers (a core gameplay loop), realizes their mistake, and runs the correct `isolate` command on the proper host.
5.  **Positive Reinforcement:** Upon successful isolation, the CISO acknowledges the recovery: *"Good catch. Always verify the source. That's how we stay sharp. Isolation confirmed on the correct host. Well done."*

**Why this works:** It treats the player like a new hire who made a common, understandable mistake. The failure state is a narrative beat that reinforces the game's core theme ("Verify") and teaches a valuable lesson about attention to detail, all without breaking the simulation.

---

### D. Visual Language: "System Guidance" over "Hand-holding"

The `FocusOverlay` shader is a powerful tool. The key is to use it with the precision and intent of a professional tool, not like a children's storybook.

**Best Practice: The "Augmented Reality" Style**

Treat the FocusOverlay not as a "tutorial arrow," but as an analytical overlay that the CISO can project onto your screen.

- **Hierarchy of Attention:**
    - **Primary Action (Active Task):** The target element is sharp, at 100% brightness, and has a clean, 1-pixel-thick **animated dashed outline** in a corporate blue or amber color. The animation is subtle, like a slowly rotating dash pattern. This signals "this is the active element in your workflow."
    - **Contextual Zone (Passive Task):** The rest of the *specific application* the player needs to use is at 80% brightness, not fully dimmed. This tells the player, "Stay in this app."
    - **Background:** The other monitors and the 3D environment are dimmed to 30-40% with the shader, becoming completely out of focus.

- **The "Look At" Cue:** Instead of a bouncing 3D waypoint in the 2D space (which would be noisy), use a subtle screen-space indicator. A small, thin line could trace a path from the center of the screen to the target button, like a faint "ping" from the CISO's guidance system. It draws the eye without obscuring the UI.

- **Color Logic:** Establish a strict color code.
    - **Amber / Yellow:** "Investigate Here" / "Pending Action."
    - **Cyan / Blue:** "System Confirmation" / "Selected Element."
    - **Green:** "Success" / "Secure."
    - **Red:** "Threat Detected" / "Urgent Mismatch" (used sparingly, even in tutorials, for critical errors like the wrong host isolation attempt).

This approach feels like a professional tool is helping you navigate complex data, which is perfectly on-theme for a SOC simulator.

---

### E. Scaffolding: Combating "Dashboard Fatigue"

Presenting five apps at once is overwhelming. You need to scaffold the player's cognitive load by introducing them as part of a logical narrative flow, not a "Here are your tools" menu.

**Best Practice: The "Investigation Narrative" Scaffold**

Introduce each application at the precise moment it becomes relevant to the story of the investigation.

1.  **Act 1: Triage (The Ticket & Email):** The game starts with the Ticket Queue and Email client. That's it. The CISO explains the ticket system and the player's first job is to open an email and read the report. The SIEM, Map, and Terminal icons are visible but greyed out or unclickable, with a tooltip that says "Access pending authorization."

2.  **Act 2: Analysis (The SIEM):** The player has read the email. The CISO says, *"The email headers show a source IP. Let's see if our SIEM has any correlated logs for that address."* At this exact moment, the SIEM icon becomes active, perhaps with a subtle glow, and the `FocusOverlay` guides them to it. They click it, and the app opens with the relevant query (the suspicious IP) pre-populated.

3.  **Act 3: Verification (The Terminal):** The SIEM logs confirm the host is compromised. The CISO: *"Confirmed. That host is beaconing to a known C2. We need to scan it. Open the Terminal."* The Terminal icon activates. The first time they open it, a log file (or a sticky note on the monitor) might contain the exact command syntax they need, teaching them the tool in a low-stakes way.

4.  **Act 4: Action (The Map & Isolation):** The scan confirms the threat. The CISO: *"Alright, we've verified. It's a go for isolation. Bring up the network map to locate the switch port."* The Map activates. After locating it, the final `isolate` command is run, and the ticket is closed.

**Why this works:** This is the "Kill Chain" you mentioned, turned into a learning path. Each app is introduced as a necessary tool to solve the current puzzle. The player never feels like they have to memorize a dashboard; instead, they learn a workflow. By the second or third ticket, they will be switching between all five apps fluidly because they understand the *purpose* of each one within the investigation narrative.