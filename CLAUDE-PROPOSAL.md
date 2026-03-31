# GEMINI Project Analysis: VERIFY.EXE (Incident Response SOC Simulator)
> **Document Version:** 2.0 — Hacker Role Integration
> **Last Updated:** Post Phase Documentation Sprint
> **Status:** Hacker Role implementation planned. Analyst campaign stable (GdUnit4: 100% pass).
> **Active Branch:** `feature/hacker-role`

---

## 1. Project Overview

This project is a single-player, 3D/2D hybrid simulation game titled **"VERIFY.EXE"** (also referred to as **Incident Response: SOC Simulator**). It is being developed using the **Godot Engine (v4.4)** and **GDScript**.

The game now supports **two parallel campaigns** with separate save paths, separate UIs, and a shared but role-aware singleton architecture:

- **Analyst Campaign** — The original SOC Analyst experience. Manage incident tickets, investigate SIEM logs, isolate compromised hosts, protect organizational integrity.
- **Hacker Campaign** — A new parallel campaign where the player is an external threat actor. Exploit hosts, exfiltrate data, evade a simulated AI Analyst, and complete Broker-issued contracts.

The central thesis value is **Mirror Mode** — a post-shift forensic report that displays the Hacker's actions side-by-side with the SIEM logs they generated, making the attack/detection relationship explicitly visible.

---

## 2. Architecture and Core Design Principles

### 2.1 — Hybrid 2D/3D World

Transitions between 3D navigation and 2D workstation interaction are managed by `TransitionManager.gd`. The system includes camera animations (sitting/standing) and a `MonitorInputBridge` that projects interactive desktop UIs onto 3D meshes using anisotropic filtering and unshaded rendering.

**Hacker Addition:** A second 3D environment, `HackerRoom.tscn`, uses the same `InteractableComputer.tscn` + `ViewAnchor` pattern as the Analyst workstation. `TransitionManager.play_secure_login(role)` accepts a role parameter and displays role-appropriate login strings and color theme.

### 2.2 — Unified State Authority

`GameState.gd` is the single source of truth for:
- **Game Mode** (`MODE_3D`, `MODE_2D`, `MODE_DIALOGUE`, `MODE_MINIGAME`, `MODE_UI_ONLY`) — unchanged
- **Role** (`Role.ANALYST`, `Role.HACKER`) — new axis added for Hacker Role

These are orthogonal. `GameMode` controls interaction context. `Role` controls campaign identity. Never conflate them.

**Critical Rule:** `GameState.switch_role(new_role)` is the ONLY function permitted to write `current_role`. It executes a 10-step ordered sequence including minigame guard, timer clear, UI pool flush, network context switch, heat cache, and ambient audio swap.

### 2.3 — Role Guard Pattern

Every system that behaves differently per role uses this guard:

```gdscript
if GameState.current_role != GameState.Role.HACKER:
    return
```

Four singletons that existed before the Hacker Role must be explicitly guarded to prevent signal bleed:
- `ConsequenceEngine` — must NOT advance Kill Chain on hacker actions
- `ValidationManager` — must NOT apply IR rules to hacker commands
- `IntegrityManager` — must NOT apply Organization Damage during hacker shifts
- `TicketManager` — must NOT attach hacker actions to Analyst tickets

### 2.4 — EventBus Signal Architecture

All inter-system communication is decoupled through `EventBus.gd`. This is the project's primary integration safety mechanism — most guard failures produce wrong behavior rather than crashes.

**Signal Hygiene Rule:** `TraceLevelManager` and `RivalAI` connect to signals only when a Hacker shift is active, and disconnect on role switch. They do not use always-on listeners with `_process` guards only.

### 2.5 — Timestamp Authority

All timestamps across the entire project — both Analyst and Hacker — use `ShiftClock.elapsed_seconds`. Never use `Time.get_unix_time_from_system()`. This rule is enforced across `HackerHistory`, `LogSystem`, and all signal payloads. Mirror Mode's correlation engine depends on this alignment.

---

## 3. Autoload Singleton Registry

### 3.1 — Analyst Singletons (Pre-existing, Role-Guarded)

All existing singletons remain. The following were extended or guarded for Hacker Role:

| Singleton | Extension / Guard |
|---|---|
| `GameState` | Role enum + 8 new variables + `switch_role()` method |
| `GlobalConstants` | 10 new constants (colors, trace costs, thresholds, save paths) |
| `TransitionManager` | `play_secure_login(role)` + `play_connection_lost(hostname)` |
| `NetworkState` | Dual context (`ANALYST` / `HACKER`) + `switch_context(role)` |
| `HeatManager` | `cache_and_reset(role)` — caches Analyst heat on switch to Hacker |
| `IntegrityManager` | Role Guard — bypasses Organization Damage during Hacker shift |
| `ConsequenceEngine` | Role Guard — does NOT consume `offensive_action_performed` |
| `ValidationManager` | Role Guard — hacker commands bypass IR gameplay rules |
| `TicketManager` | Role Guard — does not attach hacker actions to open tickets |
| `LogSystem` | New method: `prune_logs_for_host(hostname, scope) -> Array` + Analyst role guard on prune |
| `TerminalSystem` | New commands: `exploit`, `pivot`, `spoof` + `inject_system_message(text)` |
| `NarrativeDirector` | Loads `hacker_shifts/` when role is Hacker; scripted event evaluation loop |
| `SaveSystem` | Dual directory: `user://saves/analyst/` and `user://saves/hacker/` |
| `DesktopWindowManager` | `set_theme(role)` + `HackerAppProfile.tres` permission gating |
| `AudioManager` | `swap_ambient_loop(role)` + 1.5s crossfade between role loops |
| `FPSManager` | Framerate watchdog — triggers shader quality downgrade below 30fps |
| `DebugManager` | F3 (skip hacker shift), F4 (force-complete contract) with role guards |
| `ResourceAuditManager` | Audits `hacker_shifts/` + honeypot/contract cross-reference check |
| `UIObjectPool` | `flush()` called during role transition to clear previous role's pooled entries |
| `TimeManager` | `clear_all_timers()` called during role transition |

### 3.2 — New Hacker Role Singletons

Added to autoload in this order (order matters — later singletons depend on earlier ones):

| Singleton | Autoload Order | Purpose |
|---|---|---|
| `HackerHistory` | After `EventBus` | Forensic log of every offensive action. Writes to disk on every `offensive_action_performed` emission. Source for Phase 6 Mirror Mode left panel. |
| `TraceLevelManager` | After `HackerHistory` | The Hacker's "anti-Heat" meter. Single source of truth for `trace_level`. Manages passive decay, isolation lock state. |
| `RivalAI` | After `TraceLevelManager` | State machine (`IDLE` → `SEARCHING` → `LOCKDOWN`). Simulates the SOC Analyst AI. Drives isolation countdown and player-visible feedback. |
| `BountyLedger` | After `RivalAI` | Tracks accumulated bounty points. Source for Mirror Mode summary. |
| `IntelligenceInventory` | After `BountyLedger` | Stores `IntelligenceResource` items from exfiltration. Phase 5 contracts check this as a prerequisite. Write-on-add (crash-safe). |

---

## 4. New Variables in `GameState.gd`

These variables are declared in `GameState.gd`. Write ownership is strict — only the listed system may write each variable.

| Variable | Type | Default | Write Owner | Purpose |
|---|---|---|---|---|
| `current_role` | `Role` enum | `Role.ANALYST` | `switch_role()` only | Master role switch |
| `role_transition_in_progress` | `bool` | `false` | `switch_role()` only | Crash-state dirty flag |
| `current_foothold` | `String` | `""` | `TerminalSystem` | Active hacker host |
| `hacker_footholds` | `Dictionary` | `{}` | `TerminalSystem` | All compromised hosts this shift |
| `active_spoof_identity` | `Dictionary` | `{}` | `TerminalSystem` | Active MAC/IP spoof mask |
| `is_campaign_session` | `bool` | `false` | `TitleScreen` | Prevents Mirror Mode during debug sessions |

---

## 5. New Constants in `GlobalConstants.gd`

All trace costs, thresholds, and colors are constants — never hardcoded in implementation files.

| Constant | Value | Used By |
|---|---|---|
| `COLOR_CORPORATE_BLUE` | _(existing)_ | Analyst theme |
| `COLOR_HACKER_GREEN` | TBD | Hacker UI theme, login sequence |
| `COLOR_HACKER_AMBER` | TBD | Accessibility fallback |
| `COLOR_TRACE_WARNING` | TBD | Trace meter at SEARCHING state |
| `COLOR_TRACE_CRITICAL` | TBD | Trace meter at LOCKDOWN state |
| `SAVE_PATH_ANALYST` | `"user://saves/analyst/"` | SaveSystem |
| `SAVE_PATH_HACKER` | `"user://saves/hacker/"` | SaveSystem |
| `TRACE_COST_EXPLOIT` | `15.0` | TerminalSystem exploit command |
| `TRACE_COST_PIVOT` | `5.0` | TerminalSystem pivot command |
| `TRACE_COST_SPOOF` | `8.0` | TerminalSystem spoof command |
| `TRACE_COST_PHISH` | `10.0` | App_PhishCrafter |
| `TRACE_COST_RANSOMWARE` | `40.0` | App_Ransomware |
| `TRACE_COST_EXFILTRATION_PER_STREAM` | `5.0` | App_Exfiltrator |
| `TRACE_COST_WIPER` | `3.0` | App_Wiper |
| `TRACE_DECAY_RATE` | `1.0` | TraceLevelManager |
| `WIPER_MAX_REDUCE_PER_USE` | `25.0` | App_Wiper |
| `EXFIL_BASE_TRANSFER_SPEED` | `1.0` | App_Exfiltrator |
| `RIVAL_AI_SEARCHING_THRESHOLD` | `30.0` | RivalAI state machine |
| `RIVAL_AI_LOCKDOWN_THRESHOLD` | `70.0` | RivalAI state machine |
| `RIVAL_AI_BASE_ISOLATION_SECONDS` | `20.0` | RivalAI isolation countdown |
| `SHADER_FALLBACK_FPS_THRESHOLD` | `30` | FPSManager watchdog |
| `LOG_GAP_THRESHOLD_SECONDS` | `30.0` | Mirror Mode gap detection |

---

## 6. New Data Types (Resources)

Added alongside existing resources:

| Resource | Inherits From | Purpose |
|---|---|---|
| `HackerShiftResource` | `ShiftResource` | Hacker campaign shift data: contracts, scripted events, available hosts, honeypots |
| `ContractResource` | `TicketResource` | Hacker mission object. Broker-issued. Uses `VariableRegistry` token resolution. |
| `ScriptedEventResource` | — | Narrative trigger attached to a shift: `rival_ai_escalation`, `emergency_patch`, `broker_message`, `honeypot_reveal` |
| `PoisonLogResource` | `LogResource` | Injected SIEM log. Identical to LogResource but with `is_poison: true` flag (hidden during gameplay, visible in Mirror Mode only) |
| `IntelligenceResource` | — | Stolen data artifact. Fields: `source_hostname`, `data_type`, `shift_day`, `partial` |

### Extended Resource Fields

**`HostResource`** gains four new fields for Hacker Role:

| Field | Type | Default | Purpose |
|---|---|---|---|
| `vulnerability_score` | `float` | `0.5` | Probability exploit succeeds (0.0–1.0) |
| `is_honeypot` | `bool` | `false` | If true: exploit spikes Trace to max. Never shown in UI. |
| `network_bandwidth` | `float` | `1.0` | Throttles exfiltration speed |
| `data_volume` | `int` | `3` | Number of streams in App_Exfiltrator |
| `data_type` | `String` | `"generic"` | Category of IntelligenceResource produced |
| `bounty_value` | `int` | `100` | Points awarded on successful ransomware |

---

## 7. New Scene-Based Tools (Hacker Role)

All new apps inherit from their Analyst counterparts or from `MinigameBase.gd`.
All are registered in `HackerAppProfile.tres` and invisible to the Analyst.

| App Scene | Mechanic Reused | Analyst Counterpart | Purpose |
|---|---|---|---|
| `App_LogPoisoner.tscn` | — | SIEM Log Viewer (inverted) | Inject `PoisonLogResource` entries into the live SIEM feed |
| `App_PhishCrafter.tscn` | — | Email Analyzer (inverted) | Craft phishing emails. Success formula: `(urgency + authority) / HeatManager.heat_multiplier` |
| `App_Ransomware.tscn` | `CalibrationMinigame` | Decryption Tool (inverted) | Encrypt host sectors. Sets host to `RANSOMED`. +Bounty. |
| `App_Exfiltrator.tscn` | `RaidSyncMinigame` | RAID Sync (inverted) | Multi-stream data theft. Interruptible by LOCKDOWN. Partial reward at 50%+. |
| `App_Wiper.tscn` | `RuleSliderMinigame` | Rule Slider (inverted) | Overwrite logs + reduce TraceLevelManager. 3 precision tiers. |
| `App_ContractBoard.tscn` | — | Ticket Queue (replacement) | Browse, accept, and submit Broker-issued contracts |
| `MirrorMode.tscn` | — | — | Post-shift forensic report. Left: HackerHistory. Right: SIEM logs. Connector lines show correlation. |

---

## 8. EventBus Signal Registry

### 8.1 — Signals Added by Hacker Role

**Phase 2:**

| Signal | Payload | Emitted By | Authorized Consumers |
|---|---|---|---|
| `offensive_action_performed` | `Dictionary` (5 keys) | All hacker commands and payload apps | `HackerHistory`, `TraceLevelManager` |
| `poison_log_requested` | `PoisonLogResource` | `App_LogPoisoner` | `LogSystem` |
| `hacker_foothold_established` | `String` hostname | `App_PhishCrafter` | `GameState`, `HackerHistory` |

> `offensive_action_performed` required payload schema:
> `{ action_type, target, timestamp, result, trace_cost }`
> Timestamp MUST use `ShiftClock.elapsed_seconds`. Result must be one of:
> `SUCCESS`, `FAILED`, `HONEYPOT`, `EVASION`, `INTERRUPTED`, `SHALLOW`, `STANDARD`, `DEEP`

**Phase 3:**

| Signal | Payload | Emitted By | Authorized Consumers |
|---|---|---|---|
| `rival_ai_state_changed` | `int` (State enum) | `RivalAI` | UI Trace meter, `AudioManager`, `App_Exfiltrator` |
| `rival_ai_isolation_complete` | `String` hostname | `RivalAI` | `HackerHistory`, `DesktopWindowManager`, `TransitionManager`, `App_Exfiltrator` |

**Phase 5:**

| Signal | Payload | Emitted By | Authorized Consumers |
|---|---|---|---|
| `contract_accepted` | `String` contract_id | `App_ContractBoard` | `NarrativeDirector`, `HackerHistory` |
| `contract_submitted` | `String` contract_id | `App_ContractBoard` | `NarrativeDirector` |
| `contract_completed` | `String` contract_id | `NarrativeDirector` | `BountyLedger`, `HackerHistory`, `NotificationManager` |
| `contract_expired` | `String` contract_id | `NarrativeDirector` | `HackerHistory`, `NotificationManager` |
| `hacker_shift_started` | `int` day | `NarrativeDirector` | `TraceLevelManager` (reset), `RivalAI` (reset), `HackerHistory` |
| `hacker_campaign_complete` | — | `NarrativeDirector` | `MirrorMode`, `SaveSystem` |

**Phase 6:**

| Signal | Payload | Emitted By | Authorized Consumers |
|---|---|---|---|
| `mirror_mode_closed` | — | `MirrorMode.tscn` | `NarrativeDirector` |
| `desktop_theme_changed` | `Role` | `DesktopWindowManager` | All role-themed UI elements |

### 8.2 — Signals That Must NOT Cross Role Boundaries

`ConsequenceEngine`, `ValidationManager`, `IntegrityManager`, and `TicketManager` must never consume `offensive_action_performed` or `hacker_foothold_established`. Role Guards must be documented as comments in those files.

---

## 9. Narrative Structure & Progression

### 9.1 — Analyst Campaign (Unchanged)

14-day arc across two weeks.
- Week 1 (Establishment): Standard IR loop → Friday Zero Day → Weekend maintenance
- Week 2 (Escalation & Paranoia): Admin Lockouts, Wiper Scripts, Internal Betrayal
- Weekends: Saturday (Infrastructure Audit, Network Hub 3D), Sunday (Hardware Recovery, Server Vault)
- Endings: Fired (Negligence), Bankrupt (Integrity 0%), Victory (Promotion)

### 9.2 — Hacker Campaign (New)

7-day arc across three acts. Contracts issued by an off-screen Broker (alias: `ZERO_X` → `PHANTOM`).

| Act | Days | Theme | Primary Mechanic |
|---|---|---|---|
| Act 1 — Orientation | 1–2 | First contact, low-stakes | `exploit` + `pivot` fundamentals |
| Act 2 — Escalation | 3–5 | Contracts grow riskier | Ransomware + Exfiltration |
| Act 3 — Endgame | 6–7 | Broker's true motive revealed | Scripted escalations + Wiper survival |

**Day-by-Day Highlights:**
- Day 1: Tutorial-adjacent. One contract, no payload required. No honeypots.
- Day 2: First exfiltration. One honeypot introduced. One scripted SEARCHING event.
- Day 3: First dual-contract shift. First Emergency Patch scripted event.
- Day 4: Scripted LOCKDOWN mid-exfiltration. Forces "Hold and Pray" decision.
- Day 5: Wiper as primary contract objective. Broker reveals insider knowledge.
- Day 6: First `required_payload: "both"` contract. Two scripted LOCKDOWNs.
- Day 7: Final exfiltration reveals Broker's identity. `hacker_campaign_complete` emitted.

**Narrative Resolution:** The exfiltrated `data_type: "comms"` item on Day 7 reveals the Broker is an employee inside the organization — completing the insider threat narrative loop.

**Endings:**
- Full completion (Day 7 contract submitted): Mirror Mode campaign summary + narrative resolution
- MVHR completion (Days 1–3 only): Partial report shown, arc marked incomplete
- Isolation before Day 7: Campaign can be continued from last completed shift

### 9.3 — The Broker

No 3D presence. Communicates exclusively via `DialogueManager` sequences rendered as terminal overlays. Dialogue resources at `res://resources/dialogues/broker/broker_day{N}_{slug}.tres`. Tone: clinical, information-dense, professional. No Hollywood hacker clichés.

---

## 10. The RivalAI System

The core tension of the Hacker Role. Simulates the Analyst AI the player controls in the other campaign.

### 10.1 — TraceLevelManager

Single source of truth for the Hacker's exposure level.

| State | Trace Range | Player-Visible Feedback |
|---|---|---|
| IDLE | 0–29 | Meter in `COLOR_HACKER_GREEN`. No terminal messages. |
| SEARCHING | 30–69 | Meter in `COLOR_TRACE_WARNING`. Terminal: `ANOMALY DETECTED`. `NotificationManager` toast (once only). |
| LOCKDOWN | 70–100 | Meter in `COLOR_TRACE_CRITICAL` + pulse. Terminal countdown. High-urgency audio. |

Decay rate: `TRACE_DECAY_RATE` per second. Paused during: LOCKDOWN state, active minigame, Analyst role.

### 10.2 — RivalAI

State machine driven by `TraceLevelManager.get_trace_level()`. Isolation countdown duration: `RIVAL_AI_BASE_ISOLATION_SECONDS / HeatManager.heat_multiplier` (faster on high-heat shifts).

**Pivot Evasion:** `pivot` command during LOCKDOWN aborts the isolation timer. `RivalAI` transitions to SEARCHING (not IDLE). Trace is NOT cleared. Race condition guard: isolation callback checks `isolation_in_progress` as its very first step.

**Scripted Escalation:** `NarrativeDirector` can call `RivalAI.force_state(state)` to override threshold-based transitions for narrative events. Guard: if `current_foothold == ""`, escalation defers until a foothold exists.

---

## 11. Mirror Mode

The post-shift forensic report. The educational and thesis centerpiece of the Hacker Role.

### 11.1 — Trigger Points

- Start of each new shift (shows previous shift's data)
- `hacker_campaign_complete` signal (shows full 7-day campaign summary)
- Skipped on Day 1 (no previous shift data)
- Skipped during debug sessions (`is_campaign_session == false`)

### 11.2 — Data Sources

| Panel | Source | Method |
|---|---|---|
| Left — Hacker Actions | `HackerHistory` | `get_entries_for_day(day)` |
| Right — SIEM Logs | `LogSystem` | `get_logs_for_shift(day)` |
| Summary — Bounty | `BountyLedger` | `get_ledger_for_day(day)` |
| Summary — Intel | `IntelligenceInventory` | `get_all_items()` filtered by `shift_day` |

### 11.3 — Correlation Engine

Matches HackerHistory entries to LogSystem entries using `ShiftClock` timestamp proximity. Outputs `HIGH`, `MEDIUM`, `LOW`, or `UNMATCHED` confidence per action. Connector lines between panels reflect confidence visually (solid / dashed / dotted / none).

**Wiper Gap Detection:** Wiper actions are matched by absence — timestamp gaps > `LOG_GAP_THRESHOLD_SECONDS` in the SIEM log are annotated as possible evidence destruction and linked to the corresponding Wiper entry.

**Poison Log Highlighting:** `PoisonLogResource` entries (`is_poison: true`) show a colored accent bar in Mirror Mode only — never in the live SIEM view during gameplay.

---

## 12. File Structure

### 12.1 — New Directories

```
autoload/
├── HackerHistory.gd          ← new
├── TraceLevelManager.gd      ← new
├── RivalAI.gd                ← new
├── BountyLedger.gd           ← new
└── IntelligenceInventory.gd  ← new

scenes/
├── 3d/
│   └── HackerRoom.tscn       ← new
├── 2d/apps/
│   ├── App_LogPoisoner.tscn  ← new
│   ├── App_PhishCrafter.tscn ← new
│   ├── App_Ransomware.tscn   ← new
│   ├── App_Exfiltrator.tscn  ← new
│   ├── App_Wiper.tscn        ← new
│   └── App_ContractBoard.tscn← new
└── ui/
    └── MirrorMode.tscn       ← new

resources/
├── hacker_shifts/            ← new directory
│   ├── day_1.tres
│   ├── day_2.tres
│   ├── day_3.tres
│   ├── day_4.tres
│   ├── day_5.tres
│   ├── day_6.tres
│   └── day_7.tres
├── permissions/
│   └── HackerAppProfile.tres ← new
└── dialogues/
    └── broker/               ← new directory
        ├── broker_day1_intro.tres
        └── ...

scripts/resources/
├── HackerShiftResource.gd    ← new
├── ContractResource.gd       ← new
├── ScriptedEventResource.gd  ← new
├── PoisonLogResource.gd      ← new
└── IntelligenceResource.gd   ← new

user://saves/
├── analyst/                  ← existing (path now explicit)
│   ├── world_state.json
│   └── metrics.json
└── hacker/                   ← new
    ├── world_state.json
    ├── bounty.json
    ├── intelligence.json
    └── history_day_{N}.json
```

### 12.2 — Modified Existing Files

Every modification is an extension or a guard — no existing logic is removed.

| File | What Changed |
|---|---|
| `autoload/GameState.gd` | Role enum, 6 new variables, `switch_role()` method |
| `autoload/GlobalConstants.gd` | 22 new constants |
| `autoload/EventBus.gd` | 13 new signals declared |
| `autoload/TransitionManager.gd` | `role` param on `play_secure_login()` + `play_connection_lost()` |
| `autoload/NetworkState.gd` | Dual context support + `switch_context(role)` |
| `autoload/HeatManager.gd` | `cache_and_reset(role)` |
| `autoload/IntegrityManager.gd` | Role Guard on all damage logic |
| `autoload/ConsequenceEngine.gd` | Role Guard comment — does not consume hacker signals |
| `autoload/ValidationManager.gd` | Role Guard comment — hacker commands bypass IR rules |
| `autoload/TicketManager.gd` | Role Guard comment — does not attach hacker actions |
| `autoload/LogSystem.gd` | `prune_logs_for_host(hostname, scope) -> Array` + role guard + `get_logs_for_shift(day)` |
| `autoload/TerminalSystem.gd` | `exploit`, `pivot`, `spoof` commands + `inject_system_message()` + role-filtered `_cmd_help` |
| `autoload/NarrativeDirector.gd` | Hacker shift loading + scripted event evaluation loop (0.5s polling) |
| `autoload/SaveSystem.gd` | Dual directory path resolution |
| `autoload/DesktopWindowManager.gd` | `set_theme(role)` + role-aware `AppPermissionProfile` loading |
| `autoload/AudioManager.gd` | `swap_ambient_loop(role)` + 1.5s crossfade |
| `autoload/FPSManager.gd` | Framerate watchdog for shader quality tier |
| `autoload/DebugManager.gd` | F3/F4 hacker debug commands + role guards on F9/F1/F2 |
| `autoload/ResourceAuditManager.gd` | Audits `hacker_shifts/` + honeypot cross-reference check |
| `scenes/ui/TitleScreen.tscn` | Role selection step between "New Game" and campaign init |
| `scripts/resources/HostResource.gd` | 6 new fields |

---

## 13. Building and Running

This is a standard Godot project. No external build scripts or package managers required.

### Running the Game

1. Open the project in **Godot Engine 4.4**
2. Main scene: `res://scenes/ui/TitleScreen.tscn`
3. Press **F5** to run

### Running as Analyst

Select "Analyst Campaign" from the Title Screen. This is the original campaign — all existing behavior unchanged.

### Running as Hacker

Select "Hacker Campaign" from the Title Screen. Requires `user://saves/hacker/` to exist (created automatically on first launch). Uses `HackerRoom.tscn` as the 3D environment.

### Debug Hotkeys

| Key | Analyst | Hacker |
|---|---|---|
| F1 | Jump to previous shift | Jump to previous hacker shift |
| F2 | Jump to next shift | Jump to next hacker shift |
| F3 | — | Skip current hacker shift (mark all contracts complete) |
| F4 | — | Force-complete active contract |
| F9 | Chaos trigger (inject random event) | No-op (role guard) |

---

## 14. Testing

### GdUnit4 Framework

- **Manual Execution:** GdUnit4 panel in Godot editor
- **Baseline Status:** 100% pass rate (Analyst campaign — verified in Phase 0)
- **Test Directories:** `res://tests/autoload/`, `res://tests/scenes/`

### Test Categories

| Category | Coverage |
|---|---|
| Analyst regression | All pre-existing tests — must stay green after Hacker Role implementation |
| Role guard verification | `exploit` invisible in Analyst, `offensive_action_performed` does not affect `ConsequenceEngine` or `IntegrityManager` |
| Signal schema | All `offensive_action_performed` emissions have complete 5-key payload |
| Network context isolation | Hacker hosts do not appear in Analyst topology |
| Save path separation | Hacker saves write only to `SAVE_PATH_HACKER` |
| Singleton inactivity | `TraceLevelManager` and `RivalAI` process nothing during Analyst shift |
| Timestamp alignment | Both `HackerHistory` and `LogSystem` use `ShiftClock.elapsed_seconds` |
| Mirror Mode integrity | Correlation engine produces non-empty results for a known test shift |

### Minimum Viable Hacker Role (MVHR)

If under time pressure, Phases 0–4 with Day 1–3 narrative content constitute a defensible MVHR. Mirror Mode and the full 7-day arc are the "A grade" targets. The feature flag `hacker_role_enabled` in project config allows instant rollback to Analyst-only build.

---

## 15. Agent Skills and Workflow

This project uses a complementary AI workflow:

| Tool | Role |
|---|---|
| Claude | Architecture decisions, documentation, contract review, phase gate checks |
| Gemini CLI | Terminal operations, file generation, GDScript implementation |

### Installed Skills (Gemini CLI)

| Skill | Trigger | Purpose |
|---|---|---|
| `phase-agent` | "am I ready for Phase N" / "check phase" | Phase gate validation, debug diagnosis, ordered task lists |
| `gdunit4-writer` | "write tests for" / "generate gdunit4" | Generates test files from phase contract sections |
| `ui-ux-modernizer` | "modernize this UI" | UI/UX audit and improvement |

### Phase Documents

All phase implementation contracts are in `sprint/hacker-role/`:

| File | Contents |
|---|---|
| `PHASE-0-PRE-CONDITIONS.md` | Baseline verification + sign-off block |
| `PHASE-1-MODE-HACKER-REVISED.md` | Foundation & state isolation |
| `PHASE-2-OFFENSIVE-LOOP-REVISED.md` | Mirror loop & offensive tools |
| `PHASE-3-AI-COUNTER-MEASURES-REVISED.md` | RivalAI & Trace management |
| `PHASE-4-HIGH-IMPACT-PAYLOADS-REVISED.md` | Payload apps |
| `PHASE-5-NARRATIVE-ARC-REVISED.md` | 7-day campaign arc |
| `PHASE-6-INTEGRATION-POLISH-REVISED.md` | Mirror Mode, polish, testing |
s
Each document contains: system dependency map, per-task contracts, cross-phase contracts, a hardened verification checklist with `[BLOCKER]` tags, and a handoff table for the next phase.

---

## 16. Sprint Plan

8-week implementation plan. Team: Ezio (lead, architecture + thesis), Hans (AI systems + testing), Mark (3D + content + audio).

| Week | Phase | Focus | Risk |
|---|---|---|---|
| 0 | Phase 0 | Baseline verification + sign-off | Low |
| 1 | Phase 1 | Foundation & state isolation | Critical |
| 2 | Phase 2 | Offensive mirror loop | Critical |
| 3 | Phase 3 | RivalAI & Trace management | Critical |
| 4 | Phase 4 | Payload apps | High |
| 5–6 | Phase 5 | Narrative arc (2 weeks) | Medium |
| 7 | Phase 6 | Integration, Mirror Mode, testing | High |
| 8 | Buffer | Defense prep + documentation | — |

**MVHR cutoff:** End of Week 4. If behind at this point, descend to MVHR and present with documentation.