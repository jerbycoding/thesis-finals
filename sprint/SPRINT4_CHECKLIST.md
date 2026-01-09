# 📋 **SPRINT 4 CHECKLIST**
**Theme:** "Create a compelling 15-minute experience with narrative and polish"

---

## 🎯 **ACCEPTANCE CRITERIA**

- [ ] 1. 15-minute curated "first shift" narrative arc
- [ ] 2. Three NPCs with distinct roles/personalities
- [ ] 3. Corporate voice system for all game feedback
- [ ] 4. Visual/audio polish (particles, sounds, transitions)
- [ ] 5. End-of-shift archetype analysis
- [ ] 6. At least one "cascading consequence" moment
- [ ] 7. Playtested and iterated based on feedback
- [ ] 8. No critical bugs or crashes
- [ ] 9. Performance maintained at 60+ FPS
- [ ] 10. Documented content pipeline for future expansion

---

## 📅 **DAY 1: NARRATIVE ARC & NPCs**

### **Narrative Director System**
- [x] Create `NarrativeDirector.gd` autoload
- [ ] Implement scripted event sequence management
- [ ] Add first_shift_arc event timeline
- [ ] Connect to TicketManager for ticket spawning
- [ ] Connect to ConsequenceEngine for delayed events
- [ ] Test event triggering at correct times

### **Three NPC Implementations**
- [x] Create base NPC script (`NPC.gd`)
- [x] Create `NPC_CISO.tscn` with dialogue
- [x] Create `NPC_SeniorAnalyst.tscn` with dialogue
- [x] Create `NPC_ITSupport.tscn` with dialogue
- [ ] Position CISO in briefing room
- [ ] Position Senior Analyst at desk in SOC
- [ ] Position IT Support by server rack
- [ ] Test all NPC interactions

### **Dialogue System**
- [x] Create `DialogueBox.tscn` UI component
- [x] Implement dialogue display with keyboard controls
- [x] Add choice selection system
- [x] Connect dialogue choices to NPC relationships
- [ ] Add dialogue unlock/lock system
- [ ] Test dialogue flow and choices

### **Briefing Room Scene**
- [ ] Create `BriefingRoom.tscn` scene
- [ ] Add CISO podium and presentation screen
- [ ] Connect briefing room to main SOC
- [ ] Implement camera cutscene for initial briefing
- [ ] Test briefing sequence

**Day 1 Deliverable:** NPCs exist, can be talked to, initial briefing plays.

---

## 📅 **DAY 2: CORPORATE VOICE & FEEDBACK POLISH**

### **Corporate Voice System**
- [ ] Create `CorporateVoice.gd` autoload
- [ ] Implement translation functions for all event types
- [ ] Add ticket completion messages
- [ ] Add consequence messages
- [ ] Add tool disabled messages
- [ ] Add notification messages

### **Replace All Game Text**
- [ ] Update ticket descriptions to corporate voice
- [ ] Update log entries to corporate voice
- [ ] Update email content to corporate voice
- [ ] Update UI labels and tooltips
- [ ] Update notification messages
- [ ] Test all text feels "corporate"

### **Visual Feedback Polish**
- [ ] Consequence alert: Red pulse across screen edges
- [ ] Ticket completion: Green checkmark animation
- [ ] Tool disabled: Grey overlay with "MAINTENANCE" text
- [ ] Time pressure: Clock pulses red when < 60s
- [ ] Test all visual feedback

### **Audio Polish**
- [ ] Add `consequence_alert.ogg` sound effect
- [ ] Add `ticket_spawn.ogg` sound effect
- [ ] Add `tool_enable.ogg` sound effect
- [ ] Add `ui_hover.ogg` sound effect
- [ ] Add `dialogue_advance.ogg` sound effect
- [ ] Add ambient music (subtle synth pads, volume 30%)
- [ ] Test all audio feedback

**Day 2 Deliverable:** Game feels professionally "corporate" in tone.

---

## 📅 **DAY 3: ARC DESIGN & CASCADING CONSEQUENCES**

### **First Shift Arc Design**
- [ ] Minute 0-2: CISO Briefing
- [ ] Minute 2-5: Ticket 1 - "Phishing Email Review" (Email tool)
- [ ] Minute 5-8: Senior Analyst Check-in
- [ ] Minute 8-12: Ticket 2 - "Malware Detection" (SIEM + Terminal)
- [ ] Minute 12-14: CISO Returns
- [ ] Minute 14-15: Archetype Analysis
- [ ] Test complete arc flow

### **Cascading Consequence Implementation**
- [ ] Ticket 1's hidden risk → Ticket 2 spawns
- [ ] Player's dialogue choices → NPC attitudes change
- [ ] Tool usage patterns → Different end report
- [ ] Test consequences feel connected, not random

### **Difficulty Balancing**
- [ ] First ticket: Extra time, clear clues
- [ ] Second ticket: Normal time, requires synthesis
- [ ] Test average player completes in 12-18 minutes
- [ ] Adjust timing as needed

### **Arc Integration**
- [ ] NarrativeDirector controls spawn timing
- [ ] NPCs appear at scripted times
- [ ] Events trigger based on player progress
- [ ] Test arc integration

**Day 3 Deliverable:** Playable 15-minute arc with narrative flow.

---

## 📅 **DAY 4: ARCHETYPE SYSTEM & END GAME**

### **Archetype Analyzer**
- [ ] Create `ArchetypeAnalyzer.gd` autoload
- [ ] Track avg_completion_time metric
- [ ] Track risk_taken_count metric
- [ ] Track tools_used metric
- [ ] Track consequences_triggered metric
- [ ] Track npc_approval metric
- [ ] Test metric collection

### **Three Archetypes Definition**
- [ ] Define "By-the-Book" archetype (>80% compliant)
- [ ] Define "Pragmatic" archetype (40-70% compliant)
- [ ] Define "Cowboy" archetype (<40% compliant)
- [ ] Add sub-variations based on tool preferences
- [ ] Test archetype calculation

### **Shift Report Screen**
- [ ] Create `App_ShiftReport.tscn`
- [ ] Display tickets completed
- [ ] Display time efficiency
- [ ] Display risks taken
- [ ] Display consequences triggered
- [ ] Display final archetype with description
- [ ] Add "Continue to next shift?" button (placeholder)
- [ ] Test shift report display

### **Archetype-Specific Feedback**
- [ ] Different CISO dialogue based on archetype
- [ ] Senior Analyst reacts differently
- [ ] Visual changes in SOC based on performance
- [ ] Test archetype feedback

### **Title Screen Implementation**
- [ ] Create `TitleScreen.tscn`
- [ ] Add "Start First Shift" button
- [ ] Add options menu (volume controls only)
- [ ] Add credits placeholder
- [ ] Add quit button
- [ ] Test title screen flow

**Day 4 Deliverable:** Meaningful end game that reflects player choices.

---

## 📅 **DAY 5: PLAYTEST, ITERATE, POLISH**

### **Playtest Protocol**
- [ ] Find 3 testers (non-developers preferred)
- [ ] Set up observation points:
  - [ ] Minute 3: Do they understand the core choice?
  - [ ] Minute 8: Do they notice the cascading consequence?
  - [ ] Minute 12: Are they engaged or frustrated?
  - [ ] Minute 15: Can they articulate their playstyle?
- [ ] Conduct post-playtest interviews
- [ ] Document feedback

### **Bug Fixing & Polish**
- [ ] Fix all critical bugs (crashes, blockers)
- [ ] Polish transitions (smoother fades)
- [ ] Balance timing (ensure 15-minute target)
- [ ] UI tweaks based on tester feedback
- [ ] Test all fixes

### **Performance Optimization**
- [ ] Check for memory leaks
- [ ] Ensure 60 FPS on target hardware
- [ ] Reduce loading times
- [ ] Compress textures/audio where needed
- [ ] Test performance

### **Final Integration Test**
- [ ] Complete arc from title screen to end report
- [ ] Test all three archetype paths
- [ ] Test edge cases (extreme rushing, extreme caution)
- [ ] Verify no progression blockers
- [ ] Test complete flow

### **Documentation & Handoff**
- [ ] Create `VERTICAL_SLICE_COMPLETE.md` summary
- [ ] List known issues for future sprints
- [ ] Create content templates for easy expansion
- [ ] Build instructions for testers
- [ ] Update SPRINT_STATUS_ANALYSIS.md

### **Final Test Checklist**
- [ ] Title screen → Briefing → First ticket works
- [ ] Email tool teaches effectively
- [ ] Hidden risk triggers cascading consequence
- [ ] NPC interactions feel meaningful
- [ ] All three tools are used in arc
- [ ] Shift end report accurately reflects choices
- [ ] Archetype description feels true to playstyle
- [ ] No crashes or progression blockers
- [ ] 15±3 minute completion time
- [ ] Testers can describe their "analyst style"

**Day 5 Deliverable:** Bug-free, polished vertical slice ready for showing.

---

## 📁 **FOLDER STRUCTURE CHECKLIST**

### **Autoload Files**
- [x] `autoload/NarrativeDirector.gd`
- [ ] `autoload/CorporateVoice.gd`
- [ ] `autoload/ArchetypeAnalyzer.gd`

### **3D Scenes**
- [x] `scenes/3d/NPC_CISO.tscn`
- [x] `scenes/3d/NPC_SeniorAnalyst.tscn`
- [x] `scenes/3d/NPC_ITSupport.tscn`
- [ ] `scenes/3d/BriefingRoom.tscn`

### **2D App Scenes**
- [ ] `scenes/2d/apps/App_ShiftReport.tscn`

### **UI Scenes**
- [x] `scenes/ui/DialogueBox.tscn`
- [ ] `scenes/ui/ArchetypeResult.tscn`
- [ ] `scenes/ui/TitleScreen.tscn`

### **Narrative Resources**
- [ ] `resources/narrative/arc_first_shift.tres`
- [ ] `resources/narrative/dialogue_ciso.json`
- [ ] `resources/narrative/archetype_definitions.json`

### **Audio Files**
- [ ] `audio/sfx/polish/consequence_alert.ogg`
- [ ] `audio/sfx/polish/ui_hover.ogg`
- [ ] `audio/sfx/polish/ticket_spawn.ogg`
- [ ] `audio/music_ambient.ogg`

---

## 🎮 **15-MINUTE ARC FLOW CHECKLIST**

- [ ] TITLE SCREEN → START FIRST SHIFT
- [ ] [3D] Walk to briefing room (auto-walk cutscene)
- [ ] [DIALOGUE] CISO briefing: "Phishing campaign active"
- [ ] [3D] Return to SOC, sit at computer
- [ ] [2D] Desktop loads, Ticket 1 appears
- [ ] [TICKET 1] "Phishing Email - URGENT"
  - [ ] Use Email tool: Inspect headers, attachment
  - [ ] Choice: Quarantine (safe) or Approve (risky)
  - [ ] Hidden risk: Miss attachment scan
- [ ] [3D] Senior Analyst walks over
- [ ] [DIALOGUE] "First ticket done? Watch for .exe files"
- [ ] [2D] Ticket 2 spawns (consequence of hidden risk)
- [ ] [TICKET 2] "Malware Detected on Host"
  - [ ] Use SIEM: Find infected host
  - [ ] Use Terminal: `isolate host-12`
  - [ ] Higher stakes, less time
- [ ] [3D] CISO returns
- [ ] [DIALOGUE] "Shift ending. Preliminary findings?"
- [ ] [2D] Shift Report Screen
  - [ ] Shows metrics, archetype, feedback
  - [ ] "Employee Style: [Archetype] Analyst"
- [ ] END → Return to title or "Next Shift" (placeholder)

---

## 🎨 **POLISH ELEMENTS CHECKLIST**

### **Visual Polish**
- [ ] Screen transitions with subtle glitch effect
- [ ] Particle effects for important events
- [ ] UI animations (buttons pulse, slides)
- [ ] Color grading for different moods
- [ ] Lighting changes based on time of "shift"

### **Audio Polish**
- [ ] Dynamic music that intensifies under time pressure
- [ ] Room tone changes when alone vs. with NPCs
- [ ] Tool-specific sounds (terminal keystrokes, email swoosh)
- [ ] Voice placeholder (beep tones for now)

### **UX Polish**
- [ ] Tooltips for all interactive elements
- [ ] Keyboard shortcuts displayed
- [ ] Progress indicators for long operations
- [ ] Error messages in corporate voice
- [ ] Consistent button hierarchy

---

## 📊 **CURRENT PROGRESS**

**Overall Sprint 4 Progress: ~20%**

### **Completed:**
- ✅ NarrativeDirector.gd autoload
- ✅ DialogueBox UI component
- ✅ NPC base system
- ✅ Three NPCs (CISO, Senior Analyst, IT Support)
- ✅ NPC dialogue system
- ✅ Player interaction with NPCs

### **In Progress:**
- 🚧 Briefing Room scene
- 🚧 Corporate Voice system
- 🚧 Archetype Analyzer

### **Not Started:**
- ⏳ 15-minute narrative arc integration
- ⏳ Visual/audio polish
- ⏳ Shift Report screen
- ⏳ Title Screen
- ⏳ Playtesting

---

## 🎯 **SUCCESS METRICS**

**Vertical Slice Complete When:**
- [ ] A first-time player can complete the 15-minute arc without guidance
- [ ] Player experiences a "cascading consequence" from their choice
- [ ] Player receives an archetype that matches their self-perception
- [ ] Player says "I'd play another shift to try a different approach"

**If testers request to play again with different choices, you've succeeded.**

---

*Last Updated: Day 1 Complete - NPCs and Dialogue System Implemented*

