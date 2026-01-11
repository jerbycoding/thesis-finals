# log_exfil_001.gd
extends LogResource

func _init():
	log_id = "LOG-EXFIL-001"
	timestamp = "15:25:12"
	source = "Firewall"
	category = "Security"
	message = "Large outbound data transfer to external IP 203.0.113.42"
	severity = 5  # Critical
	ip_address = "203.0.113.42"
	related_ticket = "DATA-EXFIL-001"
