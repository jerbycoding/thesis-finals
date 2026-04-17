# TASK 1: OFFENSIVE TERMINAL EXTENSION

## Description
Extend `TerminalSystem.gd` to handle the full contract for all offensive commands: `exploit`, `pivot`, and `spoof`.

## Implementation Details

### A. The `exploit [hostname]` Command
Implement the full 6-step execution contract:
1.  [x] **Null Guard:** If hostname is null or does not exist in `NetworkState`, print an error and abort.
2.  [x] **Ownership Guard:** If the host is already in `GameState.hacker_footholds`, print "already compromised" and abort. Do NOT re-emit any signals.
3.  [x] **Honeypot Branch:** If `HostResource.is_honeypot == true`, emit `offensive_action_performed` with `result: "HONEYPOT"` and print a generic "exploit failed" message. Abort.
4.  [x] **Success/Fail Check:** Perform the success check using `HostResource.vulnerability_score`.
5.  [x] **Success Path:** On success, add the hostname to `GameState.hacker_footholds` and emit the signal with `result: "SUCCESS"`.
6.  [x] **Failure Path:** On failure, emit the signal with `result: "FAILED"`. The trace cost is still applied.

### B. The `pivot [hostname]` Command
1.  [x] **Ownership Guard:** The command must check if the target hostname exists in `GameState.hacker_footholds` before proceeding. If not, print an error and abort.
2.  [x] **State Update:** On success, update `GameState.current_foothold` to the new hostname.
3.  [x] **Signal Emission:** Emit `offensive_action_performed` with the relevant data.

### C. The `spoof [mac/ip]` Command
1.  [x] **State Update:** On success, it must write the spoofed identity data to `GameState.active_spoof_identity`. This makes it available for the Log Poisoner and reduces trace costs.
2.  [x] **Signal Emission:** Emit `offensive_action_performed`.

### D. The `phish [hostname]` Command
1.  [x] **Success Formula:** (vulnerability * 0.8) / HeatManager.heat_multiplier.
2.  [x] **State Update:** Adds host to footholds on success.
3.  [x] **Signal Emission:** Emit `offensive_action_performed`.

## Success Criteria
- [x] **[BLOCKER]** The `exploit` command correctly handles the `HONEYPOT` and `FAILED` branches by still emitting a signal.
- [x] **[BLOCKER]** The `exploit` command does not re-emit signals for already-compromised hosts.
- [x] The `spoof` command correctly populates `GameState.active_spoof_identity`.
- [x] The `pivot` command is guarded and correctly updates `GameState.current_foothold`.
- [x] All offensive commands (`exploit`, `pivot`, `spoof`, `phish`) are filtered from the Analyst's `_cmd_help` view.

