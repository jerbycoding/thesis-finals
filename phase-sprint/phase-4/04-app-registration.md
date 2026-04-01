# TASK 4: APP REGISTRATION (HACKER PERMISSIONS)

## Description
[SOLO DEV SCOPE] Register Ransomware app in HackerAppProfile. Makes it visible in Hacker's desktop.

## Implementation Details

### A. AppConfigResource Creation
Create `resources/apps/ransomware.tres`:
```gdscript
app_id = "ransomware"
scene_path = "res://scenes/2d/apps/App_Ransomware.tscn"
title = "Ransomware"
default_size = Vector2(600, 400)
is_restricted = false
```

### B. HackerAppProfile Creation
Create `resources/permissions/HackerAppProfile.tres`:
```gdscript
profile_name = "Hacker Campaign"
allowed_apps = ["terminal", "siem", "email", "ransomware"]
```

### C. DesktopWindowManager Extension
```gdscript
func _ready():
    # Load role-appropriate profile
    if GameState.current_role == Role.HACKER:
        active_permission_profile = load("res://resources/permissions/HackerAppProfile.tres")
    else:
        active_permission_profile = load("res://resources/permissions/training_permissions.tres")
```

## Success Criteria
- [ ] **[BLOCKER]** Ransomware app appears in Hacker's start menu
- [ ] **[BLOCKER]** Ransomware app does NOT appear in Analyst's menu
- [ ] App opens when clicked

## OUT OF SCOPE
- ❌ LogPoisoner registration (cut from scope)
- ❌ PhishCrafter registration (cut from scope)
- ❌ Exfiltrator registration (cut from scope)
- ❌ Wiper registration (cut from scope)
