# GEMINI Project Analysis: VERIFY.EXE (Incident Response SOC Simulator)

## 1. Project Overview

This project is a single-player, 3D/2D hybrid simulation game titled **"VERIFY.EXE"** (also referred to as **Incident Response: SOC Simulator**). It is being developed using the **Godot Engine (v4.3+)** and **GDScript**, utilizing Godot 4.4 features.

The core concept places the player in the role of a Security Operations Center (SOC) analyst. The gameplay revolves around managing and investigating security incident tickets within a simulated corporate environment. The central theme is the tension between following slow, safe protocols and succumbing to pressure for fast, risky resolutions, with every decision having cascading consequences.

### Architecture and Core Systems:

*   **Hybrid 2D/3D World:** The player navigates a 3D office environment but interacts with a 2D desktop interface to use analysis tools. This transition is a core architectural feature managed by `TransitionManager.gd` and `GameState.gd`.
*   **Event-Driven Architecture:** The project has evolved to use a centralized `EventBus` singleton. This decouples core managers, allowing them to react to game events (like ticket completion or host isolation) without direct dependencies on each other.
*   **Performance Optimization:** UI-heavy tools like the SIEM Log Viewer use a `UIObjectPool` to manage and reuse list entries, ensuring smooth performance even when handling hundreds of simulated logs.
*   **Autoload Singletons:** The project relies on globally accessible singleton scripts (found in the `autoload/` directory) to manage core systems:
    *   `ArchetypeAnalyzer`: Determines the player's "analyst archetype" (e.g., 'Cowboy', 'By-the-Book') by deriving metrics from the `ConsequenceEngine` choice history.
    *   `AudioManager`: Manages playback of music and sound effects, with semantic helpers for UI and notifications.
    *   `ConfigManager`: Manages persistent user settings (Volume, Display) saved in `user://settings.cfg`.
    *   `ConsequenceEngine`: The source of truth for player choices; logs history and triggers delayed, cascading consequences, including "Kill Chain" escalations.
    *   `CorporateVoice`: Provides a library of corporate-toned phrases and templates for consistent narrative style.
    *   `DesktopWindowManager`: Manages the lifecycle, Z-ordering, and snapping of desktop application windows.
    *   `DialogueManager`: Centralized system for NPC dialogue flow, display, and choice-based scene transitions.
    *   `EmailSystem`: Backend manager for the email client tool, including discovery and threat processing.
    *   `EventBus`: The central hub for global signals, reducing coupling between managers.
    *   `FPSManager`: Persistent overlay for real-time performance tracking.
    *   `GameState`: Manages the current game mode (3D, 2D, or Dialogue) and pause state.
    *   `GlobalConstants`: Central authority for shared constants, event IDs, and severity enums.
    *   `LogSystem`: Backend manager for the SIEM log viewer, featuring a ring-buffer-style history to manage memory.
    *   `NarrativeDirector`: Manages scripted story flow (Shifts 1-5), NPC interactions, and shift report generation.
    *   `NetworkState`: Single source of truth for host information (IPs, Status, Criticality) utilizing a resource-driven registry.
    *   `NotificationManager`: Handles display and queuing of notification toasts on the desktop.
    *   `SaveSystem`: Manages JSON-based serialization of player metrics, world state, and ticket progress.
    *   `TerminalSystem`: Backend for the command-line tool, including command parsing, tracing, and host isolation.
    *   `TicketManager`: Handles the lifecycle of security incidents, managing timers and ambient noise tickets.
    *   `TimeManager`: Centralizes game timers to ensure consistency across scene transitions.
    *   `TransitionManager`: Manages visual fades and state transitions between 3D world and 2D desktop.
    *   `TutorialManager`: Manages the guided onboarding experience for the "Training Simulation."
    *   `ValidationManager`: Central authority for gameplay rules (e.g., verifying evidence before a compliant closure).

### Data Types (Resources):

*   `DialogueDataResource.gd`: Stores structured dialogue data (lines, choices, effects).
*   `EmailResource.gd`: Handles email metadata, clues, and risk analysis logic.
*   `HostResource.gd`: Defines metadata for network hosts (hostname, IP, criticality).
*   `LogResource.gd`: Manages log entry data and forensic report formatting.
*   `ShiftResource.gd`: Defines the sequence of events and narrative beats for a specific work shift.
*   `TicketResource.gd`: Manages incident state, required evidence, and Kill Chain escalation paths.

### Scene-Based Tools:

*   **SIEM Log Viewer**: For forensic log analysis and evidence collection.
*   **Email Analyzer**: For inspecting headers, scanning links, and quarantining threats.
*   **Terminal**: For network commands, tracing, and host isolation.
*   **Network Mapper**: Visualizes topology and real-time host status.
*   **Decryption Tool**: Specialized utility for ransomware recovery puzzles.
*   **SOC Handbook**: Central documentation resource for the player.
*   **Resource Monitor (Task Manager)**: For monitoring system load and event-driven performance impacts.
*   **Ticket Queue**: For managing and resolving active security incidents.

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

**Latest Test Results (Report 6):**
*   **Status:** PASSED (100% Success Rate)
*   **Suites:** 1 (Integration)
*   **Tests:** 2
*   **Duration:** 175ms
*   **Key Coverage:** 
    *   `test_full_shift_chain_progression`: Verified linear progression from Monday through Friday.
    *   `test_briefing_ids_are_assigned`: Verified all shift resources have associated briefing dialogues.

### Key File Locations:

*   **Global Systems:** `autoload/`
*   **Game Scenes:** `scenes/` (separated into `2d`, `3d`, and `ui`)
*   **Game Logic:** `scripts/`
*   **Data Definitions:** `resources/`
*   **Project Vision & Progress:** `sprint/`