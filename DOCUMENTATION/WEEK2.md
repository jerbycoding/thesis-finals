# 📄 WEEK 2: "The Advanced Persistent Threat" (Content Audit)

**Theme:** Inheritance -> Instability -> Human Pressure -> Sabotage -> Total War.
**Goal:** Challenge the player's mastery of all SOC tools (Terminal, Decryption, Map) under extreme technical and psychological conditions.

---

#### 📅 **MONDAY: "Inheritance"** (Shift 8)
*   **Narrative Arc:** The attackers from Week 1 resurface. Past mistakes (Efficient closures) return via the Vulnerability Buffer.
*   **Key Tickets:**
    *   `PHISH-LEGACY-001` (Stage 1.5): A phish using signatures from Week 1.
    *   `MALWARE-POLY-001` (Stage 2): Polymorphic threat requiring **Terminal Scan**.
    *   `RANSOM-ECHO-001` (Stage 3): Ransomware executed from a "dirty" backup.
*   **Mechanic Focus:** Cross-week technical consistency.

#### 📅 **TUESDAY: "System Instability"** (Shift 9)
*   **Narrative Arc:** The attackers target the SOC's infrastructure. The SIEM becomes unreliable.
*   **Key Tickets:**
    *   `SUPPLY-CHAIN-004` (Stage 1): Catching a corrupted update via **Email Headers**.
    *   `DNS-SPOOF-001` (Stage 2): Finding an internal hijacker via **Terminal Trace**.
*   **Mechanic Focus:** **Resource Deprivation.** The `SIEM_LAG` event forces the player to use secondary tools.

#### 📅 **WEDNESDAY: "Executive Targets"** (Shift 10)
*   **Narrative Arc:** Attacker focus shifts to the C-Suite. High political pressure.
*   **Key Tickets:**
    *   `WHALING-001` (Stage 1): Fake subpoena targeting the CEO.
    *   `VIP-LAPTOP-001` (Stage 2): Choosing between a CFO's meeting and network safety.
*   **Mechanic Focus:** **Critical Decision Making.** Massive Approval hits for botched VIP tickets.

#### 📅 **THURSDAY: "Paranoia"** (Shift 11)
*   **Narrative Arc:** The mole is active. Logs are being scrubbed. NPCs are accusing each other.
*   **Key Tickets:**
    *   `MOLE-HUNT-001` (Stage 2): Verifying alibis against external login logs.
    *   `LOG-WIPER-001` (Stage 2): A race to isolate a host before it deletes the SIEM history.
*   **Mechanic Focus:** **Evidence Integrity.** Handling the `FALSE_FLAG` event.

#### 📅 **FRIDAY: "Total War"** (Shift 12)
*   **Narrative Arc:** The "Apocalypse Protocol." Coordinated destruction of all company infrastructure.
*   **Key Tickets:**
    *   `KILL-SWITCH-001` (Stage 3): Attack on the physical Tape Library.
    *   `CORE-MELTDOWN-001` (Stage 3): HVAC override threatening to melt server hardware.
    *   `ADMIN-LOCKOUT-001` (Stage 3): Hacking back into your own SOC account.
*   **Mechanic Focus:** **Survival & Multitasking.** All 3 World Events active simultaneously.

---

### 🚦 Kill Chain Integrity Check (Week 2 Evolution)

| Chain Name      | Stage 1 (Mon/Tue) | Stage 2 (Wed/Thu) | Stage 3 (Fri)   | Status       |
|:----------------|:------------------|:------------------|:----------------|:-------------|
| **Persistence** | `PHISH-LEGACY`    | `MALWARE-POLY`    | `RANSOM-ECHO`   | **COMPLETE** |
| **Executive**   | `WHALING-001`     | `VIP-LAPTOP-001`  | `RANSOM-VIP`    | **COMPLETE** |
| **Sabotage**    | `SUPPLY-CORRUPT`  | `LOG-WIPER`       | `KILL-SWITCH`   | **COMPLETE** |
| **Apocalypse**  | `DNS-SPOOF`       | `SABOTAGE-001`    | `CORE-MELTDOWN` | **COMPLETE** |

**Conclusion:**
Week 2 provides a much higher "floor" for difficulty. The player is expected to handle Stage 2 and 3 threats immediately, with narrative stakes that impact their relationships with the main NPCs.
