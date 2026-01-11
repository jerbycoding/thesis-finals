# ticket_ransomware_01.gd
extends TicketResource

func _init():
	ticket_id = "RANSOM-001"
	title = "Ransomware Alert: Critical Server Locked!"
	description = "Our FINANCE-SRV-01 has been encrypted. Ransom demand received. Immediate action required: isolate infected server and check for spread."
	severity = "Critical"
	category = "Ransomware"
	steps = [
		"Use Terminal to check status of FINANCE-SRV-01",
		"Isolate FINANCE-SRV-01 from the network",
		"Report status to CISO"
	]
	required_tool = "terminal"
	base_time = 240.0
	hidden_risks = ["Isolating wrong server", "Ransom paid automatically"]
	required_log_ids = []
