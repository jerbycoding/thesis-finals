# Phase 2: Interior & Atmosphere - "The Pressure Cooker"

## 1. Vision
We have successfully condensed the SOC into a tighter, more intense 24m x 20m layout ("The Corporate Office"). Now we must fill the gray boxes with life. The goal is to create an environment that tells a story of high-stakes, bureaucratic cybersecurity work.

## 2. Zone Breakdown & Prop Strategy

### Zone 6: Secure Server Vault (The Heart)
*   **Concept:** The physical brain of the network. Cold, loud, restricted.
*   **Props:**
    *   **Server Racks:** 4-6 units lined up against the back wall.
    *   **Cable Trays:** Messy cabling on the floor/ceiling.
    *   **Cooling Units:** Industrial AC props (or just sound effects).
*   **Lighting:** Dim, with blinking green/red LEDs from the racks.

### Zone 2: Analyst Bullpen (The Trenches)
*   **Concept:** Where the grunt work happens. Open, exposed, zero privacy.
*   **Props:**
    *   **War Wall:** A massive screen on the North Wall displaying live threat data.
    *   **Desks:** 2 Rows of 4 desks (Standard Issue).
    *   **Chairs:** Standard ergonomic chairs.
    *   **Clutter:** Coffee mugs, stacks of paper, headsets.

### Zones 3-5: Senior Analyst Offices (The Hierarchy)
*   **Concept:** The first step up the ladder. Glass walls offer "privacy" but no secrets.
*   **Props:**
    *   **Senior Desks:** Slightly larger/nicer than the bullpen.
    *   **Whiteboards:** Filled with diagrams and shift schedules.
    *   **Files:** Filing cabinets.

### Zone 1: CISO Executive Suite (The Tower)
*   **Concept:** The eye in the sky. Keeps watch over the entire floor.
*   **Props:**
    *   **Executive Desk:** Large, imposing, clean.
    *   **Meeting Table:** For "disciplinary actions."
    *   **Status:** Currently empty (CISO removed), creating an ominous "absent presence."

## 3. Implementation Plan (Manual Placement)
*   **Why Manual?** The new layout is custom and partitioned. An auto-spawner is overkill and hard to align with walls.
*   **Method:** We will instantiate `PackedScene` props directly into `SOC_Office.tscn` under a `Props` node.

## 4. Lighting Strategy
*   **Global:** Cool, sterile fluorescent office lighting (4000K).
*   **Local:**
    *   **War Wall:** Casts a dynamic blue/red glow over the Bullpen.
    *   **Server Room:** Cold blue + blinking LEDs.
    *   **Player Desk:** A warm desk lamp to create a "safe haven" feel.
