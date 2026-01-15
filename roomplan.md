# VERIFY.EXE: SOC Office Room Plan (Mission Control Scale)

## 1. Vision & Architecture
The SOC is designed as a **Massive Mission Control Center**. The goal is to make the player feel like a "small cog in a giant machine." It uses a "Sunken Pit" design for the main bullpen to emphasize the scale of the monitoring walls.

### Key Architectural Goals:
*   **Epic Scale:** A 40m wide "War Wall" to dominate the player's view.
*   **Verticality:** 10m high ceilings to create an industrial, cold atmosphere.
*   **Sunken Bullpen:** The main desk area is physically lower than the surrounding corridors.

---

## 2. Layout Breakdown (The Mission Control L-Shape)

### Zone A: The Bullpen "Pit" (40m x 25m)
*   **The War Wall:** A 40-meter wide array of glowing data screens.
*   **The Pit:** The floor is sunken (approx 1m lower than the rest of the wing).
*   **Workstations:** 3 rows of long desks. The player sits in the front row, closest to the screens.
*   **Atmosphere:** Dark, cold blue, glowing monitors.

### Zone B: The Elevated Lab (15m x 15m)
*   **Purpose:** Secure investigation.
*   **Description:** An elevated area overlooking the Bullpen, separated by glass.
*   **Staff:** IT Support.

### Zone C: The Storage Labyrinth (15m x 20m)
*   **Purpose:** Equipment storage and transitions.
*   **Key Features:**
    *   **High-Density Racks:** 8m tall server racks.
    *   **The Elevator:** Heavy blast doors leading to the Briefing Room.
*   **Atmosphere:** Industrial, warm orange emergency lighting (placeholders).

---

## 3. Measurements Table

| Area | Width | Length | Height |
| :--- | :--- | :--- | :--- |
| **Bullpen** | 40m | 25m | 10m |
| **Lab/Storage Wing** | 15m | 35m | 10m |
| **Total L-Shape** | 55m | 35m | 10m |

---

## 4. Implementation Sprint

### Phase 1: The Mega-Shell (COMPLETED)

*   [x] Expand floor slabs to 40m+ scale.

*   [x] Set wall heights to 10m.

*   [x] Implement "Sunken Pit" floor geometry.

*   [x] Add internal partitions (Glass Lab wall, Solid Storage wall).



### Phase 2: Functional Pass (COMPLETED)

*   [x] Implement the Teleport Trigger (Purple Box) in the Storage Room.

*   [x] Connect Teleport to `TransitionManager` and the Briefing Room scene.

*   [x] Add 2 "Background Analyst" NPCs to the Bullpen.

*   [x] Place "War Wall" dynamic material placeholders.

*   [x] Reposition NPCs to reflect the larger walking distances.


### Phase 3: Aesthetic Polish (COMPLETED)

*   [x] Populate the Bullpen with more workstations (3 full rows).

*   [x] Add decorative Server Racks (8m tall) to the Storage Labyrinth.

*   [x] Implement stairs or ramps connecting the Pit to the elevated corridors.

*   [x] Add "Emergency Orange" placeholder lighting to the Storage area.
