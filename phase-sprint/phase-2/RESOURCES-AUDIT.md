# RESOURCES AUDIT - PHASE 2 STATUS

## 📊 Folder Structure

```
resources/
├── apps/              ✅ 8 app configs (Analyst apps)
├── dialogue/          ✅ Dialogue resources
├── emails/            ✅ Email resources
├── handbook/          ✅ Handbook pages
├── hosts/             ⚠️ 23 hosts (5/23 configured for Phase 2)
├── logs/              ✅ Log resources
├── minigames/         ✅ Minigame configs
├── shifts/            ✅ Shift resources
├── tickets/           ✅ Ticket resources
├── *.gd               ✅ Resource scripts
└── *.tres             ✅ Various configs
```

---

## ✅ HOSTRESOURCE.GD STATUS

**File:** `resources/HostResource.gd`

**Phase 2 Fields:**
- ✅ `vulnerability_score` (0.0-1.0 slider)
- ✅ `is_honeypot` (checkbox)
- ✅ `get_vulnerability_percent()` helper
- ✅ `is_vulnerable()` helper
- ✅ Validation logic

**Status:** COMPLETE ✅

---

## 📊 HOSTS CONFIGURATION STATUS

### ✅ CONFIGURED HOSTS (5/23)

| File | Hostname | Vuln Score | Honeypot | Status |
|------|----------|------------|----------|--------|
| `WebServer.tres` | WEB-SRV-01 | 0.7 (70%) | ❌ | ✅ Ready |
| `HoneypotServer.tres` | RESEARCH-SRV-01 | 1.0 (100%) | ✅ | ✅ Ready |
| `DomainController01.tres` | DOMAIN-CTRL-01 | 0.2 (20%) | ❌ | ✅ Ready |
| `Workstation12.tres` | WORKSTATION-12 | 0.5 (50%) | ❌ | ✅ Ready |
| `IoT_DoorLock.tres` | IOT-DOOR-LOCK | 0.8 (80%) | ❌ | ✅ Ready |

### ⚠️ UNCONFIGURED HOSTS (18/23)

**These hosts need vulnerability_score added:**

#### Critical Infrastructure (Low: 0.1-0.3)
- [ ] `DatabaseServer.tres` → 0.3
- [ ] `FinanceServer.tres` → 0.2
- [ ] `LegacyPayroll.tres` → 0.3
- [ ] `MailGateway.tres` → 0.6
- [ ] `VPNGateway.tres` → 0.2
- [ ] `CFOMobile01.tres` → 0.5

#### Workstations (Medium: 0.4-0.6)
- [ ] `Workstation15.tres` → 0.5
- [ ] `Workstation22.tres` → 0.5
- [ ] `Workstation45.tres` → 0.5
- [ ] `Workstation55.tres` → 0.5
- [ ] `Workstation88.tres` → 0.5
- [ ] `WorkstationC.tres` → 0.5
- [ ] `WorkstationFinance09.tres` → 0.4
- [ ] `WorkstationMarketing02.tres` → 0.6

#### IoT Devices (High: 0.7-0.9)
- [ ] `IoT_Thermostat.tres` → 0.8
- [ ] `IoT_TV.tres` → 0.7

#### Special
- [ ] `FileServer01.tres` → 0.5
- [ ] `TutorialHost.tres` → 0.5

---

## 📝 APPS STATUS

### Current Apps (8 files)
```
apps/
├── decrypt.tres        ✅ Analyst app
├── email.tres          ✅ Analyst app
├── handbook.tres       ✅ Analyst app
├── network.tres        ✅ Analyst app
├── siem.tres           ✅ Analyst app
├── taskmanager.tres    ✅ Analyst app
├── terminal.tres       ✅ Analyst app
└── tickets.tres        ✅ Analyst app
```

### Phase 2: Need Hacker Apps
- [ ] Create `hacker_terminal.tres` (AppConfigResource)
- [ ] Create `exploit_tool.tres` (AppConfigResource)
- [ ] Register in `HackerAppProfile.tres` (doesn't exist yet)

**Status:** NOT STARTED ⚠️

---

## 🔧 APP PERMISSION PROFILES

**File:** `AppPermissionProfile.gd`

**Current Profiles:**
- `training_permissions.tres` - Tutorial profile

### Phase 2: Need
- [ ] Create `HackerAppProfile.tres` - Hacker-specific app permissions
- [ ] Link to hacker apps

**Status:** NOT STARTED ⚠️

---

## 📊 RESOURCE SCRIPTS STATUS

### Core Resources
| Script | Status | Phase 2 Usage |
|--------|--------|---------------|
| `HostResource.gd` | ✅ COMPLETE | Exploit targeting |
| `AppConfigResource.gd` | ✅ Exists | Hacker apps |
| `AppPermissionProfile.gd` | ✅ Exists | Hacker profile |
| `EmailResource.gd` | ✅ Exists | Phish crafting (Phase 5) |
| `ShiftResource.gd` | ✅ Exists | Shift tracking |
| `HandbookPage.gd` | ✅ Exists | Reference |

### Tutorial Resources
| Script | Status | Notes |
|--------|--------|-------|
| `TutorialSequenceResource.gd` | ✅ Exists | Tutorial system |
| `TutorialStepResource.gd` | ✅ Exists | Step definitions |
| `TutorialSequence.tres` | ✅ Exists | Tutorial data |

### Variable System
| Script | Status | Notes |
|--------|--------|-------|
| `VariablePool.gd` | ✅ Exists | Variable storage |
| `VariablePool.tres` | ✅ Exists | Pool instance |
| `NoiseLogPool.gd` | ✅ Exists | Log noise generation |
| `NoiseLogPool.tres` | ✅ Exists | Pool instance |

---

## 🎯 PHASE 2 COMPLETION CHECKLIST

### Host Resources
- [x] HostResource.gd extended with Phase 2 fields
- [x] 5 hosts configured with vulnerability scores
- [ ] 18 hosts need vulnerability scores (batch update needed)

### App Resources
- [ ] Create HackerAppProfile.tres
- [ ] Create hacker app configs (terminal, exploit tools)
- [ ] Register apps in profile

### Integration
- [x] TerminalSystem reads vulnerability_score
- [x] NetworkState loads hosts correctly
- [ ] Hacker apps accessible in Hacker campaign

---

## 🚀 PRIORITY TASKS

### HIGH PRIORITY (Blocks Testing)
1. **Update remaining 18 hosts** with vulnerability scores
   - Can be done in batch (copy/paste template)
   - Takes ~10 minutes

### MEDIUM PRIORITY (Blocks Phase 2 Completion)
2. **Create HackerAppProfile.tres**
   - Defines which apps Hacker can access
   - Different from Analyst apps

3. **Create hacker app configs**
   - hacker_terminal.tres
   - exploit_tool.tres (if separate app)

### LOW PRIORITY (Polish)
4. **Update host descriptions**
   - Add lore to host resources
   - Flavor text for immersion

---

## 📋 BATCH UPDATE TEMPLATE

**For each unconfigured host, add:**
```
# === PHASE 2: HACKER CAMPAIGN ===
vulnerability_score = 0.5  # Adjust per host
is_honeypot = false
```

**Quick reference:**
- Critical systems: 0.2-0.3
- Servers: 0.5-0.6
- Workstations: 0.5
- IoT: 0.7-0.8
- Tutorial: 0.5

---

## ✅ SUMMARY

**What's Done:**
- ✅ HostResource.gd extended
- ✅ 5 critical hosts configured
- ✅ Exploit command uses vulnerability_score
- ✅ List command shows vulnerability (Hacker mode)

**What's Missing:**
- ⚠️ 18 hosts need scores (easy batch update)
- ⚠️ Hacker app profile (needed for Phase 2 apps)
- ⚠️ Hacker app configs (if adding new apps)

**Blocker Status:**
- 🔴 **NO BLOCKERS** - Phase 2 is playable with current 5 hosts!
- 🟡 Remaining hosts are polish/enhancement

---

**Recommendation:** Update the 18 remaining hosts now (10 min batch job), then continue with Phase 2!
