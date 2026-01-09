# ticket_spear_phish.gd
extends TicketResource

func _init():
	ticket_id = "SPEAR-PHISH-001"
	title = "Spear Phishing Investigation"
	description = "CEO reports receiving suspicious email claiming to be from finance department. Email contains executable attachment. Investigate using Email Analyzer."
	severity = "High"
	category = "Phishing"
	steps = [
		"Inspect email headers for spoofing",
		"Scan attachment for malware",
		"Check sender domain reputation"
	]
	required_tool = "email"
	base_time = 300.0
	hidden_risks = ["missed_attachment_scan"]
	required_log_ids = []  # Email decisions don't require logs, but have consequences
