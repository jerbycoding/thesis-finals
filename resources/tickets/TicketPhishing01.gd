# ticket_phishing_01.gd
extends TicketResource

func _init():
	ticket_id = "PHISH-001"
	title = "Phishing Campaign Alert"
	description = "Multiple users report suspicious emails with urgent financial requests. Check if this is a coordinated phishing campaign."
	severity = "Medium"
	category = "Phishing"
	steps = [
		"Check SIEM for phishing campaign alerts",
		"Review email headers for spoofing indicators",
		"Determine if any user clicked malicious link"
	]
	required_tool = "siem"
	base_time = 240.0
	hidden_risks = ["User already clicked link → malware installed"]
	required_log_ids = ["LOG-PHISH-001", "LOG-EMAIL-002"]  # Two logs required for compliant completion
