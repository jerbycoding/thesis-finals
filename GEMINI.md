# GEMINI Project Analysis: VERIFY.EXE (Incident Response SOC Simulator)

## 1. Project Overview

This project is a single-player, 3D/2D hybrid simulation game titled **"VERIFY.EXE"** (also referred to as **Incident Response: SOC Simulator**). It is being developed using the **Godot Engine (v4.3+)** and **GDScript**, utilizing Godot 4.4 features.

The core concept places the player in the role of a Security Operations Center (SOC) analyst. The gameplay revolves around managing and investigating security incident tickets within a simulated corporate environment. The central theme is the tension between following slow, safe protocols and succumbing to pressure for fast, risky resolutions, with every decision having cascading consequences.

### Architecture and Core Systems:

*   **Hybrid 2D/3D World:** Transitions between 3D office navigation and 2D workstation interaction are managed by `TransitionManager.gd`. This system includes player camera animations (sitting/standing) and high-fidelity `MonitorInputBridge` that projects interactive desktop UIs onto 3D meshes using anisotropic filtering and unshaded rendering for text clarity.
*   **Unified State Authority:** `GameState.gd` serves as the single source of truth for game modes (`MODE_3D`, `MODE_2D`, `MODE_DIALOGUE`, `MODE_MINIGAME`, `MODE_UI_ONLY`). It enforces mouse authority and UI blocking (modals) globally.
*   **Procedural Truth System:** The `VariableRegistry` generates "Truth Packets" for incidents, **Asset Identities** (MAC, Firmware, Serial) for physical hardware, and **Partner Packets** for supply-chain events. This ensures semantic consistency across SIEM, Email, and physical props.
*   **Heat & Inheritance Engine:** Managed by `HeatManager.gd`, difficulty scales weekly. "Vulnerability Inheritance" caches indicators from "Efficient" closures, which then resurface in future, more severe incidents.
*   **Kill Chain Escalation:** `ConsequenceEngine.gd` tracks incident lifecycles through stages: Infiltration, Propagation, Exfiltration, and Impact. Risky closures increase escalation probabilities, eventually triggering "Zero Day" events or "Black Ticket" recovery missions.
*   **Social Dynamics & Favors:** NPC relationships impact gameplay. High approval allows trading points for "Favors" (e.g., automated evidence surfacing or IT bandwidth boosts), while poor standing triggers "Terminal Glitches."
*   **Performance Optimization:** UI-heavy tools use a **`UIObjectPool`** to reuse list entries, and **`TimeManager`** centralizes all game timers to prevent crashes during scene transitions.
*   **Autoload Singletons:**
	*   `ArchetypeAnalyzer`: Derives styles (Cowboy, By-the-Book, etc.) from metric history.
	*   `AudioManager`: Manages SFX, music, and floor-based ambient loops with dynamic typewriter sync.
	*   `ConfigManager`: Persists user settings (Volume, Display) in `user://settings.cfg`.
	*   `ConsequenceEngine`: Tracks choices, manages Kill Chain, and handles emergent NPC logic.
	*   `CorporateVoice`: Library of formatted corporate-toned phrases for consistent narrative.
	*   `DebugManager`: Hotkey jumps (F1/F2 Shifts), Chaos triggers (F9), and real-time metric HUD.
	*   `DesktopWindowManager`: Manages windows, Z-ordering, quadrant fanning, and `AppPermissionProfile` restrictions.
	*   `DialogueManager`: Handles structured NPC branching dialogue and choice-based effects.
	*   `EmailSystem`: Backend for the email client with data-driven risk analysis and training filters.
	*   `EventBus`: Central decoupled hub for all global signals.
	*   `FPSManager`: Persistent performance overlay for engine optimization.
	*   `GlobalConstants`: Absolute authority for physics layers, UI colors, and narrative IDs.
	*   `HeatManager`: Manages difficulty scaling and vulnerability inheritance.
	*   `IntegrityManager`: Manages organization stability ("HP"), handling decay and failure states.
	*   `LogSystem`: Backend for SIEM logs with ring-buffer history and event-driven log injection.
	*   `NarrativeDirector`: Manages the 7-day arc, scripted events, and weekend floor requirements.
	*   `NetworkState`: Authority for host metadata and real-time statuses (Clean, Infected, Isolated).
	*   `NotificationManager`: Handles the display, queuing, and stacking of notification toasts.
	*   `ResourceAuditManager`: Performs startup connectivity checks between Shifts, Tickets, and Logs.
	*   `SaveSystem`: JSON-based serialization of world state, metrics, and shift progress.
	*   `TerminalSystem`: Backend for command parsing (scan, trace, isolate) and event multipliers.
	*   `TicketManager`: Handles incident lifecycle, ambient noise spawning, and log attachments.
	*   `TimeManager`: Centralized timer registry for cross-scene stability.
	*   `TransitionManager`: Manages 2D/3D transitions and the "Secure Login" sequence.
	*   `TutorialManager`: Manages data-driven certification using `TutorialStepResource`.
	*   `ValidationManager`: Central authority for IR gameplay rules (e.g., scan-before-isolate).
	*   `VariableRegistry`: Procedural data provider for consistent technical indicators.

### Data Types (Resources):

*   **AppConfigResource**: Defines application metadata, scene paths, and category-based restrictions.
*   **AppPermissionProfile**: Whitelists authorized applications for specific narrative phases.
*   **DialogueDataResource**: Structured branching dialogue with choice-based effect dictionaries.
*   **EmailResource**: Metadata, forensic clues, and "hidden risk" consequence triggers.
*   **HostResource**: Network host metadata (IP, OS type, criticality).
*   **LogResource**: Log entry data and forensic report templates.
*   **ShiftResource**: Narrative sequences, random event pools, and weekend minigame types.
*   **TicketResource**: Incident state, required evidence IDs, and Kill Chain escalation paths.
*   **TutorialSequenceResource**: Orchestrates the certification module via multiple steps.
*   **TutorialStepResource**: Defines individual tutorial triggers, instructions, and visual focus nodes.
*   **MinigameConfigs**: `CalibrationMinigameConfig` and `HardwareRecoveryConfig` drive weekend parameters.

### Scene-Based Tools (Enterprise-Clean Aesthetic):

*   **SIEM Log Viewer**: Forensic analysis with volume graphs, search/filtering, and zebra-stripping.
*   **Email Analyzer**: SaaS-inspired UI for header forensics, attachment scanning, and link reputation.
*   **Terminal**: TUI-style command interface for active defense and host isolation.
*   **Network Mapper**: Interactive topology dashboard visualizing host priority and real-time status.
*   **Decryption Tool**: High-stakes hex-based puzzle utility for ransomware recovery.
*   **SOC Handbook**: PDF-style infinite scroll document reader for IR procedures.
*   **Elevator UI**: Floor-based navigation with integrated audio ambiance transitions.
*   **Ticket Queue**: Triage interface for managing incidents and building forensic cases.

### Narrative Structure & Progression:

The game follows a 14-day expanded narrative arc across two weeks.
*   **Week 1 (Establishment)**: Focus on standard 2D workstation IR loops, culminating in a Friday "Zero Day" event and physical weekend maintenance shifts (Infrastructure Audit and Hardware Recovery).
*   **Week 2 (Escalation & Paranoia)**: High-stakes technical challenges including **Admin Lockouts** (forcing Decryption use for terminal access), **Wiper Scripts** (real-time evidence destruction), and **Internal Betrayal** investigations.
*   **Weekends**: 
    *   **Saturday (Infrastructure Audit)**: Physical 3D navigation in the Network Hub; features signal calibration minigames.
    *   **Sunday (Hardware Recovery)**: Physical hardware maintenance in the Server Vault; includes blade slotting and RAID sync.
*   **Endings**: Based on metrics: **Fired** (Negligence), **Bankrupt** (Integrity hit 0%), and **Victory** (Promotion after Week 2 Friday "Total War").

## 2. Building and Running

This is a standard Godot project. There are no external build scripts or package managers required.

### Running the Game:

1.  **Open the project** in the Godot Engine (version 4.3 or higher).
2.  The main scene is `res://scenes/ui/TitleScreen.tscn`.
3.  **Press the "Play" button** (F5) in the top-right of the Godot editor to run the game.

### Testing:

The project integrates the **GdUnit4** testing framework.

*   **Manual Execution:** Execute tests via the GdUnit4 panel in Godot.
*   **Latest Test Status**: PASSED (100% Success Rate) covering shift progression, resource connectivity, and Kill Chain logic.

### Key File Locations:

*   **Global Systems:** `autoload/`
*   **Game Scenes:** `scenes/` (2d, 3d, ui)
*   **Logic Scripts:** `scripts/` (2d, 3d, ui)
*   **Data Resources:** `resources/` (tickets, logs, emails, hosts, shifts)
*   **Project Documentation**: `sprint/` and `IDEA.md`