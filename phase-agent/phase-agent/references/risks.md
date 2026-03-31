# Cross-Phase Risk & Debug Reference
## Phase Agent Reference — risks.md
## Use in DEBUG mode to diagnose integration failures by symptom.

---

## Symptom → Root Cause Table

| Symptom | Likely Source Phase | Most Probable Cause | Fix Location |
|---|---|---|---|
| Kill Chain advances when hacker exploits host | Phase 2 | `ConsequenceEngine` missing Role Guard | `autoload/ConsequenceEngine.gd` |
| Organization integrity drops during hacker shift | Phase 1 / Phase 2 | `IntegrityManager` missing Role Guard | `autoload/IntegrityManager.gd` |
| Mirror Mode shows completely empty report | Phase 2 / Phase 6 | Timestamp mismatch — HackerHistory vs LogSystem clock | Check both use `ShiftClock.elapsed_seconds` |
| Mirror Mode shows partial empty (some days missing) | Phase 2 | `HackerHistory` only writes at shift end, not on emit | `autoload/HackerHistory.gd` write-on-emit rule |
| Trace spikes during Analyst shift | Phase 3 | `TraceLevelManager` signal listener not disconnected on role switch | `autoload/TraceLevelManager.gd` signal hygiene |
| `RivalAI` state changes during Analyst shift | Phase 3 | `RivalAI` `_process` guard missing or signal not disconnected | `autoload/RivalAI.gd` |
| `exploit` command visible in Analyst terminal | Phase 2 | `_cmd_help` role filter not implemented | `autoload/TerminalSystem.gd` |
| `exploit` command returns no output | Phase 2 | NetworkState context is Analyst — wrong hosts | Phase 1 `switch_context()` ordering issue |
| Isolation fires even after successful pivot | Phase 3 | Race condition — isolation callback not checking `isolation_in_progress` first | `autoload/RivalAI.gd` isolation callback first line |
| `App_PhishCrafter` visible in Analyst launcher | Phase 2 | `AppPermissionProfile` not set to Hacker-only | `res://resources/permissions/HackerAppProfile.tres` |
| Hacker footholds persist after switching to Analyst | Phase 1 | `switch_role()` not clearing `hacker_footholds = {}` on switch to Analyst | `autoload/GameState.gd` switch_role step 8 |
| Wiper reduces Trace during isolation countdown | Phase 3 / Phase 4 | `reduce_trace()` not checking `isolation_in_progress` | `autoload/TraceLevelManager.gd` |
| Trace decays during Ransomware minigame | Phase 3 | Decay pause not checking `MinigameBase.is_active` | `autoload/TraceLevelManager.gd` decay conditions |
| `HackerHistory` has no entries in Mirror Mode | Phase 2 | write-on-emit not implemented — only writes at shift end | `autoload/HackerHistory.gd` |
| Scripted event fires multiple times | Phase 5 | `already_fired = true` set after event executes instead of before | `NarrativeDirector` scripted event handler |
| Contract target and `scan` output show different IP | Phase 5 | `VariableRegistry` queried separately for contract and terminal | Both must call `VariableRegistry.get_asset(hostname)` from same registry instance |
| `TRACE_COST_RANSOMWARE` is wrong / unexpected | Phase 3 | Constant not declared — app using hardcoded float | `autoload/GlobalConstants.gd` |
| `App_Exfiltrator` not interrupted by LOCKDOWN | Phase 4 | App not listening for `rival_ai_state_changed` | `App_Exfiltrator._ready()` signal connection |
| Partial reward granted on clean abort (player-initiated) | Phase 4 | Clean abort path incorrectly applying partial reward logic | `App_Exfiltrator` abort type check |
| `prune_logs_for_host` removes all logs (not just target host) | Phase 4 | Filter using loose match instead of exact string equality | `autoload/LogSystem.gd` prune method |
| `hacker_campaign_complete` fires before History writes | Phase 5 | `NarrativeDirector` not awaiting `history_write_complete` | `autoload/NarrativeDirector.gd` Day 7 completion |
| Honeypot visually distinguishable from normal hosts | Phase 5 | Artist added visual tell without checking spec | Network Topology Mapper host rendering |
| Emergency patch blocks re-exploit of patched host | Phase 5 | NetworkState host status set to `ISOLATED` instead of `CLEAN` | `NarrativeDirector` emergency patch handler |
| Chromatic aberration appears on Analyst desktop | Phase 6 | Shader applied to wrong CanvasLayer (shared layer) | Phase 6 — apply only to Hacker desktop CanvasLayer |
| Mirror Mode triggers during debug session | Phase 6 | `is_campaign_session` flag not checked | `MirrorMode.tscn` opening guard |
| `[CLOSE REPORT]` button always visible | Phase 6 | 50% scroll gate not implemented | `MirrorMode.tscn` scroll listener |
| Gap annotation not appearing for Wiper actions | Phase 6 | `LOG_GAP_THRESHOLD_SECONDS` too high, or LogSystem has no gap | Lower threshold or verify Wiper actually pruned entries |

---

## Phase Interaction Risk Matrix

This matrix shows which phase pairs have the highest integration risk.
Higher number = more dangerous interaction.

| | Ph1 | Ph2 | Ph3 | Ph4 | Ph5 | Ph6 |
|---|---|---|---|---|---|---|
| **Ph1** | — | 8 | 5 | 3 | 2 | 4 |
| **Ph2** | 8 | — | 9 | 6 | 4 | 8 |
| **Ph3** | 5 | 9 | — | 7 | 5 | 5 |
| **Ph4** | 3 | 6 | 7 | — | 6 | 6 |
| **Ph5** | 2 | 4 | 5 | 6 | — | 7 |
| **Ph6** | 4 | 8 | 5 | 6 | 7 | — |

**Ph2 × Ph3 (9/10):** The Kill Chain bleed and the `foothold_established` signal naming are the most dangerous integration points. Any signal name collision between Phase 2's new signals and existing Analyst signals corrupts the narrative state silently.

**Ph2 × Ph6 (8/10):** Mirror Mode's entire value depends on Phase 2 delivering correct HackerHistory entries with aligned timestamps. A Phase 2 implementation mistake surfaces in Phase 6 as a silent empty report.

**Ph1 × Ph2 (8/10):** Phase 2 assumes `NetworkState.switch_context()` is working. If Phase 1 delivered a broken context switch (e.g. wrong order of operations in `switch_role()`), every Phase 2 terminal command will query the wrong network graph.

**Ph3 × Ph4 (7/10):** Phase 4 payloads depend on Phase 3's `reduce_trace()`, `isolation_in_progress`, and the decay-during-minigame pause. A Phase 3 implementation gap makes all three payload apps behave incorrectly.

---

## "Silent Failure" Watchlist

These are failures that produce no error in the Godot Output panel.
They are the hardest to diagnose because nothing breaks visibly.

| Failure | Why It's Silent | How to Detect |
|---|---|---|
| Wrong timestamp source in HackerHistory | No error — just stores wrong float value | Check stored timestamp < 3600.0 in JSON |
| `offensive_action_performed` consumed by wrong system | No error — system just runs unexpected logic | Add debug print in ConsequenceEngine to log when it receives any signal |
| `prune_logs_for_host` removes zero entries | Returns empty Array — no error | Print return value and verify count > 0 after Wiper use |
| Scripted event `already_fired` not set — fires twice | Second fire produces same behavior — appears as "double effect" | Add counter to scripted event and assert it runs exactly once |
| `switch_context()` loads same context both ways | Both roles see same hosts — no crash | Print `NetworkState.get_all_hosts()` after switch and verify different results |
| `HackerHistory` writes only at shift end | All entries appear in file — just written late | Check: crash mid-shift, reload, verify entries still present |
| Mirror Mode correlation engine finds no matches | Report renders with all UNMATCHED | Print correlation results before rendering; check timestamp delta between matched pair |
