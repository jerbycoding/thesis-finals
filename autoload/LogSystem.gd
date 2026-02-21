# LogSystem.gd
# Autoload singleton that manages all security logs
extends Node

var all_logs: Array[LogResource] = []
var active_logs: Array[LogResource] = [] # Only these are shown in the app
var reviewed_logs: Array[String] = []
var noise_pool: NoiseLogPool = null

## Optional filter to restrict which logs can be revealed. 
## signature: func(log: LogResource, ticket_id: String) -> bool
var active_filter

const LOG_DIR = "res://resources/logs/"
const MAX_LOG_HISTORY = 150 # Performance safeguard

var siem_lag_multiplier: float = 1.0 # Affected by SIEM_LAG event

func _ready():
	print("========================================")
	print("LogSystem initialized")
	print("========================================")
	
	_load_noise_pool()
	# Connect to EventBus for events
	_initialize_system.call_deferred()

func _load_noise_pool():
	var path = "res://resources/NoiseLogPool.tres"
	if ResourceLoader.exists(path):
		noise_pool = load(path)
		print("LogSystem: Noise log pool loaded.")
	else:
		push_error("LogSystem: Could not find NoiseLogPool.tres at %s" % path)

func _initialize_system():
	EventBus.world_event_triggered.connect(_on_world_event)
	
	# Prepare the background library
	_prepare_library()
	
	# Show initial generic logs
	reveal_logs_for_ticket("")

func _on_world_event(event_id: String, active: bool, duration: float):
	if event_id == "FALSE_FLAG" and active:
		_start_false_flag_flood(duration)
	elif event_id == GlobalConstants.EVENTS.SIEM_LAG:
		siem_lag_multiplier = 5.0 if active else 1.0
		print("📋 LogSystem: SIEM_LAG event ", "ACTIVE" if active else "CLEARED")

func _start_false_flag_flood(duration: float):
	print("LogSystem: Starting FALSE_FLAG log flood...")
	var end_time = Time.get_ticks_msec() + (duration * 1000.0)
	
	while Time.get_ticks_msec() < end_time:
		_spawn_noise_log()
		await get_tree().create_timer(randf_range(0.5, 2.0)).timeout

func _spawn_noise_log():
	if not noise_pool:
		return
		
	var log_res = LogResource.new()
	log_res.log_id = "NOISE-" + str(randi() % 9999)
	log_res.timestamp = Time.get_time_string_from_system()
	log_res.source = noise_pool.sources.pick_random()
	log_res.category = "System"
	log_res.severity = randi_range(1, 2) # Random Info/Low severity
	log_res.hostname = noise_pool.hosts.pick_random()
	log_res.message = noise_pool.messages.pick_random()
	
	add_log(log_res)

func _prepare_library():
	print("📋 LogSystem: Discovering logs in %s..." % LOG_DIR)
	all_logs.clear()
	
	all_logs.assign(FileUtil.load_and_validate_resources(LOG_DIR, "LogResource"))
	for res in all_logs:
		print("  - Discovered Log: ID=%s" % res.log_id)
			
	print("📋 LogSystem: Library ready: ", all_logs.size(), " logs")

func reveal_logs_for_ticket(ticket_id: String):
	print("📋 LogSystem: reveal_logs_for_ticket(%s)" % (ticket_id if not ticket_id.is_empty() else "GENERIC"))
	
	var count = 0
	for log in all_logs:
		var should_reveal = false
		
		if active_filter != null:
			should_reveal = active_filter.call(log, ticket_id)
		else:
			var is_exact_match = not ticket_id.is_empty() and log.related_ticket == ticket_id
			var is_generic_log = log.related_ticket == "GENERIC"
			var log_is_orphaned = (log.related_ticket == "" or log.related_ticket == "NONE")
			
			if is_exact_match or is_generic_log or (ticket_id == "" and log_is_orphaned):
				should_reveal = true
		
		if should_reveal:
			if not _is_log_active(log.log_id):
				var instance = log.duplicate()
				active_logs.append(instance)
				EventBus.log_added.emit(instance)
				count += 1
				print("  - Revealed Log: ID=%s | Msg=%s" % [instance.log_id, instance.message])
	
	if count > 0:
		print("📋 LogSystem: Revealed ", count, " new logs")

func _is_log_active(id: String) -> bool:
	for l in active_logs:
		if l.log_id == id: return true
	return false

func clear_active_data():
	print("📋 LogSystem: Purging all active log data.")
	active_logs.clear()
	reviewed_logs.clear()
	# Ensure basic corporate noise returns after purge
	reveal_logs_for_ticket("") 

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
	# Search active_logs first (the live instances)
	for log in active_logs:
		if log.log_id == log_id:
			return log
	# Then check the library (the templates)
	for log in all_logs:
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
