# HOW TO PLAY — VERIFY.EXE

> **Project:** Incident Response: SOC Simulator  
> **Engine:** Godot 4.4 | **Thesis:** Dual-role symmetric design with Mirror Mode forensic report

---

## Table of Contents

- [Starting the Game](#starting-the-game)
- [Analyst Campaign](#analyst-campaign)
- [Hacker Campaign](#hacker-campaign)
- [Debug Hotkeys](#debug-hotkeys)
- [General Controls](#general-controls)

---

## Starting the Game

1. Launch the game → Main Menu appears
2. Choose one of the following:
   - **Training** — Tutorial sequence (guided mode)
   - **Campaign** — Analyst role (defensive SOC work)
   - **Hacker Campaign** — Hacker role (offensive penetration testing)

> **Note:** You cannot switch roles mid-campaign. Choose wisely.

---

## Analyst Campaign

You are a SOC (Security Operations Center) analyst. Your job is to investigate tickets, analyze logs, and respond to incidents.

### Terminal Commands

| Command | Syntax | Description |
|---------|--------|-------------|
| `scan` | `scan [hostname]` | Scan a host for vulnerabilities and status |
| `isolate` | `isolate [hostname]` | Isolate a compromised host from the network |
| `trace` | `trace [hostname]` | Trace the source of an attack |
| `restore` | `restore [hostname]` | Restore an isolated host to CLEAN status |
| `list` | `list` | List all known hostnames |
| `help` | `help` | Show available commands |

### Desktop Apps

| App | Purpose |
|-----|---------|
| **Ticket Queue** | View and triage active incident tickets |
| **SIEM Viewer** | View system logs, search for indicators of compromise |
| **Email Analyzer** | Inspect email headers, attachments, and links |
| **Network Mapper** | Visualize network topology and host relationships |
| **Terminal** | Command-line interface (commands above) |
| **Handbook** | SOC reference guide with procedures |
| **Task Manager** | Active ticket dashboard with completion tracking |
| **Decryption** | Anti-ransomware puzzle minigame (ticket-dependent) |
| **Shift Report** | End-of-shift summary and performance metrics |

### Workflow

1. **Shift starts** → CISO briefing → Tickets appear in Queue
2. **Triage tickets** → Read ticket details, check required tools
3. **Investigate** → Use SIEM, Email, Network Mapper to gather evidence
4. **Take action** → Scan, isolate, trace, or restore via Terminal
5. **Resolve tickets** → Attach evidence, submit completion
6. **Shift ends** → Review Shift Report, advance to next day

---

## Hacker Campaign

You are a penetration tester (or attacker) hired by the "Broker." Your job is to exploit network defenses and deploy ransomware on target hosts.

### Terminal Commands

| Command | Syntax | Description |
|---------|--------|-------------|
| `exploit` | `exploit [hostname]` | Exploit a host's vulnerability. Success depends on vulnerability score. **HONEYPOTS will trigger instant LOCKDOWN.** |
| `pivot` | `pivot [hostname]` | Move laterally to an adjacent host. **Evades AI isolation countdown** during LOCKDOWN state. |
| `submit` | `submit` | Submit your vulnerability report to the Broker. **Advances to the next day** and auto-saves. |
| `list` | `list` | List all known hostnames |
| `help` | `help` | Show available commands |

### Desktop Apps

| App | Purpose |
|-----|---------|
| **Terminal** | Command-line interface (commands above) |
| **Contract Board** | View and accept contracts from the Broker |
| **Ransomware** | Deploy ransomware on your current foothold. Completes the CalibrationMinigame to succeed. |
| **SIEM Viewer** | Monitor system logs (same as Analyst, but for recon) |
| **Email Analyzer** | Inspect emails for intelligence (same as Analyst) |

### Workflow

1. **Day starts** → Broker dialogue briefings → Contracts appear on Contract Board
2. **Accept a contract** → Note the target and bounty
3. **Exploit a host** → `exploit [hostname]` → Establishes a foothold
4. **Deploy ransomware** → Open Ransomware app → Complete the calibration minigame (hit the green zone 3 times)
5. **Contract completes** → Bounty awarded → Game auto-saves
6. **Advance to next day** → Type `submit` in Terminal
7. **Repeat for 3 days** → Campaign complete

### The Trace System

Every offensive action increases your **Trace Level** (0–100%):

| Action | Trace Cost |
|--------|-----------|
| Exploit (success or fail) | +15.0 |
| Ransomware (success) | +40.0 |
| Ransomware (fail) | +20.0 |
| Pivot | +5.0 |
| Honeypot exploit | **+100.0 (instant LOCKDOWN)** |

**Trace decays at 1.0 per second** when no offensive actions are performed.

### The Rival AI

The network has an AI Analyst that monitors your activity:

| Trace Level | AI State | Behavior |
|-------------|----------|----------|
| 0–30 | **IDLE** | Unaware of your presence |
| 30–70 | **SEARCHING** | Scanning for your foothold |
| 70–100 | **LOCKDOWN** | Attempting to isolate your current host |
| 100 | **ISOLATING** | 20-second countdown → **Connection Lost (Game Over)** |

**Evasion:** During LOCKDOWN, use `pivot [hostname]` to evade isolation. The AI transitions back to SEARCHING instead.

### Contracts

Each day has a unique contract:

| Day | Contract | Bounty | Notes |
|-----|----------|--------|-------|
| 1 | Ransom Any Host | $100 | No honeypots. Tutorial day. |
| 2 | Ransom Finance Server | $150 | **Honeypot: RESEARCH-SRV-01** — avoid it! |
| 3 | Ransom Database Server | $200 | Final job. Broker wants to talk after. |

### Honeypots

Some hosts are **traps**. Exploiting them triggers **instant LOCKDOWN** (Trace → 100%). They look identical to normal hosts in the UI. You'll know when it's too late.

> **Day 2 honeypot:** `RESEARCH-SRV-01` — Do NOT exploit this one.

---

## Debug Hotkeys

### Analyst Debug Keys

| Key | Function |
|-----|----------|
| F1 | Previous shift |
| F2 | Next shift |
| F9 | Chaos trigger |

### Hacker Debug Keys

| Key | Function |
|-----|----------|
| F1 | Previous hacker shift |
| F2 | Next hacker shift |
| F3 | Skip current shift |
| F4 | Force-complete active contract |
| F7 | Add 10 Trace (debug) |
| Ctrl+F4 | Add $100 bounty |
| Ctrl+F5 | Reset bounty ledger |
| Alt+F4 | Force AI to ISOLATING state |

> **Note:** Debug keys are role-guarded. Analyst keys don't work in Hacker mode and vice versa.

---

## General Controls

| Control | Function |
|---------|----------|
| WASD | 3D movement (first-person) |
| Mouse | Look around / interact with UI |
| E | Interact with objects (3D) |
| ESC | Pause menu |
| Left Click | Click UI elements, start minigames |

---

## Tips

### For Analysts
- Read the ticket description carefully — it tells you what tools to use
- Check SIEM logs for related events before isolating a host
- Email analysis can reveal phishing indicators and malicious attachments
- The Network Mapper shows host relationships — use it to find attack paths
- Don't rush — accuracy matters more than speed

### For Hackers
- Check vulnerability scores before exploiting — higher score = higher success rate
- The honeypot on Day 2 is `RESEARCH-SRV-01` — avoid it
- Use `pivot` during LOCKDOWN to escape isolation (costs +5 Trace)
- Complete contracts quickly to minimize Trace exposure
- Each contract auto-saves on completion — no manual save needed

---

## Phase Progression

| Phase | Status | Description |
|-------|--------|-------------|
| Phase 1: Foundation | ✅ | Role switching, themed login |
| Phase 2: Offensive Loop | ✅ | Exploit command, Trace system |
| Phase 3: AI Counter-Measures | ✅ | RivalAI, isolation, pivot evasion |
| Phase 4: High-Impact Payloads | ✅ | Ransomware app, contract system, bounty tracking |
| Phase 5: Narrative Arc | ✅ | 3-day campaign, Broker dialogue, honeypot traps, save/load |
| Phase 6: Integration & Polish | ⏳ | Mirror Mode, glitch aesthetics, final testing |

---

**Last Updated:** April 4, 2026  
**Version:** Phase 5 Complete
