# Role-Based Terminal Isolation Plan

## Objective
To strictly isolate the Terminal commands so that Analysts and Hackers only have access to their respective operational toolsets. This prevents narrative bleed and mechanic abuse (e.g., a Hacker using `isolate` to break the network or an Analyst using `exploit`).

## Key Files & Context
*   **Target Script:** `res://autoload/TerminalSystem.gd`
*   **Context:** Currently, the `commands` dictionary holds all commands globally. While some commands have manual guards, a structural, dictionary-level isolation is cleaner and more robust.

## Proposed Solution (The Implementation Strategy)

### 1. Dictionary Expansion (Metadata Update)
We will expand the existing `commands` dictionary in `TerminalSystem.gd` to include a `role` constraint for every command.

*   **Role Classifications:**
    *   `Role.ANALYST`: Analyst-exclusive tools (e.g., `isolate`, `restore`, `netstat`, `logs`, `trace`).
    *   `Role.HACKER`: Hacker-exclusive tools (e.g., `exploit`, `phish`, `pivot`, `spoof`, `submit`).
    *   `Role.BOTH`: Shared utilities (e.g., `help`, `list`, `scan`, `status`).

*Example:*
```gdscript
"isolate": {
    "description": "Disconnect host from network",
    "syntax": "isolate [hostname]",
    "role": GameState.Role.ANALYST
},
"exploit": {
    "description": "Exploit host vulnerability",
    "syntax": "exploit [hostname]",
    "role": GameState.Role.HACKER
}
```

### 2. Execution Guard (`execute_command`)
We will add a "Role Guard" at the very top of the `execute_command` function.
Before a command's specific `_cmd_*` function is called, the system will check the dictionary:

```gdscript
var cmd_def = commands[command_name]
var current_role = GameState.current_role if GameState else 0

if cmd_def.has("role") and cmd_def.role != current_role and cmd_def.role != 2: # Assuming 2 is BOTH
    return {"success": false, "output": "Command '%s' not recognized." % command_name}
```
*Note: We return "not recognized" rather than "unauthorized" to maintain immersion. A hacker's terminal physically shouldn't possess the Analyst's `isolate` binary.*

### 3. Dynamic Help System (`_cmd_help`)
The `help` command will be updated to filter its output based on the active role.
*   When an Analyst types `help`, they will only see `Role.ANALYST` and `Role.BOTH` commands.
*   When a Hacker types `help`, they will only see `Role.HACKER` and `Role.BOTH` commands.

### 4. Tab-Completion Fix
The `app_Terminal.gd` script's `_handle_tab_completion()` function will also be updated to only autocomplete commands that the current role is authorized to use.

## Verification
1.  Log in as Analyst. Type `help`. Verify Hacker commands (`exploit`, `phish`) are missing.
2.  Type `exploit WEB-SRV-01`. Verify it returns "Command not recognized."
3.  Switch to Hacker campaign. Type `help`. Verify Analyst commands (`isolate`, `logs`) are missing.
4.  Type `isolate DB-SRV-01`. Verify it returns "Command not recognized."
