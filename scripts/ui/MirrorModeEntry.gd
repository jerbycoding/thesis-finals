# MirrorModeEntry.gd
extends PanelContainer

@onready var time_label = %TimeLabel
@onready var action_label = %ActionLabel
@onready var detail_label = %DetailLabel
@onready var status_rect = %StatusRect

func set_hacker_action(data: Dictionary):
	var timestamp = data.get("timestamp", 0.0)
	var action = data.get("action_type", "unknown").to_upper()
	var target = data.get("target", "unknown")
	var result = data.get("result", "unknown")
	
	var minutes = int(timestamp) / 60
	var seconds = int(timestamp) % 60
	time_label.text = "[%02d:%02d]" % [minutes, seconds]
	
	action_label.text = action
	detail_label.text = "Target: %s | Result: %s" % [target, result]
	
	# Color coding
	match result:
		"SUCCESS": status_rect.color = Color(0, 1, 0, 0.5)
		"FAILED": status_rect.color = Color(1, 0, 0, 0.5)
		"HONEYPOT": status_rect.color = Color(1, 0.5, 0, 0.5)
		"ISOLATED": status_rect.color = Color(1, 0, 0, 1)
		_: status_rect.color = Color(0.5, 0.5, 0.5, 0.5)

func set_siem_log(log: LogResource):
	var timestamp = log.timestamp_seconds
	
	var minutes = int(timestamp) / 60
	var seconds = int(timestamp) % 60
	time_label.text = "[%02d:%02d]" % [minutes, seconds]
	
	action_label.text = log.source.to_upper()
	detail_label.text = log.message
	
	# Use severity color
	status_rect.color = log.get_severity_color()
	status_rect.color.a = 0.5
