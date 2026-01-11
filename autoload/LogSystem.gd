# LogSystem.gd
# Autoload singleton that manages all security logs
extends Node

signal log_added(log: LogResource)
signal log_reviewed(log_id: String)

var all_logs: Array[LogResource] = []
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
]

func _ready():
	print("========================================")
	print("LogSystem initialized")
	print("========================================")
	
	# Wait a moment for other systems to initialize
	await get_tree().create_timer(0.5).timeout
	
	# Load initial logs for testing
	_load_initial_logs()

func _load_initial_logs():
	print("📋 Loading initial logs...")
	
	for log_res in log_library:
		if log_res:
			var log = log_res.duplicate()
			add_log(log)
			print("  ✓ Loaded log: ", log.log_id)
		else:
			print("  ❌ ERROR: Failed to load log resource from library")
	
	print("📋 Total logs loaded: ", all_logs.size())

func add_log(log: LogResource):
	if not log:
		print("❌ ERROR: Trying to add null log")
		return
	
	if not log.validate():
		push_error("LogSystem: Rejected invalid log: " + str(log.log_id))
		return
	
	# Check if already exists
	for existing_log in all_logs:
		if existing_log.log_id == log.log_id:
			print("⚠ Log already exists: ", log.log_id)
			return
	
	all_logs.append(log)
	log_added.emit(log)
	print("📋 Log added: ", log.log_id, " - ", log.message.substr(0, 40))

func get_all_logs() -> Array[LogResource]:
	return all_logs.duplicate()

func get_logs_by_category(category: String) -> Array[LogResource]:
	var filtered: Array[LogResource] = []
	for log in all_logs:
		if log.category == category:
			filtered.append(log)
	return filtered

func get_logs_by_severity(min_severity: int) -> Array[LogResource]:
	var filtered: Array[LogResource] = []
	for log in all_logs:
		if log.severity >= min_severity:
			filtered.append(log)
	return filtered

func get_logs_for_ticket(ticket_id: String) -> Array[LogResource]:
	var filtered: Array[LogResource] = []
	for log in all_logs:
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
