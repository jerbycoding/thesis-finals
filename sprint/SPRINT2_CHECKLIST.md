# 📋 **SPRINT 2 CHECKLIST**
**Theme:** "Prove the security incident gameplay loop works"

---

## 🎯 **ACCEPTANCE CRITERIA**

- [x] 1. Ticket Queue app shows incoming security incidents
- [x] 2. Ticket detail view with description, timer, and steps
- [x] 3. SIEM app shows realistic(ish) security logs
- [x] 4. Player can connect logs to tickets as "evidence"
- [x] 5. Three completion states: Compliant, Efficient, Emergency
- [x] 6. Timer system with visual urgency indicators
- [x] 7. Basic consequence logging (choice → delayed effect)
- [x] 8. One complete "phishing investigation" ticket arc
- [x] 9. All systems work within the 2D desktop from Sprint 1
- [x] 10. No regression in 3D→2D transition system

**Completion:** 10/10 (100%) ✅

---

## 📅 **DAY-BY-DAY TASKS**

### **DAY 1: TICKET SYSTEM FOUNDATION**
- [x] Create `TicketResource.gd` (extends Resource)
- [x] Define ticket properties (id, title, description, severity, category, steps, etc.)
- [x] Create sample tickets (`.gd` format)
- [x] Create `TicketManager.gd` autoload
- [x] Implement `add_ticket()` method
- [x] Implement `complete_ticket()` method
- [x] Add signals: `ticket_added`, `ticket_completed`, `ticket_expired`
- [x] Create `App_TicketQueue.tscn`
- [x] Create `TicketCard.tscn` component
- [x] Implement ticket list display
- [x] Test ticket spawning and display

### **DAY 2: SIEM TOOL & LOG SYSTEM**
- [x] Create `LogResource.gd` (extends Resource)
- [x] Define log properties (id, timestamp, source, category, message, severity)
- [x] Create sample logs (7+ logs)
- [x] Create `LogSystem.gd` autoload
- [x] Create `App_SIEMViewer.tscn`
- [x] Implement log table view
- [x] Add color-coding by severity
- [x] Add filter buttons: "All", "Security Only", "High Severity"
- [x] Implement log-ticket connection system
- [x] Add "Attach to Ticket" functionality
- [x] Test log attachment to tickets

### **DAY 3: COMPLETION SYSTEM & CONSEQUENCES**
- [x] Modify `TicketManager.complete_ticket()` to accept completion type
- [x] Implement three completion types: `compliant`, `efficient`, `emergency`
- [x] Add time bonuses/penalties per completion type
- [x] Create `ConsequenceEngine.gd` autoload
- [x] Implement `log_choice()` method
- [x] Implement `spawn_followup_ticket()` method
- [x] Add hidden risk detection system
- [x] Create `NotificationToast.tscn`
- [x] Create `NotificationManager.gd`
- [x] Implement notification system
- [x] Test consequence triggering

### **DAY 4: FIRST COMPLETE TICKET ARC**
- [x] Create curated phishing ticket (`ticket_phishing_01.gd`)
- [x] Define ticket steps (3 steps)
- [x] Add hidden risk configuration
- [x] Create 3 related logs
- [x] Set required log IDs (2/2 for compliant)
- [x] Configure consequence chain
- [x] Test compliant completion path
- [x] Test efficient completion path
- [x] Test emergency completion path
- [x] Verify consequences trigger correctly

### **DAY 5: POLISH & INTEGRATION**
- [x] Add timer urgency colors (green → yellow → red)
- [x] Add real-time countdown updates
- [x] Create `CompletionModal.tscn`
- [x] Implement completion modal with 3 buttons
- [x] Fix window management system
- [x] Fix ticket visibility issues
- [x] Test complete loop: 3D → Desktop → Ticket → SIEM → Complete → Consequence
- [x] Test edge cases: Multiple tickets, expired tickets
- [x] Performance test with all apps open
- [ ] Add sound effects *(deferred to Sprint 3)*
- [ ] Create `TimeManager.gd` *(optional - deferred)*

---

## 📁 **FOLDER STRUCTURE CHECKLIST**

### **Autoload Files**
- [x] `autoload/TicketManager.gd`
- [x] `autoload/ConsequenceEngine.gd`
- [x] `autoload/LogSystem.gd`
- [ ] `autoload/TimeManager.gd` *(optional - deferred)*

### **2D App Scenes**
- [x] `scenes/2d/apps/App_TicketQueue.tscn`
- [x] `scenes/2d/apps/App_SIEMViewer.tscn`
- [x] `scenes/2d/apps/components/TicketCard.tscn`
- [x] `scenes/2d/apps/components/CompletionModal.tscn`
- [x] `scenes/2d/apps/components/WindowFrame.tscn`

### **UI Scenes**
- [x] `scenes/ui/NotificationToast.tscn`

### **Resources**
- [x] `resources/tickets/TicketResource.gd`
- [x] `resources/tickets/ticket_phishing_01.gd`
- [x] `resources/tickets/ticket_spear_phish.gd` *(Sprint 3)*
- [x] `resources/tickets/ticket_malware_containment.gd` *(Sprint 3)*
- [x] `resources/tickets/ticket_data_exfiltration.gd` *(Sprint 3)*
- [x] `resources/LogResource.gd` *(if separate)*

### **Scripts**
- [x] `scripts/2d/apps/app_TicketQueue.gd`
- [x] `scripts/2d/apps/app_SIEMViewer.gd`
- [x] `scripts/2d/apps/components/ticket_card.gd`
- [x] `scripts/2d/NotificationManager.gd`

---

## 🎮 **GAMEPLAY LOOP CHECKLIST**

### **Phishing Investigation Arc**
- [x] Player sits at computer (3D → 2D transition)
- [x] Ticket Queue shows: "Phishing Campaign - MEDIUM"
- [x] Open ticket → Description displays
- [x] Steps checklist visible (2 logs required)
- [x] Open SIEM app → Filter to "Security" logs
- [x] Find 2 logs about "phishing attempt" and "email blocked"
- [x] Attach both logs to ticket
- [x] Evidence counter shows "Evidence: 2/2"
- [x] Click "Mark Compliant" (takes 2 minutes in-game)
- [x] Notification: "Ticket resolved - Full investigation"
- [x] 60 seconds later (if Efficient/Emergency): New ticket spawns
- [x] Consequence notification appears

---

## 🎨 **UI COMPONENTS CHECKLIST**

### **Ticket Card**
- [x] Severity icon/color stripe
- [x] Title display
- [x] Severity label (MEDIUM, HIGH, etc.)
- [x] Time remaining display
- [x] Status indicator
- [x] Evidence counter (X/Y)

### **SIEM Log Entry**
- [x] Timestamp display
- [x] Source label (FIREWALL, IDS, etc.)
- [x] Category badge
- [x] Severity icon (⚠️)
- [x] Message text (truncated)
- [x] "Attach to Ticket" button

### **Completion Modal**
- [x] Three buttons:
  - [x] **Compliant**: Green, "✓ All checks completed"
  - [x] **Efficient**: Yellow, "⚡ Time saved, risks accepted"
  - [x] **Emergency**: Red, "🚨 Immediate resolution required"
- [x] Modal displays correctly
- [x] All buttons visible and functional

### **Notification Toast**
- [x] Ticket completion notifications
- [x] Consequence alerts
- [x] Proper stacking and animations
- [x] Auto-dismiss after duration

---

## 🔧 **SYSTEMS CHECKLIST**

### **Ticket System**
- [x] Ticket resource class created
- [x] TicketManager autoload functional
- [x] Active tickets tracking
- [x] Completed tickets tracking
- [x] Ticket library system
- [x] Ticket spawning from library
- [x] Ticket completion with type
- [x] Evidence attachment system

### **Log System**
- [x] Log resource class created
- [x] LogSystem autoload functional
- [x] Sample logs loaded
- [x] Log filtering (All, Security, High Severity)
- [x] Log-ticket connection
- [x] Evidence tracking

### **Consequence System**
- [x] ConsequenceEngine autoload created
- [x] Choice logging implemented
- [x] Delayed consequence spawning
- [x] Hidden risk detection
- [x] Follow-up ticket creation
- [x] Consequence signals

### **Notification System**
- [x] NotificationManager autoload
- [x] Toast notification UI
- [x] Visual feedback for all events
- [x] Proper stacking
- [x] Animation system

---

## ✅ **FINAL TEST CHECKLIST**

- [x] Ticket appears in queue when spawned
- [x] Click ticket → shows detail modal
- [x] Timer counts down with color changes
- [x] Real-time countdown updates
- [x] SIEM shows logs, can filter
- [x] Log can be attached to ticket
- [x] Evidence counter updates
- [x] All three completion types work
- [x] Efficient/Emergency spawn consequences
- [x] Notification appears for consequences
- [x] No UI overlap/visual bugs
- [x] Multiple apps can be open simultaneously
- [x] Window management system working
- [x] No regression in 3D→2D transition

---

## 🐛 **KNOWN ISSUES / DEFERRED**

### **Optional Enhancements (Not Blocking)**
- [ ] Time Manager (pause in 3D mode, global shift timer)
- [ ] Pulse animation on tickets when time < 60s
- [ ] Enhanced button hover effects
- [ ] Tooltips on completion buttons
- [ ] Sound effects *(deferred to Sprint 3)*
- [ ] Additional ticket types (beyond phishing)
- [ ] Ticket detail modal view

---

## 📊 **SPRINT 2 STATUS**

**Overall Progress: 100% Complete** ✅

**Completed:**
- ✅ Ticket Resource System
- ✅ Ticket Manager Autoload
- ✅ Ticket Queue App - Basic Functionality
- ✅ Window Management System
- ✅ Desktop Integration
- ✅ SIEM Tool
- ✅ Completion System
- ✅ Consequence Engine
- ✅ Notification System
- ✅ Complete Phishing Ticket Arc

**Sprint 2 Deliverable:** ✅ Core ticket loop proven and functional. All systems working together.

---

*Last Updated: Sprint 2 Complete - Core loop functional*

