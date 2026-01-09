# log_email_blocked.gd
extends LogResource

func _init():
	log_id = "LOG-EMAIL-002"
	timestamp = "14:28:42"
	source = "Firewall"
	category = "Security"
	message = "Blocked connection to malicious IP 192.168.1.100"
	severity = 4  # High
	related_ticket = "PHISH-001"
	ip_address = "192.168.1.100"
