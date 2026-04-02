# TraceLevelManager.gd
# Autoload singleton that tracks the hacker's exposure level (0-100%)
# Increases with offensive actions, decays passively over time
extends Node

signal trace_level_changed(new_level: float)
signal trace_critical()  # Emitted at 80%+ (AI responds in Phase 3)
signal trace_maxed()     # Emitted at 100% (instant lockdown in Phase 3)

# === CONFIGURATION ===
const MAX_TRACE = 100.0
const MIN_TRACE = 0.0
const DECAY_RATE = 1.0  # Trace points per second

# Current trace level
var trace_level: float = 0.0

# Decay timer
var decay_timer: Timer

# State tracking
var is_decay_active: bool = true
var last_action_timestamp: float = 0.0

# Debug display
var show_debug_display: bool = false  # Set to true for real-time display

func _ready():
	print("========================================")
	print("TraceLevelManager initialized")
	print("  Decay Rate: %.1f/sec" % DECAY_RATE)
	print("  Max Trace: %.0f" % MAX_TRACE)
	print("========================================")
	
	# Connect to offensive action signal
	if EventBus:
		EventBus.offensive_action_performed.connect(_on_offensive_action)
	
	# Setup decay timer
	_setup_decay_timer()

func _setup_decay_timer():
	"""Initialize passive decay timer (ticks every 0.5 seconds)."""
	decay_timer = Timer.new()
	decay_timer.wait_time = 0.5  # Check twice per second for smooth decay
	decay_timer.timeout.connect(_on_decay_tick)
	add_child(decay_timer)
	decay_timer.start()

func _on_decay_tick():
	"""Passive decay logic - reduces trace over time."""
	if not is_decay_active:
		return
	
	# Don't decay during minigames (Phase 2+)
	if _is_minigame_active():
		return
	
	# Don't decay if trace is already at 0
	if trace_level <= MIN_TRACE:
		return
	
	# Calculate decay for this tick (0.5 sec = half of decay rate)
	var decay_amount = DECAY_RATE * decay_timer.wait_time
	var old_trace = trace_level
	
	trace_level = max(MIN_TRACE, trace_level - decay_amount)
	
	# Emit signal if changed significantly
	if abs(old_trace - trace_level) >= 0.5:
		trace_level_changed.emit(trace_level)

func _on_offensive_action(data: Dictionary):
	"""
	Handle offensive action signal.
	Adds trace_cost to current trace level.
	"""
	var cost = data.get("trace_cost", 0.0)
	var action_type = data.get("action_type", "unknown")
	var target = data.get("target", "unknown")
	var result = data.get("result", "unknown")
	
	# Accumulate trace
	var old_trace = trace_level
	trace_level = min(MAX_TRACE, trace_level + cost)
	last_action_timestamp = Time.get_unix_time_from_system()
	
	# Debug output
	print("🔍 TRACE: %s on %s (%s) → +%.1f trace (%.0f → %.0f)" % [
		action_type.to_upper(),
		target,
		result,
		cost,
		old_trace,
		trace_level
	])
	
	# Emit signals
	trace_level_changed.emit(trace_level)
	_check_thresholds(old_trace, trace_level)

func _check_thresholds(old_trace: float, new_trace: float):
	"""Check if trace crossed critical thresholds."""
	# Critical threshold (80%+)
	if old_trace < 80.0 and new_trace >= 80.0:
		print("⚠️ TRACE CRITICAL: %.0f%% - AI responding in Phase 3!" % new_trace)
		trace_critical.emit()
	
	# Max threshold (100%)
	if old_trace < 100.0 and new_trace >= 100.0:
		print("🚨 TRACE MAXED: %.0f%% - Instant lockdown in Phase 3!" % new_trace)
		trace_maxed.emit()

func _is_minigame_active() -> bool:
	"""Check if any minigame is currently active (pause decay)."""
	# Check GameState for minigame mode
	if GameState and GameState.current_mode == GameState.GameMode.MODE_MINIGAME:
		return true
	
	# Check for active minigame nodes in scene tree
	for node in get_tree().get_nodes_in_group("minigames"):
		if node is Control and node.visible:
			return true
	
	return false

# === PUBLIC API ===

func get_trace_level() -> float:
	"""Returns current trace level (0.0-100.0)."""
	return trace_level

func get_trace_normalized() -> float:
	"""Returns trace as 0.0-1.0 (for UI bars)."""
	return trace_level / MAX_TRACE

func get_trace_percent() -> int:
	"""Returns trace as percentage (0-100)."""
	return int(trace_level)

func add_trace(amount: float):
	"""Manually add trace (for debugging or special events)."""
	var old_trace = trace_level
	trace_level = min(MAX_TRACE, trace_level + amount)
	trace_level_changed.emit(trace_level)
	print("🔍 TRACE: Manual add %.1f (%.0f → %.0f)" % [amount, old_trace, trace_level])

func reduce_trace(amount: float):
	"""Manually reduce trace (for Phase 4+ tools)."""
	var old_trace = trace_level
	trace_level = max(MIN_TRACE, trace_level - amount)
	trace_level_changed.emit(trace_level)
	print("🔍 TRACE: Manual reduce %.1f (%.0f → %.0f)" % [amount, old_trace, trace_level])

func reset_trace():
	"""Reset trace to 0 (for new shift/session)."""
	trace_level = 0.0
	trace_level_changed.emit(trace_level)
	print("🔍 TRACE: Reset to 0")

func pause_decay(pause: bool):
	"""Manually pause/resume decay (for cutscenes, etc.)."""
	is_decay_active = not pause
	print("🔍 TRACE: Decay ", "PAUSED" if pause else "RESUMED")

func _process(_delta):
	"""Debug: Show trace level every second if enabled."""
	if show_debug_display and Engine.get_frames_drawn() % 60 == 0:
		print("🔍 TRACE: %.0f%% (decay: %.1f/sec)" % [get_trace_percent(), DECAY_RATE])

# === SOLO DEV PHASE 2: DEBUG COMMANDS ===

func _input(event):
	"""Debug input for testing (F7-F10). Only works in Hacker campaign."""
	# === ROLE GUARD: Only process in Hacker campaign ===
	if GameState and GameState.current_role == GameState.Role.ANALYST:
		return  # Skip Hacker debug keys in Analyst campaign
	
	if not event is InputEventKey or not event.pressed:
		return
	
	# F7: Add 10 trace (simulate exploit)
	if event.keycode == KEY_F7:
		add_trace(10.0)
		print("DEBUG: F7 - Added 10 trace")
	
	# F8: Reduce 10 trace
	if event.keycode == KEY_F8:
		reduce_trace(10.0)
		print("DEBUG: F8 - Reduced 10 trace")
	
	# F9: Reset trace
	if event.keycode == KEY_F9:
		reset_trace()
		print("DEBUG: F9 - Reset trace")
	
	# F10: Toggle debug display (real-time trace level)
	if event.keycode == KEY_F10:
		show_debug_display = not show_debug_display
		print("DEBUG: F10 - Trace display ", "ENABLED" if show_debug_display else "DISABLED")
