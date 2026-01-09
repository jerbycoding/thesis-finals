# 📅 **SPRINT 3: WEEK 3 - COMPLETE TOOLSET**
**Theme:** "Build all three investigation tools and integrate them"

---

## 🎯 **SPRINT GOAL**
**Player has:** Three distinct investigation tools (SIEM, Email, Terminal) that create different gameplay experiences and risk profiles.

**Builds on Sprint 2:** Adds two new tools that integrate with the ticket system, creating variety in investigations.

---

## 📊 **ACCEPTANCE CRITERIA**
1. ✅ Email Analyzer app functional (phishing detection)
2. ✅ Terminal app functional (command-line risk/reward)
3. ✅ All three tools can be required by different tickets
4. ✅ Tools have distinct risk profiles and learning curves
5. ✅ Cross-tool integration (find clue in email → check in SIEM)
6. ✅ Tool-specific consequences (wrong email decision → spam flood)
7. ✅ UI consistency across all three tools
8. ✅ Three new ticket types requiring different tools
9. ✅ No regression in existing SIEM/ticket systems
10. ✅ All tools work within desktop window management system

---

## 📁 **FOLDER STRUCTURE ADDITIONS**
```
/incident_response_soc/
├── /autoload/ (ADDITIONS)
│   └── ToolManager.gd
├── /scenes/2d/apps/ (NEW APPS)
│   ├── App_EmailAnalyzer.tscn     # Phishing detection
│   ├── App_Terminal.tscn          # Command-line interface
│   └── components/ (ADDITIONS)
│       ├── EmailCard.tscn
│       ├── TerminalLine.tscn
│       └── AttachmentViewer.tscn
├── /resources/ (ADDITIONS)
│   ├── /emails/
│   │   ├── email_phishing_01.tres
│   │   ├── email_legit_urgent.tres
│   │   └── email_spear_phish.tres
│   ├── /commands/
│   │   ├── command_help.tres
│   │   ├── command_scan.tres
│   │   └── command_isolate.tres
│   └── EmailResource.gd
└── /scripts/systems/ (ADDITIONS)
    ├── EmailSystem.gd
    └── TerminalSystem.gd
```

---

## 📝 **DAY-BY-DAY TASKS**

### **DAY 1: EMAIL ANALYZER FOUNDATION**
**Goal:** Functional email client for phishing detection

**Tasks:**
1. **Email Resource Class**
   - Create `EmailResource.gd` (extends Resource)
   - Properties:
     ```gdscript
     @export var email_id: String
     @export var sender: String # "CEO", "IT Dept", "External"
     @export var subject: String
     @export_multiline var body: String
     @export var attachments: Array[String] = [] # ".exe", ".pdf", etc.
     @export var headers: Dictionary # SPF, DKIM, DMARC
     @export var is_malicious: bool
     @export var is_urgent: bool
     @export var clues: Array[String] = [] # "suspicious_link", "bad_attachment"
     @export var related_ticket: String
     ```
   - Create 5 sample emails as `.tres` files

2. **Email Analyzer App**
   - `App_EmailAnalyzer.tscn`: Inbox view + detail view
   - Inbox shows: Sender, Subject, Urgency icon
   - Click email → shows full view with inspection tools

3. **Inspection Tools**
   - "View Headers" button: Shows SPF/DKIM/DMARC results
   - "Scan Attachments" button: Reveals file type risks
   - "Check Links" button: Shows domain reputation
   - Each inspection consumes time (10-30 seconds)

4. **Decision System**
   - Three buttons: "Approve (Deliver)", "Quarantine", "Escalate"
   - Each decision has different consequences
   - Feedback: "Email quarantined - Potential phishing detected"

**Deliverable:** Email app shows inbox, emails can be inspected and judged.

---

### **DAY 2: TERMINAL TOOL FOUNDATION**
**Goal:** Functional command-line interface for advanced operations

**Tasks:**
1. **Terminal System**
   - Create `TerminalSystem.gd` autoload
   - Manages available commands and their effects
   - Command structure:
     ```gdscript
     {
       "command": "scan",
       "description": "Scan host for malware",
       "syntax": "scan [hostname]",
       "risk_level": 2, # 1-5
       "time_cost": 45.0,
       "effect_function": "scan_host"
     }
     ```

2. **Terminal App**
   - `App_Terminal.tscn`: Retro green-on-black aesthetic
   - Components:
     - `TextEdit` for output (readonly, monospace)
     - `LineEdit` for input (with autocomplete hint)
     - Scrollable command history

3. **Core Commands (5 total)**
   - `help` - Shows available commands
   - `scan [host]` - Checks host status (30s)
   - `isolate [host]` - Disconnects host from network (high risk)
   - `status` - Shows system status
   - `logs [host]` - Gets recent logs from host (requires ticket)

4. **Risk/Reward System**
   - Successful command: +time to ticket, useful info
   - Failed command: Spawns "Security Alert" ticket
   - Critical failure: Terminal disabled for 60s

**Deliverable:** Terminal accepts commands, gives responses, has risk system.

---

### **DAY 3: TOOL INTEGRATION & TICKET EXPANSION**
**Goal:** Tickets that require specific tools and cross-tool investigation

**Tasks:**
1. **New Ticket Types**
   - Create 3 new tickets requiring different tools:
     1. **"Spear Phishing Investigation"** → Requires Email tool
     2. **"Malware Containment"** → Requires Terminal tool  
     3. **"Data Exfiltration Alert"** → Requires SIEM + Email tools

2. **Cross-Tool Clues**
   - Email contains suspicious IP → Check in SIEM
   - SIEM shows malware beacon → Use Terminal to isolate
   - Terminal reveals compromised account → Check Email for phishing

3. **Tool-Specific UI Indicators**
   - Ticket shows required tool icon
   - Apps highlight when they have relevant data
   - "Evidence sharing" between apps

4. **Integrated Workflow Test**
   - Test: Email ticket → Find IP in email → Check SIEM for that IP → Find malware → Use Terminal to isolate
   - Ensure smooth app switching

**Deliverable:** Tickets can require specific tools, clues cross-reference between tools.

---

### **DAY 4: CONSEQUENCE EXPANSION & RISK PROFILES**
**Goal:** Each tool has distinct failure modes and consequences

**Tasks:**
1. **Email Consequences**
   - Approve malicious: Spawns "Malware Outbreak" ticket
   - Quarantine legitimate: Spawns "User Complaint" ticket  
   - Miss spear phishing: Spawns "Data Breach" ticket (delayed)

2. **Terminal Consequences**
   - Wrong isolate command: Spawns "Service Outage" ticket
   - Failed scan: Spawns "Undetected Malware" ticket
   - Terminal locked: Tool disabled for time penalty

3. **Tool Risk Profiles**
   - **SIEM**: Low risk, information gathering
   - **Email**: Medium risk, judgment calls
   - **Terminal**: High risk, high reward, technical

4. **Learning Curve Implementation**
   - SIEM: Simple filtering/attaching
   - Email: Multiple inspection steps
   - Terminal: Syntax memory, parameter risks

5. **Consequence Feedback**
   - Clear message: "Quarantined legitimate email → User cannot access urgent document"
   - Visual: Different consequence icons per tool
   - Audio: Distinct sounds for tool failures

**Deliverable:** Each tool has meaningful, distinct consequences for mistakes.

---

### **DAY 5: POLISH, BALANCE & INTEGRATION**
**Goal:** All three tools feel cohesive, balanced, and integrated

**Tasks:**
1. **UI Consistency Pass**
   - Same button styles across all apps
   - Consistent color coding (red=bad, green=good, yellow=risk)
   - Unified notification system
   - Tooltip system for all interactive elements

2. **Window Management**
   - Apps can be minimized/maximized/closed
   - Multiple apps open simultaneously
   - Alt+Tab switching between apps
   - App positions saved per computer station

3. **Balance Tuning**
   - Time costs: SIEM (fast), Email (medium), Terminal (slow)
   - Risk levels proportional to time saved
   - Consequence severity matches risk taken
   - Test all tool combinations

4. **Desktop Environment Polish**
   - App icons reflect current state (notification badges)
   - Active ticket shows required tools
   - Quick-launch toolbar for frequently used apps
   - Desktop notifications for important events

5. **Comprehensive Integration Test**
   - Test complete workflow: Email → SIEM → Terminal
   - Test tool switching during ticket
   - Test multiple concurrent tickets with different tools
   - Test consequence chains across tools

**Final Test Checklist:**
- [ ] Email: Can inspect, judge, see consequences
- [ ] Terminal: Can enter commands, see risk/reward
- [ ] SIEM: Still works from Sprint 2
- [ ] Tickets can require any tool or combination
- [ ] Cross-tool clues work (email IP → SIEM search)
- [ ] Each tool has distinct failure consequences
- [ ] All apps can be open simultaneously
- [ ] UI is consistent across all tools
- [ ] Performance with 3 apps open is acceptable
- [ ] No regression in core ticket loop

---

## 🎮 **TOOL COMPARISON**

| Tool | Primary Use | Risk Level | Time Cost | Learning Curve | Consequence Example |
|------|-------------|------------|-----------|----------------|---------------------|
| **SIEM** | Log analysis | Low | Fast | Shallow | Missed alert → delayed detection |
| **Email** | Phishing detection | Medium | Medium | Moderate | Wrong judgment → malware infection |
| **Terminal** | Active response | High | Slow | Steep | Wrong command → system outage |

---

## 🎨 **UI PATTERNS BY TOOL**

### **SIEM (Information Density)**
- Table view with filters
- Color-coded severity
- Quick attach/detach
- **Feels like**: Data analyst tool

### **Email (Decision Focus)**
- Card-based inbox
- Step-by-step inspection
- Clear approve/deny choices
- **Feels like**: Judgment call under pressure

### **Terminal (Precision Required)**
- Retro monospace interface
- Exact syntax required
- Command history
- **Feels like**: Hacker movie fantasy

---

## ⚠️ **KNOWN RISKS & MITIGATION**

1. **Terminal feels too technical**
   - Include `help` command with clear examples
   - Auto-complete for commands
   - Pre-populate commands in ticket descriptions

2. **Email judgment feels arbitrary**
   - Clear clues in headers/attachments
   - Consistent rules (external + .exe = always malicious)
   - Tutorial email that teaches the rules

3. **Tool switching feels clunky**
   - Alt+Tab quick switching
   - "Pin" important apps
   - Shared clipboard for clues (IP addresses)

4. **Overwhelming with three tools**
   - Introduce tools gradually (one per ticket in arc)
   - First uses are heavily guided
   - Default to SIEM for simple tickets

---

## 📦 **DELIVERABLES FOR WEEK 3**

1. **Email Analyzer App** with phishing detection
2. **Terminal App** with command-line interface
3. **Tool Integration System** for cross-app clues
4. **Tool-Specific Consequences** and risk profiles
5. **Three new ticket types** requiring different tools
6. **Window Management System** for multiple apps
7. **Balanced time/risk ratios** across all tools

---

## 🔄 **DEPENDENCIES FOR SPRINT 4**
*What Sprint 4 will need:*

1. ✅ All three tools functional and balanced
2. ✅ Cross-tool clue system working
3. ✅ Window management for multiple apps
4. ✅ Consequence system expanded for all tools
5. ✅ Framework for adding NPC interactions

---

## 🚨 **STRETCH GOALS (If Time Permits)**
- [ ] Email attachments can be "detonated in sandbox"
- [ ] Terminal command auto-complete
- [ ] App-specific keyboard shortcuts
- [ ] Email "report phishing" button that users actually use
- [ ] Terminal command scripts (batch operations)

---

## 📝 **DAILY CHECK-IN QUESTIONS**

**End of each day, ask:**
1. Does each tool feel distinct and purposeful?
2. Are the risk/reward tradeoffs clear per tool?
3. Can a player understand all three tools in one session?
4. Is tool switching smooth and intuitive?

---

## 🏁 **SPRINT COMPLETE WHEN...**

You can complete a ticket that requires:
1. Check email for phishing attempt (Email tool)
2. Find malicious IP in email header
3. Search for that IP in SIEM logs (SIEM tool)
4. Find malware beacon to that IP
5. Use Terminal to isolate infected host (Terminal tool)

**If this multi-tool workflow feels cohesive (not tacked together), Sprint 3 is complete.**

---

## 🎯 **READY FOR SPRINT 4 WHEN...**

The player has a **complete investigative toolkit** with clear strengths, weaknesses, and synergies. Week 4 will add NPCs, narrative arc, and polish to create the 15-minute vertical slice.

---

**Remember:** Three tools should feel like **one cohesive investigation suite**, not three separate minigames. The integration is what makes the SOC fantasy work.

*"Additional tools authorized. Email analysis protocols loaded. Terminal access granted. Remember: Each tool amplifies both capability and responsibility. Misuse is detectable. Excellence is expected. Integrate and proceed."*