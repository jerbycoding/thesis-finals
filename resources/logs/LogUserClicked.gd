# log_user_clicked.gd
extends LogResource

func _init():
	log_id = "LOG-USER-007"
	timestamp = "14:30:10"
	source = "Email Gateway"
	category = "Security"
	message = "User clicked suspicious link in phishing email"
	severity = 4  # High
	related_ticket = "PHISH-001"
	hostname = "workstation-12"


