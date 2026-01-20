# GlobalConstants.gd
# Central authority for shared constants and Enums
extends Node

# --- Core Gameplay Identifiers ---

const COMPLETION_TYPE = {
	COMPLIANT: "compliant",
	EFFICIENT: "efficient",
	EMERGENCY: "emergency",
	TIMEOUT: "timeout"
}

const NPC_ID = {
	CISO: "ciso",
	SENIOR_ANALYST: "senior_analyst",
	IT_SUPPORT: "it_support"
}

const CONSEQUENCE_ID = {
	# From ConsequenceEngine
	MAJOR_BREACH: "MAJOR-BREACH-FOLLOWUP",
	INCIDENT_ESCALATION: "INCIDENT-ESCALATION-FOLLOWUP",
	USER_COMPLAINT: "USER-COMPLAINT-FOLLOWUP",
	SERVICE_OUTAGE: "SERVICE-OUTAGE-FOLLOWUP",
	MALWARE_CLEANUP: "MALWARE-CLEANUP-FOLLOWUP",
	DATA_BREACH: "DATA-BREACH-CRITICAL",
	
	# From NarrativeDirector
	MISSED_ATTACHMENT_SCAN: "missed_attachment_scan",
	
	# Generic
	DATA_LOSS: "data_loss",
	ESCALATION: "escalation",
	BLACK_TICKET: "black_ticket"
}

const RISK_TYPE = {
	MALWARE: "malware",
	DATA_BREACH: "data_breach",
	PHISHING: "phishing",
	MISCONFIG: "misconfiguration",
	ATTACHMENT_SCAN_MISSED: "missed_attachment_scan"
}

const EMAIL_DECISION = {
	APPROVE: "approve",
	QUARANTINE: "quarantine",
	ESCALATE: "escalate"
}

const ARCHETYPE = {
	NEGLIGENT: "Negligent",
	BY_THE_BOOK: "By-the-Book",
	COWBOY: "Cowboy",
	PRAGMATIC: "Pragmatic"
}

# --- Narrative & Event Identifiers ---

const NARRATIVE_EVENT_TYPE = {
	NPC_INTERACTION: "npc_interaction",
	SPAWN_TICKET: "spawn_ticket",
	SPAWN_CONSEQUENCE: "spawn_consequence",
	SYSTEM_EVENT: "system_event",
	SHIFT_END: "shift_end"
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
	"CRYPTO_SPIKE": "CRYPTO_SPIKE"
}

# Standardized Severity Levels
enum Severity {
	LOW = 1,
	MEDIUM = 2,
	HIGH = 3,
	CRITICAL = 4
}

# String to Enum conversion helper
static func get_severity_from_string(sev_str: String) -> int:
	match sev_str.to_lower():
		"low": return Severity.LOW
		"medium": return Severity.MEDIUM
		"high": return Severity.HIGH
		"critical": return Severity.CRITICAL
		_: return Severity.LOW