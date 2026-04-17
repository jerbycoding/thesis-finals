# PROJECT MANDATE: VERIFY.EXE (Incident Response SOC Simulator)
> **Role-Aware Context for Gemini CLI**
> **Thesis Goal:** Educational simulation of the attack/detection relationship via "Mirror Mode."
> **Architecture Style:** Hybrid 2D/3D world with dual-campaign role isolation.

---

## 1. The Core Thesis: Mirror Mode
The defining purpose of this project is **Modular Inversion**. Every action the player performs in the **Hacker Campaign** must generate a corresponding, scientifically accurate forensic footprint for the **Analyst Campaign**.

- **Hacker History:** A ground-truth log of every offensive packet, exploit, and pivot.
- **SIEM Logs:** The "digital shadow" seen by the defender.
- **The Payoff:** A post-shift report side-by-side comparison that correlates attack (left) vs. detection (right).

---

## 2. Foundational Mandates (The "Never-Break" Rules)

### 2.1 — Timestamp Authority
**LAW:** All timestamps across both roles MUST use `ShiftClock.elapsed_seconds`.
- **Reasoning:** System time (`Time.get_unix_time_from_system()`) is unreliable for Mirror Mode correlation due to pauses, restarts, and game speed scaling.
- **Forensic Accuracy:** Correlation logic depends entirely on a unified "Seconds since shift start" counter.

### 2.2 — Absolute Role Isolation (The Guard Pattern)
**LAW:** Hacker actions must NEVER accidentally trigger Analyst consequences (Integrity damage, Ticket spawning, etc.).
- **Enforcement:** Every singleton shared between roles MUST contain a Role Guard at its entry point or signal connection logic:
  ```gdscript
  if GameState.current_role != Role.HACKER: return
  ```
- **Bleed Protection:** Defensive singletons (`ConsequenceEngine`, `IntegrityManager`) are "read-only" or "off" during Hacker shifts.

### 2.3 — State Authority
**LAW:** `GameState.gd` is the Master Authority for the **Game Mode** (Interaction) and **Role** (Identity).
- **Mode vs Role:** `GameMode` (3D, 2D, UI) controls *how* the player interacts. `Role` (Analyst, Hacker) controls *who* the player is. They are orthogonal.
- **Switch Authority:** `GameState.switch_role()` is the only function permitted to modify the role. It handles mandatory cleanup (flushing pools, clearing timers, caching heat).

---

## 3. High-Level Architectural Principles

### 3.1 — Hybrid 2D/3D Interface
The world is a 3D physical environment (`SOC_Office.tscn`, `HackerRoom.tscn`). Interactive computer screens use a `MonitorInputBridge` to project 2D Desktop UIs (`ComputerDesktop.tscn`) onto 3D meshes.
- **Immersion Rule:** Transition animations (Sitting/Standing) must be respected to maintain the "Workstation Operator" feel.

### 3.2 — Event-Driven Decoupling
Systems communicate primarily through `EventBus.gd`. This is our primary safety mechanism. If a system fails to listen or a guard fails, the result should be "wrong behavior" (silent) rather than a hard crash.

---

## 4. Tactical Arsenal (Modular Inversion)

Hacker tools are designed as "Inversions" of the SOC Analyst tools:
- **Exploit Command:** The inverse of the **Scan/Verify** loop.
- **Log Poisoner:** The inverse of the **SIEM Viewer**.
- **Phish Crafter:** The inverse of the **Email Analyzer**.
- **Wiper Script:** The inverse of the **Evidence Preservation** mandate.
- **Ransomware:** The inverse of the **Decryption/Recovery** loop.

---

## 5. Narrative Progression
- **Analyst:** A 14-day escalation from routine phishing to Zero-Day infrastructure collapse.
- **Hacker:** A 7-day arc working for "The Broker," revealing an internal corporate conspiracy.
- **Insider Threat:** The two arcs intersect at Day 7, where the Broker's identity completes the narrative loop.

---

## 6. Implementation Maturity Model

| Stage | Milestone | Status |
|---|---|---|
| **MVHR** | 3 Days, Exploit Command, RivalAI, Ransomware, Bounty | **STABLE** |
| **Tactical** | Exfiltrator (Multi-stream), Wiper (Precision), Intelligence Inventory | **PENDING** |
| **Narrative** | Days 4-7 Arc, Token Resolution, Scripted Hazards, Broker Reveal | **PENDING** |
| **Thesis** | Mirror Mode UI, Correlation Engine, Glitch Aesthetics, Audit Pass | **FINAL** |

---

## 7. Developer's Quick-Start
- **Main Scene:** `res://scenes/ui/TitleScreen.tscn`
- **Primary Logic:** `autoload/GameState.gd`
- **Signals:** `autoload/EventBus.gd`
- **Forensics:** `autoload/HackerHistory.gd` vs `autoload/LogSystem.gd`
- **Opponent:** `autoload/RivalAI.gd` (State Machine)
