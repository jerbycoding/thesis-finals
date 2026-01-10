# ticket_insider_threat_01.gd
extends TicketResource

func _init():
	ticket_id = "INSIDER-001"
	title = "Suspicious Data Access: Ex-Employee"
	description = "Former employee, 'Jane Doe', accessed sensitive project files an hour after her termination. Investigate her workstation logs for suspicious activity."
	severity = "High"
	category = "Insider Threat"
	steps = [
		"Search SIEM logs for 'Jane Doe' activity on her workstation (WORKSTATION-52)",
		"Identify unusual file access or outbound connections",
		"Report findings to Senior Analyst"
	]
	required_tool = "siem"
	base_time = 300.0
	hidden_risks = ["Dismissing legitimate access", "Alerting insider before evidence collected"]
	required_log_ids = ["LOG-JANE-DOE-ACCESS", "LOG-EXFIL-JANE-DOE"]
