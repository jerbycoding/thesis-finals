# Sprint Week 8: Spatial Reconstruction (The Bunker Redesign)

## 1. Objective
Pivot from a "Large Scale Warehouse" architecture to a "High-Density Tactical Bunker." This redesign reduces walking friction and prepares the 3D environment for upcoming physical server rack interactions.

## 2. Tasks

### 2.1 Structural Downsizing
*   **Footprint Reduction:** Shrink the SOC floor from 55m x 35m to a compact **15m x 12m** rectangle.
*   **Ceiling Compression:** Lower ceiling height to **3.5m** to create a focused, high-tech atmosphere.
*   **Asset Cleanup:** Remove the 24+ procedural workstations in favor of a bespoke central cluster.

### 2.2 Command Center Overhaul
*   **Curved War Wall:** Transform the flat 40m monitoring wall into a curved, wrap-around display centered on the player's desk.
*   **Desk Consolidation:** Implement a 3-desk "Command Pod" (Player in center, 2 background analysts flanking).
*   **Pivot UX:** Optimize layout so all critical infrastructure (Racks, Workbench, Elevator) is within a 5-meter "Pivot and Walk" radius.

### 2.3 High-Density Integration
*   **The Server Ring:** Position server racks in a U-shape surrounding the player’s desk.
*   **Zone Merging:** 
    *   Merge the **IT Lab** into a specialized **Forensics Workbench** in the room corner.
    *   Merge **Storage** assets directly into the server rack wall layout.
*   **Visual Complexity:** Add overhead cable trays, cooling pipes, and floor-mounted cable guards to fill the smaller volume with detail.

### 2.4 Environmental Signaling
*   **Bunker Lighting:** Shift primary illumination to screen emissives and rack status LEDs (Green/Yellow/Red).
*   **Diegetic Linkage:** Prepare rack materials to react to `NetworkState` (e.g., physical rack flashes red when a host is infected).

## 3. Technical Requirements
*   Update `PropSpawner.gd` or create a static version for the new 3-desk layout.
*   Ensure `TransitionManager.gd` camera positions are updated for the tighter room bounds.
*   Collision meshes must be regenerated for the new compact geometry.
