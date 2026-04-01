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

## Critical File Paths
```
autoload/
├── GameState.gd              # Role enum + switch_role()
├── TraceLevelManager.gd      # NEW — trace level authority
├── RivalAI.gd                # NEW — AI Analyst simulator
└── HackerHistory.gd          # NEW — forensic action log

scenes/
├── 3d/HackerRoom.tscn        # NEW — hacker's safe house
└── 2d/apps/
    ├── App_LogPoisoner.tscn  # NEW — inject false SIEM logs
    ├── App_PhishCrafter.tscn # NEW — send phishing emails
    ├── App_Ransomware.tscn   # NEW — encrypt hosts (CalibrationMinigame)
    ├── App_Exfiltrator.tscn  # NEW — steal data (RaidSyncMinigame)
    └── App_Wiper.tscn        # NEW — destroy evidence (RuleSliderMinigame)

resources/
├── hacker_shifts/day_{1-7}.tres
├── permissions/HackerAppProfile.tres
└── dialogues/broker/
```

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
| Phase 3: AI Counter-Measures | ✅ Consolidated | 4 tasks (01-04) |
| Phase 4: High-Impact Payloads | ✅ Consolidated | 5 tasks (01-05) |
| Phase 5: Narrative Arc | ✅ Consolidated | 6 tasks (01-06) |
| Phase 6: Integration & Polish | ✅ Consolidated | 5 tasks (01-05) — duplicates removed |

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
