# GEMINI Project Analysis: VERIFY.EXE (Incident Response SOC Simulator)

## 1. Project Overview

This project is a single-player, 3D/2D hybrid simulation game titled **"VERIFY.EXE"** (also referred to as **Incident Response: SOC Simulator**). It is being developed using the **Godot Engine (v4.3+)** and **GDScript**, utilizing Godot 4.4 features.

The core concept places the player in the role of a Security Operations Center (SOC) analyst. The gameplay revolves around managing and investigating security incident tickets within a simulated corporate environment. The central theme is the tension between following slow, safe protocols and succumbing to pressure for fast, risky resolutions, with every decision having cascading consequences.

### Architecture and Core Systems:

*   **Hybrid 2D/3D World:** Transitions between 3D office navigation and 2D workstation interaction are managed by `TransitionManager.gd`. This system includes player camera animations (sitting/standing) and a high-fidelity `MonitorInputBridge` that projects interactive desktop UIs onto 3D meshes using anisotropic filtering for text clarity.
*   **Unified State Authority:** `GameState.gd` serves as the single source of truth for game modes (`MODE_3D`, `MODE_2D`, `MODE_DIALOGUE`, `MODE_MINIGAME`, `MODE_UI_ONLY`). It enforces mouse authority and UI blocking (modals) globally.
*   **Procedural Truth System:** The `VariableRegistry` generates "Truth Packets" for each incident. This ensures that technical indicators like IPs, hostnames, and victim names remain semantically consistent across all investigative tools (SIEM, Email, Terminal).
*   **Heat & Inheritance Engine:** Managed by `HeatManager.gd`, the game scales difficulty weekly. It features "Vulnerability Inheritance," where unresolved risks or "Efficient" closures cache technical indicators that reappear in future, more severe incidents.
*   **Kill Chain Escalation:** The `ConsequenceEngine` tracks incident lifecycles through four stages: Infiltration, Propagation, Exfiltration, and Impact. Ignoring alerts or choosing risky resolutions allows threats to mature, eventually triggering "Zero Day" events or "Black Ticket" recovery missions.
*   **Social Dynamics & Favors:** NPC relationships are tracked via `ConsequenceEngine`. High approval allows players to trade relationship points for "Favors" (e.g., Senior Analyst auto-forensics or IT Support bandwidth boosts).
*   **Performance Optimization:** UI-heavy tools like the SIEM Log Viewer and Email Analyzer use a `UIObjectPool` to manage and reuse list entries, ensuring smooth performance during "Log Floods."
*   **Autoload Singletons:**
	*   `ArchetypeAnalyzer`: Derives the player's analyst style (Cowboy, By-the-Book, etc.) from metric history.
	*   `AudioManager`: Manages SFX, music, and floor-based ambient loops with dynamic typewriter sounds.
	*   `ConfigManager`: Persists user settings (Volume, Display) in `user://settings.cfg`.
	*   `ConsequenceEngine`: Tracks choices, manages the Kill Chain, and handles NPC relationship logic.
	*   `CorporateVoice`: A library of formatted corporate-toned phrases for consistent narrative style.
	*   `DesktopWindowManager`: Manages application windows, Z-ordering, and context-based app permissions.
	*   `DialogueManager`: Handles structured NPC dialogue flows and choice-based effects.
	*   `EmailSystem`: Backend for the email client, featuring data-driven risk analysis and inspection tools.
	*   `EventBus`: The central hub for all global signals.
	*   `HeatManager`: Manages difficulty scaling and vulnerability inheritance.
	*   `IntegrityManager`: Manages organization stability ("HP"), handling decay rates and integrity-based failure states.
	*   `LogSystem`: Backend for SIEM logs, featuring a ring-buffer history and event-driven log injection.
	*   `NarrativeDirector`: Manages the 7-day arc, scripted events, and weekend transitions.
	*   `NetworkState`: Authority for host metadata and real-time statuses (Clean, Infected, Isolated).
	*   `NotificationManager`: Handles the display and queuing of toast notifications.
	*   `ResourceAuditManager`: Performs startup connectivity checks between Shifts, Tickets, and Logs.
	*   `SaveSystem`: JSON-based serialization of player metrics, world state, and shift progress.
	*   `TerminalSystem`: Backend for command parsing (scan, trace, isolate) and network multipliers.
	*   `TicketManager`: Handles the incident lifecycle, ambient noise spawning, and log attachment.
	*   `TutorialManager`: Manages the "Tier 1 Certification" onboarding using `TutorialSequenceResource`.
	*   `ValidationManager`: Central authority for IR gameplay rules (e.g., scan-before-isolate).

### Data Types (Resources):

*   **AppConfigResource**: Defines application metadata, scene paths, and context-based restrictions.
*   **EmailResource**: Metadata, forensic clues, and "hidden risk" consequence triggers.
*   **HostResource**: Network host metadata (IP, OS type, criticality).
*   **LogResource**: Log entry data and forensic report templates.
*   **ShiftResource**: Narrative sequences, random event pools, and weekend minigame configurations.
*   **TicketResource**: Incident state, required evidence, and Kill Chain escalation paths.
*   **TutorialSequenceResource**: Data-driven steps for the certification module, including visual highlight paths.

### Scene-Based Tools (Enterprise-Clean Aesthetic):

*   **SIEM Log Viewer**: Forensic analysis with volume graphs, zebra-stripping, and detailed inspector pane.
*   **Email Analyzer**: SaaS-inspired UI for inspecting headers, scanning attachments, and link reputation.
*   **Terminal**: TUI-style command interface for active defense and host isolation.
*   **Network Mapper**: Interactive topology dashboard visualizing host priority and real-time status.
*   **Decryption Tool**: High-stakes hex-based puzzle utility for ransomware recovery.
*   **SOC Handbook**: PDF-style infinite scroll document reader for IR procedures.
*   **Task Manager**: Performance monitor with real-time procedural graphs for CPU and Network load.
*   **Ticket Queue**: Triage interface for managing incidents and building forensic cases.
s
### Narrative Structure & Weekend Shifts:

The game follows a 7-day narrative arc (Monday-Sunday).
*   **Weekdays (Mon-Fri)**: Focus on the 2D workstation IR loop, culminating in a Friday "Zero Day" event.
*   **Saturday (Infrastructure Audit)**: Physical 3D navigation in the Network Hub, featuring signal calibration and ACL slider minigames.
*   **Sunday (Hardware Recovery)**: Physical hardware maintenance in the Server Vault, including slotting server blades and RAID parity synchronization.
*   **Endings**: Distinct outcomes based on performance: **Fired** (Negligence), **Bankrupt** (Data Loss), and **Victory** (Promotion).

## 2. Building and Running

This is a standard Godot project. There are no external build scripts or package managers required.

### Running the Game:

1.  **Open the project** in the Godot Engine (version 4.3 or higher).
2.  The main scene is `res://scenes/ui/TitleScreen.tscn`.
3.  **Press the "Play" button** (F5) in the top-right of the Godot editor to run the game.

### Testing:

The project integrates the **GdUnit4** testing framework.

*   **Manual Execution:** Execute tests via the GdUnit4 panel in Godot.
*   **Latest Test Status**: PASSED (100% Success Rate) covering shift progression, briefing ID assignments, and resource connectivity.

### Key File Locations:

*   **Global Systems:** `autoload/`
*   **Game Scenes:** `scenes/` (2d, 3d, ui)
*   **Logic Scripts:** `scripts/` (2d, 3d, ui)
*   **Data Resources:** `resources/` (tickets, logs, emails, hosts, shifts)
*   **Project Documentation**: `VERIFY.EXE_DOCUMENTATION/` and `sprint/`