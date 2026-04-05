# GlobalConstants.gd
# Central authority for shared constants and Enums
extends Node

# --- Core Gameplay Identifiers ---

# === SOLO DEV PHASE 1: ROLE SYSTEM ===
const ROLE = {
	"ANALYST": "analyst",
	"HACKER": "hacker"
}

# Hacker Campaign App IDs (Phase 2+)
const HACKER_APP = {
	"EXPLOIT": "hacker_exploit",
	"SCANNER": "hacker_scanner", 
	"RANSOMWARE": "hacker_ransomware",
	"BACKDOOR": "hacker_backdoor",
	"KEYLOGGER": "hacker_keylogger"
}

# Hacker Permission Levels
const HACKER_PERMISSION = {
	"USER": 0,
	"ADMIN": 1,
	"ROOT": 2,
	"SYSTEM": 3
}

# Hacker Foothold States
const HACKER_FOOTHOLD = {
	"NONE": "none",
	"INITIAL": "initial",
	"PERSISTENT": "persistent",
	"COMPROMISED": "compromised"
}
# =====================================

const COMPLETION_TYPE = {
	"COMPLIANT": "compliant",
	"EFFICIENT": "efficient",
	"EMERGENCY": "emergency",
	"TIMEOUT": "timeout"
}

const NPC_ID = {
	"CISO": "ciso",
	"SENIOR_ANALYST": "senior_analyst",
	"IT_SUPPORT": "it_support",
	"NETWORK_SPECIALIST": "network_specialist",
	"VAULT_TECHNICIAN": "vault_technician",
	"JUNIOR_ANALYST": "junior_analyst"
}

const CONSEQUENCE_ID = {
	# From ConsequenceEngine
	"MAJOR_BREACH": "MAJOR-BREACH-FOLLOWUP",
	"INCIDENT_ESCALATION": "INCIDENT-ESCALATION-FOLLOWUP",
	"USER_COMPLAINT": "USER-COMPLAINT-FOLLOWUP",
	"SERVICE_OUTAGE": "SERVICE-OUTAGE-FOLLOWUP",
	"MALWARE_CLEANUP": "MALWARE-CLEANUP-FOLLOWUP",
	"DATA_BREACH": "DATA-BREACH-CRITICAL",
	"PROCEDURAL_VIOLATION": "PROCEDURAL-VIOLATION-FOLLOWUP",

	# From NarrativeDirector
	"MISSED_ATTACHMENT_SCAN": "missed_attachment_scan",

	# Generic
	"DATA_LOSS": "data_loss",
	"ESCALATION": "escalation",
	"BLACK_TICKET": "black_ticket",

	# === SOLO DEV PHASE 1: HACKER CAMPAIGN ===
	"HACKER_DETECTED": "hacker_detected",
	"HACKER_SUCCESS": "hacker_success",
	"RANSOMWARE_DEPLOYED": "ransomware_deployed",
	"FOOTHOLD_LOST": "foothold_lost",
	"EXPLOIT_FAILED": "exploit_failed"
}

const RISK_TYPE = {
	"MALWARE": "malware",
	"DATA_BREACH": "data_breach",
	"PHISHING": "phishing",
	"MISCONFIG": "misconfiguration",
	"ATTACHMENT_SCAN_MISSED": "missed_attachment_scan",
	# === SOLO DEV PHASE 1: HACKER CAMPAIGN ===
	"HACKER_INTRUSION": "hacker_intrusion",
	"EXPLOIT_DETECTED": "exploit_detected",
	"RANSOMWARE_ATTACK": "ransomware_attack"
}

const EMAIL_DECISION = {
	"APPROVE": "approve",
	"QUARANTINE": "quarantine",
	"ESCALATE": "escalate"
}

const ARCHETYPE = {
	"NEGLIGENT": "Negligent",
	"BY_THE_BOOK": "By-the-Book",
	"COWBOY": "Cowboy",
	"PRAGMATIC": "Pragmatic"
}

const TICKET_CATEGORY = {
	"PHISHING": "Phishing",
	"MALWARE": "Malware",
	"UNAUTHORIZED_ACCESS": "Unauthorized Access",
	"RANSOMWARE": "Ransomware",
	"DDoS": "DDoS",
	"DATA_BREACH": "Data Breach",
	"SYSTEM": "System",
	"AUTHENTICATION": "Authentication",
	"FORENSICS": "Forensics",
	"SOCIAL_ENGINEERING": "Social Engineering",
	"MAINTENANCE": "Maintenance",
	"GENERAL": "General"
}

const HOST_STATUS = {
	"CLEAN": 0,
	"SUSPICIOUS": 1,
	"INFECTED": 2,
	"ISOLATED": 3,
	"RANSOMED": 4
}

# --- Scene Paths ---
const SCENES = {
	"SOC": "res://scenes/3d/WorkstationRoom.tscn",
	"VAULT": "res://scenes/3d/ServerVault.tscn",
	"HUB": "res://scenes/3d/NetworkHub.tscn",
	"BRIEFING": "res://scenes/3d/BriefingRoom.tscn",
	"TITLE": "res://scenes/ui/TitleScreen.tscn",
	"MAIN_MENU": "res://scenes/3d/MainMenu3D.tscn",
	# === SOLO DEV PHASE 1: HACKER CAMPAIGN ===
	"HACKER_ROOM": "res://scenes/3d/HackerRoom.tscn"
}

# --- Physical World & Interaction ---
const PHYSICS_LAYERS = {
	"DEFAULT": 1,
	"WORLD": 2,
	"PLAYER": 3,
	"INTERACTABLE": 4,
	"NPC": 5,
	"MONITOR": 20
}

# --- Player Physics & Animation ---
const PLAYER = {
	"EYE_HEIGHT":2.15,
	"SEATED_HEIGHT": 1.35,
	"CAMERA_OFFSET_Z": -0.23,
	"BOB_FREQ": 2.0,
	"BOB_AMP": 0.04,
	"FOOTSTEP_INTERVAL": 0.5,
	"CARRY_SPEED_PENALTY": 0.75,
	"LOOK_LIMIT_X": 1.5,
	"FLOOR_RAYCAST_DIST": 2.0
}

# --- Organizational Integrity Balance ---
const INTEGRITY = {
	"DELTA_COMPLIANT": 5.0,
	"DELTA_EFFICIENT": -2.0,
	"DELTA_EMERGENCY": -5.0,
	"DELTA_TIMEOUT": -10.0,
	"DELTA_BREACH": -40.0,
	"DELTA_VIOLATION": -15.0,
	"THRESHOLD_CRITICAL": 0.0,
	"THRESHOLD_WARNING": 20.0,
	"BASE_DECAY_PER_HOUR": 1.0
}

# --- Visual Foundation Palette (Enterprise-Clean) ---

enum DIFFICULTY { JUNIOR, ANALYST, LEAD }

const DIFFICULTY_DATA = {
	DIFFICULTY.JUNIOR: {
		"label": "ANALYST",
		"time_mult": 1.0,
		"damage_mult": 1.0,
		"chaos_interval": 45.0,
		"description": "STANDARD PROTOCOL :: BALANCED OPERATIONAL RIGOR"
	},
	DIFFICULTY.ANALYST: {
		"label": "LEAD",
		"time_mult": 0.7,
		"damage_mult": 1.5,
		"chaos_interval": 25.0,
		"description": "ZERO TOLERANCE :: HIGH-STRESS SIMULATION"
	},
	DIFFICULTY.LEAD: {
		"label": "CHIEF ANALYST",
		"time_mult": 0.5,
		"damage_mult": 2.0,
		"chaos_interval": 15.0,
		"description": "CRITICAL ENGAGEMENT :: MAXIMUM THREAT ENVIRONMENT"
	}
}

const UI_COLORS = {
	"PAGE_BG": Color("#FDFDFD"),      # Off-white background
	"DARK_BG": Color("#0E1117"),      # Deep charcoal for dark dashboards
	"HEADER_BLACK": Color("#000000"), # Absolute black for headers/primary buttons
	"INFO_BLUE": Color("#006CFF"),    # Modern information blue
	"TEXT_PRIMARY": Color("#1A1A1A"), # Near-black for readability
	"TEXT_SECONDARY": Color("#666666"),# Gray for metadata
	"SUCCESS_FLAT": Color("#2E7D32"), # Forest green (No glow)
	"ERROR_FLAT": Color("#C62828"),   # Crimson red (No glow)
	"WARNING_FLAT": Color("#F57C00"), # Sharp orange (No glow)
	"GRID_LINE": Color("#EEEEEE")     # Subtle grid lines
}

# === SOLO DEV PHASE 1: HACKER THEME COLORS ===
const HACKER_COLORS = {
	"PRIMARY": Color(0, 1, 0, 1),        # Pure green (terminal)
	"BRIGHT": Color(0.2, 1, 0.2, 1),     # Bright green (highlights)
	"DIM": Color(0, 0.5, 0, 1),          # Dim green (background elements)
	"ALERT": Color(1, 0, 0, 1),          # Red (alerts/warnings)
	"WARNING": Color(1, 0.8, 0, 1),      # Yellow (caution)
	"BG_DARK": Color(0, 0.05, 0, 1)      # Near-black with green tint
}

# === PHASE 2 PREP: TRACE COSTS ===
# Trace level increases when hacker performs actions
const TRACE_COST = {
	"EXPLOIT": 15.0,      # Running exploit against host
	"PIVOT": 5.0,         # Lateral movement (low trace, evasion tool)
	"PHISH": 10.0,        # Sending phishing email
	"RANSOMWARE": 40.0,   # Deploying ransomware (HIGH!)
	"BACKDOOR": 20.0,     # Installing persistent backdoor
	"KEYLOGGER": 5.0,     # Installing keylogger (low profile)
	"SCAN": 3.0,          # Network scan (minimal trace)
	"DECAY_RATE": 1.0     # Trace decay per second
}

# === PHASE 3 PREP: RIVAL AI THRESHOLDS ===
const RIVAL_AI = {
	"SEARCHING_THRESHOLD": 30.0,    # Trace level where AI starts searching
	"LOCKDOWN_THRESHOLD": 70.0,     # Trace level where AI initiates lockdown
	"BASE_ISOLATION_SECONDS": 20.0, # Base time to isolate hacker
	"DETECT_SCAN_CHANCE": 0.1,      # Chance to detect network scan
	"DETECT_EXPLOIT_CHANCE": 0.3,   # Chance to detect exploit attempt
	"DETECT_RANSOMWARE_CHANCE": 0.9 # Ransomware is almost always detected
}
# ================================================

# --- Narrative & Event Identifiers ---

const NARRATIVE_EVENT_TYPE = {
	"NPC_INTERACTION": "npc_interaction",
	"SPAWN_TICKET": "spawn_ticket",
	"SPAWN_CONSEQUENCE": "spawn_consequence",
	"SYSTEM_EVENT": "system_event",
	"SHIFT_END": "shift_end"
}

# Event IDs for the NarrativeDirector and systems
const EVENTS = {
	"ZERO_DAY": "ZERO_DAY",
	"SIEM_LAG": "SIEM_LAG",
	"FALSE_FLAG": "FALSE_FLAG",
	"NPC_APPROACH": "BOSS_APPROACHING",
	"DDOS_ATTACK": "DDOS_ATTACK",
	"LATERAL_MOVEMENT": "LATERAL_MOVEMENT",
	"SERVER_LOCKDOWN": "SERVER_LOCKDOWN",
	"CRYPTO_SPIKE": "CRYPTO_SPIKE",
	"ISP_THROTTLING": "ISP_THROTTLING",
	"POWER_FLICKER": "POWER_FLICKER",
	"GOSSIP_FLOOD": "GOSSIP_FLOOD",
	# === SOLO DEV PHASE 1: HACKER CAMPAIGN ===
	"HACKER_SCAN": "HACKER_SCAN",
	"HACKER_EXPLOIT": "HACKER_EXPLOIT",
	"HACKER_RANSOMWARE": "HACKER_RANSOMWARE",
	"HACKER_FOOTPRINT": "HACKER_FOOTPRINT"
}

# Standardized Severity Levels
enum Severity {
	LOW = 1,
	MEDIUM = 2,
	HIGH = 3,
	CRITICAL = 4
}

const RELATIONSHIP_RANK = {
	"HATED": "Hated",
	"DISTRUSTED": "Distrusted",
	"NEUTRAL": "Neutral",
	"RESPECTED": "Respected",
	"ADMIRED": "Admired"
}

const RELATIONSHIP_THRESHOLD = {
	"ADMIRED": 1.5,
	"RESPECTED": 0.5,
	"NEUTRAL": -0.5,
	"DISTRUSTED": -1.5,
	"HATED": -2.5
}

# String to Enum conversion helper
static func get_severity_from_string(sev_str: String) -> int:
	match sev_str.to_lower():
		"low": return Severity.LOW
		"medium": return Severity.MEDIUM
		"high": return Severity.HIGH
		"critical": return Severity.CRITICAL
		_: return Severity.LOW
