# log_auth_failure.gd
extends LogResource

func _init():
	log_id = "LOG-AUTH-003"
	timestamp = "14:15:33"
	source = "Authentication"
	category = "Security"
	message = "Multiple failed login attempts from 10.0.0.45"
	severity = 4  # High
	ip_address = "10.0.0.45"
	hostname = "workstation-12"


