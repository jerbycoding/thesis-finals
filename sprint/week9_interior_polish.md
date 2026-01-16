# Sprint 9: Interior Polish & Atmosphere

**Goal:** Transform the "Corporate Office" graybox into a living, breathing Security Operations Center. Focus on manual prop placement, lighting, and environmental storytelling.

## 1. Zone 6: Secure Server Vault
- [ ] **Prop Placement:** Instantiate 4-6 `Prop_ServerRack` scenes in Zone 6.
- [ ] **Atmosphere:** Add a local `OmniLight3D` (Blue/Green) to simulate rack LEDs.
- [ ] **Cable Management:** Add simple cable primitives or decals if time permits.

## 2. Zone 2: Analyst Bullpen
- [ ] **The War Wall:** Re-integrate `WarWall.gd` and the screen mesh on the North Wall.
- [ ] **Workstations:** Place 2 rows of `Prop_Desk` + `Prop_Chair` + `Prop_Monitor`.
- [ ] **Clutter:** Add random `Prop_Mug` and `Prop_Plant` instances to make desks look used.

## 3. Zone 1: Executive Suite (CISO)
- [ ] **Furniture:** Add a large Executive Desk and a Meeting Table.
- [ ] **Glass:** Ensure the window shader allows clear visibility from the Bullpen.

## 4. Lighting & Post-Processing
- [ ] **Ceiling Lights:** Add `SpotLight3D` instances for the new lower ceiling (5m).
- [ ] **Environment:** Tweak `WorldEnvironment` for a slightly darker, higher-contrast "cyber" office look.
