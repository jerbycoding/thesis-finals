# 📅 **SPRINT 4: WEEK 4 - POLISH, NPCs & VERTICAL SLICE**
**Theme:** "Create a compelling 15-minute experience with narrative and polish"

---

## 🎯 **SPRINT GOAL**
**Deliver:** A complete 15-minute vertical slice that showcases the core fantasy of being a SOC analyst making impossible choices under pressure.

**Builds on Sprint 3:** Adds NPC interactions, narrative arc, visual/audio polish, and playtesting iteration to create a cohesive experience.

---

## 📊 **ACCEPTANCE CRITERIA**
1. ✅ 15-minute curated "first shift" narrative arc
2. ✅ Three NPCs with distinct roles/personalities
3. ✅ Corporate voice system for all game feedback
4. ✅ Visual/audio polish (particles, sounds, transitions)
5. ✅ End-of-shift archetype analysis
6. ✅ At least one "cascading consequence" moment
7. ✅ Playtested and iterated based on feedback
8. ✅ No critical bugs or crashes
9. ✅ Performance maintained at 60+ FPS
10. ✅ Documented content pipeline for future expansion

---

## 📁 **FOLDER STRUCTURE ADDITIONS**
```
/incident_response_soc/
├── /autoload/ (ADDITIONS)
│   ├── NarrativeDirector.gd      # Controls story flow
│   ├── CorporateVoice.gd         # All game text in "corporate speak"
│   └── ArchetypeAnalyzer.gd      # Analyzes player choices
├── /scenes/
│   ├── /3d/ (ADDITIONS)
│   │   ├── NPC_CISO.tscn         # CISO character
│   │   ├── NPC_SeniorAnalyst.tscn
│   │   ├── NPC_ITSupport.tscn
│   │   └── BriefingRoom.tscn     # Separate room for meetings
│   ├── /2d/ (ADDITIONS)
│   │   └── /apps/
│   │       └── App_ShiftReport.tscn  # End of shift analysis
│   └── /ui/ (ADDITIONS)
│       ├── DialogueBox.tscn
│       ├── ArchetypeResult.tscn
│       └── TitleScreen.tscn
├── /resources/narrative/ (NEW)
│   ├── arc_first_shift.tres      # Scripted event sequence
│   ├── dialogue_ciso.json
│   └── archetype_definitions.json
└── /audio/ (ADDITIONS)
    ├── /voice/ (placeholder)
    ├── /sfx/polish/
    │   ├── consequence_alert.ogg
    │   ├── ui_hover.ogg
    │   └── ticket_spawn.ogg
    └── music_ambient.ogg
```

---

## 📝 **DAY-BY-DAY TASKS**

### **DAY 1: NARRATIVE ARC & NPCs**
**Goal:** Scripted 15-minute experience with NPC interactions

**Tasks:**
1. **Narrative Director System**
   - Create `NarrativeDirector.gd` autoload
   - Manages scripted event sequence:
     ```gdscript
     var first_shift_arc = [
       {time: 0, event: "briefing_ciso"},
       {time: 60, event: "spawn_ticket", data: "phishing_intro"},
       {time: 180, event: "npc_checkin", data: "senior_analyst"},
       {time: 420, event: "spawn_ticket", data: "malware_response"},
       {time: 600, event: "spawn_consequence", data: "from_earlier"},
       {time: 840, event: "shift_end_report"}
     ]
     ```

2. **Three NPC Implementations**
   - **CISO (Chief Information Security Officer)**
     - Position: Briefing room (separate area)
     - Role: Gives initial briefing, appears at shift end
     - Dialogue: Corporate, pressure-focused
   
   - **Senior Analyst**
     - Position: At their desk in main SOC
     - Role: Gives tips, reacts to player choices
     - Dialogue: Jaded but helpful
   
   - **IT Support**
     - Position: By server rack
     - Role: Can restore disabled tools (with time cost)
     - Dialogue: Technical, overworked

3. **Dialogue System**
   - `DialogueBox.tscn`: Modal with character portrait, text, choices
   - Dialogue choices affect NPC relationships
   - Some choices unlock/lock future options

4. **Briefing Room Scene**
   - Separate room connected to main SOC
   - CISO stands at podium with presentation screen
   - Initial camera cutscene for immersion

**Deliverable:** NPCs exist, can be talked to, initial briefing plays.

---

### **DAY 2: CORPORATE VOICE & FEEDBACK POLISH**
**Goal:** All game text uses consistent "corporate security" voice

**Tasks:**
1. **Corporate Voice System**
   - Create `CorporateVoice.gd` autoload
   - Translation functions:
     ```gdscript
     func translate(event: String, data: Dictionary) -> String:
         match event:
             "ticket_complete":
                 return "Incident #{id} resolved. Time variance: {variance}%."
             "consequence_triggered":
                 return "Secondary incident detected. Root cause: {cause}."
             "tool_disabled":
                 return "Resource {tool} temporarily unavailable for maintenance."
     ```

2. **Replace All Game Text**
   - Ticket descriptions
   - Log entries
   - Email content
   - UI labels and tooltips
   - Notification messages
   - Example: "You missed a log" → "Required evidence collection incomplete"

3. **Visual Feedback Polish**
   - Consequence alert: Red pulse across screen edges
   - Ticket completion: Green checkmark animation
   - Tool disabled: Grey overlay with "MAINTENANCE" text
   - Time pressure: Clock pulses red when < 60s

4. **Audio Polish**
   - Add 5 key sound effects:
     1. `consequence_alert.ogg` - Low ominous tone
     2. `ticket_spawn.ogg` - New ticket notification
     3. `tool_enable.ogg` - Tool restored
     4. `ui_hover.ogg` - Button hover
     5. `dialogue_advance.ogg` - Text advance
   - Ambient music: Subtle synth pads (volume 30%)

**Deliverable:** Game feels professionally "corporate" in tone.

---

### **DAY 3: ARC DESIGN & CASCADING CONSEQUENCES**
**Goal:** Curated 15-minute experience that teaches all systems

**Tasks:**
1. **First Shift Arc Design**
   ```
   Minute 0-2: CISO Briefing
   - "Welcome to SOC. Phishing campaign active. Stay vigilant."
   
   Minute 2-5: Ticket 1 - "Phishing Email Review" (Email tool)
   - Teaches email inspection
   - Hidden risk: Miss attachment scan
   - Consequence: Spawns Ticket 2 at minute 7
   
   Minute 5-8: Senior Analyst Check-in
   - "How's first ticket? Remember to check headers."
   - Choice: Admit rushing or claim thoroughness
   
   Minute 8-12: Ticket 2 - "Malware Detection" (SIEM + Terminal)
   - Result of earlier hidden risk
   - Requires checking SIEM logs, then using Terminal
   - Tests if player learned from earlier
   
   Minute 12-14: CISO Returns
   - "Shift ending. Preliminary report?"
   - Quick decisions about what to report
   
   Minute 14-15: Archetype Analysis
   - Shows player's "analyst style"
   - Based on actual choices made
   ```

2. **Cascading Consequence Implementation**
   - Ticket 1's hidden risk → Ticket 2 spawns
   - Player's dialogue choices → NPC attitudes change
   - Tool usage patterns → Different end report
   - Must feel connected, not random

3. **Difficulty Balancing**
   - First ticket: Extra time, clear clues
   - Second ticket: Normal time, requires synthesis
   - Ensure average player completes in 12-18 minutes

4. **Arc Integration**
   - NarrativeDirector controls spawn timing
   - NPCs appear at scripted times
   - Events trigger based on player progress

**Deliverable:** Playable 15-minute arc with narrative flow.

---

### **DAY 4: ARCHETYPE SYSTEM & END GAME**
**Goal:** Meaningful analysis of player's choices and style

**Tasks:**
1. **Archetype Analyzer**
   - Create `ArchetypeAnalyzer.gd`
   - Tracks metrics:
     ```gdscript
     var metrics = {
         "avg_completion_time": 0.0,
         "risk_taken_count": 0,
         "tools_used": {},
         "consequences_triggered": 0,
         "npc_approval": 0.0
     }
     ```

2. **Three Archetypes Definition**
   - **By-the-Book**: >80% compliant, slow, avoids risks
   - **Pragmatic**: 40-70% compliant, balances speed/risk
   - **Cowboy**: <40% compliant, fast, takes many risks
   - Each has sub-variations based on tool preferences

3. **Shift Report Screen**
   - `App_ShiftReport.tscn` (replaces desktop at shift end)
   - Shows:
     - Tickets completed
     - Time efficiency
     - Risks taken
     - Consequences triggered
     - Final archetype with description
   - "Continue to next shift?" button (placeholder)

4. **Archetype-Specific Feedback**
   - Different CISO dialogue based on archetype
   - Senior Analyst reacts differently
   - Visual changes in SOC based on performance
   - Example: Cowboy gets messier desk, By-the-Book gets "employee of month" certificate

5. **Title Screen Implementation**
   - Simple title with "Start First Shift" button
   - Options menu (volume controls only)
   - Credits placeholder
   - Quit button

**Deliverable:** Meaningful end game that reflects player choices.

---

### **DAY 5: PLAYTEST, ITERATE, POLISH**
**Goal:** Bug-free, polished vertical slice ready for showing

**Tasks:**
1. **Playtest Protocol**
   - Find 3 testers (non-developers preferred)
   - Observation points:
     1. Minute 3: Do they understand the core choice?
     2. Minute 8: Do they notice the cascading consequence?
     3. Minute 12: Are they engaged or frustrated?
     4. Minute 15: Can they articulate their playstyle?
   - Interview questions post-playtest

2. **Bug Fixing & Polish**
   - Fix all critical bugs (crashes, blockers)
   - Polish transitions (smoother fades)
   - Balance timing (ensure 15-minute target)
   - UI tweaks based on tester feedback

3. **Performance Optimization**
   - Check for memory leaks
   - Ensure 60 FPS on target hardware
   - Reduce loading times
   - Compress textures/audio where needed

4. **Final Integration Test**
   - Complete arc from title screen to end report
   - Test all three archetype paths
   - Test edge cases (extreme rushing, extreme caution)
   - Verify no progression blockers

5. **Documentation & Handoff**
   - Create `VERTICAL_SLICE_COMPLETE.md` summary
   - List known issues for future sprints
   - Create content templates for easy expansion
   - Build instructions for testers

**Final Test Checklist:**
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

---

## 🎮 **15-MINUTE ARC FLOW**

```
TITLE SCREEN → START FIRST SHIFT

[3D] Walk to briefing room (auto-walk cutscene)
[DIALOGUE] CISO briefing: "Phishing campaign active"

[3D] Return to SOC, sit at computer
[2D] Desktop loads, Ticket 1 appears

[TICKET 1] "Phishing Email - URGENT"
- Use Email tool: Inspect headers, attachment
- Choice: Quarantine (safe) or Approve (risky)
- Hidden risk: Miss attachment scan

[3D] Senior Analyst walks over
[DIALOGUE] "First ticket done? Watch for .exe files"

[2D] Ticket 2 spawns (consequence of hidden risk)
[TICKET 2] "Malware Detected on Host"
- Use SIEM: Find infected host
- Use Terminal: `isolate host-12`
- Higher stakes, less time

[3D] CISO returns
[DIALOGUE] "Shift ending. Preliminary findings?"
- Quick reporting choices affect archetype

[2D] Shift Report Screen
- Shows metrics, archetype, feedback
- "Employee Style: Pragmatic Analyst"

END → Return to title or "Next Shift" (placeholder)
```

---

## 🎨 **POLISH ELEMENTS TO ADD**

### **Visual Polish:**
1. **Screen transitions** with subtle glitch effect
2. **Particle effects** for important events
3. **UI animations** (buttons pulse, slides)
4. **Color grading** for different moods
5. **Lighting changes** based on time of "shift"

### **Audio Polish:**
1. **Dynamic music** that intensifies under time pressure
2. **Room tone** changes when alone vs. with NPCs
3. **Tool-specific sounds** (terminal keystrokes, email swoosh)
4. **Voice placeholder** (beep tones for now)

### **UX Polish:**
1. **Tooltips** for all interactive elements
2. **Keyboard shortcuts** displayed
3. **Progress indicators** for long operations
4. **Error messages** in corporate voice
5. **Consistent button hierarchy**

---

## ⚠️ **CRITICAL RISKS & MITIGATION**

1. **15 minutes feels rushed**
   - Include buffer time in script
   - Allow pausing (spacebar)
   - Clear "this is a tutorial" messaging

2. **Archetype feels inaccurate**
   - Weight metrics carefully
   - Show raw data in report so players understand
   - Multiple archetype factors, not just completion %

3. **NPCs feel shallow**
   - Give each 3 distinct dialogue states
   - React to player's recent choices
   - Visual variety in animations

4. **Corporate voice feels confusing**
   - Include "translation" option in settings
   - Keep some human elements (Senior Analyst is casual)
   - Test with non-corporate people

---

## 📦 **DELIVERABLES FOR WEEK 4**

1. **Complete 15-minute narrative arc**
2. **Three interactive NPCs** with dialogue
3. **Corporate voice system** applied throughout
4. **Archetype analysis system** with shift report
5. **Visual/audio polish** (particles, sounds, transitions)
6. **Title screen** and basic menu system
7. **Playtest feedback** and iteration documentation
8. **Content pipeline templates** for expansion

---

## 🏁 **VERTICAL SLICE COMPLETE WHEN...**

A first-time player can:
1. Complete the 15-minute arc without guidance
2. Experience a "cascading consequence" from their choice
3. Receive an archetype that matches their self-perception
4. Say "I'd play another shift to try a different approach"

**If testers request to play again with different choices, you've succeeded.**

---

## 🚀 **NEXT STEPS AFTER SPRINT 4**

### **Immediate (Week 5):**
1. Address playtest feedback
2. Create 3 more tickets for variety
3. Add "second shift" with increased difficulty
4. Implement save/load system

### **Future Sprints:**
1. Stakeholder system (Security vs. Business pressure)
2. Tool upgrades/unlocks
3. Multiple SOC layouts
4. Procedural ticket generation
5. Full narrative campaign

---

## 📝 **PLAYTESTER QUESTIONS**

**Post-playtest interview:**
1. "What kind of SOC analyst were you trying to be?"
2. "Did any consequence feel unfair or random?"
3. "Which tool felt most satisfying to use?"
4. "Did you understand why you got your archetype?"
5. "What would you do differently next shift?"
6. "Did the corporate speak help or hinder immersion?"
7. "On a scale of 1-10, how much did you feel 'in the SOC'?"

**Success:** Average 7+ on question 7, coherent answers to 1-5.

---

## 🎯 **THE ULTIMATE TEST**

Watch a playtester's face during these moments:
1. **Minute 4**: First email inspection - Do they lean in?
2. **Minute 8**: Consequence appears - Do they say "oh no"?
3. **Minute 12**: Terminal command - Do they hesitate?
4. **Minute 15**: Archetype revealed - Do they nod in recognition?

**3/4 positive reactions = Vertical slice achieved.**

---

**Remember:** This sprint isn't about adding features—it's about making what exists **feel complete**. Polish transforms systems into experience.

*"Vertical slice protocol initiated. Narrative elements integrated. Polish systems engaged. Remember: This is the demonstration of core fantasy. Player experience is the ultimate metric. Emotional resonance is the target. Execute final assembly."*