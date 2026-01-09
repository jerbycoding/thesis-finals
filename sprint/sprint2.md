# 📅 **SPRINT 2: WEEK 2 - CORE TICKET LOOP**
**Theme:** "Prove the security incident gameplay loop works"

---

## 🎯 **SPRINT GOAL**
**Player can:** Receive security incidents → Investigate using 2D tools → Make risk/reward decisions → See immediate consequences

**Builds on Sprint 1:** All gameplay happens within the 2D desktop environment.

---

## 📊 **ACCEPTANCE CRITERIA**
1. ✅ Ticket Queue app shows incoming security incidents
2. ✅ Ticket detail view with description, timer, and steps
3. ✅ SIEM app shows realistic(ish) security logs
4. ✅ Player can connect logs to tickets as "evidence"
5. ✅ Three completion states: Compliant, Efficient, Emergency
6. ✅ Timer system with visual urgency indicators
7. ✅ Basic consequence logging (choice → delayed effect)
8. ✅ One complete "phishing investigation" ticket arc
9. ✅ All systems work within the 2D desktop from Sprint 1
10. ✅ No regression in 3D→2D transition system

---

## 📁 **FOLDER STRUCTURE ADDITIONS**
```
/incident_response_soc/
├── /autoload/ (ADDITIONS)
│   ├── TicketManager.gd
│   ├── ConsequenceEngine.gd
│   └── TimeManager.gd
├── /scenes/
│   ├── /2d/apps/ (NEW APPS)
│   │   ├── App_TicketQueue.tscn     # Main ticket dashboard
│   │   ├── App_SIEMViewer.tscn      # Log analysis tool
│   │   └── components/ (NEW)
│   │       ├── TicketCard.tscn
│   │       ├── LogEntry.tscn
│   │       └── TimerDisplay.tscn
│   └── /ui/ (ADDITIONS)
│       ├── NotificationToast.tscn
│       └── CompletionModal.tscn
├── /resources/ (NEW FOLDER)
│   ├── /tickets/
│   │   ├── ticket_phishing_01.tres
│   │   ├── ticket_malware_01.tres
│   │   └── ticket_unauth_01.tres
│   ├── /logs/
│   │   ├── log_auth_failure.tres
│   │   ├── log_phishing_attempt.tres
│   │   └── log_malware_detected.tres
│   └── TicketResource.gd
└── /scripts/ (ADDITIONS)
    └── /systems/
        ├── TicketSystem.gd
        └── LogSystem.gd
```

---

## 📝 **DAY-BY-DAY TASKS**

### **DAY 1: TICKET SYSTEM FOUNDATION**
**Goal:** Create the ticket resource system and basic queue UI

**Tasks:**
1. **Ticket Resource Class**
   - Create `TicketResource.gd` (extends Resource)
   - Properties:
     ```gdscript
     @export var ticket_id: String
     @export var title: String
     @export_multiline var description: String
     @export var severity: String # "Low", "Medium", "High", "Critical"
     @export var category: String # "Phishing", "Malware", "Unauthorized Access"
     @export var steps: Array[String] = [] # Max 3 steps
     @export var required_tool: String # "siem", "email", "terminal", "none"
     @export var base_time: float = 180.0 # seconds
     @export var hidden_risks: Array[String] = []
     ```
   - Create 3 sample tickets as `.tres` files

2. **Ticket Manager Autoload**
   - `TicketManager.gd` manages active/pending tickets
   - Methods: `add_ticket(ticket_resource)`, `complete_ticket(ticket_id, completion_type)`
   - Signals: `ticket_added`, `ticket_completed`, `ticket_expired`

3. **Ticket Queue App**
   - Replace placeholder Ticket app from Sprint 1
   - `App_TicketQueue.tscn`: Shows list of active tickets
   - Each ticket shows: severity icon, title, time remaining
   - Click ticket → opens detail modal

4. **Ticket Detail Modal**
   - Shows full description, steps checklist, timer
   - Buttons: "Mark Compliant", "Mark Efficient", "Emergency Resolve"
   - Timer counts down visibly

**Deliverable:** Tickets appear in queue, can be viewed, timer counts down.

---

### **DAY 2: SIEM TOOL & LOG SYSTEM**
**Goal:** Functional log viewer that connects to tickets

**Tasks:**
1. **Log Resource Class**
   - Create `LogResource.gd` (extends Resource)
   - Properties:
     ```gdscript
     @export var log_id: String
     @export var timestamp: String # "HH:MM:SS"
     @export var source: String # "Firewall", "IDS", "Authentication"
     @export var category: String # "Security", "System", "Network"
     @export_multiline var message: String # Max 60 chars
     @export var severity: int # 1-5
     @export var related_ticket: String # Optional ticket_id
     ```
   - Create 8 sample logs as `.tres` files

2. **SIEM Viewer App**
   - Replace placeholder SIEM app from Sprint 1
   - `App_SIEMViewer.tscn`: Table view of logs
   - Columns: Time, Source, Message (truncated)
   - Color-coded by severity (green→yellow→red)
   - Filter buttons: "All", "Security Only", "High Severity"

3. **Log-Ticket Connection**
   - Tickets can reference required log IDs
   - SIEM app shows "Attach to Ticket" button on selected log
   - Ticket detail shows "Evidence attached: X/Y"

4. **Log Manager**
   - `LogSystem.gd` manages log generation/retrieval
   - Methods: `get_logs_for_ticket(ticket_id)`, `mark_log_reviewed(log_id)`

**Deliverable:** SIEM shows logs, logs can be attached to tickets.

---

### **DAY 3: COMPLETION SYSTEM & CONSEQUENCES**
**Goal:** Three completion paths with different outcomes

**Tasks:**
1. **Completion State System**
   - Modify `TicketManager.complete_ticket()` to accept completion type
   - Three types: `compliant`, `efficient`, `emergency`
   - Each has different time bonuses/penalties
   - Visual feedback for each type

2. **Consequence Engine Foundation**
   - Create `ConsequenceEngine.gd` autoload
   - Tracks player choices in `choice_log` array
   - Methods: `log_choice(ticket_id, choice_type, details)`
   - Basic consequence: `spawn_followup_ticket(ticket_id, delay_seconds)`

3. **Hidden Risk Detection**
   - Each ticket can have hidden risks (e.g., "missed_log_check")
   - System checks if player triggered hidden risk
   - If yes → schedules consequence

4. **Notification System**
   - `NotificationToast.tscn`: Small popup at top-right
   - Shows: "Ticket completed - Efficient resolution"
   - Shows: "Consequence queued - Check logs missed"

**Deliverable:** Different completion types trigger different consequences.

---

### **DAY 4: FIRST COMPLETE TICKET ARC**
**Goal:** One playable phishing investigation from start to finish

**Tasks:**
1. **Curated Phishing Ticket**
   - Create `ticket_phishing_investigation.tres`
   - Steps:
     1. "Check SIEM for phishing campaign alerts"
     2. "Review email headers for spoofing indicators"
     3. "Determine if user clicked malicious link"
   - Hidden risk: "User already clicked link → malware installed"
   - Required tool: "siem" (logs)

2. **Corresponding Logs**
   - 3 logs related to this ticket
   - 2 logs required for "compliant" completion
   - 1 misleading log (red herring)

3. **Consequence Chain**
   - Compliant completion: No consequence
   - Efficient (miss 1 log): Spawns "Malware Cleanup" ticket in 60s
   - Emergency: Spawns "Data Breach Report" immediately

4. **Integrated Testing**
   - Test all three completion paths
   - Verify consequences trigger correctly
   - Ensure UI feedback is clear

**Deliverable:** One complete ticket with meaningful choices.

---

### **DAY 5: POLISH & INTEGRATION**
**Goal:** Bug-free, satisfying gameplay loop

**Tasks:**
1. **UI Polish**
   - Add timer urgency colors (green → yellow → red)
   - Pulse animation when ticket < 60 seconds
   - Sound effects: `ticket_complete.wav`, `log_attach.wav`
   - Tooltips explaining completion types

2. **Time Management**
   - Create `TimeManager.gd` autoload
   - Pauses ticket timers when in 3D mode
   - Global "shift timer" (15 minutes for vertical slice)
   - Speed controls (1x, 2x, paused) for testing

3. **Desktop Integration**
   - Replace all placeholder apps with real ones
   - Ensure apps can be opened simultaneously
   - Add "Active Ticket" widget to desktop wallpaper

4. **Comprehensive Testing**
   - Test complete loop: 3D → Desktop → Ticket → SIEM → Complete → Consequence
   - Test edge cases: Multiple tickets, expired tickets
   - Performance test with all apps open

5. **Documentation & Handoff**
   - Update API documentation for Ticket/Log systems
   - Create `TICKET_CREATION_GUIDE.md` template
   - Note any limitations for Sprint 3

**Final Test Checklist:**
- [ ] Ticket appears in queue when spawned
- [ ] Click ticket → shows detail modal
- [ ] Timer counts down with color changes
- [ ] SIEM shows logs, can filter
- [ ] Log can be attached to ticket
- [ ] All three completion types work
- [ ] Efficient/Emergency spawn consequences
- [ ] Notification appears for consequences
- [ ] No UI overlap/visual bugs
- [ ] All sounds play correctly

---

## 🎮 **GAMEPLAY LOOP (Phishing Example)**

```
1. Player sits at computer (3D → 2D transition)
2. Ticket Queue shows: "Phishing Campaign - MEDIUM"
3. Open ticket → Description: "Users reporting phishing emails..."
4. Steps: "Check SIEM for related logs" (2 logs required)
5. Open SIEM app → Filter to "Security" logs
6. Find 2 logs about "phishing attempt" and "email blocked"
7. Attach both logs to ticket
8. Click "Mark Compliant" (takes 2 minutes in-game)
9. Notification: "Ticket resolved - Full investigation"
10. 60 seconds later (if Efficient/Emergency): New ticket spawns
```

---

## 🎨 **UI SPECIFICATIONS**

### **Ticket Card:**
```
[ICON] [SEVERITY COLOR STRIPE]
Title: Phishing Campaign Alert
Severity: MEDIUM (yellow)
Time: 02:45 remaining
Status: In Progress
```

### **SIEM Log Entry:**
```
[14:32:05] [FIREWALL] [SECURITY] [⚠️]
Blocked connection to malicious IP 192.168.1.100
[ATTACH TO TICKET] button
```

### **Completion Modal Buttons:**
- **Compliant**: Green, "✓ All checks completed"
- **Efficient**: Yellow, "⚡ Time saved, risks accepted"
- **Emergency**: Red, "🚨 Immediate resolution required"

---

## ⚠️ **KNOWN RISKS & MITIGATION**

1. **Too many tickets overwhelming**
   - Limit to 3 active tickets max
   - Auto-pause lower priority tickets

2. **Log analysis feels like reading**
   - Keep logs short (< 60 chars)
   - Color-code key information
   - Use icons for quick scanning

3. **Consequences feel unfair**
   - Always show what triggered consequence
   - "Last action: Skipped log check → Malware installed"

4. **Time pressure causes anxiety**
   - Add "pause" button for new players
   - First ticket has extra time

---

## 📦 **DELIVERABLES FOR WEEK 2**

1. **Ticket Resource System** with 3 sample tickets
2. **SIEM Viewer App** with filterable logs
3. **Completion System** with 3 paths
4. **Consequence Engine** that logs choices
5. **One complete ticket arc** (phishing investigation)
6. **Integrated notification system**
7. **Updated desktop** with functional apps

---

## 🔄 **DEPENDENCIES FOR SPRINT 3**
*What Sprint 3 will need:*

1. ✅ Working TicketManager API
2. ✅ ConsequenceEngine with scheduling
3. ✅ App framework for adding new tools
4. ✅ UI component library (cards, modals, notifications)
5. ✅ One proven gameplay loop

---

## 🚨 **STRETCH GOALS (If Time Permits)**
- [ ] Multiple ticket categories with different UI colors
- [ ] "Starred" tickets (player can flag important ones)
- [ ] Ticket history log
- [ ] Export ticket as "report" (text file)
- [ ] Sound for ticket expiration

---

## 📝 **DAILY CHECK-IN QUESTIONS**

**End of each day, ask:**
1. Can I complete the phishing ticket arc with all three choices?
2. Are consequences clearly traceable to player actions?
3. Is the UI intuitive without tutorial text?
4. Am I maintaining 60 FPS with all apps open?

---

## 🏁 **SPRINT COMPLETE WHEN...**

You can record a 2-minute video showing:
1. Desktop opens, phishing ticket appears
2. Player opens SIEM, attaches 2 logs
3. Player chooses "Efficient" completion
4. Notification: "Consequence queued"
5. 60 seconds later: New malware ticket spawns
6. Player can articulate why consequence happened

**If the consequence feels earned (not random), Sprint 2 is complete.**

---

## 🎯 **READY FOR SPRINT 3 WHEN...**

The core ticket loop is **engaging, meaningful, and extensible**. Week 3 will add the Email and Terminal tools to create a complete toolkit.

---

**Remember:** You're building the CORE LOOP. If this isn't fun/engaging with just one tool (SIEM), adding more tools won't fix it. Nail the feel first.

*"First incident received. SIEM logs populated. Decision matrix loaded. Remember: Every choice propagates. Every shortcut compounds. Your efficiency is being measured. Begin investigation."*






## 📝 **DAY-BY-DAY TASKS (UPDATED)**

### **DAY 1-2: COMPLETED**
- ✅ TicketResource system (.gd format)
- ✅ TicketManager autoload
- ✅ App_TicketQueue basic UI
- ✅ TicketCard component
- ✅ Desktop integration (click opens app)

### **DAY 3: WINDOW VISIBILITY FIX (IMMEDIATE)**
**Problem:** App windows open but content not visible due to layout/sizing issues.

**Solutions to test:**
1. **Manual sizing fix** (Quick):
   - Set explicit sizes on `App_TicketQueue` (500x400)
   - Set background opacity to 0.95
   - Position at (200, 100)

2. **If fails → Minimal WindowFrame** (Fallback):
   - Create `SimpleWindow.tscn` with just background and padding
   - Wrap app content in SimpleWindow
   - No titlebar/drag to save time

### **DAY 4: CORE LOOP COMPLETION**
**Priority:** Get ONE ticket visible and selectable in queue.
- Test ticket spawns and appears in list
- Click ticket → opens detail modal (placeholder OK)
- SIEM app loads logs (placeholder OK)
- Complete ticket → triggers consequence notification

### **DAY 5: POLISH WHAT WORKS**
- Fix any visibility issues found
- Add timer colors
- Add sound effects
- Document limitations for Sprint 3

### **SPRINT 3 PLANNING NOTES**
**Window Management System** deferred to Sprint 3 due to:
- Core gameplay loop more critical than window UI
- Can test loop with fixed-size visible windows
- Full window system (drag, close, stack) adds complexity

**Sprint 2 Success Criteria Updated:**
- [x] Ticket appears in queue when spawned
- [ ] **Ticket visible in UI** ← CURRENT BLOCKER
- [ ] Timer counts down
- [ ] SIEM shows logs (placeholder)
- [ ] Completion types work
- [ ] Consequences trigger