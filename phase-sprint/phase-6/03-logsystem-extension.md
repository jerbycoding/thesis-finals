# TASK 3: LOGSYSTEM EXTENSION (MIRROR MODE SUPPORT)

## Description
[SOLO DEV SCOPE] Add `get_logs_for_shift()` method to LogSystem. Required for Mirror Mode.

## Implementation Details

### A. New Method in LogSystem.gd
```gdscript
func get_logs_for_shift(day: int) -> Array[LogResource]:
    # For now, return all logs (no shift filtering)
    # Phase 6 TODO: Filter by ShiftClock timestamps
    return active_logs.duplicate()
```

### B. Stub for Phase 6 TODO
```gdscript
# When ShiftClock is implemented:
func get_logs_for_shift(day: int) -> Array[LogResource]:
    var filtered: Array[LogResource] = []
    var shift_start = ShiftClock.get_shift_start(day)
    var shift_end = ShiftClock.get_shift_end(day)
    
    for log in active_logs:
        var log_time = ShiftClock.parse_timestamp(log.timestamp)
        if log_time >= shift_start and log_time <= shift_end:
            filtered.append(log)
    
    return filtered
```

## Success Criteria
- [ ] **[BLOCKER]** `get_logs_for_shift()` method exists
- [ ] Returns array of LogResource
- [ ] Mirror Mode can call this method

## OUT OF SCOPE
- ❌ Actual timestamp filtering (return all for now)
- ❌ ShiftClock integration (stub ok)
