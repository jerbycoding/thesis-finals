# Phase Gate Checklists
## Phase Agent Reference — gates.md

Each section defines what must be true BEFORE the target phase begins.
These are extracted directly from the revised phase documents' handoff tables.

---

## Gate: Phase 0 → Phase 1

Phase 0 has no incoming prerequisites. It is always available.

Before Phase 1 begins, verify Phase 0 sign-off block is complete:

- [ ] Sign-off date is filled in
- [ ] All six YES/NO fields in Section 7 are marked YES
- [ ] GdUnit4 baseline recorded: 0 failures
- [ ] EventBus signal baseline table filled in
- [ ] `user://saves/hacker/` does NOT yet exist (Phase 1 creates it)
- [ ] `GlobalConstants.COLOR_CORPORATE_BLUE` confirmed present (or absence noted)

**Minimum to GO:** Sign-off date exists AND GdUnit4 shows 0 failures.

---

## Gate: Phase 1 → Phase 2

All items from the Phase 1 → Phase 2 Handoff Checklist (Section 14 of Phase 1 doc):

- [ ] `GameState.Role` enum declared with exactly `ANALYST` and `HACKER`
- [ ] `GameState.current_role` defaults to `Role.ANALYST`
- [ ] `GameState.current_foothold` declared as `String`, default `""`
- [ ] `GameState.hacker_footholds` declared as `Dictionary`, default `{}`
- [ ] `GameState.active_spoof_identity` declared as `Dictionary`, default `{}`
- [ ] `GameState.switch_role()` is the only function that writes `current_role`
- [ ] `user://saves/hacker/` directory exists and is writable
- [ ] `GlobalConstants.SAVE_PATH_ANALYST` declared
- [ ] `GlobalConstants.SAVE_PATH_HACKER` declared
- [ ] `GlobalConstants.COLOR_HACKER_GREEN` declared
- [ ] `GlobalConstants.COLOR_TRACE_WARNING` declared
- [ ] `GlobalConstants.COLOR_TRACE_CRITICAL` declared
- [ ] `NetworkState.switch_context(role)` implemented and working
- [ ] `NetworkState` returns correct context hosts per role
- [ ] `IntegrityManager` has Role Guard — does not apply damage during Hacker shift
- [ ] `HackerAppProfile.tres` exists with Terminal and Network Mapper allowed
- [ ] `HackerRoom.tscn` exists — camera sit animation completes
- [ ] `MonitorInputBridge` configured on HackerRoom computer mesh
- [ ] `NarrativeDirector` loads from `res://resources/hacker_shifts/` when role is Hacker
- [ ] `res://resources/hacker_shifts/` directory exists with Day 1 placeholder
- [ ] `HackerShiftResource` class declared as subclass of `ShiftResource`
- [ ] `AudioManager.swap_ambient_loop(role)` declared

**Minimum to GO (BLOCKERS only):**
`GameState` variables declared + `switch_context()` working + `user://saves/hacker/` writable + `IntegrityManager` Role Guard in place.

---

## Gate: Phase 2 → Phase 3

All items from Phase 2 → Phase 3 Handoff (Phase 2 doc, Section 9.1 and checklist):

- [ ] `EventBus.offensive_action_performed` signal declared
- [ ] Signal payload has all five keys: `action_type`, `target`, `timestamp`, `result`, `trace_cost`
- [ ] `GlobalConstants.TRACE_COST_EXPLOIT = 15.0`
- [ ] `GlobalConstants.TRACE_COST_PIVOT = 5.0`
- [ ] `GlobalConstants.TRACE_COST_SPOOF = 8.0`
- [ ] `GlobalConstants.TRACE_COST_PHISH = 10.0`
- [ ] `HackerHistory` registered as autoload singleton
- [ ] `HackerHistory.get_entries_for_day(day)` stub declared — returns empty Array
- [ ] `HackerHistory` writes to disk on every signal receipt (not just shift end)
- [ ] Save path `user://saves/hacker/history_day_{N}.json` verified writable
- [ ] `EventBus.hacker_foothold_established` declared (distinct from `foothold_established`)
- [ ] `ConsequenceEngine` has Role Guard comment — does NOT listen to `offensive_action_performed`
- [ ] `ValidationManager` has Role Guard comment — hacker commands bypass IR rules
- [ ] `TicketManager` has Role Guard comment — does not attach offensive actions to tickets
- [ ] `exploit`, `pivot`, `spoof` commands invisible in Analyst `_cmd_help` output
- [ ] `PoisonLogResource` schema-complete — no null fields at injection time
- [ ] `App_LogPoisoner` invisible in Analyst app launcher
- [ ] `App_PhishCrafter` invisible in Analyst app launcher
- [ ] `HostResource.vulnerability_score` field declared (default 0.5)
- [ ] `HostResource.is_honeypot` field declared (default false)

**Minimum to GO (BLOCKERS only):**
`offensive_action_performed` signal declared with full schema + all four `TRACE_COST_*` constants + `HackerHistory` autoload with stub method + `ConsequenceEngine` Role Guard.

---

## Gate: Phase 3 → Phase 4

All items from Phase 3 → Phase 4 Handoff (Phase 3 doc, Section 14):

- [ ] `TraceLevelManager` registered as autoload after `EventBus` and `GameState`
- [ ] `TraceLevelManager.get_trace_level()` callable
- [ ] `TraceLevelManager.get_trace_normalized()` callable
- [ ] `TraceLevelManager.reduce_trace(amount)` callable — clamps to 0.0 minimum
- [ ] `TraceLevelManager.set_isolation_in_progress(value)` callable
- [ ] `TraceLevelManager.isolation_in_progress` readable via getter
- [ ] Trace decay pauses when `MinigameBase.is_active == true`
- [ ] `RivalAI` registered as autoload after `TraceLevelManager`
- [ ] `RivalAI.current_state` readable
- [ ] `RivalAI.force_state(state)` stub declared and documented
- [ ] `GlobalConstants.TRACE_COST_RANSOMWARE = 40.0`
- [ ] `GlobalConstants.RIVAL_AI_SEARCHING_THRESHOLD = 30.0`
- [ ] `GlobalConstants.RIVAL_AI_LOCKDOWN_THRESHOLD = 70.0`
- [ ] `GlobalConstants.RIVAL_AI_BASE_ISOLATION_SECONDS = 20.0`
- [ ] `TerminalSystem.inject_system_message(text)` declared
- [ ] `EventBus.rival_ai_state_changed` declared
- [ ] `EventBus.rival_ai_isolation_complete` declared
- [ ] Isolation countdown timer registered via `TimeManager` (not standalone Timer node)
- [ ] Race condition guard in isolation callback: checks `isolation_in_progress` as first step
- [ ] `HackerHistory` extended to listen for `rival_ai_isolation_complete`

**Minimum to GO (BLOCKERS only):**
`TraceLevelManager` with all four public methods + decay pause on minigame + `RivalAI.force_state()` stub + `rival_ai_isolation_complete` signal + race condition guard.

---

## Gate: Phase 4 → Phase 5

All items from Phase 4 → Phase 5 Handoff (Phase 4 doc, Section 15):

- [ ] `IntelligenceInventory` registered as autoload
- [ ] `IntelligenceInventory.has_item(hostname, data_type)` callable
- [ ] `IntelligenceInventory.consume_item(hostname, data_type)` callable
- [ ] `IntelligenceInventory.get_all_items()` callable
- [ ] `IntelligenceInventory.add_item(resource)` callable
- [ ] `IntelligenceInventory` writes to disk on every `add_item()` call
- [ ] `BountyLedger` registered as autoload
- [ ] `BountyLedger.add_bounty(amount, source)` callable
- [ ] `BountyLedger.get_total_bounty()` callable
- [ ] `BountyLedger.get_ledger_for_day(day)` callable
- [ ] `NetworkState` recognizes `RANSOMED` as a valid host status
- [ ] `HostResource.bounty_value` declared (default 100)
- [ ] `HostResource.data_type` declared (default "generic")
- [ ] `HostResource.data_volume` declared (default 3)
- [ ] `HostResource.network_bandwidth` declared (default 1.0)
- [ ] `LogSystem.prune_logs_for_host(hostname, scope)` implemented
- [ ] `prune_logs_for_host` has Analyst role guard
- [ ] `App_Exfiltrator` listens for `rival_ai_state_changed` — LOCKDOWN interruption works
- [ ] Partial reward grants `IntelligenceResource` only at 50%+ per stream
- [ ] All three payload apps registered in `HackerAppProfile.tres`

**Minimum to GO (BLOCKERS only):**
`IntelligenceInventory` with all four methods + write-on-add + `BountyLedger` with three methods + `prune_logs_for_host()` with role guard + LOCKDOWN interruption on `App_Exfiltrator`.

---

## Gate: Phase 5 → Phase 6

All items from Phase 5 → Phase 6 Handoff (Phase 5 doc, Section 17):

- [ ] `EventBus.hacker_campaign_complete` signal declared
- [ ] `EventBus.hacker_shift_started(day: int)` signal declared
- [ ] `EventBus.contract_accepted` declared
- [ ] `EventBus.contract_submitted` declared
- [ ] `EventBus.contract_completed` declared
- [ ] `EventBus.contract_expired` declared
- [ ] `BountyLedger.get_ledger_for_day(day)` returns correct data
- [ ] `IntelligenceInventory.get_all_items()` returns full history
- [ ] `HackerHistory` has contract lifecycle events stored
- [ ] All seven `day_{N}.tres` shift files exist and are playable end-to-end
- [ ] `hacker_campaign_complete` fires correctly on Day 7 contract submission
- [ ] All `ContractResource` targets consistent with SIEM/terminal output
- [ ] `HackerHistory` emits `history_write_complete` after each disk write
- [ ] Day 7 `NarrativeDirector` awaits `history_write_complete` before emitting campaign complete

**Minimum to GO (BLOCKERS only):**
`hacker_campaign_complete` signal declared + all seven shift files playable + `HackerHistory` has entries from a test campaign run + timestamp alignment verified between HackerHistory and LogSystem.

---

## Special Gate: Timestamp Alignment Verification

This gate applies specifically before Mirror Mode development in Phase 6.
It must be run explicitly as a standalone check.

**Steps:**
1. Run a short test Hacker shift (Day 1 minimum)
2. After the shift, open `user://saves/hacker/history_day_1.json`
3. Check the `timestamp` field on any entry — it should be a float < 3600.0
4. Open `LogSystem` in-memory log for the same shift period
5. Check a log entry's `timestamp` field — it should also be < 3600.0
6. Compare the two timestamps for the same event — they should be within 5 seconds

If either timestamp is > 1,700,000,000 — that system is using Unix system time.
Identify which one and fix it to use `ShiftClock.elapsed_seconds` before Phase 6 proceeds.

**This check is a Phase 6 prerequisite. Mirror Mode will silently produce empty results if skipped.**
