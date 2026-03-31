# HACKER ROLE: "THE REMOTE OPERATOR" (Symmetric Adversarial Design)

## 1. Core Concept: The Pressure Cooker
The Hacker Role is a **Symmetric Mirror** of the SOC Analyst. Instead of navigating a corporate office, the player is confined to a single, high-fidelity 3D "Home Office." This role leverages the existing **Kill Chain Engine**, **Heat Manager**, and **Procedural Truth System** but flips the player's intent from **Defense** to **Offense**.

### The Narrative Hook: "Hacking Your Own Ghost"
The "AI Analyst" you are hacking isn't a random script—it is a **mirror of your own performance metrics** from the SOC Analyst campaign. The game reads your `ArchetypeAnalyzer` data to determine if the AI opponent is "Thorough/By-the-Book" or "Fast/Cowboy." You are literally fighting against your own past habits.

---

## 2. 3D Environment: The Physical Dashboard
Since there is no navigation, the 3D room serves as a **Physical Stress Simulator**.

*   **Multi-Monitor Setup:** The workstation features 3-4 interactive 2D monitors. Each monitor runs an inverted version of the SOC tools.
*   **Physical Heat Indicators:** Instead of just a UI bar, the "Trace Level" (Heat) is reflected in the 3D world:
    *   **Low Trace:** Calm rain, lo-fi music, static lighting.
    *   **Medium Trace:** Police scanners on the desk start crackling; red/blue lights reflect in the window.
    *   **High Trace:** Power flickers, hardware cooling fans get louder, and the "Integrity Manager" (HP) becomes the literal door to the room. If the door is breached, the "Trace" hit 100%.
*   **Tactile Interactions:** 
    *   **Physical Phone:** Used for "Social Engineering" dialogue and receiving stolen 2FA codes.
    *   **Manual Reset:** A physical router on the desk that the player must interact with to "Reset IP" (temporarily dropping Heat but freezing all active downloads).

---

## 3. The Mirror Loop: Offensive Toolset
We reuse the existing App architecture but inject a `MODE_HACKER` flag to invert functionality.

| Tool | SOC Analyst (Defensive) | Remote Operator (Offensive) |
| :--- | :--- | :--- |
| **Email Analyzer** | Identify phishing risk. | **The Phish-Crafter:** Select a "Stolen Identity" and a "Template." Balance Urgency vs. Authority to bypass the SOC AI's heuristic filter. |
| **SIEM Log Viewer** | Find the attacker's trail. | **Log Poisoner:** See the logs the SOC AI is currently analyzing. Inject "Noise Logs" (False Positives) to distract the AI while your real exploit runs. |
| **Network Mapper** | Protect critical nodes. | **Recon Mapper:** Identify "Vulnerabilities" (Inherited from the Analyst's past mistakes) and "Pivot" deeper into the internal network. |
| **Terminal** | `scan` / `isolate [IP]` | **Exploit Console:** `exploit [IP]`, `bruteforce [Service]`, `exfiltrate [Data]`. |

---

## 4. Win/Loss Conditions: The Inverted Kill Chain

### The "Truth Packet" (Win Condition)
The Hacker's goal is to compile a **Master Exfiltration Resource**.
1.  **Infiltration:** Successfully land a Phishing email via the Email Tool.
2.  **Propagation:** Move laterally through the Network Mapper by exploiting unpatched hosts.
3.  **Exfiltration:** Initiate a "Drip Feed" download. The player must actively "Poison" the SIEM logs to keep the "Heat Manager" from detecting the high bandwidth usage.

### Failure State (Loss Condition)
*   **Trace Level (100%):** The SOC AI correlates your behavior, traces your IP, and the "Physical Integrity" of your room is compromised (Police Breach).
*   **Integrity Hit:** The company's automated "Wiper Scripts" delete your footholds before the Exfil is complete.

---

## 5. Technical Implementation (Architectural Reuse)

This role is a "Thesis-Level" implementation because it requires **zero new core systems**.

*   **ArchetypeAnalyzer:** Feeds the "AI Analyst" behavior profile.
*   **HeatManager:** Swaps "Analyst Stress" for "Hacker Trace Level."
*   **Procedural Truth System:** Generates the "Vulnerabilities" and "Credential Sets" for the Hacker to find.
*   **VariableRegistry:** Populates the technical indicators (MACs, IPs, Firmware) used in both modes to ensure semantic consistency.
*   **GameState.gd:** Adds `MODE_HACKER` to enforce the desk-bound 3D constraints and multi-monitor authority.

---

## 6. Desktop Reuse Strategy: "Symmetric Workspace"

The existing `ComputerDesktop.tscn` is a versatile container that can be dynamically "skinned" based on the `GameState.current_mode`.

### Implementation Steps:
1.  **Hacker Theme Injection:** 
    *   Create `HackerTheme.tres` (Darker colors, Red/Amber accents).
    *   In `ComputerDesktop._ready()`, check `if GameState.current_mode == GameState.MODE_HACKER:`.
    *   Apply the `HackerTheme` and change the wallpaper to a dark, high-contrast texture.
2.  **App Filtering (The "Toolbox"):**
    *   Create a `hacker_permission_profile.tres`.
    *   Whitelist hacker-specific `AppConfigResource` files (e.g., "Phish-Crafter", "Log Poisoner").
    *   `DesktopWindowManager` will automatically only show these icons in the Start Menu and on the desktop.
3.  **App Inversion:**
    *   Existing apps (SIEM, Terminal) will be "wrapped" in hacker-specific scenes that reuse the underlying logic but change the UI labels and "Action" triggers (e.g., "Scan" → "Exploit").
4.  **Multi-Monitor Persistence:**
    *   In the 3D House scene, the player interacts with the same `InteractableComputer.tscn`.
    *   The `TransitionManager` will handle the persistence of the hacker's desktop windows across the "Remote Operator" session.

---

## 7. System Reusability Audit: "Modular Inversion"

A key technical highlight of this design is its **90%+ reusability** of existing code. This demonstrates a high-quality, modular architecture where gameplay intent is decoupled from the underlying systems.

### 7.1 Autoload Singletons (Core Logic)
| Autoload | Reuse Level | Hacker-Specific Application |
| :--- | :--- | :--- |
| `VariableRegistry` | 100% | Ensures MAC/IP/Firmware consistency between hacker recon and SIEM records. |
| `NetworkState` | 100% | Used by the hacker to identify "Pivots" and "Vulnerable" nodes. |
| `HeatManager` | 90% | Renamed to **"Trace Level"**; scales AI analyst response speed and detection probability. |
| `IntegrityManager`| 90% | Renamed to **"Stealth Integrity"**; depletion triggers a physical "Police Breach" fail state. |
| `TerminalSystem` | 70% | Core command parsing is reused; adds offensive commands (`exploit`, `spoof`, `pivot`). |
| `LogSystem` | Inverted | Instead of receiving logs, the Hacker **injects** spoofed logs to poison the SIEM. |
| `EmailSystem` | Inverted | Instead of analyzing emails, the Hacker **dispatches** phishing templates to victims. |

### 7.2 Scripts & UI (Interaction Layer)
*   **`MonitorInputBridge.gd`:** 100% Reused. This is the primary driver for the multi-monitor desk interaction in the Hacker's home office.
*   **`ComputerDesktop.gd`:** 100% Reused. Reuses the windowing logic, taskbar, and start menu, simply swapping the `Theme` and `AppPermissionProfile`.
*   **`App_NetworkMapper.gd`:** 80% Reused. The visual topology remains the same; the "ContextMenu" actions are swapped from `Isolate` to `Deploy Persistence`.
*   **`App_Decryption.gd`:** 100% Reused. Mechanically identical, but framed as "Cracking Credentials" or "Encrypting Target Data."

### 7.3 Resource Architecture (Data Layer)
The hacker role reuses existing **Class Structures** but utilizes **New Data Instances (.tres)** to maintain separate campaign progress.

1.  **Reuse the Code Class:** `HostResource`, `LogResource`, and `EmailResource` classes are kept as-is.
2.  **New Data Files:**
    *   `HackerObjectiveResource`: (Inherits from `TicketResource`) Defines offensive goals (e.g., "Exfiltrate Payroll") instead of defensive alerts.
    *   `ExploitPool.tres`: (Uses `VariablePool` class) A new collection of known vulnerabilities and phishing payloads for the hacker to select.
    *   `HackerShiftResource`: Defines the sequence of night-ops and exfiltration windows.

---

## 8. Expected Gameplay Experience: "The Cat-and-Mouse Loop"

The gameplay is divided into three distinct phases that mirror the offensive Kill Chain. Unlike the SOC Analyst who reacts to events, the Hacker **initiates** them and must manage the **Trace Level** (Heat) throughout the shift.

### 8.1 Phase 1: Recon & Infiltration (Low Tension)
*   **Action:** The player uses the **Recon Mapper** to identify a "Weak Link" (an unpatched workstation or a distracted NPC).
*   **The "Phish":** Using the **Phish-Crafter**, the player sends a targeted email. They must wait in real-time for an NPC to "click" the link. 
*   **Atmosphere:** Calm. Lo-fi music plays. The only sound is the rain outside and the hum of the cooling fans.

### 8.2 Phase 2: Propagation & Pivoting (Medium Tension)
*   **Action:** Once a foothold is established, the player uses the **Exploit Console** (Terminal) to move laterally. 
*   **The "Ghost" Interaction:** The AI Analyst (your past self) begins to "investigate" your noise. You see the AI's queries appearing in the **Log Poisoner** (SIEM).
*   **Log Poisoning:** To stay hidden, the player must inject "Noise Logs" (e.g., a fake printer error or a generic system update) to distract the AI from the real IP address being used for the pivot.

### 8.3 Phase 3: The Exfiltration Finale (High Tension)
*   **Action:** The player initiates the download of the "Master Exfiltration Resource." A progress bar appears on the center monitor.
*   **The "Trace" Surge:** Bandwidth usage spikes the **Trace Level**. Outside the 3D window, red and blue lights begin to reflect. Police scanners crackle on the physical desk radio.
*   **Active Defense:** The player must "Counter-Hack" the AI Analyst by temporarily locking their terminal or crashing their SIEM view using **Logic Bombs** to buy time for the final 10% of the download.

---

### 8.4 Win/Loss Outcomes

| Outcome | Visual/Narrative Feedback |
| :--- | :--- |
| **WIN (Exfil Complete)** | The player hits "Disconnect." The lo-fi music returns. A final terminal message reads: *"Assets secured. Traces purged."* The player walks away from the desk as the screen fades to black. |
| **LOSS (Traced/HP 0%)** | The **Trace Level** hits 100%. The music cuts out instantly. The 3D room's door is kicked in with a loud crash. The screen glitches into static and displays: *"CONNECTION TERMINATED BY AUTHORITIES."* |

---

**Professor's Value Proposition:** 
*This implementation demonstrates the robustness of the Unified State Authority. By flipping the logic of the singletons, we create a completely different gameplay experience without rebuilding the backend, showcasing professional-grade modularity and symmetric AI design.*
