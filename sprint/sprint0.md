# 🎮 **SPRINT 0: GAME VISION & FOUNDATION**

## **Game Title:** *Incident Response: SOC Simulator* (working title)

---

## 🎯 **CORE PHILOSOPHY**

> **"The firewall is perfect. Your judgment is the vulnerability."**

This is not a game about "winning" or "losing." It's about **surviving in a security operations center where every decision has cascading consequences**. You are a SOC (Security Operations Center) Analyst caught between:

1. **Security Protocols** (slow, thorough, by-the-book)
2. **Business Pressure** (fast, efficient, keep systems running)
3. **Human Limitations** (you can't check everything, something will be missed)

The system is designed to fail. Your job is to decide *what* fails and when.

---

## 🖥️ **HYBRID 2D/3D APPROACH**

### **The Dual Reality:**
- **3D World**: The physical SOC office. Walk between desks, talk to colleagues, see the big monitoring wall.
- **2D Desktop**: Your computer workstation. Dive deep into tools, analyze logs, make critical decisions.
- **Transition**: Sit at any computer → screen fades to your 2D desktop → immersion in digital tools.

### **Why Hybrid?**
- **Immersion**: Feels like actually working in a SOC
- **Clarity**: 2D interfaces are perfect for complex tools
- **Atmosphere**: Contrast between social 3D space and isolated 2D focus
- **Performance**: Heavy UI rendering separated from 3D environment

---

## 🎮 **CORE MECHANICS OVERVIEW**

### **1. Security Incident Tickets**
- Digital tickets arrive via your 2D desktop
- Each has: Severity, description, steps, hidden risks
- Three completion styles:
  - **COMPLIANT**: Follow all protocols (slow, safe)
  - **EFFICIENT**: Skip some checks (fast, risky)
  - **EMERGENCY**: Panic button (instant, costly)

### **2. Three Analysis Tools (2D Apps)**
- **SIEM Viewer**: Security logs - spot patterns, not read everything
- **Email Analyzer**: Phishing detection - clues in headers/attachments
- **Incident CLI**: Command line - powerful but dangerous

### **3. Security Posture Meter**
- Organization's "security health" (0-100%)
- Drains with missed threats, poor decisions
- At 0% → Major breach → "Performance review" (soft reset)
- Visualized on the 3D SOC wall monitor

### **4. Consequence Engine**
- Every choice logged
- Poor decisions → delayed consequences (next shift, next day)
- Creates the "ah hell" moment: "My rushed decision from yesterday caused today's crisis"

---

## 🏆 **THE ARCHETYPE SYSTEM**

At the end of your shift, the system classifies you:

| Archetype | Playstyle | Consequences |
|-----------|-----------|--------------|
| **By-the-Book** | Always compliant, check everything | Slow progression, boring but safe |
| **Pragmatic** | Balance risk vs. speed | Some successes, some consequences |
| **Cowboy** | Fast decisions, take risks | Big wins or catastrophic failures |

**No "best" archetype** - just different ways to survive.

---

## 📐 **TECHNICAL FOUNDATION**

### **Engine & Tools:**
- **Godot 4.3+** (Forward+ renderer)
- **Solo Developer** - All code, art, design
- **Systems-first approach** - Mechanics before polish

### **Platform Target:**
- **Primary**: Windows PC
- **Secondary**: Linux/Mac if time permits
- **No mobile** - Requires keyboard/mouse precision

### **Art Style:**
- **3D**: Low-poly, clean, corporate aesthetic
- **2D**: Corporate software UI (blues, grays, red alerts)
- **Typography**: Monospace throughout (feels "technical")
- **Animation**: Minimal, functional only

### **Audio:**
- **3D**: Office ambiance, distant conversations, server hum
- **2D**: Computer fan, keyboard clicks, UI beeps
- **Music**: None initially - let the tension of silence speak

---

## 🎯 **VERTICAL SLICE GOAL**

### **15-Minute Proof of Concept:**
1. **Minute 1-3**: Enter 3D SOC, sit at computer, receive first ticket
2. **Minute 4-8**: Investigate phishing email using 2D tools
3. **Minute 9-12**: Consequence from earlier choice triggers
4. **Minute 13-15**: Shift ends, receive your "analyst archetype"

### **Success Metrics:**
- ✅ Player understands the core tension (security vs. speed)
- ✅ Player experiences at least one cascading consequence
- ✅ Player can articulate "what kind of analyst I was"
- ✅ No bugs blocking the 15-minute experience

---

## 🚫 **CONSTRAINTS & ANTI-FEATURES**

### **DO NOT BUILD (in vertical slice):**
1. ❌ Realistic network topology simulation
2. ❌ Complex command line parser
3. ❌ Multiple SOC locations
4. ❌ Character customization
5. ❌ Voice acting
6. ❌ Multiplayer
7. ❌ Save/load system (yet)
8. ❌ Settings menu beyond volume

### **CRITICAL SIMPLIFICATIONS:**
- **SIEM**: 5-8 log entries max, color-coded categories
- **Email**: 3-5 fields to check (sender, attachment, links)
- **CLI**: 3 commands only, exact match input
- **3D World**: One room, 4-5 computers, 2-3 NPCs

---

## 📊 **RISK ASSESSMENT**

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| **2D/3D transition feels jarring** | Medium | High | Smooth fades, consistent audio cues |
| **Cybersecurity concepts too technical** | High | High | Simplify jargon, tooltips, gradual teaching |
| **Game feels repetitive** | Medium | Medium | Varied incident types, consequence variety |
| **3D world feels empty** | Low | Low | Ambient NPCs, environmental storytelling |
| **Player feels unfairly punished** | High | High | Every consequence must be traceable to a player choice |

---

## 📅 **SPRINT OVERVIEW (4 Weeks)**

**Week 1**: 3D Foundation + Desktop Transition (Hybrid pipeline)  
**Week 2**: Core Ticket Loop in 2D (First playable incident)  
**Week 3**: Complete Toolset + Integration (All 3 tools working)  
**Week 4**: Polish, NPCs, Cyber Arc (15-minute experience)

---

## 🧪 **TESTING PHILOSOPHY**

### **Three Types of Testers:**
1. **Non-technical friends**: "Do they understand the basic choice?"
2. **Gamers**: "Is it fun/rewarding to play?"
3. **Cybersecurity folks**: "Does it feel authentic-ish?"

### **Key Questions to Answer:**
- "What kind of employee were you trying to be?"
- "Did any consequence feel unfair or random?"
- "Were you ever confused about what to do next?"
- "Would you play another shift?"

---

## 💭 **THE ULTIMATE TEST**

Watch a playtester and note:
1. **Minute 3**: Do they understand they're in a security operations center?
2. **Minute 8**: Do they hesitate before marking an incident "resolved"?
3. **Minute 12**: Do they say "oh no" when a consequence from earlier appears?
4. **Minute 15**: Do they ask "what kind of analyst was I?" or similar?

**3/4 yes = Success.** You've created a game about meaningful choices in high-pressure systems.

---

## 🏁 **SUCCESS DEFINITION**

> "A player completes the 15-minute arc and can describe what kind of SOC analyst they chose to be—citing specific moments where they sacrificed thoroughness for speed, took calculated risks, or followed protocol despite pressure—and requests to play 'one more shift' to try a different approach."

---

## 📁 **PROJECT STRUCTURE SKETCH**
*(Detailed in sprint1, but for planning:)*
```
/godot_project/
├── /scenes/3d/           # SOC room, player, computers
├── /scenes/2d/           # Desktop, apps, UI components
├── /autoloads/           # GameState, ConsequenceEngine, etc.
├── /resources/           # Tickets, logs, emails as .tres
└── /audio/               # Minimal sound effects
```

---

## 🚀 **NEXT STEP**

**Sprint 1 (Week 1) begins** with building the 3D environment and proving the 2D/3D transition works before any game systems are added.

---

*"Welcome to the Security Operations Center. Your access has been logged. Your decisions will be reviewed. Remember: The protocol exists for your protection. Deviation is measurable. Vigilance is mandatory. Begin your shift."*

---

**Ready for Sprint 1 details?** This foundation document should guide all development decisions. Every feature request should answer: "Does this serve the core fantasy of being a SOC analyst making impossible choices?"