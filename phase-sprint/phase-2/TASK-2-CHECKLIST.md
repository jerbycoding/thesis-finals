# Phase 2 Task 2: Trace Level System - COMPLETE! ✅

## 📋 What Was Implemented

### **Files Created:**
1. **`autoload/TraceLevelManager.gd`** - Trace accumulation + decay system

### **Files Modified:**
1. **`project.godot`** - Registered TraceLevelManager autoload
2. **`autoload/DebugTools.gd`** - Added role guard (Hacker campaign only)
3. **`autoload/TraceLevelManager.gd`** - Added role guard + F10 debug display

---

## 🆕 New Features

### **1. Trace Accumulation**
```gdscript
# Automatically listens for offensive_action_performed
exploit WEB-SRV-01 → +15.0 trace
exploit IOT-DOOR-LOCK → +15.0 trace
```

### **2. Passive Decay**
```gdscript
# Decay rate: 1.0 trace per second
# Ticks every 0.5 seconds for smooth decay
# Pauses during minigames
```

### **3. Debug Display (F10)**
```gdscript
# Toggle real-time trace display
F10 → Enable/Disable
Shows: "🔍 TRACE: 15% (decay: 1.0/sec)"
```

### **4. Debug Keys (Hacker Campaign Only)**
| Key | Action |
|-----|--------|
| **F7** | Add 10 trace |
| **F8** | Reduce 10 trace |
| **F9** | Reset trace |
| **F10** | Toggle debug display |

### **5. Public API**
```gdscript
get_trace_level() → float       # 0.0-100.0
get_trace_normalized() → float  # 0.0-1.0 (for UI bars)
get_trace_percent() → int       # 0-100
add_trace(amount)               # Manual add
reduce_trace(amount)            # Manual reduce
reset_trace()                   # Reset to 0
pause_decay(pause)              # Pause/resume
```

### **6. Signals**
```gdscript
trace_level_changed(new_level: float)  # Emitted on change
trace_critical()                        # Emitted at 80%+
trace_maxed()                           # Emitted at 100%
```

---

## ✅ Success Criteria

- [x] **[BLOCKER]** Exploit increases Trace by 15.0
- [x] **[BLOCKER]** Trace decays by 1.0 per second when idle
- [x] Decay pauses during minigames
- [x] `get_trace_level()` returns correct value
- [x] Debug display shows current trace (F10)
- [x] Role guards prevent key conflicts (Analyst vs Hacker)

---

## 🧪 Test Instructions

### **Test 1: Trace Accumulation**
1. Press F4 → Hacker Room
2. Open computer
3. Type: `exploit WEB-SRV-01`
4. **Expected:** `🔍 TRACE: EXPLOIT on WEB-SRV-01 (SUCCESS) → +15.0 trace (0 → 15)`

### **Test 2: Trace Decay**
1. After exploit, press **F10** to enable display
2. Wait 15 seconds
3. **Expected:** Trace decays from 15% → 0%
   ```
   🔍 TRACE: 15% (decay: 1.0/sec)
   🔍 TRACE: 14% (decay: 1.0/sec)
   ...
   🔍 TRACE: 0% (decay: 1.0/sec)
   ```

### **Test 3: Debug Keys**
1. Press **F7** → Trace +10
2. Press **F8** → Trace -10
3. Press **F9** → Trace reset to 0
4. Press **F10** → Toggle display on/off

### **Test 4: Role Guards**
1. Start **Analyst Campaign**
2. Press F4, F7, F9 → Should NOT trigger Hacker debug
3. Start **Hacker Campaign**
4. Press F4, F7, F9 → Should work correctly

---

## 📊 Trace Costs (Phase 2)

| Action | Trace Cost | Notes |
|--------|------------|-------|
| **Exploit** | +15.0 | Standard hack |
| **Phish** | +10.0 | Phase 5 |
| **Ransomware** | +40.0 | Phase 4 (HIGH!) |
| **Backdoor** | +20.0 | Phase 4 |
| **Keylogger** | +5.0 | Phase 4 (stealthy) |
| **Scan** | +3.0 | Minimal trace |

**Decay Rate:** -1.0 per second

---

## 🎯 Gameplay Implications

### **Safe Zone (0-30%)**
- AI doesn't respond (Phase 3)
- Can operate freely
- Decay brings you back to safety quickly

### **Warning Zone (31-69%)**
- AI starts investigating (Phase 3)
- Risk of detection increases
- Should lay low or use countermeasures

### **Critical Zone (70-99%)**
- AI actively hunting (Phase 3)
- Lockdown imminent
- Need to exit network NOW

### **Max Trace (100%)**
- Instant lockdown (Phase 3)
- Connection lost
- Campaign failure state

---

## 🐛 Troubleshooting

### **Trace doesn't increase:**
- Check EventBus signal is connected
- Verify `offensive_action_performed` is emitted
- Check console for "TRACE:" messages

### **Trace doesn't decay:**
- Check decay timer is running (should start in `_ready()`)
- Verify not in minigame (decay pauses during minigames)
- Check `is_decay_active` is true

### **Debug keys don't work:**
- Verify in **Hacker Campaign** (role guard blocks Analyst)
- Check `debug_enabled` is true
- Verify TraceLevelManager is in autoload list

### **F10 display doesn't show:**
- Press F10 to toggle display on
- Check console for "DEBUG: F10 - Trace display ENABLED"
- Display shows every 60 frames (once per second)

---

## 📝 Code Quality Notes

### **What's Good:**
- ✅ Clean separation of concerns (accumulation vs. decay)
- ✅ Role guards prevent key conflicts
- ✅ Public API is well-documented
- ✅ Signals for UI integration (Phase 6)
- ✅ Minigame pause logic (Phase 2+)

### **What Could Be Better:**
- ⚠️ No persistence across sessions (Phase 5)
- ⚠️ No visual UI element (Phase 6)
- ⚠️ No sound effects for trace changes (Phase 6)

---

## 🚀 Integration Points

### **Phase 3 (Rival AI):**
```gdscript
# AI reads trace level and responds
if TraceLevelManager.get_trace_level() > 70.0:
    RivalAI.trigger_lockdown()
```

### **Phase 4 (Ransomware):**
```gdscript
# High trace cost for ransomware
EventBus.offensive_action_performed.emit({
    "action_type": "ransomware",
    "trace_cost": 40.0  # HIGH!
})
```

### **Phase 6 (Mirror Mode):**
```gdscript
# Trace timeline for report
var trace_timeline = TraceLevelManager.get_trace_history()
```

---

## ✅ TASK 2 STATUS: COMPLETE!

**Implementation:** 100%
**Tested:** ✅ Working
**Ready for:** Phase 3 (AI response)

🎉 **Trace system is LIVE!** Now hacking has consequences! 📈

---

## 🎮 SOLO DEV NOTES

**Time Spent:** ~45 minutes
**Lines Added:** ~200 (TraceLevelManager.gd)
**Key Insight:** Role guards are essential for clean debug key separation

**Next:** Task 3 - HackerHistory (forensic logging)
