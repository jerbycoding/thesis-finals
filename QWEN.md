# QWEN.md — Project Context for VERIFY.EXE

> **Project:** Incident Response: SOC Simulator (VERIFY.EXE)
> **Engine:** Godot 4.4 | **Language:** GDScript
> **Thesis:** Dual-role symmetric design with Mirror Mode forensic report

---

## Quick Reference

| Document | Purpose |
|----------|---------|
| [GEMINI.md](./GEMINI.md) | **Technical authority** — Full implementation spec, signal registry, file inventory |
| [HACKER.md](./HACKER.md) | Design overview & narrative pitch |
| [PHASE/](./PHASE/) | High-level phase contracts (6 phases) |
| [phase-sprint/](./phase-sprint/) | Detailed sprint tasks with BLOCKER tags |

---

## Architecture Principles

### 1. Dual-Axis State System
```gdscript
# GameState.gd — Two orthogonal axes:
var current_mode := GameMode.MODE_2D    # Interaction context (3D/2D/UI/MINIGAME)
var current_role := Role.ANALYST        # Campaign identity (ANALYST/HACKER)
```
**Never conflate these.** Role is set via `GameState.switch_role()` only (10-step sequence).

### 2. Role Guard Pattern
```gdscript
# In Analyst-only singletons:
if GameState.current_role != GameState.Role.HACKER:
    return

# In Hacker-only singletons:
if GameState.current_role != GameState.Role.HACKER:
    return
```

### 3. Signal Hygiene
- `TraceLevelManager` and `RivalAI` **connect/disconnect** from EventBus on hacker shift start/end
- They do NOT use always-on listeners with `_process` guards only
- Four singletons must NEVER consume `offensive_action_performed`:
  - `ConsequenceEngine`, `ValidationManager`, `IntegrityManager`, `TicketManager`

### 4. Timestamp Authority
**All timestamps use `ShiftClock.elapsed_seconds`** — never `Time.get_unix_time_from_system()`.
Required for Mirror Mode correlation engine.

---

## Key Systems

### Hacker Role Singletons (Autoload Order Matters)
| Order | Singleton | Purpose |
|-------|-----------|---------|
| 1 | `HackerHistory.gd` | Forensic log — writes to disk on every offensive action |
| 2 | `TraceLevelManager.gd` | Hacker's exposure meter (0-100%), manages decay + isolation lock |
| 3 | `RivalAI.gd` | State machine: IDLE → SEARCHING → LOCKDOWN |
| 4 | `BountyLedger.gd` | Tracks bounty points from contracts |
| 5 | `IntelligenceInventory.gd` | Stores exfiltrated data resources (write-on-add for crash safety) |

---

## Complete Autoload Registry (56 files)

### Core State & Configuration
| File | Status | Description |
|------|--------|-------------|
| `GameState.gd` | ✅ Existing | Master state: `GameMode` (3D/2D) + `Role` (Analyst/Hacker), `switch_role()` 11-step sequence |
| `GlobalConstants.gd` | ✅ Existing | All enums, colors, trace costs, thresholds, save paths — single source of truth |
| `EventBus.gd` | ✅ Existing | 40+ signals for decoupled communication; 13 Hacker signals to add |
| `ConfigManager.gd` | ✅ Existing | User settings persistence (graphics, audio, gameplay difficulty) |
| `VariableRegistry.gd` | ✅ Existing | Procedural truth packets (IPs, MACs, hostnames) for semantic consistency |

### Analyst Campaign Systems
| File | Status | Description |
|------|--------|-------------|
| `TicketManager.gd` | ✅ Existing | Ticket lifecycle: spawn, timer, evidence attachment, completion |
| `LogSystem.gd` | ✅ Existing | SIEM log authority: reveal, pool, `prune_logs_for_host()` to add |
| `EmailSystem.gd` | ✅ Existing | Email analysis: headers, attachments, links inspection |
| `TerminalSystem.gd` | ✅ Existing | Defensive commands (`scan`, `isolate`, `trace`); offensive cmds to add |
| `NetworkState.gd` | ✅ Existing | Host topology; dual-context (Analyst/Hacker) to add |
| `IntegrityManager.gd` | ✅ Existing | Organization HP (0-100%); role guard to bypass for Hacker |
| `ConsequenceEngine.gd` | ✅ Existing | Kill Chain escalation, NPC relationships, follow-up tickets |
| `ValidationManager.gd` | ✅ Existing | Gameplay rules (compliant completion, isolation auth); role guard needed |
| `HeatManager.gd` | ✅ Existing | Week progression, heat multiplier, vulnerability buffer |
| `ArchetypeAnalyzer.gd` | ✅ Existing | Analyzes player behavior → AI profile for RivalAI mirroring |
| `CorporateVoice.gd` | ✅ Existing | Corporate-speak phrase generator for terminal/UI text |
| `TutorialManager.gd` | ✅ Existing | Guided mode certification sequence |

### Narrative & Progression
| File | Status | Description |
|------|--------|-------------|
| `NarrativeDirector.gd` | ✅ Existing | Shift flow, event scheduling, scripted triggers; `hacker_shifts/` loading to add |
| `DialogueManager.gd` | ✅ Existing | NPC dialogue trees, remote dialogue fallback |
| `TimeManager.gd` | ✅ Existing | Centralized timer registry; `clear_all_timers()` on role switch |

### UI & Window Management
| File | Status | Description |
|------|--------|-------------|
| `DesktopWindowManager.gd` | ✅ Existing | Window lifecycle, app permissions, `HackerAppProfile` loading to add |
| `UIObjectPool.gd` | ✅ Existing | UI component pooling (`scripts/ui/`); `flush()` on role switch |
| `NotificationManager.gd` | ✅ Existing | Toast notifications (success/warning/error/info) |
| `TransitionManager.gd` | ✅ Existing | 3D↔2D transitions, secure login, dossier phase; role-param login to add |
| `FPSManager.gd` | ✅ Existing | Framerate watchdog; shader quality downgrade below 30fps |

### Audio & Immersion
| File | Status | Description |
|------|--------|-------------|
| `AudioManager.gd` | ✅ Existing | SFX, music, ambient loops; `swap_ambient_loop(role)` to add |

### Debug & Quality Assurance
| File | Status | Description |
|------|--------|-------------|
| `DebugManager.gd` | ✅ Existing | F1-F12 hotkeys, debug HUD; F3/F4 Hacker commands to add |
| `ResourceAuditManager.gd` | ✅ Existing | Connectivity audit (shifts→tickets→logs); `hacker_shifts/` scan to add |

### Hacker Role Singletons (TO CREATE)
| File | Status | Description |
|------|--------|-------------|
| `HackerHistory.gd` | ❌ Missing | Forensic action log; writes to disk on every `offensive_action_performed` |
| `TraceLevelManager.gd` | ❌ Missing | Trace meter (0-100%), passive decay, isolation lock state |
| `RivalAI.gd` | ❌ Missing | AI Analyst state machine (IDLE→SEARCHING→LOCKDOWN), isolation countdown |
| `BountyLedger.gd` | ❌ Missing | Bounty point tracking from ransomware/contracts |
| `IntelligenceInventory.gd` | ❌ Missing | Exfiltrated data storage; write-on-add for crash safety |

---

## Project Directory Structure

> **Last updated:** April 4, 2026 — reflects actual filesystem state

### autoload/ (32 `.gd` files — all registered as singletons)

```
autoload/
├── ─── State & Core ───
├── GameState.gd              # GameMode + Role enum, switch_role() 11-step sequence
├── GlobalConstants.gd        # Enums, trace costs, thresholds, event IDs, save paths
├── EventBus.gd               # 40+ decoupled signals; role boundary guards
├── VariableRegistry.gd       # Procedural truth packets (IPs, MACs, hostnames)
├── ConfigManager.gd          # User settings persistence (graphics, audio, difficulty)
│
├── ─── Analyst Campaign ───
├── TicketManager.gd          # Ticket lifecycle + evidence attachment
├── LogSystem.gd              # SIEM log authority, reveal pool, pruning
├── EmailSystem.gd            # Email analysis: headers, attachments, links
├── TerminalSystem.gd         # scan/isolate/trace/restore + exploit/pivot (Hacker)
├── NetworkState.gd           # Host topology, dual-context (ANALYST/HACKER)
├── IntegrityManager.gd       # Org HP (0-100%), role guard bypasses for Hacker
├── ConsequenceEngine.gd      # Kill Chain escalation, NPC relationships
├── ValidationManager.gd      # IR gameplay rules, role guard for Hacker
├── HeatManager.gd            # Week progression, heat multiplier, vulnerability buffer
├── ArchetypeAnalyzer.gd      # Player behavior → AI profile for RivalAI mirroring
├── CorporateVoice.gd         # Corporate-speak phrase generator
├── TutorialManager.gd        # Guided mode certification sequence
│
├── ─── Narrative & Progression ───
── NarrativeDirector.gd      # Shift flow, event scheduling, scripted triggers
├── DialogueManager.gd        # NPC dialogue trees, remote dialogue fallback
├── TimeManager.gd            # Centralized timer registry, clear_all_timers() on role switch
│
├── ─── UI & Window Management ───
── DesktopWindowManager.gd   # Window lifecycle, app permissions, theme switching
├── NotificationManager.gd    # Toast notifications (success/warning/error/info)
├── TransitionManager.gd      # 3D↔2D transitions, secure login, connection lost
├── FPSManager.gd             # Framerate watchdog, shader quality fallback <30fps
├── UIObjectPool.gd           # UI component pooling, flush() on role switch
│
├── ─── Audio & Immersion ───
── AudioManager.gd           # SFX, music, ambient loops
│
├── ─── Debug & QA ───
├── DebugManager.gd           # F1-F12 hotkeys, debug HUD
├── DebugTools.gd             # Additional debug utilities
├── ResourceAuditManager.gd   # Connectivity audit (shifts→tickets→logs)
│
├── ─── Hacker Role (Phase 1-3 Complete) ───
├── HackerHistory.gd          # Forensic log, disk persistence, isolation recording
├── TraceLevelManager.gd      # Trace meter 0-100%, passive decay, isolation lock
├── RivalAI.gd                # AI state machine: IDLE→SEARCHING→LOCKDOWN→ISOLATING
│
├── ─── Hacker Role (Phase 4+ Pending) ───
└── BountyLedger.gd           # TODO — bounty tracking from contracts
    IntelligenceInventory.gd  # TODO — exfiltrated data storage
```

### scenes/ (120 `.tscn` files)

```
scenes/
├── InteractableComputer.tscn # 3D computer interaction trigger
├── Player3D.tscn             # First-person player controller
├── SOC_Office.tscn           # Main SOC office 3D environment
├── office_playground.tscn    # Dev/test playground
│
├── 3d/
│   ├── ─── Rooms ───
│   ├── HackerRoom.tscn       # Hacker campaign safe house
│   ├── AnalystWingRoom.tscn
│   ├── BriefingRoom.tscn
│   ├── ExecutiveSuite.tscn
│   ├── JuniorAnalystRoom.tscn
│   ├── SeniorAnalystOffice.tscn
│   ├── ServerVault.tscn
│   ├── WorkstationRoom.tscn
│   ├── NetworkHub.tscn
│   ├── MainMenu3D.tscn
│   ├── TutorialWaypoint.tscn
│   │
│   ├── ─── NPCs ───
│   ├── NPC_Auditor.tscn
│   ├── NPC_CISO.tscn
│   ├── NPC_Helpdesk.tscn
│   ├── NPC_ITSupport.tscn
│   ├── NPC_JuniorAnalyst.tscn
│   ├── NPC_NetworkSpecialist.tscn
│   ├── NPC_SeniorAnalyst.tscn
│   ├── NPC_VaultTechnician.tscn
│   ├── NPC_Victim.tscn
│   │
│   └── props/
│       ├── Prop_Router.tscn
│       └── graybox/          # 30+ graybox placeholder props (desks, servers, etc.)
│
├── 2d/
│   ├── ComputerDesktop.tscn  # Main desktop container (taskbar, start menu, window area)
│   ├── AmbientDesktop.tscn   # 3D monitor projection mirror
│   ├── AmbientWindow.tscn    # Ambient 3D monitor app frame
│   ├── DesktopIcon.tscn
│   ├── DesktopSearchBar.tscn
│   ├── StartMenu.tscn
│   ├── StartMenuAppButton.tscn
│   ├── TaskbarIcon.tscn
│   │
│   └── apps/
│       ├── ─── Analyst Apps (9) ───
│       ├── App_Decryption.tscn       # Anti-ransomware puzzle minigame
│       ├── App_EmailAnalyzer.tscn    # Email inspection tool
│       ├── App_Handbook.tscn         # SOC reference guide
│       ├── App_NetworkMapper.tscn    # Network topology viewer
│       ├── App_ShiftReport.tscn      # End-of-shift summary
│       ├── App_SIEMViewer.tscn       # Log stream viewer
│       ├── App_TaskManager.tscn      # Active ticket dashboard
│       ├── App_Terminal.tscn         # Command-line interface
│       ├── App_TicketQueue.tscn      # Ticket list
│       │
│       └── components/
│           ├── WindowFrame.tscn      # Draggable/resizable app wrapper
│           ├── CompletionModal.tscn
│           ├── EmailListEntry.tscn
│           ├── ForensicReportModal.tscn
│           ├── LogEntry.tscn
│           ├── NetworkNode.tscn
│           ├── TicketArtifactTag.tscn
│           └── TicketCard.tscn
│
└── ui/
    ├── ─── HUD & Overlays ───
    ├── UnifiedHUD.tscn         # Main in-game HUD
    ├── TabletHUD.tscn          # Tablet-mode HUD
    ├── TutorialHUD.tscn
    ├── MaintenanceHUD.tscn
    ├── NotificationToast.tscn
    ├── PauseMenu.tscn
    ├── StartupLogo.tscn
    ├── TransitionOverlay.tscn
    ├── MatrixRain.tscn
    │
    ├── ─── Dialogue & Comms ───
    ├── DialogueBox.tscn
    ├── CommsSidebar.tscn
    ├── CommsMessage.tscn
    │
    ├── ─── Minigames ───
    ├── CalibrationMinigame.tscn    # Oscillating bar skill check (used by Decryption)
    ├── RaidSyncMinigame.tscn       # Multi-stream timing (TODO: Exfiltrator)
    ├── RuleSliderMinigame.tscn     # Precision sliders (TODO: Wiper)
    │
    ├── ─── Specialty UI ───
    ├── ForensicTablet.tscn
    ├── ThreatIntelDossier.tscn
    ├── DiagnosticUI.tscn
    ├── ATG_SelectionBox.tscn
    ├── AuditSelectionModal.tscn
    ├── CertificationSummary.tscn
    ├── ElevatorUI.tscn
    ├── InteractionPrompt.tscn
    ├── RouterTechnicalTable.tscn
    ├── RunbookSidebar.tscn
    ├── TerminalMenu2D.tscn
    │
    └── endings/
        ├── Ending_Bankrupt.tscn
        └── Ending_Fired.tscn
```

### scripts/ (93 `.gd` files — scene scripts, not autoloads)

```
scripts/
├── PlayerController.gd       # 3D FPS controller
├── CollisionGenerator.gd     # Physics collision mesh generation
├── EnvironmentDirector.gd    # 3D environment state management
├── FileUtil.gd               # Resource loading utilities
│
├── 2d/
│   ├── ComputerDesktop.gd    # Main desktop logic
│   ├── AmbientDesktop.gd     # 3D monitor sync with real desktop
│   ├── AmbientWindow.gd      # Ambient app frame (loads scenes read-only)
│   ├── DesktopClock.gd
│   ├── DesktopIcon.gd
│   ├── ExitButton.gd
│   ├── StartMenu.gd
│   ├── StartMenuAppButton.gd
│   ├── TaskbarIcon.gd
│   ├── NotificationToast.gd
│   ├── ConsequenceTester.gd
│   ├── KillChainTester.gd
│   │
│   └── apps/
│       ├── App_Decryption.gd
│       ├── app_EmailAnalyzer.gd
│       ├── App_Handbook.gd
│       ├── App_NetworkMapper.gd
│       ├── App_ShiftReport.gd
│       ├── app_SIEMViewer.gd
│       ├── App_TaskManager.gd
│       ├── app_Terminal.gd
│       ├── app_TicketQueue.gd
│       │
│       └── components/
│           ├── WindowFrame.gd          # Draggable window frame, load_content()
│           ├── CompletionModal.gd
│           ├── EmailListEntry.gd
│           ├── ForensicReportModal.gd
│           ├── LogEntry.gd
│           ├── NetworkNode.gd
│           ├── TicketArtifactTag.gd
│           └── TicketCard.gd
│
├── 3d/
│   ├── ─── Player & Movement ───
│   ├── PlayerAnimator.gd
│   ├── MainMenu3D.gd
│   │
│   ├── ─── Interaction ───
│   ├── MonitorInputBridge.gd           # Projects 2D desktop onto 3D monitor
│   ├── InteractableDoor.gd
│   ├── InteractableAuditNode.gd
│   ├── AutoDoor.gd
│   ├── SlidingDoor.gd
│   ├── SwingingDoor.gd
│   ├── RoomTeleporter.gd
│   ├── WorkstationTeleporter.gd
│   │
│   ├── ─── NPCs ───
│   ├── NPC.gd                            # Base NPC behavior
│   ├── NPC_Auditor.gd
│   ├── NPC_CISO.gd
│   ├── NPC_Helpdesk.gd
│   ├── NPC_ITSupport.gd
│   ├── NPC_JuniorAnalyst.gd
│   ├── NPC_SeniorAnalyst.gd
│   ├── NPC_Victim.gd
│   ├── PatrolNPC.gd
│   ├── NPC_Helpdesk.gd
│   │
│   ├── ─── Props & Environment ───
│   ├── Prop_Monitor.gd
│   ├── Prop_WallClock.gd
│   ├── PropSpawner.gd
│   ├── HostStatusMonitor.gd
│   ├── PatchPanel.gd
│   ├── CarryableHardware.gd
│   ├── HardwareSocket.gd
│   ├── HardwareSpawner.gd
│   ├── GuidingLights.gd
│   ├── MixamoAnimator.gd
│   ├── ScrollingMaterial.gd
│   │
│   └── ── Tutorial ───
│       ├── TutorialTrigger.gd
│       ├── TutorialWaypoint.gd
│       └── WarWall.gd
│
└── ui/
    ├── ─── HUD ───
    ├── UnifiedHUD.gd
    ├── TabletHUD.gd
    ├── TutorialHUD.gd
    ├── MaintenanceHUD.gd
    ├── PauseMenu.gd
    │
    ├── ─── Minigames ───
    ├── MinigameBase.gd                   # Base class for all minigames
    ├── CalibrationMinigame.gd
    ├── RaidSyncMinigame.gd
    ├── RuleSliderMinigame.gd
    │
    ├── ─── Dialogue & Narrative ───
    ├── DialogueBox.gd
    ├── CommsSidebar.gd
    ├── CommsMessage.gd
    ├── ThreatIntelDossier.gd
    │
    ├── ─── Specialty ───
    ├── ForensicTablet.gd
    ├── DiagnosticUI.gd
    ├── ATG_SelectionBox.gd
    ├── AuditSelectionModal.gd
    ├── CertificationSummary.gd
    ├── ElevatorUI.gd
    ├── InteractionPrompt.gd
    ├── RouterTechnicalTable.gd
    ├── RunbookSidebar.gd
    ├── TerminalMenu2D.gd
    ├── MatrixRain.gd
    ├── VirtualCursor.gd
    │
    ├── ─── Endings ───
    ├── EndingScreen.gd
    ├── TerminalCredits.gd
    │
    └── UIObjectPool.gd                   # UI component pooling
```

### resources/ (340+ files)

```
resources/
├── ─── Core Resource Classes ───
├── AppConfigResource.gd        # App metadata: app_id, scene_path, restrictions
├── AppPermissionProfile.gd     # Permission gating for app visibility
├── EmailResource.gd
├── HostResource.gd             # + vulnerability_score, is_honeypot, bounty_value
├── LogResource.gd
├── ShiftResource.gd
├── TicketResource.gd
├── DialogueDataResource.gd
│
├── apps/                       # AppConfig instances (8 apps registered)
│   ├── decrypt.tres
│   ├── email.tres
│   ├── handbook.tres
│   ├── network.tres
│   ├── siem.tres
│   ├── taskmanager.tres
│   ├── terminal.tres
│   └── tickets.tres
│
├── dialogue/                   # NPC dialogue trees
│   ├── DialogueDataResource.gd
│   ├── ciso_*.tres             # CISO briefings, tutorial dialogue
│   ├── senior_analyst_*.tres   # Senior analyst interactions
│   ├── helpdesk_default.tres
│   ├── it_support_*.tres
│   ├── auditor_default.tres
│   ├── junior_analyst_default.tres
│   ├── network_specialist_default.tres
│   ├── vault_technician_default.tres
│   ├── victim_patrol_default.tres
│   └── staff_random_chatter.tres
│
├── emails/                     # Email instances (~50 emails)
│   ├── EMAIL-TRN-*.tres        # Tutorial emails
│   ├── EmailPhishing*.tres     # Phishing templates
│   ├── EmailSocialEng.tres
│   ├── EmailRansomNote.tres
│   ├── EmailShadow*.tres
│   ├── EmailNoise_*.tres       # Flavour/noise emails
│   └── ...
│
├── hosts/                      # Host definitions
├── logs/                       # Log templates
├── shifts/                     # Analyst shift definitions
├── tickets/                    # Ticket definitions
├── variable_pools/             # Procedural truth pools (IPs, MACs, etc.)
│
├── ─── Phase 4+ Hacker Content (NOT YET CREATED) ───
├── hacker_shifts/              # TODO — hacker campaign shifts (day_1-7.tres)
├── permissions/                # TODO — HackerAppProfile.tres
├── dialogues/broker/           # TODO — Broker dialogue trees
├── contracts/                  # TODO — ContractResource instances
└── intelligence/               # TODO — IntelligenceResource instances
```

---

## How Apps Load (Critical Pattern for Phase 4+)

**Two loading paths — both use `AppConfigResource` from `resources/apps/`:**

| Path | Where | What it does | Works? |
|------|-------|-------------|--------|
| **DesktopWindowManager** | Live desktop (2D) | `WindowFrame.instantiate()` → `load_content(scene)` → adds to `ContentContainer` | ✅ Working |
| **AmbientWindow** | 3D monitor view | `load(scene_path).instantiate()` → `_freeze_node_recursive()` → adds to `ContentArea` | ⚠️ Read-only mirror |

**Key pattern for new Hacker apps:**
1. Create `.tscn` scene with root `Control` + script
2. Mark **every** interactive node with `unique_name_in_owner = true` in the `.tscn`
3. Script uses `%NodeName` for all `@onready` references — **never** `$path/to/node`
4. Create `AppConfigResource` (`.tres`) in `resources/apps/`
5. Test via live desktop first — ambient 3D view is secondary

---

## Common Commands

### Running Tests (GdUnit4)
- Open Godot → GdUnit4 panel → Run All
- Baseline: 100% pass (Analyst campaign)
- New tests needed: Role guard verification, signal schema validation, timestamp alignment

### Debug Hotkeys
| Key | Analyst | Hacker |
|-----|---------|--------|
| F1 | Previous shift | Previous hacker shift |
| F2 | Next shift | Next hacker shift |
| F3 | — | Skip current shift |
| F4 | — | Force-complete contract |
| F9 | Chaos trigger | No-op (guarded) |

---

## Implementation Checklist Status

| Phase | Status | Sprint Tasks |
|-------|--------|--------------|
| Phase 1: Foundation | ✅ Consolidated | 7 tasks (01-04c) |
| Phase 2: Offensive Loop | ✅ Consolidated | 6 tasks (01-06) |
| Phase 3: AI Counter-Measures | ✅ **100% COMPLETE** | 5 tasks (01-05) |
| Phase 4: High-Impact Payloads | ✅ **100% COMPLETE** | 5 tasks (01-05). MVHR loop verified in Godot. |
| Phase 5: Narrative Arc | ⏳ **READY TO START** | 5 tasks (01-shift system, 02-broker dialogue, 03-honeypot, 04-save/load, 05-role switch flow). Sprint plan prepared in `phase-sprint/phase-5/`. |
| Phase 6: Integration & Polish | ⏳ Pending | Mirror Mode, glitch aesthetics, final testing. |

---

## Coding Conventions

### GDScript Style
- **Naming:** `snake_case` for variables/functions, `PascalCase` for classes/resources
- **Type Safety:** Use explicit types (`var count: int = 0`)
- **Signals:** Declare in class, emit with descriptive payload dictionaries
- **Guards:** Early return pattern for role/mode checks

### Resource Pattern
```gdscript
# Always export variables for editor configuration:
@export var vulnerability_score: float = 0.5
@export var is_honeypot: bool = false
```

### Singleton Communication
```gdscript
# Use EventBus — never call singletons directly for cross-system logic:
EventBus.offensive_action_performed.emit({
    action_type = "exploit",
    target = hostname,
    timestamp = ShiftClock.elapsed_seconds,
    result = "SUCCESS",
    trace_cost = GlobalConstants.TRACE_COST_EXPLOIT
})
```

---

## Thesis Value Propositions

1. **Modular Inversion:** 90%+ code reuse between Analyst/Hacker via role guards and inverted logic
2. **Mirror Mode:** Post-shift forensic report showing attack/detection correlation
3. **Symmetric AI:** RivalAI mirrors player's own ArchetypeAnalyzer data from Analyst campaign
4. **Crash-Safe Design:** Write-on-disk persistence, transition guards, recovery on load

---

## Known Gotchas

| Issue | Solution |
|-------|----------|
| Direct `current_role` assignment | **Forbidden** — always use `GameState.switch_role()` |
| Hardcoded trace costs | Use `GlobalConstants.TRACE_COST_*` |
| System time for timestamps | Use `ShiftClock.elapsed_seconds` only |
| Shader on 3D viewport | Apply only to 2D `CanvasLayer` |
| Android performance | FPS watchdog triggers `CanvasModulate` fallback below 30fps |
| Exfiltration ticks | Collapse consecutive ticks in `HackerHistory` for clean Mirror Mode display |

---

## Team & Workflow

| Role | Responsibility |
|------|----------------|
| Ezio | Architecture, thesis documentation, phase gates |
| Hans | AI systems (RivalAI, TraceLevelManager), testing |
| Mark | 3D environments, audio, content authoring |

**AI Workflow:**
- **Claude:** Architecture decisions, documentation review, phase gate checks
- **Gemini CLI:** Terminal operations, file generation, GDScript implementation
- **Qwen Code:** Context-aware assistance with project conventions

---

## Development Strategy: Solo Dev Momentum (Option C)

**Philosophy:** One vertical slice per phase. Each phase delivers ONE complete, testable mechanic — no parallel work, no context switching hell.

### Phase Roadmap (10 Weeks Total)

| Phase | Duration | ONE Thing to Complete | Playable? | Demo Script |
|-------|----------|----------------------|-----------|-------------|
| **Phase 1: Foundation** | 1 week | Role switching + themed login | ⚠️ Visual demo | "Switch to Hacker, see green login" |
| **Phase 2: First Tool** | 1.5 weeks | Terminal `exploit` + Trace system | ⚠️ Mechanic demo | "Exploit a host, watch Trace rise" |
| **Phase 3: AI Response** | 1.5 weeks | RivalAI reacts to exploit | ⚠️ Tension demo | "AI chases you, get caught at 100%" |
| **Phase 4: Win Condition** | 2 weeks | Ransomware OR Exfiltrator (pick ONE) | ✅ **MVHR** | "Complete 1 contract, win or lose" |
| **Phase 5: Campaign** | 2 weeks | 3-day arc (Days 1-3 only) | ✅ Campaign demo | "Play 3 days, meet Broker" |
| **Phase 6: Thesis** | 2 weeks | Mirror Mode + polish | ✅ **Thesis-Complete** | "See your actions vs. logs" |

### Why This Works for Solo Dev

1. **Week 1:** You see the Hacker room — feels real
2. **Week 2.5:** You exploit something — feels like a game
3. **Week 4:** AI catches you — there's tension
4. **Week 6:** You win — there's a loop
5. **Week 8:** Story unfolds — there's meaning
6. **Week 10:** Thesis complete — you're done

**Every 1-2 weeks, you ship ONE thing that works.** No "almost done" syndrome.

### Scope Safety Net

If you fall behind, here's what to cut **per phase**:

| Phase | Cut This | Keep This |
|-------|----------|-----------|
| Phase 1 | Themed login strings | Role switching works |
| Phase 2 | Trace decay | Exploit + accumulate |
| Phase 3 | Pivot evasion | Isolation + Connection Lost |
| Phase 4 | Ransomware animation | Contract completion logic |
| Phase 5 | Days 2-3 | Day 1 only (MVHR) |
| Phase 6 | Correlation lines | Side-by-side panels only |

**Absolute Minimum for Thesis Defense:**
- Phase 4 MVHR (5-minute loop)
- Phase 6 Mirror Mode (side-by-side, no lines)

---

## Getting Started as New AI Assistant

1. Read this file for architecture overview
2. Read [GEMINI.md](./GEMINI.md) for complete technical specification
3. Check [phase-sprint/](./phase-sprint/) for current implementation tasks
4. Verify BLOCKER items are completed before proceeding to dependent tasks
5. Run GdUnit4 tests after any code changes

**Key Question to Ask:** *"Does this change respect the Role guard pattern and signal hygiene rules?"*

---

## Phase Sprint Structure (Solo Dev Optimized)

Each phase folder now contains consolidated tasks for solo development:

| Phase | Folder | Tasks | Deliverable |
|-------|--------|-------|-------------|
| 1 | `phase-sprint/phase-1/` | 5 tasks | Role switching + themed login |
| 2 | `phase-sprint/phase-2/` | 5 tasks | Exploit command + Trace system |
| 3 | `phase-sprint/phase-3/` | 5 tasks | RivalAI + isolation |
| 4 | `phase-sprint/phase-4/` | 5 tasks | Ransomware app + contract |
| 5 | `phase-sprint/phase-5/` | 5 tasks | 3-day campaign (Days 1-3) |
| 6 | `phase-sprint/phase-6/` | 5 tasks | Mirror Mode + polish |

Each phase includes a `PHASE-X-SOLO.md` summary with:
- Playability test script
- Demo recording checklist
- Integration requirements
- Handoff notes to next phase
