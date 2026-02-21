# 🔍 PHASE 1 — VALIDATION & FAILURE PROOFING (YOU'RE HERE)

**Goal: Kill exploits.**

**What happens:**

- Player path exhaustion
- Negligence punished
- Edge cases handled
- Scoring tied to responsibility

> **⚠️ If players can AFK and win → you cannot move on.**

**This phase is non-negotiable.**

## Actionable Steps:

1. **Test every possible player strategy**
   - Can they ignore the main mechanic and still win?
   - What happens if they click nothing for 5 minutes?
   - What if they spam every button randomly?
   - Does the game punish or prevent degenerate strategies?

2. **Create failure conditions**
   - Define what "losing" means in your game
   - Make sure players can actually fail
   - Test: Can a player fail within the first 2 minutes?
   - Ensure consequences are clear and immediate

3. **Edge case checklist**
   - What happens at 0 resources?
   - What happens at max resources?
   - What if two conflicting events trigger simultaneously?
   - What if the player does nothing during a critical moment?
   - What if they try to break the game intentionally?

4. **Scoring integrity**
   - Remove score inflation exploits
   - Tie points to meaningful decisions, not button mashing
   - Make sure high scores require skill, not patience
   - Test: Can you get high scores by accident?

**Exit Criteria:** Playtest with someone who tries to break it. If they can't find an exploit in 30 minutes, you pass.

---

# 🧠 PHASE 2 — CORE CONTENT LOCK (NOT EXPANSION)

**Goal: One week feels complete.**

**Define:**

1. 1 full Monday–Sunday loop
2. 1 weekend mode
3. 1 archetype outcome

**After this phase:**

> You can finish the game even if you add nothing else.  
> **This is the real "finish" moment.**

## Actionable Steps:

1. **Design the complete week structure**
   - Map out Monday through Sunday: what happens each day?
   - Define the rhythm: work days vs. weekend days
   - Create clear escalation: how does difficulty/complexity grow?
   - Establish the "reset" point: what carries over week-to-week?

2. **Build the weekend mode**
   - How does gameplay change on Saturday/Sunday?
   - Different threats? Different mechanics? Relaxation period?
   - This should feel distinct but not disconnected
   - Test: Does the weekend feel earned or arbitrary?

3. **Lock in ONE archetype outcome**
   - What is the "win state" for a perfect week?
   - What is the "failure state"?
   - What are 2-3 middle outcomes?
   - Write the ending text/screens for each
   - Don't build multiple paths yet—just one complete arc

4. **Define the minimal viable loop**
   - A player should be able to play one full week and feel satisfied
   - They should understand the core risk/reward
   - They should want to play again with a different strategy
   - Test: Can someone finish a week in 20-40 minutes?

**Exit Criteria:** Someone can play from start to finish, reach an ending, and say "I want to try again differently."

---

# 🧹 PHASE 3 — TECHNICAL DEBT REDUCTION (SELECTIVE)

**Goal: Remove blockers only.**

**Fix:**

- Architecture pain
- Performance killers
- Tooling friction

**Do not refactor for beauty.**  
**Refactor only what blocks shipping.**

## Actionable Steps:

1. **Identify pain points**
   - What makes adding content slow or frustrating?
   - What breaks every time you change something?
   - What causes crashes or lag?
   - What requires you to manually update 5 files for one change?

2. **Fix architecture blockers**
   - Consolidate duplicate systems
   - Create data-driven configs for content (JSON, CSV, etc.)
   - Build tools for rapid iteration (level editor, event creator)
   - Make it easy to add content without touching code

3. **Performance optimization**
   - Profile the game: where are the slowdowns?
   - Fix only the top 3 performance issues
   - Optimize assets that are causing problems
   - Don't optimize things that run fast enough

4. **Developer quality of life**
   - Can you playtest a change in under 30 seconds?
   - Can you add a new scenario without breaking others?
   - Do you have debug tools to skip to specific game states?

**Exit Criteria:** Adding new content takes minutes, not hours. The game runs smoothly on target hardware.

**⚠️ CRITICAL:** Set a time limit (1-2 weeks max). Tech debt is infinite. Fix only what blocks Phase 4.

---

# 🎮 PHASE 4 — CONTENT EXPANSION (SAFE NOW)

**Goal: Variety, not depth.**

**Add:**

- More scenarios
- New threats
- Extra apps
- Difficulty curves

**No new systems unless unavoidable.**

## Actionable Steps:

1. **Multiply scenarios (not mechanics)**
   - Take your existing systems and create variations
   - If you have 5 scenarios, create 15 more using the same structure
   - Remix existing elements in new combinations
   - Test: Can you create a new scenario in under 1 hour?

2. **Add threat variety**
   - More enemy types, obstacles, or challenges
   - Different risk profiles: fast/slow, high-damage/low-damage
   - Introduce threats at different pacing
   - Don't add new mechanics—add new content using existing mechanics

3. **Expand your content library**
   - If you have apps/tools/items, add more
   - Create "obvious" variations first (easy mode: add 10 recolors)
   - Add context-specific content (work-themed, weekend-themed)
   - Use your Phase 3 tools to make this fast

4. **Implement difficulty progression**
   - Week 1: Tutorial difficulty
   - Week 2-3: Core challenge
   - Week 4+: Expert/mastery content
   - Each week should introduce 1-2 new wrinkles
   - Reuse mechanics in harder contexts

5. **Create unlock progression**
   - New apps/tools unlock after Week 1, Week 2, etc.
   - Give players new toys to keep things fresh
   - Don't gate core mechanics—gate variety

**Exit Criteria:** The game has enough content for 3-5 hours of unique gameplay. Players don't see all content in one playthrough.

**⚠️ WARNING:** If you find yourself saying "I need to code a new system for this," STOP. Reskin existing systems instead.

---

# 🎨 PHASE 5 — UX, UI, AUDIO

**Goal: Trust and clarity.**

**Improve:**

- Feedback
- Readability
- Emotional pacing
- Audio cues

**This is when players start believing your game is "real".**

## Actionable Steps:

1. **Feedback loops**
   - Every action needs visual/audio acknowledgment
   - Players should know: "Did that work? What just happened?"
   - Add screen shake, particle effects, sound effects
   - Test: Close your eyes and play. Can you tell what's happening?

2. **Visual clarity**
   - Increase contrast between important and unimportant elements
   - Add icons, color coding, visual hierarchies
   - Ensure text is readable at all times
   - Remove visual clutter that doesn't serve gameplay

3. **Emotional pacing through UI**
   - Use color psychology: red for danger, green for safety, yellow for warning
   - Animate transitions to create rhythm and breathing room
   - Add anticipation: telegraph threats before they arrive
   - Make victories feel victorious (screen flash, sound sting, etc.)

4. **Audio design**
   - Add sound effects for all major actions
   - Create audio cues for threats/dangers
   - Background music that matches the emotional tone
   - Use silence strategically
   - Test: Play with sound off. What's missing?

5. **Tutorial and onboarding**
   - Can a new player understand the game in 60 seconds?
   - Show, don't tell (use visual tutorials, not text walls)
   - Introduce mechanics one at a time
   - Let players fail safely in the first week

6. **Polish pass on all screens**
   - Main menu, pause menu, game over screen, victory screen
   - Everything should feel cohesive
   - Add transitions between screens
   - No placeholder text or programmer art

**Exit Criteria:** A new player can pick up your game and understand it without your explanation. The game feels professional.

---

# ✨ PHASE 6 — POLISH & SHIP

**Goal: Respect the player.**

- Bug fixing
- Balance
- Small delights
- Removal of leftovers

**Stop adding features here. Ruthlessly.**

## Actionable Steps:

1. **Bug triage**
   - List every known bug
   - Fix all crashes and softlocks (priority 1)
   - Fix all gameplay-breaking bugs (priority 2)
   - Fix visual/audio bugs (priority 3)
   - Don't fix cosmetic issues unless they're embarrassing

2. **Balance pass**
   - Playtest: Is Week 1 too hard? Too easy?
   - Adjust difficulty curves based on player feedback
   - Ensure no dominant strategy (one approach that's always best)
   - Make sure all mechanics are useful at some point

3. **Juice and delight**
   - Add tiny touches that make actions feel good
   - Screen shake when things explode
   - Particles when you succeed
   - Satisfying sound effects
   - Smooth animations
   - These take minutes to add but elevate the feel

4. **Remove everything unfinished**
   - Delete placeholder content
   - Remove unfinished features entirely
   - Hide debug tools from players
   - Remove "coming soon" or "TODO" text
   - A small complete game beats a large incomplete one

5. **Final content audit**
   - Play through the entire game start to finish
   - Does anything feel out of place?
   - Does anything break immersion?
   - Cut anything that doesn't serve the core experience

6. **Pre-launch checklist**
   - Write your store page description
   - Create screenshots and trailer
   - Get 5 people to playtest the final build
   - Fix only critical issues they find
   - Set a ship date and commit to it

**Exit Criteria:** The game is complete, stable, and ready for players. You're proud to show it to people.

---

## 🚀 SHIPPING MINDSET

### Rules for finishing:

1. **Done is better than perfect**
   - Your first game doesn't need to be your magnum opus
   - Ship it, learn from it, make the next one better

2. **Scope cuts are not failures**
   - Every shipped game is the result of ruthless cutting
   - If a feature doesn't make it, save it for the sequel

3. **The last 10% takes 90% of the time**
   - This is real. Plan for it.
   - Don't add features in the final stretch

4. **Your game will never feel "ready"**
   - There will always be one more thing to add
   - Ship it anyway

5. **Post-launch updates are allowed**
   - You can fix bugs after release
   - You can add content after release
   - But only if you actually release

### When to move between phases:

- **Phase 1 → 2:** When exploits are dead and failure is real
- **Phase 2 → 3:** When one complete week exists and feels good
- **Phase 3 → 4:** When adding content is fast and painless
- **Phase 4 → 5:** When you have "enough" content (3-5 hours)
- **Phase 5 → 6:** When the game feels professional and clear
- **Phase 6 → SHIP:** When critical bugs are fixed and you've cut everything unfinished

### Emergency scope reduction:

If you're stuck and overwhelmed, cut in this order:

1. Cut secondary game modes
2. Cut cosmetic variety
3. Cut late-game content (keep weeks 1-3, cut week 4+)
4. Cut tutorial polish (keep it functional)
5. Cut audio (use free SFX libraries)
6. Cut storyline complexity
7. Cut difficulty modes (keep medium only)

**The minimum viable game:**
- Works without crashing
- Has a clear goal
- Can be won and lost
- Takes 30-60 minutes to complete
- Feels fair

If you have that, you can ship.

---

**Remember:** A finished small game is infinitely more valuable than an unfinished ambitious one. Ship this one, then make the next one better.