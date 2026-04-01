# Phase 1 Task 4: GlobalConstants - COMPLETE! ✅

## 📋 What Was Added

### **Files Modified:**
- **`autoload/GlobalConstants.gd`** - Added Hacker-specific constants

---

## 🆕 New Constants Added

### **1. Role System**
```gdscript
const ROLE = {
    "ANALYST": "analyst",
    "HACKER": "hacker"
}
```

### **2. Hacker App IDs (Phase 2+)**
```gdscript
const HACKER_APP = {
    "EXPLOIT": "hacker_exploit",
    "SCANNER": "hacker_scanner", 
    "RANSOMWARE": "hacker_ransomware",
    "BACKDOOR": "hacker_backdoor",
    "KEYLOGGER": "hacker_keylogger"
}
```

### **3. Hacker Permission Levels**
```gdscript
const HACKER_PERMISSION = {
    "USER": 0,
    "ADMIN": 1,
    "ROOT": 2,
    "SYSTEM": 3
}
```

### **4. Hacker Foothold States**
```gdscript
const HACKER_FOOTHOLD = {
    "NONE": "none",
    "INITIAL": "initial",
    "PERSISTENT": "persistent",
    "COMPROMISED": "compromised"
}
```

### **5. Scene Paths**
```gdscript
const SCENES = {
    ...
    "HACKER_ROOM": "res://scenes/3d/HackerRoom.tscn"
}
```

### **6. Hacker Theme Colors**
```gdscript
const HACKER_COLORS = {
    "PRIMARY": Color(0, 1, 0, 1),        # Pure green (terminal)
    "BRIGHT": Color(0.2, 1, 0.2, 1),     # Bright green (highlights)
    "DIM": Color(0, 0.5, 0, 1),          # Dim green (background)
    "ALERT": Color(1, 0, 0, 1),          # Red (alerts)
    "WARNING": Color(1, 0.8, 0, 1),      # Yellow (caution)
    "BG_DARK": Color(0, 0.05, 0, 1)      # Near-black with green tint
}
```

### **7. Hacker Consequence IDs**
```gdscript
const CONSEQUENCE_ID = {
    ...
    "HACKER_DETECTED": "hacker_detected",
    "HACKER_SUCCESS": "hacker_success",
    "RANSOMWARE_DEPLOYED": "ransomware_deployed",
    "FOOTHOLD_LOST": "foothold_lost",
    "EXPLOIT_FAILED": "exploit_failed"
}
```

### **8. Hacker Risk Types**
```gdscript
const RISK_TYPE = {
    ...
    "HACKER_INTRUSION": "hacker_intrusion",
    "EXPLOIT_DETECTED": "exploit_detected",
    "RANSOMWARE_ATTACK": "ransomware_attack"
}
```

### **9. Hacker Events**
```gdscript
const EVENTS = {
    ...
    "HACKER_SCAN": "HACKER_SCAN",
    "HACKER_EXPLOIT": "HACKER_EXPLOIT",
    "HACKER_RANSOMWARE": "HACKER_RANSOMWARE",
    "HACKER_FOOTPRINT": "HACKER_FOOTPRINT"
}
```

---

## 🧪 How to Use (Examples)

### **Accessing Hacker Colors:**
```gdscript
# In any script
$Label.modulate = GlobalConstants.HACKER_COLORS.PRIMARY
```

### **Checking Role:**
```gdscript
if GlobalConstants.ROLE.HACKER == "hacker":
    # Hacker-specific logic
```

### **Using Hacker App IDs:**
```gdscript
# Phase 2: When creating exploit app
var app = AppRegistry.get_app(GlobalConstants.HACKER_APP.EXPLOIT)
```

### **Scene Loading:**
```gdscript
get_tree().change_scene_to_file(GlobalConstants.SCENES.HACKER_ROOM)
```

---

## ✅ Benefits

- [x] **No more magic strings** - Using constants instead of hardcoded "hacker" strings
- [x] **Autocomplete support** - Godot will suggest `HACKER_APP.` etc.
- [x] **Refactoring safety** - Change once in GlobalConstants, updates everywhere
- [x] **Documentation** - Constants serve as official reference
- [x] **Phase 2 ready** - All IDs needed for Exploit Command implemented

---

## 🐛 Troubleshooting

**If constants don't appear in autocomplete:**
- Restart Godot Editor
- Check that GlobalConstants.gd is in autoload list

**If you get "Identifier not found" errors:**
- Make sure you're using `GlobalConstants.` prefix
- Example: `GlobalConstants.HACKER_COLORS.PRIMARY`

---

## Next Steps

**Task 5: Debug Tools** - Add F1 shortcut to jump to HackerRoom for faster testing!

---

## 📝 Notes for Future Phases

- **Phase 2**: Use `HACKER_APP` constants when registering apps
- **Phase 3**: Use `HACKER_PERMISSION` for access control
- **Phase 4**: Use `HACKER_FOOTHOLD` for tracking compromised hosts
- **Phase 5**: Use `HACKER_COLORS` for UI theming
- **Phase 6**: Use `EVENTS.HACKER_*` for narrative triggers
