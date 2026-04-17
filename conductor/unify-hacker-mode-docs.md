# Objective
Unify the Hacker Mode documentation across the `PHASE/` and `phase-sprint/` directories to reflect the full, uncompromised feature set of the Hacker Campaign. Remove all "Solo Dev Scope" restrictions and consolidate the completion status to clearly distinguish between what is already built and what remains to be implemented.

# Key Files & Context
- `PHASE/*.md`: The high-level phase definitions.
- `phase-sprint/phase-*/*.md`: The detailed, task-by-task implementation plans and checklists.
- **Context:** The project currently uses duplicate files in `phase-sprint/` (e.g., `01-role-switching.md` vs. `01-gamestate-extension.md`) where the "Solo" versions explicitly cut scope. The user has already built a functional 3-day MVHR (Minimum Viable Hacker Role) but wants to pursue the full 7-day arc and complete feature set (Exfiltrator, Wiper, Mirror Mode correlation).

# Implementation Steps

## 1. Delete Obsolete "Solo" and Summary Files
Remove all files that were explicitly created for the restricted "Solo Dev Scope" or that are now obsolete summaries:
- **Phase 1:** Delete `01-role-switching.md`, `02-hacker-room.md`, `03-themed-login.md`, `04-global-constants.md`, `05-debug-tools.md`, `PHASE-1-SOLO.md`, `PHASE-1-STATUS.md`.
- **Phase 2:** Delete `03-hacker-history.md`, `04-host-resource-extension.md`, `05-role-guards.md`, `PHASE-2-SOLO.md`, `PHASE-2-SUMMARY.md`, `PHASE-2-AUDIT.md`.
- **Phase 3:** Delete `01-rival-ai.md`, `02-isolation-sequence.md`, `03-pivot-evasion.md`, `04-eventbus-extensions.md`, `05-hacker-history-extension.md`, `PHASE-3-SOLO.md`.
- **Phase 4:** Delete `01-ransomware-app.md`, `02-bounty-ledger.md`, `03-basic-contract.md`, `04-app-registration.md`, `05-network-state-extension.md`, `PHASE-4-SOLO.md`.
- **Phase 5:** Delete `01-hacker-shift-resource.md` (already marked obsolete), `01-hacker-shift-system.md`, `02-broker-dialogue.md`, `02-contract-manager-extension.md`, `03-honeypot-implementation.md` (already marked obsolete), `03-honeypot-integration.md`, `04-broker-dialogue.md` (already marked obsolete), `04-save-load-extension.md`, `05-role-switch-flow.md`, `05-save-system-extension.md`, `PHASE-5-SOLO.md`.
- **Phase 6:** Delete `01-mirror-mode.md`, `02-glitch-aesthetics.md`, `03-logsystem-extension.md`, `04-hacker-history-extension.md`, `05-testing-checklist.md`, `PHASE-6-SOLO.md`.
- **General Checklists:** Delete `TASK-*-CHECKLIST.md` files as they are mostly related to the solo scope and clutter the directory.

## 2. Restore and Consolidate Master Task Files
Ensure the remaining (master) task files in each phase accurately reflect the full scope and track current progress:
- Review each master task file (e.g., `01-gamestate-extension.md`, `02-remote-office-scaffolding.md`, etc.).
- Update checklists within these files: mark items that are already implemented (e.g., Role enum, HackerRoom creation, trace decay) as `[x]` and items that were previously "OUT OF SCOPE" but are now part of the full feature set as `[ ]`.
- Remove any remaining `[SOLO DEV SCOPE]` or `[REVISED]` tags that refer to cutting features.
- Specifically restore documentation for:
  - **Phase 4:** Exfiltrator app, Wiper app.
  - **Phase 5:** Days 4-7 of the narrative arc, full Broker dialogue, scripted events.
  - **Phase 6:** Mirror Mode correlation lines, confidence tiers, Wiper gap detection.

## 3. Update High-Level `PHASE` Documents
- Update `PHASE-1-MODE-HACKER.md` through `PHASE-6-INTEGRATION-POLISH.md` to ensure they describe the full feature set without referencing solo mode cuts.
- Organize the completion strategies within these documents so they act as the definitive source of truth for the project's goals.

# Verification & Testing
- List the contents of `phase-sprint/` to ensure all duplicate and obsolete solo files have been removed.
- Perform a text search (`grep_search`) for "Solo Dev Scope", "OUT OF SCOPE", and "Cut for Solo Dev" to verify these restrictions have been fully purged from the documentation.
- Verify that the master task files clearly delineate completed work from pending work for the full feature set.