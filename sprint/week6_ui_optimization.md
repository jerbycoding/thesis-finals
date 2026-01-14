# Sprint Week 6: UI Performance & Text Data

## 1. Objective
Optimize list rendering and move hard-baked text into the `CorporateVoice` system.

## 2. Tasks
### 2.1 Incremental SIEM Updates
*   **Log List Optimization:** Modify `App_SIEMViewer.gd` to `add_child` for new logs instead of `queue_free()` on the whole list.
*   **Capping:** Limit the visible log list to the latest 50 entries to maintain high FPS during "False Flag" log floods.

### 2.2 CorporateVoice Migration
*   **Text Decoupling:** Move all BBCode formatting templates from `App_SIEMViewer.gd` and `App_Terminal.gd` into `CorporateVoice.gd`.
*   **Standardized Formatting:** Create helper functions for `get_ip_markup()` or `get_host_markup()`.

## 3. Technical Requirements
*   `LogList` must remain responsive during high-volume spawning.
*   All UI scripts should contain zero hardcoded user-facing strings.
