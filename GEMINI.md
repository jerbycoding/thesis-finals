# GEMINI Project Analysis: VERIFY.EXE (Incident Response SOC Simulator)

## 1. Project Overview

This project is a single-player, 3D/2D hybrid simulation game titled **"VERIFY.EXE"** (also referred to as **Incident Response: SOC Simulator**). It is being developed using the **Godot Engine (v4.3+)** and **GDScript**. The project is configured for Godot 4.4 features.

The core concept places the player in the role of a Security Operations Center (SOC) analyst. The gameplay revolves around managing and investigating security incident tickets within a simulated corporate environment. The central theme is the tension between following slow, safe protocols and succumbing to pressure for fast, risky resolutions, with every decision having cascading consequences.

### Architecture and Core Systems:

*   **Hybrid 2D/3D World:** The player navigates a 3D office environment but interacts with a 2D desktop interface to use analysis tools. This transition is a core architectural feature managed by `TransitionManager.gd` and `GameState.gd`.
*   **Autoload Singletons:** The project relies heavily on globally accessible singleton scripts (found in the `autoload/` directory) to manage the game's core systems. These include:
    *   `ArchetypeAnalyzer`: Tracks player metrics (e.g., risks taken, time per ticket) to determine their "analyst archetype" (e.g., 'Cowboy', 'By-the-Book', 'Negligent') at the end of a shift.
    *   `AudioManager`: Manages the playback of background music and sound effects.
    *   `ConsequenceEngine`: A crucial system that logs player choices and triggers delayed, cascading consequences, including the "Kill Chain" escalation logic and "Black Ticket" redemption paths.
    *   `CorporateVoice`: Provides a library of corporate-toned phrases and RichText templates to ensure a consistent narrative style in UI text and notifications.
    *   `DesktopWindowManager`: Manages the lifecycle, positioning, Z-ordering, and snapping of all desktop application windows.
    *   `DialogueManager`: Centralized system for managing NPC dialogue flow, displaying the dialogue UI, and handling player choices, ensuring persistence across scene changes.
    *   `EmailSystem`: Backend manager for the player's email client tool, including discovery and processing.
    *   `FPSManager`: Provides a persistent overlay for real-time performance tracking.
    *   `GameState`: Manages the current game mode (3D, 2D, or Dialogue).
    *   `GlobalConstants`: Central authority for shared constants, event IDs, and severity enums.
    *   `LogSystem`: Backend manager for the SIEM log viewer tool, featuring dynamic log discovery and event-driven log flooding.
    *   `NarrativeDirector`: Manages the scripted story flow, shifts (1, 2, and 3), NPC interactions, and shift report generation.
    *   `NetworkState`: Manages the state (e.g., Clean, Infected, Isolated) of all hosts in the simulated corporate network, utilizing dynamic resource discovery.
    *   `NotificationManager`: Handles the display and queuing of notification toasts on the desktop.
    *   `SaveSystem`: Manages JSON-based serialization and deserialization of game state, allowing progress to persist across shifts.
    *   `TerminalSystem`: Backend manager for the terminal/command-line tool, including command parsing, scanning, and host isolation.
    *   `TicketManager`: Handles the lifecycle of security incidents (tickets), including timers, ambient spawning, and evidence attachment.
    *   `TransitionManager`: Manages the visual and state transitions (fades, overlays) between the 3D world, 2D desktop, and scene changes.
    *   `ValidationManager`: The central authority for gameplay rules and logic validation (e.g., checking for sufficient evidence before ticket closure).
*   **Resource-Based Data:** Game data like tickets, logs, emails, and dialogue content are defined using custom `Resource` scripts (e.g., `TicketResource.gd`, `EmailResource.gd`, `DialogueDataResource.gd`, `ShiftResource.gd`).
*   **New Data Types:** 
    *   `DialogueDataResource.gd`: Stores structured dialogue data (NPC name, portrait, lines, choices, effects).
    *   `ShiftResource.gd`: Defines the sequence of events and narrative beats for a specific work shift.
*   **Scene-Based Tools:** The 2D analysis tools are built as individual scenes (`.tscn`) managed by the `DesktopWindowManager`. These include:
    *   **SIEM Log Viewer**: For forensic log analysis and evidence collection.
    *   **Email Analyzer**: For inspecting headers, scanning links, and quarantining threats.
    *   **Terminal**: For network commands, host scanning, and isolation.
    *   **SOC Handbook**: A central documentation resource for the player.
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

**NOTE:** AI agents are instructed **not** to run these tests automatically to prevent excessive token consumption. Users should execute tests manually.

### Running Tests:
1.  Ensure GdUnit4 is enabled in the Godot project.
2.  Tests can be run from the Godot editor's GdUnit4 panel or via the command line.

**To run tests from the command line (Windows example):**
```cmd
addons/gdUnit4/runtest.cmd --godot_binary "C:\Path\To\Your\Godot.exe" -a "res://tests/unit/"
```

**Test File Location:** Unit tests are located in `tests/unit/`, and integration tests in `tests/integration/`.

## 3. Development Conventions

### Code Style:

*   **GDScript:** All game logic is written in GDScript.
*   **Naming:**
    *   Nodes and files use `PascalCase` (e.g., `TicketManager`, `App_SIEMViewer.tscn`).
    *   Variables and functions use `snake_case` (e.g., `current_ticket`, `_on_log_added`).
    *   Private functions are prefixed with an underscore (`_`).
*   **Structure:**
    *   Core systems are implemented as autoload singletons for global access.
    *   Data structures are defined as `class_name` extensions of the `Resource` type.
    *   UI scenes and their logic are clearly separated.
    *   The `_ready` function often uses `await get_tree().process_frame` to avoid race conditions.

### Project Management:

*   **Sprint-Based Development:** The `sprint/` directory contains detailed markdown files outlining the development roadmap.
*   **Systems-First Approach:** Robust, interconnected systems (like the consequence and ticket engines) are prioritized over static content.

### Key File Locations:

*   **Global Systems:** `autoload/`
*   **Game Scenes:** `scenes/` (separated into `2d`, `3d`, and `ui`)
*   **Game Logic:** `scripts/` (mirrors the scene structure)
*   **Data Definitions:** `resources/`
*   **Data Content:** `resources/tickets/`, `resources/logs/`, `resources/emails/`, `resources/shifts/`
*   **Project Vision & Progress:** `sprint/`
*   **Tests:** `tests/`
