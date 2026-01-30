# 🕒 Shift & Narrative Arc Documentation

The narrative of **VERIFY.EXE** spans a 7-day arc, transitioning from 2D desktop workstation shifts during the week to physical 3D maintenance tasks on weekends.

## Weekday Routine (Mon - Fri)
Players operate from the SOC Desk. Narrative progress is managed by the `NarrativeDirector.gd` through scheduled events and random pools.

### Monday: Active Monitoring
*   **Theme:** Orientation and low-intensity threats.
*   **Key Event:** Training Certification refresher.
*   **Threats:** Standard `PHISH-001`.

### Tuesday: Noise
*   **Theme:** High informational volume.
*   **Key Event:** `FALSE_FLAG` log flood.
*   **Threats:** Social Engineering and spoofed vendors.

### Wednesday: Outbreak
*   **Theme:** Subnet containment.
*   **Key Event:** `LATERAL_MOVEMENT` active simulation.
*   **Threats:** Active Malware beacons and first Ransomware sightings.

### Thursday: Betrayal
*   **Theme:** Internal suspicion.
*   **Key Event:** Scrutinizing internal employees.
*   **Threats:** Insider exfiltration and unauthorized cloud apps.

### Friday: Zero Day
*   **Theme:** Total technical breakdown.
*   **Key Event:** Global `ZERO_DAY` exploit.
*   **Threats:** Massive DDoS attacks and critical server encryption.

---

## 🎲 The Chaos Engine
Each shift features a `random_event_pool` that ensures no two Mondays feel the same.
*   **ISP Throttling:** Multiplies Terminal command duration by 3x.
*   **Power Flicker:** Screen blacks out; locally open app windows crash/close.
*   **Gossip Flood:** Clutters the Email Analyzer with non-malicious noise.
*   **SIEM Lag:** Injects artificial delay when selecting logs for forensics.

---

## 🛠️ Weekend Shifts (Sat - Sun)
Weekend shifts focus on 3D interaction and specialized minigames.

### Saturday: Infrastructure Audit
*   **Location:** Floor -2 (Network Hub).
*   **Mechanic:** Physical inspection of router nodes.
*   **Minigame:** `Calibration Minigame` (Signal Lock & Handshake).
*   **Payoff:** Suspend Integrity Decay if all nodes are verified.

### Sunday: Hardware Recovery
*   **Location:** Floor -1 (Server Vault).
*   **Mechanic:** Carrying and slotting server blades.
*   **Minigame:** `Raid Sync` (Master Backplane Initialization).
*   **Payoff:** Large Integrity restore bonus upon successful master sync.
