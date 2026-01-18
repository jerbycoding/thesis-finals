# LogSystem.gd
# Autoload singleton that manages all security logs
extends Node

var all_logs: Array[LogResource] = []
var active_logs: Array[LogResource] = [] # Only these are shown in the app
var reviewed_logs: Array[String] = []

const LOG_DIR = "res://resources/logs/"
const MAX_LOG_HISTORY = 150 # Performance safeguard

func _ready():
	print("========================================")
	print("LogSystem initialized")
	print("========================================")
	
	# Connect to EventBus for events
	_initialize_system.call_deferred()

func _initialize_system():
	EventBus.world_event_triggered.connect(_on_world_event)
	
	# Prepare the background library
	_prepare_library()
	
	# Show initial generic logs
	reveal_logs_for_ticket("")

func _on_world_event(event_id: String, active: bool, duration: float):
	if event_id == "FALSE_FLAG" and active:
		_start_false_flag_flood(duration)

func _start_false_flag_flood(duration: float):
	print("LogSystem: Starting FALSE_FLAG log flood...")
	var end_time = Time.get_ticks_msec() + (duration * 1000.0)
	
	while Time.get_ticks_msec() < end_time:
		_spawn_noise_log()
		await get_tree().create_timer(randf_range(0.5, 2.0)).timeout

func _spawn_noise_log():
	var hosts = ["SRV-PATCH-01", "DC-02", "MAIL-GATEWAY", "VPN-CON-01", "BACKUP-NAS", "WORKSTATION-12", "WORKSTATION-88"]
	var sources = ["System", "Kernel", "UpdateAgent", "AuditD", "WinRM"]
	var messages = [
		"Service 'UpdateAgent' reported status: OFFLINE (Scheduled Maintenance)",
		"User 'admin' logged in from 10.0.0.5 (Internal)",
		"File integrity check completed on /etc/hosts. No changes.",
		"Network interface eth0 received 1.2GB in last 60 minutes.",
		"Automatic system clock synchronization successful.",
		"DHCP lease renewed for client 10.0.4.55",
		"Print spooler service restarted automatically."
	]
	
	var log_res = LogResource.new()
	log_res.log_id = "NOISE-" + str(randi() % 9999)
	log_res.timestamp = Time.get_time_string_from_system()
	log_res.source = sources.pick_random()
	log_res.category = "System"
	log_res.severity = randi_range(1, 2) # Random Info/Low severity
	log_res.hostname = hosts.pick_random()
	log_res.message = messages.pick_random()
	
	add_log(log_res)

func _prepare_library():
	print("📋 LogSystem: Discovering logs in %s..." % LOG_DIR)
	all_logs.clear()
	
	var paths = FileUtil.get_resource_paths(LOG_DIR)
	for path in paths:
		var res = load(path)
		if res and res is LogResource:
			if not res.validate():
				print("  - ❌ LogSystem: Skipping malformed resource: %s" % path)
				continue
				
			all_logs.append(res)
			print("  - Discovered Log: ID=%s" % res.email_id if "email_id" in res else res.log_id)
		else:
			print("  - ❌ LogSystem: Skipping invalid resource: %s" % path)
			
	print("📋 LogSystem: Library ready: ", all_logs.size(), " logs")

func reveal_logs_for_ticket(ticket_id: String):
	print("📋 LogSystem: reveal_logs_for_ticket(%s)" % (ticket_id if not ticket_id.is_empty() else "GENERIC"))
	var count = 0
	for log in all_logs:
		var is_exact_match = log.related_ticket == ticket_id
		var is_generic_match = (ticket_id.contains("GENERIC") and log.related_ticket == "GENERIC")
		var log_is_orphaned = (log.related_ticket == "" or log.related_ticket == "NONE")
		
		if is_exact_match or is_generic_match or (ticket_id == "" and log_is_orphaned):
			if log not in active_logs:
				active_logs.append(log)
				EventBus.log_added.emit(log)
				count += 1
				print("  - Revealed Log: ID=%s | Msg=%s" % [log.log_id, log.message])
	
	if count > 0:
		print("📋 LogSystem: Revealed ", count, " new logs")

func add_log(log: LogResource):
	if not log: return
	
	# Enforcement of sliding window history (Ring Buffer behavior)
	if active_logs.size() >= MAX_LOG_HISTORY:
		_prune_oldest_non_essential_log()
		
	print("📋 LogSystem: Appending log ID=%s" % log.log_id)
	
	if log not in active_logs:
		active_logs.append(log)
		EventBus.log_added.emit(log)

func _prune_oldest_non_essential_log():
	# Optimization: We want to remove the oldest log that ISN'T evidence.
	# Evidence preservation is key.
	
	var target_index = -1
	
	# Priority 1: Oldest Noise log
	for i in range(active_logs.size()):
		if active_logs[i].log_id.begins_with("NOISE-"):
			target_index = i
			break
			
	# Priority 2: Oldest log with no ticket
	if target_index == -1:
		for i in range(active_logs.size()):
			if active_logs[i].related_ticket == "" or active_logs[i].related_ticket == "NONE":
				target_index = i
				break
				
	# Priority 3: Absolute oldest (forced ring buffer)
	if target_index == -1:
		target_index = 0
		
	var removed = active_logs[target_index]
	active_logs.remove_at(target_index)
	print("📋 LogSystem: Pruned log %s to free capacity." % removed.log_id)

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
	# Search all_logs first (the library)
	for log in all_logs:
		if log.log_id == log_id:
			return log
	# Then check active_logs
	for log in active_logs:
		if log.log_id == log_id:
			return log
	return null

func mark_log_reviewed(log_id: String):
	if log_id not in reviewed_logs:
		reviewed_logs.append(log_id)
		EventBus.log_reviewed.emit(log_id)
		print("📋 Log marked as reviewed: ", log_id)

func is_log_reviewed(log_id: String) -> bool:
	return log_id in reviewed_logs

func get_unreviewed_logs() -> Array[LogResource]:
	var filtered: Array[LogResource] = []
	for log in all_logs:
		if log.log_id not in reviewed_logs:
			filtered.append(log)
	return filtered