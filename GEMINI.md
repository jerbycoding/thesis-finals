# GEMINI Project Analysis: Incident Response SOC Simulator

## 1. Project Overview

This project is a single-player, 3D/2D hybrid simulation game titled **"Incident Response: SOC Simulator"**. It is being developed using the **Godot Engine (v4.3+)** and **GDScript**. The project is configured for Godot 4.4 features.

The core concept places the player in the role of a Security Operations Center (SOC) analyst. The gameplay revolves around managing and investigating security incident tickets within a simulated corporate environment. The central theme is the tension between following slow, safe protocols and succumbing to pressure for fast, risky resolutions, with every decision having cascading consequences.

### Architecture and Core Systems:

*   **Hybrid 2D/3D World:** The player navigates a 3D office environment but interacts with a 2D desktop interface to use analysis tools. This transition is a core architectural feature managed by `TransitionManager.gd` and `GameState.gd`.
*   **Autoload Singletons:** The project relies heavily on globally accessible singleton scripts (found in the `autoload/` directory) to manage the game's core systems. These include:
    *   `ArchetypeAnalyzer`: Tracks player metrics (e.g., risks taken, time per ticket) to determine their "analyst archetype" (e.g., 'Cowboy', 'By-the-Book') at the end of a shift.
    *   `AudioManager`: Manages the playback of background music and sound effects.
    *   `ConsequenceEngine`: A crucial system that logs player choices and triggers delayed, cascading consequences.
    *   `CorporateVoice`: Provides a library of corporate-toned phrases to ensure a consistent narrative style in UI text and notifications.
    *   `DesktopWindowManager`: Manages the lifecycle, positioning, and Z-ordering of all desktop application windows.
    *   `DialogueManager`: Centralized system for managing NPC dialogue flow, displaying the dialogue UI, and handling player choices, ensuring persistence across scene changes.
    *   `EmailSystem`: Backend manager for the player's email client tool.
    *   `GameState`: Manages the current mode (3D, 2D, or Dialogue).
    *   `LogSystem`: Backend manager for the SIEM log viewer tool.
    *   `NarrativeDirector`: Manages the scripted story flow and NPC interactions.
    *   `NetworkState`: Manages the state (e.g., Clean, Infected, Isolated) of all hosts in the simulated corporate network.
    *   `TerminalSystem`: Backend manager for the terminal/command-line tool.
    *   `TicketManager`: Handles the lifecycle of security incidents (tickets).
    *   `TransitionManager`: Manages the visual and state transitions between the 3D world and the 2D desktop.
*   **Resource-Based Data:** Game data like tickets, logs, emails, and dialogue content are defined using custom `Resource` scripts (e.g., `TicketResource.gd`, `EmailResource.gd`, `DialogueDataResource.gd`). This is a standard and effective Godot practice for creating custom, reusable data structures.
*   **New Data Type:** `DialogueDataResource.gd` is a new custom resource used to store structured dialogue data (NPC name, portrait, lines, choices, effects) separate from NPC scripts.
*   **Scene-Based Tools:** The 2D analysis tools (SIEM, Email Analyzer, Terminal) are built as individual scenes (`.tscn`) with corresponding GDScript files for their logic, located in `scenes/2d/apps/` and `scripts/2d/apps/`.

## 2. Building and Running
##
This is a standard Godot project. There are no external build scripts or package managers required.

### Running the Game:

1.  **Open the project** in the Godot Engine (version 4.3 or higher).
2.  The main scene is `res://scenes/ui/TitleScreen.tscn`.
3.  **Press the "Play" button** (F5) in the top-right of the Godot editor to run the game.

### Testing:

The project now integrates the **GdUnit4** testing framework for automated unit and integration tests.

**NOTE:** To prevent excessive token consumption and potential execution loops, the AI is instructed **not** to run these tests. The user should execute test commands manually in their own terminal.

### Running Tests:
1.  Ensure you have GdUnit4 installed as an addon in your project.
2.  Open your project in the Godot Engine (version 4.3+).
3.  Tests can be run directly from the Godot editor's GdUnit4 panel or via the command line.

**To run tests from the command line (Windows example):**
Execute the `runtest.cmd` script located in your `addons/gdUnit4/` directory from your project's root:

```cmd
addons/gdUnit4/runtest.cmd --godot_binary "C:\Path\To\Your\Godot.exe" -a "res://tests/unit/"
```

*   Replace `"C:\Path\To\Your\Godot.exe"` with the absolute path to your Godot executable.
*   The `-a "res://tests/unit/"` argument specifies to run all tests in the `tests/unit/` directory.

**To run tests from the command line (Linux/macOS example):**
```bash
addons/gdUnit4/runtest.sh --godot_binary "/path/to/your/Godot" -a "res://tests/unit/"
```

**Test File Location:** Unit tests are located in the `tests/unit/` directory.

## 3. Development Conventions

The project follows a clear and consistent set of conventions.

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
    *   The `_ready` function often uses `await get_tree().process_frame` to avoid race conditions when accessing nodes.

### Project Management:

*   **Sprint-Based Development:** The `sprint/` directory contains highly detailed markdown files that outline a rigorous, week-by-week development plan. This is the primary source of truth for the project's vision, goals, and progress.
*   **Systems-First Approach:** The development philosophy prioritizes building robust, interconnected systems (like the ticket and consequence engines) before focusing on content or polish.

### Key File Locations:

*   **Global Systems:** `autoload/`
*   **Game Scenes:** `scenes/` (separated into `2d`, `3d`, and `ui`)
*   **Game Logic:** `scripts/` (mirrors the scene structure)
*   **Data Definitions:** `resources/` (e.g., `TicketResource.gd`)
*   **Data Content:** `resources/tickets/`, `resources/logs/`, `resources/emails/`
*   **Project Vision & Progress:** `sprint/`