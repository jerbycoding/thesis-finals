# GlobalConstants.gd
# Central authority for shared constants and Enums
extends Node

# Event IDs for the NarrativeDirector and systems
const EVENTS = {
	"ZERO_DAY": "ZERO_DAY",
	"SIEM_LAG": "SIEM_LAG",
	"FALSE_FLAG": "FALSE_FLAG",
	"NPC_APPROACH": "BOSS_APPROACHING",
	"DDOS_ATTACK": "DDOS_ATTACK",
	"LATERAL_MOVEMENT": "LATERAL_MOVEMENT",
	"SERVER_LOCKDOWN": "SERVER_LOCKDOWN"
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