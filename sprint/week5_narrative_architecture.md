# Sprint Week 5: Narrative Decoupling

## 1. Objective
Move shift event data out of code and into manageable resource files.

## 2. Tasks
### 2.1 ShiftResource Definition
*   **Create `ShiftResource.gd`:** A new resource type to store arrays of event dictionaries.
*   **Data Migration:** Create `Shift1.tres`, `Shift2.tres`, and `Shift3.tres`.

### 2.2 NarrativeDirector Overhaul
*   **Dynamic Loading:** Update `NarrativeDirector.gd` to load a `ShiftResource` instead of hardcoded arrays.
*   **Endless/Random Support:** Implement a "Procedural Shift" option that picks random events from a pool.

## 3. Technical Requirements
*   The transition from Shift 1 to Shift 2 must be handled via resource loading.
*   The `SaveSystem` must store the file path of the current shift resource.
