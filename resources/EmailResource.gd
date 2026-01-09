# EmailResource.gd
extends Resource
class_name EmailResource

@export var email_id: String
@export var sender: String # "CEO", "IT Dept", "External", "Security Team"
@export var subject: String
@export_multiline var body: String
@export var attachments: Array[String] = [] # ".exe", ".pdf", ".zip", etc.
@export var headers: Dictionary = {} # SPF, DKIM, DMARC results
@export var is_malicious: bool = false
@export var is_urgent: bool = false
@export var clues: Array[String] = [] # "suspicious_link", "bad_attachment", "spoofed_sender", "suspicious_domain"
@export var related_ticket: String = "" # Optional ticket_id this email relates to
@export var suspicious_ip: String = "" # IP address found in headers (for cross-tool integration)
@export var suspicious_domain: String = "" # Domain from links (for cross-tool integration)

func _to_string() -> String:
	return "[Email: %s - %s]" % [email_id, subject]

func get_sender_color() -> Color:
	match sender:
		"CEO", "IT Dept", "Security Team":
			return Color(0.2, 0.8, 0.2)  # Green - Internal
		"External":
			return Color(1.0, 0.5, 0.0)  # Orange - External
		_:
			return Color.WHITE

func get_urgency_icon() -> String:
	if is_urgent:
		return "⚠️"
	return ""

func has_suspicious_attachment() -> bool:
	for attachment in attachments:
		# Extract extension from filename string
		var ext = ""
		var dot_index = attachment.rfind(".")
		if dot_index >= 0:
			ext = attachment.substr(dot_index).to_lower()
		if ext in [".exe", ".bat", ".scr", ".vbs", ".js"]:
			return true
	return false

func get_header_status() -> Dictionary:
	# Returns SPF, DKIM, DMARC status
	return headers.get("status", {
		"spf": "PASS",
		"dkim": "PASS",
		"dmarc": "PASS"
	})


