# log_system_normal.gd
extends LogResource

func _init():
	log_id = "LOG-SYS-004"
	timestamp = "13:45:20"
	source = "System"
	category = "System"
	message = "Scheduled backup completed successfully"
	severity = 1  # Info
	hostname = "backup-server-01"


