# Phish Crafter Implementation Plan

## Objective
To provide the Hacker role with a dedicated, visual application ("Phish Crafter") for executing Social Engineering attacks. This replaces the reliance on the raw `phish [hostname]` terminal command, making the "Mirror Mode" tactical choices (Loud Exploit vs. Quiet Phish) explicit and educational.

## Key Files & Context
*   **Target Scene:** `res://scenes/2d/apps/App_PhishCrafter.tscn` (New)
*   **Target Script:** `res://scripts/2d/apps/App_PhishCrafter.gd` (New)
*   **Target Config:** `res://resources/apps/phishcrafter.tres` (New)
*   **Backend Logic:** `res://autoload/TerminalSystem.gd` (Existing `_cmd_phish` logic will be leveraged).

## Proposed Solution (The App Experience)
The Phish Crafter will be a dark, tactical application window with the following flow:

1.  **Target Selection:** A dropdown menu populated by `NetworkState.get_all_hostnames()`.
2.  **Payload Design (Flavor):** A set of radio buttons allowing the hacker to choose the "lure" (e.g., *Urgent Invoice*, *Password Reset*, *System Update*). Mechanically, these all use the same backend logic, but they provide critical roleplaying flavor.
3.  **Execution:** A "Launch Campaign" button that starts the sequence.
4.  **Live Status:** A terminal-style output log within the app that displays the phases of the attack (OSINT Gathering -> Crafting -> Sending -> Result).
5.  **Result Handling:** If successful, the app announces the new Foothold. If failed, it warns of increased Trace levels.

## Implementation Steps

### Phase 1: Resource Creation
1.  Create `phishcrafter.tres` (Type: `AppConfig`).
2.  Set `app_id = "phishcrafter"`, `title = "Phish Crafter"`, and `required_role = 1` (HACKER).

### Phase 2: UI Scene Assembly (`App_PhishCrafter.tscn`)
1.  **Layout:** Use a `VBoxContainer` with standard Enterprise theme headers.
2.  **Targeting:** Add an `OptionButton` for selecting the victim hostname.
3.  **Lure Selection:** Add a `ButtonGroup` with three CheckBoxes (Invoice, IT Reset, Payroll).
4.  **Control:** Add a primary "LAUNCH PHISHING CAMPAIGN" button.
5.  **Telemetry:** Add a `RichTextLabel` with a black background to serve as the live operation log.
6.  **Progress:** Add a `ProgressBar` to visually indicate the "Wait" time inherent to social engineering.

### Phase 3: Script Logic (`App_PhishCrafter.gd`)
1.  **Initialization (`_ready`):** Fetch known hostnames from `NetworkState` and populate the dropdown.
2.  **Launch Sequence (`_on_launch_pressed`):** 
    *   Disable the launch button to prevent spamming.
    *   Append "INITIATING CAMPAIGN..." to the log.
    *   Start a visual `Tween` on the progress bar.
3.  **Backend Integration:**
    *   Instead of rewriting the complex success/fail math, the app will act as a wrapper, calling `TerminalSystem.execute_command("phish " + selected_hostname)`.
    *   *Alternative:* Expose the `_cmd_phish` logic in `TerminalSystem` as a public `start_phishing(hostname)` method for cleaner return data handling.
4.  **Result Parsing:** Read the result from the backend and print the green (Success) or red (Failure) outcome to the app's internal log.

## Verification & Testing
1.  Log in to the Hacker Campaign.
2.  Open the Start Menu; verify the "Phish Crafter" icon is present and clickable.
3.  Select a known host (e.g., `DB-SRV-01`) from the dropdown.
4.  Click Launch. Verify the progress bar fills over a few seconds.
5.  Verify the result correctly awards a foothold (if successful) or triggers an event (if failed) without crashing the terminal.