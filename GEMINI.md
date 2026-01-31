# GEMINI Project Analysis: VERIFY.EXE (Incident Response SOC Simulator)

## 1. Project Overview

This project is a single-player, 3D/2D hybrid simulation game titled **"VERIFY.EXE"** (also referred to as **Incident Response: SOC Simulator**). It is being developed using the **Godot Engine (v4.3+)** and **GDScript**, utilizing Godot 4.4 features.

The core concept places the player in the role of a Security Operations Center (SOC) analyst. The gameplay revolves around managing and investigating security incident tickets within a simulated corporate environment. The central theme is the tension between following slow, safe protocols and succumbing to pressure for fast, risky resolutions, with every decision having cascading consequences.

### Architecture and Core Systems:

*   **Hybrid 2D/3D World:** The player navigates a 3D office environment but interacts with a 2D desktop interface to use analysis tools. This transition is managed by `TransitionManager.gd` and `GameState.gd`, featuring an architectural overhaul that uses `CSGBox3D` for high-fidelity office environments.
*   **Event-Driven Architecture:** A centralized `EventBus` singleton decouples core managers. Recent improvements include the `prepare_for_scene_change` signal, which allows persistent 2D UIs to automatically clean themselves up during transitions.
*   **Unified State Authority:** `GameState.gd` serves as the single source of truth for the mouse cursor and game modes (`MODE_3D`, `MODE_2D`, `MODE_DIALOGUE`, `MODE_MINIGAME`, `MODE_UI_ONLY`). It automatically enforces mouse capture or visibility based on the current context.
*   **Performance Optimization:** UI-heavy tools like the SIEM Log Viewer use a `UIObjectPool` to manage and reuse list entries, ensuring smooth performance even when handling hundreds of simulated logs.
*   **Autoload Singletons:** The project relies on globally accessible singleton scripts (found in the `autoload/` directory) to manage core systems:
	*   `ArchetypeAnalyzer`: Determines the player's "analyst archetype" (e.g., 'Cowboy', 'By-the-Book') by deriving metrics from the `ConsequenceEngine` choice history.
	*   `AudioManager`: Manages playback of music and sound effects, with semantic helpers for UI and notifications.
	*   `ConfigManager`: Manages persistent user settings (Volume, Display) saved in `user://settings.cfg`.
	*   `ConsequenceEngine`: The source of truth for player choices; logs history and triggers delayed, cascading consequences, including "Kill Chain" escalations.
	*   `CorporateVoice`: Provides a library of corporate-toned phrases and templates for consistent narrative style.
	*   `DebugManager`: Provides hotkey jumps (F1-F10) for shift testing and manual state manipulation.
	*   `DesktopWindowManager`: Manages the lifecycle, Z-ordering, and snapping of desktop application windows.
	*   `DialogueManager`: Centralized system for NPC dialogue flow, display, and choice-based scene transitions.
	*   `EmailSystem`: Backend manager for the email client tool, including discovery and threat processing.
	*   `EventBus`: The central hub for global signals, reducing coupling between managers.
	*   `FPSManager`: Persistent overlay for real-time performance tracking.
	*   `GameState`: Manages the current game mode and pause state, enforcing global mouse authority.
	*   `GlobalConstants`: Central authority for shared constants, event IDs, and severity enums.
	*   `HeatManager`: Manages difficulty scaling and "Vulnerability Inheritance," where unresolved risks from previous tickets impact future ones.
	*   `IntegrityManager`: Manages organizational "HP" (Stability), handling decay rates and integrity-based failure states.
	*   `LogSystem`: Backend manager for the SIEM log viewer, featuring a ring-buffer-style history to manage memory.
	*   `NarrativeDirector`: Manages scripted story flow (Shifts 1-5 + Weekends), NPC interactions, and shift report generation.
	*   `NetworkState`: Single source of truth for host information (IPs, Status, Criticality) utilizing a resource-driven registry.
	*   `NotificationManager`: Handles display and queuing of notification toasts on the desktop.
	*   `SaveSystem`: Manages JSON-based serialization of player metrics, world state, and ticket progress.
	*   `TerminalSystem`: Backend for the command-line tool, including command parsing, tracing, and host isolation.
	*   `TicketManager`: Handles the lifecycle of security incidents, managing timers and ambient noise tickets.
	*   `TimeManager`: Centralizes game timers to ensure consistency across scene transitions.
	*   `TransitionManager`: Manages visual fades and state transitions between 3D world and 2D desktop, triggering global cleanup signals.
	*   `TutorialManager`: Manages the guided onboarding experience, utilizing a persistent subtitle system in `TutorialHUD`.
	*   `ValidationManager`: Central authority for gameplay rules (e.g., verifying evidence before a compliant closure).
	*   `VariableRegistry`: The engine for "Procedural Truth," generating consistent technical context (IPs, Hostnames, Victim names) across all tools for each incident.

### Data Types (Resources):

*   `DialogueDataResource.gd`: Stores structured dialogue data (lines, choices, effects).
*   `EmailResource.gd`: Handles email metadata, clues, and risk analysis logic.
*   `HostResource.gd`: Defines metadata for network hosts (hostname, IP, criticality).
*   `LogResource.gd`: Manages log entry data and forensic report formatting.
*   `ShiftResource.gd`: Defines the sequence of events and narrative beats for a specific work shift.
*   `TicketResource.gd`: Manages incident state, required evidence, and Kill Chain escalation paths.

### Scene-Based Tools (Enterprise-Clean Aesthetic):

*   **SIEM Log Viewer**: For forensic log analysis and evidence collection.
*   **Email Analyzer**: For inspecting headers, scanning links, and quarantining threats.
*   **Terminal**: For network commands, tracing, and host isolation.
*   **Network Mapper**: Visualizes topology and real-time host status.
*   **Decryption Tool**: Specialized utility for ransomware recovery puzzles.
*   **SOC Handbook**: Overhauled into a PDF-style infinite scroll document reader.
*   **Resource Monitor (Task Manager)**: A high-density dashboard for monitoring system load and performance impacts.
*   **Ticket Queue**: For managing and resolving active security incidents with high-contrast UI.
*   **Shift Report**: Post-shift analysis UI displaying metrics and archetype derivation.
*   **Field Tablet (Forensic Tablet)**: Handheld 3D tool used during maintenance shifts for network topology audits and hardware synchronization.

### Narrative Structure & Weekend Shifts:

The game follows a 7-day narrative arc. While weekdays (Mon-Fri) focus on the 2D desktop workstation loop, weekend shifts introduce physical 3D objectives:
*   **Saturday (Infrastructure Audit)**: Requires physical inspection of router nodes and technical handshake minigames in the Network Hub.
*   **Sunday (Hardware Recovery)**: Focuses on physical hardware maintenance in the Server Vault, including carrying and replacing server drives.

## 2. Building and Running

This is a standard Godot project. There are no external build scripts or package managers required.

### Running the Game:

1.  **Open the project** in the Godot Engine (version 4.3 or higher).
2.  The main scene is `res://scenes/ui/TitleScreen.tscn`.
3.  **Press the "Play" button** (F5) in the top-right of the Godot editor to run the game.

### Testing:

The project integrates the **GdUnit4** testing framework for automated unit and integration tests. 

*   **Manual Execution:** Users should execute tests manually via the GdUnit4 panel in Godot or via the command line.
*   **AI Policy:** AI agents are instructed **not** to run tests automatically to prevent excessive token consumption.

**To run tests from the command line:**
```cmd
addons\gdUnit4\runtest.cmd --godot_bin "C:\Godot 4\Godot 4.exe" -a "tests/unit/"
```

**Latest Test Results (Report 5):**
*   **Status:** PASSED (100% Success Rate)
*   **Suites:** 1 (Integration)
*   **Tests:** 2
*   **Duration:** 175ms
*   **Key Coverage:** 
	*   `test_full_shift_chain_progression`: Verified linear progression from Monday through Sunday.
	*   `test_briefing_ids_are_assigned`: Verified all shift resources have associated briefing dialogues.

### Key File Locations:

*   **Global Systems:** `autoload/`
*   **Game Scenes:** `scenes/` (separated into `2d`, `3d`, and `ui`)
*   **Game Logic:** `scripts/`
*   **Data Definitions:** `resources/`
*   **Project Vision & Progress:** `sprint/`