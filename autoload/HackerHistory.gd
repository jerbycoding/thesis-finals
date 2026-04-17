# HackerHistory.gd
# Autoload singleton that records every offensive action to disk
# This is the forensic log for Phase 6 Mirror Mode report
extends Node

signal history_updated(entry_count: int)

# === FORENSIC HISTORY ===
var history: Array[Dictionary] = []

# === SAVE PATH ===
const SAVE_PATH = "user://saves/hacker_history.json"

# === PHASE 6 STUBS ===
var current_shift_day: int = 0  # Updated by NarrativeDirector

func _ready():
	print("========================================")
	print("HackerHistory initialized")
	print("  Save Path: %s" % SAVE_PATH)
	print("  Crash-Safe: YES (immediate write)")
	print("  Debug: Ctrl+F7 (show), Ctrl+F8 (clear), Ctrl+F9 (save)")
	print("========================================")
	
	# Connect to offensive action signal
	if EventBus:
		EventBus.offensive_action_performed.connect(_on_offensive_action)
		EventBus.rival_ai_isolation_complete.connect(_on_isolation_complete)
		EventBus.connection_lost.connect(_on_connection_lost)
	
	# Ensure save directory exists
	_ensure_save_directory()
	
	# Load existing history (if any)
	_load_from_disk()

func _ensure_save_directory():
	"""Create saves directory if it doesn't exist."""
	var dir = DirAccess.open("user://")
	if dir and not dir.dir_exists("saves"):
		dir.make_dir("saves")
		print("📝 HISTORY: Created saves directory")

func _on_offensive_action(data: Dictionary):
	"""
	Record offensive action to forensic history.
	Called automatically via EventBus signal.
	"""
	# Validate payload has required keys
	var required_keys = ["action_type", "target", "timestamp", "result", "trace_cost"]
	for key in required_keys:
		if not data.has(key):
			push_warning("HackerHistory: Missing required key '%s' in payload" % key)
			return
	
	# Add shift_day if not present (Phase 5+)
	if not data.has("shift_day"):
		data["shift_day"] = current_shift_day
	
	# Append to history
	history.append(data)
	
	# Debug output
	var action_type = data.get("action_type", "unknown").to_upper()
	var target = data.get("target", "unknown")
	var result = data.get("result", "unknown")
	print("📝 HISTORY: Recorded %s on %s (%s) - Entry #%d" % [
		action_type,
		target,
		result,
		history.size()
	])
	
	# === CRASH-SAFE: Write to disk IMMEDIATELY ===
	_write_to_disk()
	
	# Emit signal for UI updates
	history_updated.emit(history.size())

func _on_isolation_complete(hostname: String):
	"""
	Record when RivalAI isolation is aborted (pivot evasion succeeded).
	"""
	var entry = {
		"action_type": "isolation_aborted",
		"target": hostname if hostname != "" else "unknown",
		"timestamp": ShiftClock.elapsed_seconds,
		"result": "EVASION_SUCCESS",
		"trace_cost": 0.0,
		"shift_day": current_shift_day,
		"note": "Pivot evasion aborted AI isolation countdown"
	}

	history.append(entry)
	_write_to_disk()

	print("📝 HISTORY: Recorded isolation aborted (pivot) on %s" % entry.target)
	history_updated.emit(history.size())

func _on_connection_lost():
	"""
	Record when isolation timer reaches zero (game over).
	"""
	var entry = {
		"action_type": "connection_lost",
		"target": GameState.current_foothold if GameState.current_foothold != "" else "unknown",
		"timestamp": ShiftClock.elapsed_seconds,
		"result": "ISOLATED",
		"trace_cost": 0.0,
		"shift_day": current_shift_day,
		"note": "RivalAI isolation countdown reached zero — connection terminated"
	}

	history.append(entry)
	_write_to_disk()

	print("📝 HISTORY: Recorded connection lost (game over)")
	history_updated.emit(history.size())

func _write_to_disk():
	"""
	Write history array to disk as JSON.
	Called after EVERY action for crash safety.
	"""
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		push_warning("HackerHistory: Failed to open save file for writing!")
		return
	
	# Convert to JSON with proper formatting
	var json_string = JSON.stringify(history, "  ", false)  # 2-space indent, no quotes on keys
	file.store_string(json_string)
	file.close()
	
	print("💾 HISTORY: Saved %d entries to disk" % history.size())

func _load_from_disk():
	"""
	Load history from disk on startup.
	Recovers forensic data from previous sessions.
	"""
	if not FileAccess.file_exists(SAVE_PATH):
		print("📝 HISTORY: No existing save file found (new campaign)")
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		push_warning("HackerHistory: Failed to open save file for reading!")
		return
	
	var json_string = file.get_as_text()
	file.close()
	
	# Parse JSON
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		push_warning("HackerHistory: Failed to parse save file - starting fresh")
		return
	
	# Type cast: json.data is Array, we need Array[Dictionary]
	var loaded_data = json.data
	if loaded_data is Array:
		history.clear()
		for entry in loaded_data:
			if entry is Dictionary:
				history.append(entry)
		print("💾 HISTORY: Loaded %d entries from disk" % history.size())
	else:
		push_warning("HackerHistory: Save file has invalid format - starting fresh")

# === PUBLIC API ===

func add_entry(data: Dictionary):
	"""
	Manually add a forensic entry. 
	Used for narrative events and non-offensive actions.
	"""
	if not data.has("shift_day"):
		data["shift_day"] = current_shift_day
	
	if not data.has("timestamp"):
		data["timestamp"] = ShiftClock.elapsed_seconds if "ShiftClock" in self else 0.0
		
	history.append(data)
	_write_to_disk()
	history_updated.emit(history.size())

func get_history() -> Array:
	"""Returns complete history array."""
	return history

func get_entry_count() -> int:
	"""Returns number of recorded actions."""
	return history.size()

func get_last_entry() -> Dictionary:
	"""Returns most recent action (or empty dict if none)."""
	if history.is_empty():
		return {}
	return history[-1]

func get_entries_for_action_type(action_type: String) -> Array:
	"""Returns all entries matching action type."""
	var filtered: Array = []
	for entry in history:
		if entry.get("action_type") == action_type:
			filtered.append(entry)
	return filtered

func get_entries_for_target(target: String) -> Array:
	"""Returns all entries targeting specific host."""
	var filtered: Array = []
	for entry in history:
		if entry.get("target") == target:
			filtered.append(entry)
	return filtered

func clear_history():
	"""Clear history (for new campaign)."""
	history.clear()
	_write_to_disk()
	print("📝 HISTORY: Cleared all entries")

# === PHASE 6 STUBS ===

func get_entries_for_day(day: int) -> Array:
	"""
	Returns all actions from a specific shift day.
	"""
	var filtered: Array = []
	for entry in history:
		if entry.get("shift_day", 0) == day:
			filtered.append(entry)
	return filtered

func get_timeline() -> Array:
	"""
	Returns formatted timeline for Mirror Mode report.
	Phase 6: Format with timestamps, correlation data
	Phase 2: Return raw history (stub)
	"""
	# TODO Phase 6: Format for Mirror Mode
	# var timeline: Array = []
	# for entry in history:
	#     timeline.append({
	#         "time": _format_timestamp(entry.timestamp),
	#         "action": entry.action_type,
	#         "target": entry.target,
	#         "result": entry.result,
	#         "trace": entry.trace_cost
	#     })
	# return timeline
	
	return history  # Phase 2 stub

func get_correlation_data() -> Dictionary:
	"""
	Returns data for correlating hacker actions with analyst detections.
	Phase 6: Match timestamps with SIEM logs
	Phase 2: Empty (stub)
	"""
	return {}  # Phase 6 stub

# === DEBUG COMMANDS (Hacker Campaign Only) ===

func _input(event):
	"""Debug input for testing (Ctrl+F7-F9). Only works in Hacker campaign."""
	# === ROLE GUARD: Only process in Hacker campaign ===
	if GameState and GameState.current_role == GameState.Role.ANALYST:
		return
	
	if not event is InputEventKey or not event.pressed:
		return
	
	# Ctrl+F7: Show history
	if event.keycode == KEY_F7 and event.ctrl_pressed:
		print("📝 HISTORY: === CURRENT HISTORY ===")
		for i in range(history.size()):
			var entry = history[i]
			print("  [%d] %s on %s (%s) [Day %d]" % [
				i,
				entry.get("action_type", "?").to_upper(),
				entry.get("target", "?"),
				entry.get("result", "?"),
				entry.get("shift_day", 0)
			])
		print("📝 HISTORY: Total entries: %d" % history.size())
	
	# Ctrl+F8: Clear history
	if event.keycode == KEY_F8 and event.ctrl_pressed:
		clear_history()
		print("DEBUG: Ctrl+F8 - History cleared")
	
	# Ctrl+F9: Force save
	if event.keycode == KEY_F9 and event.ctrl_pressed:
		_write_to_disk()
		print("DEBUG: Ctrl+F9 - Force save to disk")
