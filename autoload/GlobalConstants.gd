# GlobalConstants.gd
# Central authority for shared constants and Enums
extends Node

# --- Core Gameplay Identifiers ---

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
	"BLACK_TICKET": "black_ticket"
}

const RISK_TYPE = {
	"MALWARE": "malware",
	"DATA_BREACH": "data_breach",
	"PHISHING": "phishing",
	"MISCONFIG": "misconfiguration",
	"ATTACHMENT_SCAN_MISSED": "missed_attachment_scan"
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
	"ISOLATED": 3
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
	"EYE_HEIGHT":2.75,
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
	"GOSSIP_FLOOD": "GOSSIP_FLOOD"
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
