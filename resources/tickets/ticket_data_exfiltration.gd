# ticket_data_exfiltration.gd
extends TicketResource

func _init():
	ticket_id = "DATA-EXFIL-001"
	title = "Data Exfiltration Alert"
	description = "Suspicious outbound traffic detected. Email contains external IP address. Cross-reference email and SIEM logs to identify data breach."
	severity = "Critical"
	category = "Data Breach"
	steps = [
		"Check email for suspicious IP address",
		"Search IP in SIEM logs",
		"Use Terminal to check host status if needed"
	]
	required_tool = "none"  # Multi-tool - can use any combination
	base_time = 360.0
	hidden_risks = ["Data already exfiltrated → breach confirmed"]
	required_log_ids = ["LOG-EXFIL-001", "LOG-NETWORK-001"]  # Multiple logs required
