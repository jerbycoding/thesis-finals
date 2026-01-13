# LogSystem.gd
# Autoload singleton that manages all security logs
extends Node

signal log_added(log: LogResource)
signal log_reviewed(log_id: String)

var all_logs: Array[LogResource] = []
var active_logs: Array[LogResource] = [] # Only these are shown in the app
var reviewed_logs: Array[String] = []

# Log library - preloaded .tres resources
var log_library: Array[LogResource] = [
	preload("res://resources/logs/LogPhishingAttempt.tres"),
	preload("res://resources/logs/LogEmailBlocked.tres"),
	preload("res://resources/logs/LogAuthFailure.tres"),
	preload("res://resources/logs/LogSystemNormal.tres"),
	preload("res://resources/logs/LogNetworkScan.tres"),
	preload("res://resources/logs/LogMalwareBeacon.tres"),
	preload("res://resources/logs/LogUserClicked.tres"),
	preload("res://resources/logs/LogMalware001.tres"),
	preload("res://resources/logs/LogExfil001.tres"),
	preload("res://resources/logs/LogNetwork001.tres"),
	preload("res://resources/logs/LogInsiderAccess.tres"),
	preload("res://resources/logs/LogInsiderExfil.tres"),
	preload("res://resources/logs/LogRansomFileActivity.tres"),
]

func _ready():
	print("========================================")
	print("LogSystem initialized")
	print("========================================")
	
	# Wait a moment for other systems to initialize
	await get_tree().create_timer(0.5).timeout
	
	# Prepare the background library
	_prepare_library()
	
	# Show initial generic logs
	reveal_logs_for_ticket("")

func _prepare_library():
	print("📋 Preparing log library...")
	for log_res in log_library:
		if log_res:
			all_logs.append(log_res.duplicate())
	print("📋 Library ready: ", all_logs.size(), " logs")

func reveal_logs_for_ticket(ticket_id: String):
	print("📋 Revealing logs for ticket: ", ticket_id if not ticket_id.is_empty() else "GENERIC")
	var count = 0
	for log in all_logs:
		if log.related_ticket == ticket_id:
			if log not in active_logs:
				active_logs.append(log)
				log_added.emit(log)
				count += 1
	
	if count > 0:
		print("📋 Revealed ", count, " new logs for ", ticket_id)

func add_log(log: LogResource):
	if not log:
		return
	
	if log not in all_logs:
		all_logs.append(log)
	
	if log not in active_logs:
		active_logs.append(log)
		log_added.emit(log)

func get_all_logs() -> Array[LogResource]:
	return active_logs.duplicate()

func get_logs_by_category(category: String) -> Array[LogResource]:
	var filtered: Array[LogResource] = []
	for log in active_logs:
		if log.category == category:
			filtered.append(log)
	return filtered

func get_logs_by_severity(min_severity: int) -> Array[LogResource]:
	var filtered: Array[LogResource] = []
	for log in active_logs:
		if log.severity >= min_severity:
			filtered.append(log)
	return filtered

func get_logs_for_ticket(ticket_id: String) -> Array[LogResource]:
	var filtered: Array[LogResource] = []
	for log in active_logs:
		if log.related_ticket == ticket_id:
			filtered.append(log)
	return filtered

func get_log_by_id(log_id: String) -> LogResource:
	for log in all_logs:
		if log.log_id == log_id:
			return log
	return null

func mark_log_reviewed(log_id: String):
	if log_id not in reviewed_logs:
		reviewed_logs.append(log_id)
		log_reviewed.emit(log_id)
		print("📋 Log marked as reviewed: ", log_id)

func is_log_reviewed(log_id: String) -> bool:
	return log_id in reviewed_logs

func get_unreviewed_logs() -> Array[LogResource]:
	var filtered: Array[LogResource] = []
	for log in all_logs:
		if log.log_id not in reviewed_logs:
			filtered.append(log)
	return filtered
