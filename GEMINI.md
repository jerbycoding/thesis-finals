# GEMINI Project Analysis: VERIFY.EXE (Incident Response SOC Simulator)

## 1. Project Overview

This project is a single-player, 3D/2D hybrid simulation game titled **"VERIFY.EXE"** (also referred to as **Incident Response: SOC Simulator**). It is being developed using the **Godot Engine (v4.3+)** and **GDScript**, utilizing Godot 4.4 features.

The core concept places the player in the role of a Security Operations Center (SOC) analyst. The gameplay revolves around managing and investigating security incident tickets within a simulated corporate environment. The central theme is the tension between following slow, safe protocols and succumbing to pressure for fast, risky resolutions, with every decision having cascading consequences.

### Architecture and Core Systems:

*   **Hybrid 2D/3D World:** The player navigates a 3D office environment but interacts with a 2D desktop interface to use analysis tools. This transition is managed by `TransitionManager.gd` and `GameState.gd`, featuring an architectural overhaul that uses `CSGBox3D` for high-fidelity office environments and an `InputBridge` for seamless monitor interactions.
*   **Event-Driven Architecture:** A centralized `EventBus` singleton decouples core managers. The system uses a `prepare_for_scene_change` signal for cleanup and a robust narrative event system for spawning tickets and triggering dialogue.
*   **Unified State Authority:** `GameState.gd` serves as the single source of truth for game modes (`MODE_3D`, `MODE_2D`, `MODE_DIALOGUE`, `MODE_MINIGAME`, `MODE_UI_ONLY`). It automatically enforces mouse capture or visibility based on the current context.
*   **Procedural Truth System:** The `VariableRegistry` and `VariablePool` generate "Truth Packets" for each incident. This ensures technical indicators (IPs, hostnames, victim names) are semantically consistent across all tools (SIEM, Email, Terminal).
*   **Vulnerability Inheritance:** Managed by `HeatManager.gd`, unresolved risks or "Efficient" closures from previous tickets are cached and "inherited" by future incidents, driving a persistent difficulty curve.
*   **Performance Optimization:** UI-heavy tools like the SIEM Log Viewer and Email Analyzer use a `UIObjectPool` to manage and reuse list entries, ensuring smooth performance even with hundreds of simulated logs.
*   **Autoload Singletons:**
	*   `ArchetypeAnalyzer`: Derives the player's analyst archetype (e.g., 'Cowboy', 'By-the-Book') from choice history.
	*   `AudioManager`: Manages SFX, music, and dynamic ambient audio loops based on the current floor.
	*   `ConfigManager`: Persists user settings (Volume, Display) in `user://settings.cfg`.
	*   `ConsequenceEngine`: Tracks player choices, triggers delayed consequences (follow-up tickets, breaches), and manages NPC relationships/social favors.
	*   `CorporateVoice`: Provides a library of corporate-toned phrases for consistent narrative style.
	*   `DebugManager`: Provides hotkey jumps (F1-F11) for testing shifts and state manipulation.
	*   `DesktopWindowManager`: Manages application windows, Z-ordering, and context-based app permissions.
	*   `DialogueManager`: Centralized system for NPC dialogue flow and choice-based scene transitions.
	*   `EmailSystem`: Backend manager for the email client, handling discovery and threat processing.
	*   `EventBus`: The central hub for global signals.
	*   `FPSManager`: Persistent overlay for real-time performance tracking.
	*   `GameState`: Manages the current game mode, pause state, and mouse authority.
	*   `GlobalConstants`: Central authority for shared constants, event IDs, and severity enums.
	*   `HeatManager`: Manages difficulty scaling and vulnerability inheritance.
	*   `IntegrityManager`: Manages organizational stability ("HP"), handling decay rates and integrity-based failure states.
	*   `LogSystem`: Backend manager for SIEM logs, featuring a ring-buffer history and "SIEM Lag" event support.
	*   `NarrativeDirector`: Manages the 7-day narrative arc, scripted story beats, and NPC interactions.
	*   `NetworkState`: Single source of truth for host metadata and real-time statuses (Clean, Infected, Isolated).
	*   `NotificationManager`: Handles the display and queuing of toast notifications.
	*   `SaveSystem`: Manages JSON-based serialization of player metrics and world state.
	*   `TerminalSystem`: Backend for command parsing (scan, trace, isolate) and network multipliers.
	*   `TicketManager`: Handles the incident lifecycle, ambient noise spawning, and log attachment.
	*   `TimeManager`: Centralizes game timers to prevent drift across scene transitions.
	*   `TransitionManager`: Manages visual fades and transitions between 3D and 2D modes.
	*   `TutorialManager`: Manages data-driven onboarding sequences using `TutorialStepResource`.
	*   `ValidationManager`: Central authority for gameplay rules (e.g., scan-before-isolate enforcement).
	*   `VariableRegistry`: Generates procedurally consistent technical context for incidents.

### Data Types (Resources):

*   **DialogueDataResource**: Structured dialogue lines, choices, and effects.
*   **EmailResource**: Metadata, risk analysis logic, and "quarantine hidden risks."
*   **HostResource**: Network host metadata (IP, OS type, criticality).
*   **LogResource**: Log entry data and forensic report formatting.
*   **ShiftResource**: Narrative sequences, random event pools, and weekend minigame configs.
*   **TicketResource**: Incident state, required evidence, and "Kill Chain" escalation paths.
*   **TutorialSequenceResource**: A collection of data-driven steps for the certification module.

### Scene-Based Tools (Enterprise-Clean Aesthetic):

*   **SIEM Log Viewer**: Forensic analysis with zebra-stripping, object pooling, and inspector pane.
*   **Email Analyzer**: Inspection tools for headers, attachments, and links with SaaS-inspired UI.
*   **Terminal**: TUI-style command interface for active defense and host isolation.
*   **Network Mapper**: Dashboard visualizing topology and host priority with real-time status updates.
*   **Decryption Tool**: High-stakes ransomware recovery utility with procedural hex puzzles.
*   **SOC Handbook**: PDF-style infinite scroll document reader for IR procedures.
*   **Task Manager**: High-density dashboard monitoring CPU load and network throughput.
*   **Ticket Queue**: Triage interface for managing incidents and building forensic cases.
*   **Field Tablet**: Handheld 3D tool for maintenance shifts, featuring live topology and RAID sync controls.

### Narrative Structure & Weekend Shifts:

The game follows a 7-day narrative arc (Monday-Sunday).
*   **Weekdays (Mon-Fri)**: Focus on the 2D workstation IR loop, culminating in a "Zero Day" event.
*   **Saturday (Infrastructure Audit)**: Physical inspection of router nodes in the Network Hub, featuring signal calibration minigames.
*   **Sunday (Hardware Recovery)**: Physical hardware maintenance in the Server Vault, including slotting server blades and RAID parity synchronization.
*   **Endings**: Three distinct endings based on performance: **Fired** (Negligence), **Bankrupt** (Data Loss), and **Victory** (Promotion).

## 2. Building and Running

This is a standard Godot project. There are no external build scripts or package managers required.

### Running the Game:

1.  **Open the project** in the Godot Engine (version 4.3 or higher).
2.  The main scene is `res://scenes/ui/TitleScreen.tscn`.
3.  **Press the "Play" button** (F5) in the top-right of the Godot editor to run the game.

### Testing:

The project integrates the **GdUnit4** testing framework.

*   **Manual Execution:** Execute tests via the GdUnit4 panel in Godot.
*   **Latest Test Status**: PASSED (100% Success Rate) covering shift progression and briefing ID assignments.

### Key File Locations:

*   **Global Systems:** `autoload/`
*   **Game Scenes:** `scenes/` (2d, 3d, ui)
*   **Logic Scripts:** `scripts/` (2d, 3d, ui)
*   **Data Resources:** `resources/` (tickets, logs, emails, hosts, shifts)
*   **Project Documentation**: `VERIFY.EXE DOCUMENTATION/` and `sprint/`
