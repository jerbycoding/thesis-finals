# 🏢 Phase: Office Environment & Prop Polish

**Status:** Graybox Methodology Initiated
**Objective:** Transform the SOC Office from a sparse environment into a dense, realistic corporate space using automated and manual placement.

---

## 🛠️ The Graybox Strategy
To ensure perfect scale and performance, we are using **Graybox Placeholders**.
1. **Shell Scenes:** We have created `.tscn` files in `res://scenes/3d/props/graybox/`.
2. **Primitives:** These scenes contain simple gray cubes with the correct real-world dimensions and collision.
3. **Instancing:** These scenes are instanced throughout the level (via Spawner or Manual).
4. **The Swap:** When a final model is downloaded, we replace the Mesh node inside the Placeholder scene. **The entire office updates instantly.**

---

## 🛒 Model "Shopping List"
Find these models (FBX, GLB, or OBJ) to replace the current graybox cubes:

| Prop | Search Term | Target Location |
| :--- | :--- | :--- |
| **IP Phone** | "Cisco/Polycom IP Phone" | Every Analyst Desk |
| **Laptop** | "Closed Laptop / ThinkPad" | Random Desks / Cabinets |
| **Coffee Maker** | "Countertop Espresso Machine" | Break Area (Zone 7) |
| **Water Cooler** | "Standing Water Dispenser" | Break Area / Bullpen |
| **Vending Machine**| "Snack Vending Machine" | Break Area (Zone 7) |
| **Paper Shredder** | "Office Paper Shredder" | Near CISO / Senior Analyst |
| **Fire Extinguisher**| "Fire Extinguisher Prop" | Room Corners / Near Server |
| **Server UPS** | "APC Floor UPS / Battery" | Server Vault (Zone 6) |
| **Server Blade** | "1U/2U Server Unit Low Poly"| Inside Server Racks |
| **Rack Switch** | "Rack Mount Network Switch" | Inside Server Racks |
| **Rack Console** | "KVM Rack Monitor Unit" | Inside Server Racks |
| **Desk** | "Modular Office Desk" | Bullpen / Offices |
| **Chair** | "Ergonomic Office Chair" | Bullpen / Offices |
| **Window** | "Modern Office Window Frame"| External Walls |
| **Plant in Pot** | "Potted Snake Plant / Monstera"| Room Corners |
| **Ceiling Light** | "Linear LED Tube Light" | Ceiling Grid |

---

## 📋 Implementation Roadmap

### 1. Automated Clutter (Tomorrow's First Task)
*   Update `PropSpawner.gd` node in `SOC_Office.tscn`.
*   Add `Graybox_Phone` and `Graybox_Laptop` to the `clutter_scenes` array.
*   Trigger `spawn_props` to see the density across all desk rows.

### 2. Manual Zone Detailing
*   **Zone 1 (CISO):** Place Shredder, specialized Desk Lamp, and Picture.
*   **Zone 7 (Break Area):** Place Vending Machine, Water Cooler, and Coffee Maker.
*   **Zone 6 (Server Vault):** Place UPS units on the floor near the racks.

### 3. Lighting & Vibe Shift
*   Transition `WorldEnvironment` from "Neon Blue" to "Corporate Daylight."
*   Adjust `WarWall.gd` to use professional **Enterprise Blue (#006CFF)** instead of neon cyan.

### 4. NPC Integration
*   Swap current NPC placeholders for `Man.glb` and `Stylized Character.glb`.
*   Assign unique "Work" animations (typing, standing) to give the office life.

---

**Next Session Start:** "Initialize PropSpawner with Graybox Clutter"
