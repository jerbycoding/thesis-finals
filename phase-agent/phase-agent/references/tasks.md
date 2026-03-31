# Ordered Task Lists
## Phase Agent Reference — tasks.md
## Use in PLAN mode to tell the developer what to do next.

Tasks are ordered by: BLOCKERS → cross-phase contracts → core mechanics → hooks → polish.
Never suggest a lower-priority task when a higher-priority one is incomplete.

---

## Phase 1 — Foundation

### Priority 1: BLOCKERS (do these first, in order)
1. Add `enum Role { ANALYST, HACKER }` to `GameState.gd`
2. Add `var current_role = Role.ANALYST` to `GameState.gd`
3. Declare ALL Phase 1 + Phase 2 reserved variables in `GameState.gd`:
   `role_transition_in_progress`, `current_foothold`, `hacker_footholds`, `active_spoof_identity`, `is_campaign_session`
4. Implement `GameState.switch_role(new_role)` with the 10-step ordered sequence
5. Add crash guard: on load, if `role_transition_in_progress == true`, reset to ANALYST
6. Create `user://saves/hacker/` directory and verify write access
7. Implement `NetworkState.switch_context(role)` — dual context support
8. Add `IntegrityManager` Role Guard

### Priority 2: Cross-Phase Contracts (downstream phases need these)
9. Declare ALL color constants in `GlobalConstants.gd`:
   `COLOR_HACKER_GREEN`, `COLOR_HACKER_AMBER`, `COLOR_TRACE_WARNING`, `COLOR_TRACE_CRITICAL`
10. Declare save path constants: `SAVE_PATH_ANALYST`, `SAVE_PATH_HACKER`
11. Declare `HackerShiftResource` class (stub only — Phase 5 populates)
12. Create `res://resources/hacker_shifts/` directory with Day 1 placeholder

### Priority 3: Core Systems
13. Extend `TransitionManager.play_secure_login(role)` with role parameter
14. Create `HackerRoom.tscn` with `ViewAnchor` and `MonitorInputBridge`
15. Create `HackerAppProfile.tres` with Terminal and Network Mapper allowed
16. Extend `NarrativeDirector` to load from `hacker_shifts/` when role is Hacker
17. Extend `HeatManager` with `cache_and_reset(role)` method
18. Extend `SaveSystem` with dual directory path resolution

### Priority 4: Hooks
19. Add `AudioManager.swap_ambient_loop(role)` — placeholder audio path acceptable
20. Add `DebugManager` role guards on F9 Chaos trigger and F1/F2 shift-jump
21. Register `hacker_shifts/` with `ResourceAuditManager` startup audit

### Priority 5: Polish
22. Test themed login sequence displays correct strings and `COLOR_HACKER_GREEN`
23. Verify sit animation completes correctly in HackerRoom

---

## Phase 2 — Offensive Loop

### Priority 1: BLOCKERS
1. Declare `EventBus.offensive_action_performed` signal with Dictionary payload
2. Declare `EventBus.hacker_foothold_established` signal (distinct name)
3. Add all four `TRACE_COST_*` constants to `GlobalConstants.gd`
4. Register `HackerHistory.gd` as autoload singleton
5. Implement `HackerHistory.get_entries_for_day(day) -> Array` stub
6. Implement write-on-emit in `HackerHistory` — disk write on every signal receipt
7. Add Role Guards to `ConsequenceEngine`, `ValidationManager`, `IntegrityManager`, `TicketManager`

### Priority 2: Cross-Phase Contracts
8. Verify `LogSystem.get_logs_for_shift(day)` exists — create stub if not
9. Add `HostResource.vulnerability_score` field (default 0.5)
10. Add `HostResource.is_honeypot` field (default false)

### Priority 3: Core Systems
11. Implement `exploit` command in `TerminalSystem` (all 6 steps including honeypot branch)
12. Implement `pivot` command (foothold update + Phase 3 note in comment)
13. Implement `spoof` command (VariableRegistry live query)
14. Implement `_cmd_help` role filter — offensive commands invisible to Analyst
15. Create `PoisonLogResource` class inheriting `LogResource` with `is_poison` flag
16. Implement `App_LogPoisoner` — injects via `EventBus.poison_log_requested`
17. Implement `App_PhishCrafter` — success formula using `HeatManager.heat_multiplier`

### Priority 4: Hooks
18. Register `App_LogPoisoner` and `App_PhishCrafter` in `HackerAppProfile.tres`
19. Wire four `AudioManager` SFX hooks (placeholder paths)

### Priority 5: Polish
20. Verify `PoisonLogResource` renders identically to `LogResource` in SIEM
21. Verify both apps invisible in Analyst app launcher

---

## Phase 3 — Rival AI

### Priority 1: BLOCKERS
1. Create `TraceLevelManager.gd` and register as autoload (after EventBus, GameState)
2. Implement all four public methods: `get_trace_level`, `get_trace_normalized`, `reduce_trace`, `set_isolation_in_progress`
3. Implement decay pause conditions: minigame active, LOCKDOWN state, not Hacker role
4. Register decay timer via `TimeManager` — NOT standalone Timer node
5. Create `RivalAI.gd` and register as autoload (after TraceLevelManager)
6. Implement `_transition_to(state)` — all transitions through this method only
7. Implement `RivalAI.force_state(state)` stub with Phase 5 documentation comment
8. Add race condition guard in isolation callback — check `isolation_in_progress` FIRST
9. Register isolation countdown timer via `TimeManager`

### Priority 2: Cross-Phase Contracts
10. Declare `GlobalConstants.TRACE_COST_RANSOMWARE = 40.0` (Phase 4 reads this)
11. Declare `GlobalConstants.RIVAL_AI_SEARCHING_THRESHOLD = 30.0`
12. Declare `GlobalConstants.RIVAL_AI_LOCKDOWN_THRESHOLD = 70.0`
13. Declare `GlobalConstants.RIVAL_AI_BASE_ISOLATION_SECONDS = 20.0`
14. Declare `GlobalConstants.TRACE_DECAY_RATE = 1.0`
15. Add `TerminalSystem.inject_system_message(text)` method
16. Extend `HackerHistory` to listen for `rival_ai_isolation_complete`

### Priority 3: Core Systems
17. Implement SEARCHING state feedback: terminal injection + notification toast + meter color
18. Implement LOCKDOWN state feedback: countdown terminal + meter pulse + alert
19. Implement pivot evasion: abort timer + shift AI to SEARCHING (not IDLE)
20. Implement `TransitionManager.play_connection_lost(hostname)`
21. Define post-isolation state: Trace retained, AI stays SEARCHING, host stays ISOLATED

### Priority 4: Hooks
22. Wire four `AudioManager` SFX hooks: scan pulse loop, LOCKDOWN alert, isolation SFX, evasion SFX
23. Implement connect/disconnect signal hygiene — not always-on listeners

### Priority 5: Polish
24. Verify AI completely inactive during Analyst shift (role guard + signal disconnect both)
25. Test trace meter color transitions match threshold values

---

## Phase 4 — Payloads

### Priority 1: BLOCKERS
1. Add four fields to `HostResource`: `network_bandwidth`, `data_volume`, `data_type`, `bounty_value`
2. Implement `LogSystem.prune_logs_for_host(hostname, scope) -> Array` with Analyst role guard
3. Register `IntelligenceInventory.gd` as autoload — implement all four methods
4. Implement write-on-add in `IntelligenceInventory`
5. Register `BountyLedger.gd` as autoload — implement all three methods
6. Add `App_Exfiltrator` listener for `rival_ai_state_changed` — LOCKDOWN interruption sequence
7. Implement partial reward logic at 50%+ threshold

### Priority 2: Cross-Phase Contracts
8. Declare all Phase 4 `GlobalConstants`: `TRACE_COST_EXFILTRATION_PER_STREAM`, `TRACE_COST_WIPER`, `WIPER_MAX_REDUCE_PER_USE`, `EXFIL_BASE_TRANSFER_SPEED`
9. Declare `IntelligenceResource` class with all four fields
10. Document `"INTERRUPTED"`, `"SHALLOW"`, `"STANDARD"`, `"DEEP"` result strings in `EventBus.gd` signal comment

### Priority 3: Core Systems
11. Implement common launch guard (Section 5.3) for all three apps
12. Implement `App_Ransomware` — CalibrationMinigame inversion + bounty reward
13. Implement `App_Exfiltrator` — RaidSyncMinigame inversion + "Hold and Pray" mechanic
14. Implement `App_Wiper` — RuleSliderMinigame inversion + three precision tiers

### Priority 4: Hooks
15. Register all three apps in `HackerAppProfile.tres`
16. Wire all eight `AudioManager` SFX hooks for payloads

### Priority 5: Polish
17. Verify `RANSOMED` host cannot be re-targeted by Ransomware
18. Verify Wiper blocked when `isolation_in_progress == true`
19. Verify partial reward only on forced abort (not clean player abort)

---

## Phase 5 — Narrative Arc

### Priority 1: BLOCKERS
1. Declare `ContractResource` class with all fields from Section 4.1
2. Declare `ScriptedEventResource` class with all fields from Section 8.2
3. Declare all six new Phase 5 signals on `EventBus.gd`
4. Create all seven `day_{N}.tres` shift files — even if minimal content
5. Verify no honeypot hostname appears as a contract target in any shift file

### Priority 2: Cross-Phase Contracts
6. Extend `ResourceAuditManager` with honeypot/contract cross-reference check
7. Extend `ResourceAuditManager` with VariableRegistry token resolution check
8. Ensure `HackerHistory` emits `history_write_complete` after disk write
9. Ensure `NarrativeDirector` awaits `history_write_complete` before emitting `hacker_campaign_complete`

### Priority 3: Core Systems
10. Implement `VariableRegistry` token resolution for `{VAR:hostname:field}` tokens
11. Implement `App_ContractBoard` — four UI states + `[SUBMIT]` gating
12. Extend `NarrativeDirector` with seven-step Hacker shift load sequence
13. Implement scripted event evaluation loop — `TimeManager` polling at 0.5s (NOT `_process`)
14. Implement four scripted event types: `rival_ai_escalation`, `emergency_patch`, `broker_message`, `honeypot_reveal`
15. Implement honeypot exploit behavior — Trace spike to `trace_max` with 5-second isolation override
16. Implement shift unlock condition evaluation

### Priority 4: Hooks
17. Create all Broker dialogue resources at correct paths
18. Add `DebugManager` F3 and F4 commands with role guards
19. Wire contract completion and broker arrival SFX hooks

### Priority 5: Polish
20. Verify Day 7 emits `hacker_campaign_complete` correctly
21. Full playthrough test — Day 1 to Day 7 without null references

---

## Phase 6 — Integration

### Priority 1: BLOCKERS (timestamp alignment first — before any Mirror Mode UI)
1. Run timestamp alignment verification (see gates.md Special Gate section)
2. Fix any timestamp source mismatch before writing Mirror Mode UI code
3. Implement `MirrorMode.tscn` scene — basic layout first, data second
4. Implement Mirror Mode data loading with `[NO DATA]` fallback for all sources
5. Implement correlation engine — timestamp proximity matching per action type
6. Implement Wiper gap detection — absence-based, not timestamp matching
7. Implement `FPSManager` watchdog for shader auto-downgrade

### Priority 2: Core Systems
8. Implement Title Screen role selection flow — extend, do not replace
9. Implement `DesktopWindowManager.set_theme(role)` + `desktop_theme_changed` signal
10. Implement chromatic aberration shader on 2D CanvasLayer only
11. Implement shader quality tiers with `TimeManager` polling at 0.25s
12. Wire `AudioManager` crossfade (1.5s) between role ambient loops
13. Implement campaign summary report (Day 7) — six sections

### Priority 3: Testing
14. Run all existing GdUnit4 tests — all must pass
15. Add and run all eight new regression tests (Section 7.1)
16. Run role switch stress test (5 switches, all variable checks)
17. Run Mirror Mode data integrity test against known dataset
18. Android build verification (minimum-spec device)

### Priority 4: Hooks
19. Replace all placeholder audio paths with final assets
20. Declare two new `GlobalConstants`: `SHADER_FALLBACK_FPS_THRESHOLD`, `LOG_GAP_THRESHOLD_SECONDS`

### Priority 5: Polish
21. `[CLOSE REPORT]` button only visible after 50% left panel scroll
22. Poison log accent bar visible in Mirror Mode only — verify not in live SIEM
23. Connector line visual styles: solid/dashed/dotted per confidence level
24. Fill Phase 0 Section 8 comparison table with final delta values
