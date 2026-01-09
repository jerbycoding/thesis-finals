# LogResource.gd
extends Resource
class_name LogResource

@export var log_id: String
@export var timestamp: String # "HH:MM:SS" format
@export var source: String # "Firewall", "IDS", "Authentication", "System"
@export var category: String # "Security", "System", "Network"
@export_multiline var message: String # Max 60 chars recommended
@export var severity: int = 1 # 1-5 (1=Info, 2=Low, 3=Medium, 4=High, 5=Critical)
@export var related_ticket: String = "" # Optional ticket_id this log relates to
@export var ip_address: String = "" # Optional IP address mentioned in log
@export var hostname: String = "" # Optional hostname mentioned in log

func _to_string() -> String:
	return "[Log: %s - %s - %s]" % [timestamp, source, message.substr(0, 30)]

func get_severity_color() -> Color:
	match severity:
		1: return Color(0.5, 0.5, 0.5)  # Gray - Info
		2: return Color(0.2, 0.8, 0.2)  # Green - Low
		3: return Color(1.0, 0.8, 0.2)  # Yellow - Medium
		4: return Color(1.0, 0.5, 0.0) # Orange - High
		5: return Color(1.0, 0.2, 0.2) # Red - Critical
		_: return Color.WHITE

func get_severity_text() -> String:
	match severity:
		1: return "INFO"
		2: return "LOW"
		3: return "MEDIUM"
		4: return "HIGH"
		5: return "CRITICAL"
		_: return "UNKNOWN"


