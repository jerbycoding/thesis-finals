# 🏢 Environment & Room Documentation

**VERIFY.EXE** takes place across a multi-floor facility representing the infrastructure of a modern corporation. Each room serves a specific narrative or mechanical purpose, and gameplay transitions between these spaces as the week progresses.

---

## 📍 Floor 2: Executive Suite
*   **Narrative Role:** The center of authority.
*   **Key Occupant:** **CISO** (Chief Information Security Officer).
*   **Atmosphere:** High-end, pristine, intimidating. Expensive furniture, panoramic city views, and isolation from the chaos of the lower floors.
*   **Key Interactions:**
    *   **Performance Reviews:** Players are summoned here for major plot beats (promotions, warnings, or termination).
    *   **The Big Picture:** Displays global threat maps and high-level strategy, contrasting with the granular logs seen in the SOC.

---

## 📍 Floor 1: Main SOC Office (The Bullpen)
*   **Narrative Role:** The player's primary workspace.
*   **Atmosphere:** Functional, high-tech, slightly claustrophobic. "Command Center" aesthetic with blue-tinted lighting, rows of workstations, and a massive **War Wall** displaying real-time metrics.
*   **Key Mechanics:**
    *   **Player Workstation:** The entry point for the 2D desktop gameplay loop.
    *   **War Wall:** A reactive environment prop that changes color based on active ticket volume (Cyan = Calm, Yellow = Warning, Red = Crisis).
    *   **NPC Interactions:** Home to the **Senior Analyst**, **Junior Analyst**, **IT Support**, and **Helpdesk**.
*   **Sub-Area: Briefing Room**
    *   **Function:** Used for Monday morning briefings and crisis meetings.
    *   **Features:** A projector screen for mission details and a conference table for team dialogue.

---

## 📍 Floor -1: Server Vault
*   **Narrative Role:** The organization's "brain."
*   **Gameplay Role:** **Sunday Shift (Hardware Recovery).**
*   **Atmosphere:** Cold, industrial, sterile. The hum of cooling fans is constant. Rows of high-density server racks dominate the space.
*   **Key Mechanic:** **Hardware Replacement.** Players must physically carry server blades from the storage area to specific rack slots (`RACK_1` through `RACK_6`).
*   **Interactive Props:**
    *   **Active Racks:** Server slots that can accept `Prop_ServerBlade` items.
    *   **Status LEDs:** Visual indicators on racks showing drive health (Green/Red).

---

## 📍 Floor -2: Network Hub
*   **Narrative Role:** The organization's "nervous system."
*   **Gameplay Role:** **Saturday Shift (Infrastructure Audit).**
*   **Atmosphere:** Utilities-focused, gritty, unfinished. Exposed cabling, HVAC ducts, and concrete floors.
*   **Key Mechanic:** **Signal Calibration.** Players navigate a maze of pipes and machinery to locate and audit physical routers.
*   **Interactive Props:**
    *   **Router Nodes:** Physical interaction points that trigger the **Calibration Minigame**.
    *   **Patch Panels:** Wall-mounted interfaces for tracing cable faults.

---

## 🚀 Navigation & Transition
*   **The Elevator:** The central connector for all floors.
    *   **Mechanism:** Players use the `RoomTeleporter` script attached to the elevator panel to travel between scenes.
    *   **Restrictions:** Access to lower floors (Vault/Hub) is restricted to specific weekend shifts or narrative events.
*   **Wayfinding:** 
    *   **Label3D** nodes in the 3D world provide in-universe signage (e.g., "OFFICE C: YOUR ROOM").
    *   **Tutorial Waypoints:** Floating markers guide the player during the onboarding phase.
