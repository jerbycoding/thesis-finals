# ticket_social_eng_01.gd
extends TicketResource

func _init():
	ticket_id = "SOCIAL-001"
	title = "Social Engineering Attempt Reported"
	description = "A user reported a call from someone impersonating IT Support, asking for their password. Investigate if similar calls were made and alert users."
	severity = "Medium"
	category = "Social Engineering"
	steps = [
		"Check call logs for similar suspicious calls (SIEM)",
		"Draft a company-wide security alert (Email)",
		"Inform Corporate Voice to update security awareness"
	]
	required_tool = "none" # Multi-tool
	base_time = 180.0
	hidden_risks = ["Ignoring user report", "Misidentifying legitimate IT calls"]
	required_log_ids = []
