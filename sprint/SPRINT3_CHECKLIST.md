# 📋 **SPRINT 3 CHECKLIST**
**Theme:** "Build all three investigation tools and integrate them"

---

## 🎯 **ACCEPTANCE CRITERIA**

- [x] 1. Email Analyzer app functional (phishing detection)
- [x] 2. Terminal app functional (command-line risk/reward)
- [x] 3. All three tools can be required by different tickets
- [x] 4. Tools have distinct risk profiles and learning curves
- [x] 5. Cross-tool integration (find clue in email → check in SIEM)
- [x] 6. Tool-specific consequences (wrong email decision → spam flood)
- [x] 7. UI consistency across all three tools
- [x] 8. Three new ticket types requiring different tools
- [x] 9. No regression in existing SIEM/ticket systems
- [x] 10. All tools work within desktop window management system

**Completion:** 10/10 (100%) ✅

---

## 📅 **DAY-BY-DAY TASKS**

### **DAY 1: EMAIL ANALYZER FOUNDATION**
- [x] Create `EmailResource.gd` (extends Resource)
- [x] Define email properties (id, sender, subject, body, attachments, headers, etc.)
- [x] Create sample emails (3+ emails)
- [x] Create `EmailSystem.gd` autoload
- [x] Create `App_EmailAnalyzer.tscn`
- [x] Implement inbox view
- [x] Implement email detail view
- [x] Add "View Headers" inspection tool
- [x] Add "Scan Attachments" inspection tool
- [x] Add "Check Links" inspection tool
- [x] Implement decision system (Approve, Quarantine, Escalate)
- [x] Test email inspection and decision flow

### **DAY 2: TERMINAL TOOL FOUNDATION**
- [x] Create `TerminalSystem.gd` autoload
- [x] Define command structure and properties
- [x] Create `App_Terminal.tscn`
- [x] Implement terminal UI (green-on-black aesthetic)
- [x] Add TextEdit for output (readonly, monospace)
- [x] Add LineEdit for input
- [x] Implement command history
- [x] Add `help` command
- [x] Add `scan [host]` command
- [x] Add `isolate [host]` command
- [x] Add `status` command
- [x] Add `logs [host]` command
- [x] Implement risk/reward system
- [x] Test terminal command execution

### **DAY 3: TOOL INTEGRATION & TICKET EXPANSION**
- [x] Create "Spear Phishing Investigation" ticket (requires Email tool)
- [x] Create "Malware Containment" ticket (requires Terminal tool)
- [x] Create "Data Exfiltration Alert" ticket (requires SIEM + Email tools)
- [x] Implement cross-tool clues system
- [x] Email IPs → SIEM search integration
- [x] SIEM malware beacon → Terminal isolate integration
- [x] Add tool-specific UI indicators
- [x] Test integrated workflow (Email → SIEM → Terminal)
- [x] Test app switching during ticket

### **DAY 4: CONSEQUENCE EXPANSION & RISK PROFILES**
- [x] Implement Email consequences:
  - [x] Approve malicious → Spawns "Malware Outbreak" ticket
  - [x] Quarantine legitimate → Spawns "User Complaint" ticket
  - [x] Miss spear phishing → Spawns "Data Breach" ticket (delayed)
- [x] Implement Terminal consequences:
  - [x] Wrong isolate command → Spawns "Service Outage" ticket
  - [x] Failed scan → Spawns "Undetected Malware" ticket
  - [x] Terminal locked → Tool disabled for time penalty
- [x] Define tool risk profiles:
  - [x] SIEM: Low risk, information gathering
  - [x] Email: Medium risk, judgment calls
  - [x] Terminal: High risk, high reward, technical
- [x] Implement learning curve differences
- [x] Add consequence feedback messages
- [x] Test all tool-specific consequences

### **DAY 5: POLISH, BALANCE & INTEGRATION**
- [x] UI consistency pass across all apps
- [x] Same button styles across all tools
- [x] Consistent color coding (red=bad, green=good, yellow=risk)
- [x] Unified notification system
- [x] Window management system (multiple apps open)
- [x] Balance time costs (SIEM fast, Email medium, Terminal slow)
- [x] Balance risk levels proportional to time saved
- [x] Test complete workflow: Email → SIEM → Terminal
- [x] Test tool switching during ticket
- [x] Test multiple concurrent tickets with different tools
- [x] Test consequence chains across tools
- [x] Performance test with 3 apps open

---

## 📁 **FOLDER STRUCTURE CHECKLIST**

### **Autoload Files**
- [x] `autoload/EmailSystem.gd`
- [x] `autoload/TerminalSystem.gd`

### **2D App Scenes**
- [x] `scenes/2d/apps/App_EmailAnalyzer.tscn`
- [x] `scenes/2d/apps/App_Terminal.tscn`
- [x] `scenes/2d/apps/components/EmailCard.tscn` *(if used)*

### **Resources**
- [x] `resources/EmailResource.gd`
- [x] Sample email resources (3+ emails)

### **Scripts**
- [x] `scripts/2d/apps/app_EmailAnalyzer.gd`
- [x] `scripts/2d/apps/app_Terminal.gd`

---

## 🎮 **TOOL FUNCTIONALITY CHECKLIST**

### **Email Analyzer Tool**
- [x] Inbox view with email list
- [x] Email detail view
- [x] "View Headers" inspection (shows SPF/DKIM/DMARC)
- [x] "Scan Attachments" inspection (reveals file type risks)
- [x] "Check Links" inspection (shows domain reputation)
- [x] Decision buttons: Approve, Quarantine, Escalate
- [x] Inspection results display
- [x] Time cost for inspections (10-30 seconds)
- [x] Decision consequences implemented

### **Terminal Tool**
- [x] Retro green-on-black interface
- [x] Command input (LineEdit)
- [x] Output display (TextEdit, readonly, monospace)
- [x] Command history
- [x] `help` command with available commands
- [x] `scan [host]` command (30s, checks host status)
- [x] `isolate [host]` command (high risk, disconnects host)
- [x] `status` command (shows system status)
- [x] `logs [host]` command (gets recent logs, requires ticket)
- [x] Risk/reward system
- [x] Command execution feedback
- [x] Terminal lockout on critical failure

### **SIEM Tool** *(from Sprint 2)*
- [x] Log table view
- [x] Filter buttons (All, Security, High Severity)
- [x] Color-coded severity
- [x] Log attachment to tickets
- [x] Still functional from Sprint 2

---

## 🔗 **CROSS-TOOL INTEGRATION CHECKLIST**

- [x] Email contains suspicious IP → Can check in SIEM
- [x] SIEM shows malware beacon → Can use Terminal to isolate
- [x] Terminal reveals compromised account → Can check Email for phishing
- [x] IP addresses shared between tools
- [x] Evidence sharing between apps
- [x] Tool-specific UI indicators when relevant data available
- [x] Smooth app switching workflow

---

## 🎫 **NEW TICKET TYPES CHECKLIST**

- [x] **Spear Phishing Investigation** ticket
  - [x] Requires Email tool
  - [x] Uses email inspection features
  - [x] Has email-specific consequences
- [x] **Malware Containment** ticket
  - [x] Requires Terminal tool
  - [x] Uses terminal commands (scan, isolate)
  - [x] Has terminal-specific consequences
- [x] **Data Exfiltration Alert** ticket
  - [x] Requires SIEM + Email tools
  - [x] Multi-tool investigation
  - [x] Cross-tool clues

---

## ⚠️ **TOOL-SPECIFIC CONSEQUENCES CHECKLIST**

### **Email Consequences**
- [x] Approve malicious email → Spawns "Malware Outbreak" ticket
- [x] Quarantine legitimate email → Spawns "User Complaint" ticket
- [x] Miss spear phishing → Spawns "Data Breach" ticket (delayed)

### **Terminal Consequences**
- [x] Wrong isolate command → Spawns "Service Outage" ticket
- [x] Failed scan → Spawns "Undetected Malware" ticket
- [x] Terminal locked → Tool disabled for time penalty

### **SIEM Consequences** *(from Sprint 2)*
- [x] Missed log check → Follow-up tickets
- [x] Incomplete evidence → Consequences

---

## 🎨 **UI CONSISTENCY CHECKLIST**

- [x] Same button styles across all apps
- [x] Consistent color coding:
  - [x] Red = bad/danger
  - [x] Green = good/safe
  - [x] Yellow = risk/warning
- [x] Unified notification system
- [x] Consistent window frame system
- [x] Similar layout patterns
- [x] Consistent typography (monospace where appropriate)

---

## 🎮 **TOOL RISK PROFILES**

| Tool | Risk Level | Time Cost | Learning Curve | Status |
|------|-----------|-----------|----------------|--------|
| **SIEM** | Low | Fast | Shallow | ✅ Complete |
| **Email** | Medium | Medium | Moderate | ✅ Complete |
| **Terminal** | High | Slow | Steep | ✅ Complete |

---

## ✅ **FINAL TEST CHECKLIST**

- [x] Email: Can inspect, judge, see consequences
- [x] Terminal: Can enter commands, see risk/reward
- [x] SIEM: Still works from Sprint 2
- [x] Tickets can require any tool or combination
- [x] Cross-tool clues work (email IP → SIEM search)
- [x] Each tool has distinct failure consequences
- [x] All apps can be open simultaneously
- [x] UI is consistent across all tools
- [x] Performance with 3 apps open is acceptable
- [x] No regression in core ticket loop
- [x] Window management system working
- [x] Tool switching is smooth

---

## 🚨 **STRETCH GOALS** *(Not Implemented)*

- [ ] Email attachments can be "detonated in sandbox"
- [ ] Terminal command auto-complete
- [ ] App-specific keyboard shortcuts
- [ ] Email "report phishing" button
- [ ] Terminal command scripts (batch operations)

---

## 📊 **SPRINT 3 STATUS**

**Overall Progress: 100% Complete** ✅

**Completed:**
- ✅ Email Analyzer Tool - Full inspection and decision system
- ✅ Terminal Tool - Command system with risk/reward
- ✅ EmailSystem & TerminalSystem autoloads
- ✅ Cross-tool integration - Email IPs → SIEM search
- ✅ Tool-specific consequences - Email/terminal mistakes spawn tickets
- ✅ Three new ticket types - Spear Phish, Malware Containment, Data Exfiltration
- ✅ All tickets loading correctly from library
- ✅ UI consistency across all three tools
- ✅ Window management system - multiple apps working

**Sprint 3 Deliverable:** ✅ Complete toolset implemented. All three tools functional and integrated. Ready for Sprint 4 (Polish, NPCs & Vertical Slice).

---

*Last Updated: Sprint 3 Complete - All tools implemented and integrated*

