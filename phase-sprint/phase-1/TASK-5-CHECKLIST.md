# Phase 1 Task 5: Debug Tools - COMPLETE! ✅

## 📋 What Was Created

### **Files Created:**
- **`autoload/DebugTools.gd`** - Debug utilities autoload singleton

### **Files Modified:**
- **`project.godot`** - Registered DebugTools autoload

---

## 🎮 Debug Controls

| Key | Action | Description |
|-----|--------|-------------|
| **F3** | Print State | Print current role and game state to console |
| **F4** | Jump to Hacker Room | Instant teleport to HackerRoom.tscn |
| **F5** | Jump to Analyst Room | Instant teleport to WorkstationRoom.tscn |
| **F6** | Toggle Debug | Enable/disable debug output |

**⚠️ Note:** F1/F2 are reserved by DebugManager.gd for shift navigation!

---

## 🔧 Features

### **1. Instant Room Switching**
- No transition animations (for speed)
- Automatically sets correct role (Hacker/Analyst)
- Cleans up desktop mode if active
- Sets `is_campaign_session = true`

### **2. Debug Output**
- Console prints for all debug actions
- Shows role, scene path, and state changes
- Can be toggled on/off with F6

### **3. Utility Functions**

```gdscript
# Print current game state
DebugTools.print_role_info()

# Conditional logging
DebugTools.log("Something happened", "CUSTOM")
```

---

## 🧪 How to Use

### **Quick Testing Workflow:**

1. **Start game once** (to initialize autoloads)
2. **Press F4** → Jump to Hacker Room
   - Test hacker campaign
   - Interact with computer
   - Test apps
3. **Press F5** → Jump to Analyst Room
   - Test analyst campaign
   - Compare experiences
4. **Press F3** → Print state to console
   - See current role, mode, campaign status
5. **Repeat** - No more menu navigation!

### **In Your Code:**

```gdscript
# Log debug info (respects toggle)
DebugTools.log("Exploit started", "HACKER")

# Print full state
DebugTools.print_role_info()
```

---

## ✅ Success Criteria

- [x] F3 prints game state to console
- [x] F4 jumps to HackerRoom
- [x] F5 jumps to WorkstationRoom
- [x] Role is set correctly after jump
- [x] Console shows debug messages
- [x] F6 toggles debug output
- [x] No errors in console
- [x] Works from any scene
- [x] **Doesn't conflict with DebugManager.gd**

---

## 🐛 Troubleshooting

**If F3-F6 don't work:**
- Check that DebugTools is in autoload list
- Verify Godot reloaded after adding autoload
- Check console for "DebugTools initialized" message
- Make sure DebugManager.gd isn't consuming the keys first

**If scene doesn't load:**
- Verify scene paths in GlobalConstants.SCENES
- Check that scenes exist at those paths

**If role doesn't change:**
- DebugTools sets `current_role` directly (bypasses switch_role())
- This is intentional for speed (no transition effects)

---

## 🎯 Testing Workflow

### **Before DebugTools:**
1. Run game
2. Navigate menu
3. Select campaign
4. Wait for login sequence
5. Walk to computer
6. **TEST**

### **After DebugTools:**
1. Run game (once)
2. **Press F4**
3. **TEST**

**Time saved: ~30 seconds per test iteration!** 🚀

---

## 📝 Notes

- DebugTools is **always active** (not stripped in release)
- Can be disabled with F6 but not removed
- For production build, consider conditional compilation
- `debug_enabled` variable controls all output
- **Doesn't conflict with DebugManager.gd** (uses F3-F6 instead of F1-F2)

---

## 🎉 PHASE 1 COMPLETE!

All 5 tasks done! You now have:
- ✅ Role switching system
- ✅ Hacker Room environment
- ✅ Themed login sequences
- ✅ GlobalConstants for Hacker campaign
- ✅ Debug tools for rapid testing

**Ready for Phase 2: Exploit Command!** 🔓
