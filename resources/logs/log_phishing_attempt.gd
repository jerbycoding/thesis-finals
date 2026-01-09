# log_phishing_attempt.gd
extends LogResource

func _init():
	log_id = "LOG-PHISH-001"
	timestamp = "14:32:15"
	source = "Email Gateway"
	category = "Security"
	message = "Blocked phishing email from suspicious domain. User reported."
	severity = 3  # Medium
	related_ticket = "PHISH-001"
	ip_address = "192.168.1.100"


