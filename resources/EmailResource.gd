# EmailResource.gd
extends Resource
class_name EmailResource

enum ThreatCategory { BENIGN, PHISHING, SPEAR_PHISH, MALWARE }

@export var email_id: String
@export var sender: String # "CEO", "IT Dept", "External", "Security Team"
@export var subject: String
@export_multiline var body: String
@export var attachments: Array[String] = [] # ".exe", ".pdf", ".zip", etc.
@export var headers: Dictionary = {} # SPF, DKIM, DMARC results
@export var is_malicious: bool = false
@export var is_urgent: bool = false
@export var threat_category: ThreatCategory = ThreatCategory.BENIGN
@export var clues: Array[String] = [] # "suspicious_link", "bad_attachment", "spoofed_sender", "suspicious_domain"
@export var related_ticket: String = "" # Optional ticket_id this email relates to
@export var is_focused: bool = false # NEW: If true, shows in the 'Focused' inbox tab
@export var suspicious_ip: String = "" # IP address found in headers (for cross-tool integration)
@export var suspicious_domain: String = "" # Domain from links (for cross-tool integration)

## Map of inspection tool name to consequence ID if tool was NOT used before quarantine.
## Valid keys: "headers", "attachments", "links"
@export var quarantine_hidden_risks: Dictionary = {}

var truth_packet: Dictionary = {} # Procedural data inherited from parent ticket

func _to_string() -> String:
	return "[Email: %s - %s]" % [email_id, subject]

func get_formatted_subject() -> String:
	if truth_packet.is_empty():
		return subject
	return subject.format(truth_packet)

func get_formatted_body() -> String:
	var text = body
	if not truth_packet.is_empty():
		text = body.format(truth_packet)
	
	# Tutorial Highlighting: Make the suspicious domain pop if we are in guided mode
	if GameState and GameState.is_guided_mode and not suspicious_domain.is_empty():
		var highlight = "[b][color=#00FFFF][pulse]%s[/pulse][/color][/b]" % suspicious_domain
		text = text.replace(suspicious_domain, highlight)
		
	return text

func get_sender_color() -> Color:
	var s = sender.to_lower()
	if "@corporate.com" in s or "ceo" in s or "it dept" in s or "security team" in s:
		return Color(0.2, 0.8, 0.2)  # Green - Internal
	return Color(1.0, 0.5, 0.0)  # Orange - External

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
	# Check for nested 'status' or just return the dict itself
	if headers.has("status"):
		return headers["status"]
	return headers

func validate() -> bool:
	if email_id.is_empty():
		return false
	if sender.is_empty():
		return false
	return true

# --- Risk Analysis Methods (Task 2: Resource-Driven Risk Logic) ---

func get_header_analysis() -> Dictionary:
	var status = get_header_status()
	var report = {
		"text": "[b]Email Headers Analysis:[/b]\n\n",
		"is_malicious": false
	}
	
	report.text += "SPF: %s\n" % status.get("spf", "UNKNOWN")
	report.text += "DKIM: %s\n" % status.get("dkim", "UNKNOWN")
	report.text += "DMARC: %s\n" % status.get("dmarc", "UNKNOWN")
	
	if status.get("spf") == "FAIL" or status.get("dkim") == "FAIL":
		report.text += "\n[color=red]⚠ WARNING: Email authentication failed![/color]"
		report.is_malicious = true
		
	return report

func get_attachment_analysis() -> Dictionary:
	var report = {
		"text": "[b]Attachment Scan Results:[/b]\n\n",
		"has_malware": false
	}
	
	if attachments.is_empty():
		report.text += "No attachments detected.\n"
		return report
		
	for attachment in attachments:
		var ext = attachment.get_extension().to_lower()
		if ext in ["exe", "bat", "scr", "vbs", "js"]:
			report.text += "[color=red]⚠ %s - CRITICAL: Executable payload detected![/color]\n" % attachment
			report.has_malware = true
		elif ext in ["pdf", "doc", "docx", "zip"]:
			report.text += "[b][bgcolor=yellow][color=black] ⚠ %s - Potential macro/container risk. [/color][/bgcolor][/b]\n" % attachment
		else:
			report.text += "✓ %s - Analysis clean.\n" % attachment
			
	return report

func get_link_analysis() -> Dictionary:
	var report = {
		"text": "[b]Link Analysis Results:[/b]\n\n",
		"is_suspicious": false
	}
	
	if not suspicious_domain.is_empty():
		report.text += "[color=red]⚠ Suspicious domain detected: %s[/color]\n" % suspicious_domain
		report.text += "Reputation: [color=red]BLACKLISTED[/color]\n"
		report.text += "Pattern: Known phishing landing page.\n"
		report.is_suspicious = true
	else:
		report.text += "No suspicious external links identified.\n"
		
	if not suspicious_ip.is_empty():
		report.text += "\n[b][bgcolor=yellow][color=black] Embedded IP: %s [/color][/bgcolor][/b]\n" % suspicious_ip
		report.text += "Action: Cross-reference with SIEM logs for lateral movement.\n"
		
	return report

func is_spear_phishing() -> bool:
	"""Returns true if this email exhibits characteristics of a targeted spear-phishing attack."""
	if threat_category == ThreatCategory.SPEAR_PHISH:
		return true
		
	# Fallback for older resources or procedural generation
	if "spear" in email_id.to_lower():
		return true
	
	if not related_ticket.is_empty() and "spear" in related_ticket.to_lower():
		return true
	
	# Spear phishing often spoofs executives
	if sender in ["CEO", "CFO", "CTO", "Executive"] and is_malicious:
		if clues.has("spoofed_sender") or clues.has("bad_attachment"):
			return true
	
	# Check subject for spear phishing patterns
	if "spear" in subject.to_lower() or "targeted" in subject.to_lower():
		return true
	
	return false
