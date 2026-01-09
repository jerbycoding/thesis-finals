# log_network_scan.gd
extends LogResource

func _init():
	log_id = "LOG-NET-005"
	timestamp = "14:50:11"
	source = "IDS"
	category = "Security"
	message = "Port scan detected from external IP 203.0.113.42"
	severity = 3  # Medium
	ip_address = "203.0.113.42"


