# PHASE 2: COMPREHENSIVE AUDIT

## 📊 Phase 2 Overview

**Objective:** Add ONE offensive tool (`exploit`) with consequences (Trace system)

**Duration:** 1.5 weeks (Solo Dev)

**End Goal:** Exploit host → Trace rises → decays when idle

---

## 📋 TASK BREAKDOWN (5 Tasks)

### **TASK 1: Exploit Command** 🔓
**File:** `phase-sprint/phase-2/01-exploit-command.md`

**What to Build:**
- Add `exploit [hostname]` command to TerminalSystem
- 6-step execution flow (Null Guard → Ownership → Honeypot → Success/Fail → Signal)
- Emit `offensive_action_performed` signal with 5-key payload

**Files to Modify:**
- `autoload/TerminalSystem.gd` - Add exploit command
- `resources/HostResource.gd` - Add vulnerability_score, is_honeypot

**Success Criteria:**
- [ ] `exploit WEB-SRV-01` works in terminal
- [ ] Successful exploit adds host to `GameState.hacker_footholds`
- [ ] Signal emits with correct payload (action_type, target, timestamp, result, trace_cost)
- [ ] Failed exploit still emits signal
- [ ] Honeypot exploit emits with "HONEYPOT" result

**Dependencies:**
- ✅ GameState.hacker_footholds (Phase 1)
- ✅ GameState.current_foothold (Phase 1)
- ⚠️ HostResource.vulnerability_score (NEW)
- ⚠️ HostResource.is_honeypot (NEW)

---

### **TASK 2: Trace Level System** 📈
**File:** `phase-sprint/phase-2/02-trace-level-system.md`

**What to Build:**
- Create `TraceLevelManager.gd` autoload
- Listen for `offensive_action_performed` signal
- Add trace cost (15.0 for exploit)
- Passive decay (1.0/second)

**Files to Create:**
- `autoload/TraceLevelManager.gd` (NEW)

**Success Criteria:**
- [ ] Exploit increases Trace by 15.0
- [ ] Trace decays by 1.0 per second when idle
- [ ] Decay pauses during minigames
- [ ] `get_trace_level()` returns correct value

**Dependencies:**
- ⚠️ `EventBus.offensive_action_performed` signal (NEW - Task 1)
- ✅ `GlobalConstants.TRACE_COST_EXPLOIT` (Phase 1)
- ✅ `GlobalConstants.TRACE_DECAY_RATE` (Phase 1)

---

### **TASK 3: Hacker History (Forensic Log)** 📝
**File:** `phase-sprint/phase-2/03-hacker-history.md`

**What to Build:**
- Create `HackerHistory.gd` autoload
- Record every offensive action to disk
- Crash-safe persistence

**Files to Create:**
- `autoload/HackerHistory.gd` (NEW)

**Success Criteria:**
- [ ] Every exploit appends to `history` array
- [ ] History writes to disk after each action
- [ ] `get_entries_for_day()` stub exists

**Dependencies:**
- ⚠️ `offensive_action_performed` signal (NEW - Task 1)
- ✅ SaveSystem (Phase 1)

---

### **TASK 4: Host Resource Extension** 🖥️
**File:** `phase-sprint/phase-2/04-host-resource-extension.md`

**What to Build:**
- Add `vulnerability_score` field (0.0-1.0)
- Add `is_honeypot` field (bool)
- Validation logic

**Files to Modify:**
- `resources/HostResource.gd` - Add new fields

**Success Criteria:**
- [ ] `vulnerability_score` field exists and validates
- [ ] `is_honeypot` field exists
- [ ] Existing hosts remain functional (no regressions)

**Dependencies:**
- None (pure data addition)

---

### **TASK 5: Role Guards (Signal Hygiene)** 🛡️
**File:** `phase-sprint/phase-2/05-role-guards.md`

**What to Build:**
- Add role guard comments to 4 Analyst singletons
- Prevent "Kill Chain bleed" from Hacker actions

**Files to Modify:**
- `autoload/ConsequenceEngine.gd` - Add guard comment
- `autoload/ValidationManager.gd` - Add guard comment
- `autoload/IntegrityManager.gd` - Add guard comment (✅ ALREADY DONE in Phase 1!)
- `autoload/TicketManager.gd` - Add guard comment

**Success Criteria:**
- [ ] All 4 files contain role guard comments
- [ ] IntegrityManager bypasses damage for Hacker role (✅ DONE)
- [ ] ConsequenceEngine does not consume `offensive_action_performed`

**Dependencies:**
- None (documentation/guards)

---

## 📦 FILES TO CREATE (4 new files)

1. **`autoload/TraceLevelManager.gd`** - Trace accumulation + decay
2. **`autoload/HackerHistory.gd`** - Forensic logging
3. **`resources/apps/AppConfig` for Hacker apps** (if needed)
4. **`scenes/2d/apps/HackerTerminal.tscn`** (if separate from Analyst terminal)

---

## 📝 FILES TO MODIFY (7 files)

1. **`autoload/TerminalSystem.gd`** - Add exploit command
2. **`resources/HostResource.gd`** - Add vulnerability_score, is_honeypot
3. **`autoload/ConsequenceEngine.gd`** - Add role guard comment
4. **`autoload/ValidationManager.gd`** - Add role guard comment
5. **`autoload/IntegrityManager.gd`** - Add role guard comment (✅ DONE)
6. **`autoload/TicketManager.gd`** - Add role guard comment
7. **`autoload/EventBus.gd`** - Add `offensive_action_performed` signal

---

## ✅ WHAT PHASE 1 PROVIDED

**Ready to Use:**
- ✅ `GameState.Role` enum (ANALYST/HACKER)
- ✅ `GameState.current_role` variable
- ✅ `GameState.hacker_footholds` dictionary
- ✅ `GameState.current_foothold` variable
- ✅ `GlobalConstants.TRACE_COST_EXPLOIT` (15.0)
- ✅ `GlobalConstants.TRACE_DECAY_RATE` (1.0)
- ✅ `GlobalConstants.HACKER_APP` constants
- ✅ `GlobalConstants.HACKER_PERMISSION` constants
- ✅ Debug tools (F4/F5 room jumping)
- ✅ IntegrityManager guard (prevents damage in Hacker mode)

---

## ⚠️ WHAT NEEDS TO BE CREATED

**New Signals:**
- ⚠️ `EventBus.offensive_action_performed` (Dictionary payload)

**New Autoloads:**
- ⚠️ `TraceLevelManager.gd`
- ⚠️ `HackerHistory.gd`

**New Resource Fields:**
- ⚠️ `HostResource.vulnerability_score`
- ⚠️ `HostResource.is_honeypot`

**New Commands:**
- ⚠️ `TerminalSystem._cmd_exploit()`

---

## 🎯 RECOMMENDED BUILD ORDER

**Week 1 (Core Mechanics):**
1. **Day 1:** Add `offensive_action_performed` signal to EventBus
2. **Day 2:** Add exploit command to TerminalSystem
3. **Day 3:** Add vulnerability_score/is_honeypot to HostResource
4. **Day 4:** Create TraceLevelManager
5. **Day 5:** Test exploit → trace loop

**Week 2 (Persistence + Polish):**
6. **Day 6:** Create HackerHistory
7. **Day 7:** Add role guards to Analyst singletons
8. **Day 8:** Integration testing
9. **Day 9:** Bug fixes + Phase 2 demo video

---

## 🧪 PHASE 2 PLAYABILITY TEST

**Demo Script (1 minute):**
1. Press F4 to load Hacker campaign
2. Open Terminal (press E at computer)
3. Type `exploit WEB-SRV-01`
4. Watch Trace rise from 0 → 15
5. Wait 10 seconds, watch Trace decay to 5
6. Type `exploit INVALID-HOST` → See error
7. Type `exploit WEB-SRV-01` again → "already compromised"

**What Works:**
- ✅ Offensive command
- ✅ Consequence system (Trace)
- ✅ Forensic logging

**What Doesn't Work Yet:**
- ❌ AI doesn't respond to Trace (Phase 3)
- ❌ No win/loss condition (Phase 4)
- ❌ No other tools (phish, ransomware cut from Phase 2)

---

## 📊 SCOPE COMPARISON: Original vs. Solo Dev

| Feature | Original Plan | Solo Dev Scope | Status |
|---------|--------------|----------------|--------|
| **Exploit Command** | Yes | Yes | ✅ Phase 2 |
| **Pivot Command** | Yes | Cut (maybe Phase 5) | ❌ |
| **Spoof Command** | Yes | Cut (maybe Phase 5) | ❌ |
| **Phish Command** | Yes | Cut (Phase 5) | ❌ |
| **Log Poisoner** | Yes | Cut (Phase 6 polish) | ❌ |
| **Trace System** | Yes | Yes | ✅ Phase 2 |
| **Hacker History** | Yes | Yes | ✅ Phase 2 |
| **Rival AI** | Phase 3 | Phase 3 | ⏭️ |
| **Honeypots** | Yes | Yes | ✅ Phase 2 |

---

## 🚨 POTENTIAL BLOCKERS

### **High Risk:**
1. **TerminalSystem complexity** - May need refactoring to support hacker commands
2. **Signal payload structure** - Must be consistent across all offensive actions
3. **HostResource validation** - Must not break existing Analyst hosts

### **Medium Risk:**
1. **Trace decay timer** - Must not interfere with existing timers
2. **Disk persistence** - HackerHistory must not cause save conflicts
3. **Role guards** - Must ensure Analyst systems don't consume hacker signals

### **Low Risk:**
1. **Honeypot logic** - Simple bool check, low complexity
2. **Vulnerability scoring** - Simple float, already have constants

---

## ✅ PHASE 2 CHECKLIST

### **Pre-Flight:**
- [ ] Read all 5 task documents
- [ ] Understand signal payload structure
- [ ] Review HostResource class

### **Core Implementation:**
- [ ] Add `offensive_action_performed` signal to EventBus
- [ ] Add exploit command to TerminalSystem
- [ ] Add vulnerability_score to HostResource
- [ ] Add is_honeypot to HostResource
- [ ] Create TraceLevelManager
- [ ] Create HackerHistory

### **Role Guards:**
- [ ] Add guard to ConsequenceEngine
- [ ] Add guard to ValidationManager
- [ ] Add guard to IntegrityManager (✅ DONE)
- [ ] Add guard to TicketManager

### **Testing:**
- [ ] Exploit works on valid host
- [ ] Exploit fails on invalid host
- [ ] Exploit fails on already-compromised host
- [ ] Exploit triggers honeypot branch
- [ ] Trace increases correctly
- [ ] Trace decays correctly
- [ ] History writes to disk
- [ ] No Analyst system consumes hacker signals

### **Documentation:**
- [ ] Update PHASE-2-SOLO.md with completion status
- [ ] Record 1-minute demo video
- [ ] Document signal payload structure

---

## 🎯 READY TO START?

**Phase 2 is well-scoped for solo dev!**

**Key Insights:**
1. Only 2 new autoloads to create (TraceLevelManager, HackerHistory)
2. Only 1 new command to implement (exploit)
3. Phase 1 already provided all constants
4. Role guards are mostly documentation

**Start with:** Task 4 (HostResource extension) - easiest, no dependencies!

Then: Task 1 (Exploit command) - core mechanic
Then: Task 2 (Trace system) - consequence
Then: Task 3 (Hacker History) - persistence
Finally: Task 5 (Role guards) - documentation

---

**Questions?**
- Signal payload structure needs to be defined early
- Trace decay timer must not conflict with other timers
- Honeypot behavior needs clear design (instant fail? or just warning?)

**Ready to build?** 🚀
