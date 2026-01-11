# log_network_001.gd
extends LogResource

func _init():
	log_id = "LOG-NETWORK-001"
	timestamp = "15:24:58"
	source = "Network Monitor"
	category = "Network"
	message = "Unusual network activity pattern detected - multiple connections"
	severity = 4  # High
	ip_address = "203.0.113.42"
	related_ticket = "DATA-EXFIL-001"


