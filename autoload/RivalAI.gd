# RivalAI.gd
# Autoload singleton that simulates AI Analyst responding to hacker's trace level
# Phase 3: AI Counter-Measures
extends Node

# === AI STATE MACHINE ===
enum AIState { IDLE, SEARCHING, LOCKDOWN, ISOLATING }

# Current state
var current_state: AIState = AIState.IDLE
var previous_state: AIState = AIState.IDLE
var state_enter_time: float = 0.0

# === CONFIGURATION ===
const TRACE_THRESHOLD_SEARCHING = 30.0
const TRACE_THRESHOLD_LOCKDOWN = 70.0
const ISOLATION_COUNTDOWN = 20.0

# === ISOLATION STATE ===
var is_isolation_active: bool = false
var isolation_timer: float = 0.0

func _ready():
	print("========================================")
	print("RivalAI initialized")
	print("  Searching Threshold: %.0f%%" % TRACE_THRESHOLD_SEARCHING)
	print("  Lockdown Threshold: %.0f%%" % TRACE_THRESHOLD_LOCKDOWN)
	print("  Isolation Countdown: %.0fs" % ISOLATION_COUNTDOWN)
	print("  Debug: Alt+F1-F5 (AI state control)")
	print("========================================")
	
	# Connect to trace signal
	if TraceLevelManager:
		TraceLevelManager.trace_level_changed.connect(_on_trace_level_changed)
	
	# Initial state
	state_enter_time = Time.get_unix_time_from_system()

func _process(delta: float):
	_update_ai_state()
	_update_isolation(delta)

func _update_ai_state():
	"""Check trace level and update AI state accordingly."""
	var trace = _get_current_trace()
	
	match current_state:
		AIState.IDLE:
			if trace >= TRACE_THRESHOLD_LOCKDOWN:
				_transition_to(AIState.LOCKDOWN)
			elif trace >= TRACE_THRESHOLD_SEARCHING:
				_transition_to(AIState.SEARCHING)
		
		AIState.SEARCHING:
			if trace >= TRACE_THRESHOLD_LOCKDOWN:
				_transition_to(AIState.LOCKDOWN)
			elif trace < TRACE_THRESHOLD_SEARCHING:
				_transition_to(AIState.IDLE)  # Hacker went quiet
		
		AIState.LOCKDOWN:
			if trace >= 100.0:
				_transition_to(AIState.ISOLATING)
			elif trace < TRACE_THRESHOLD_SEARCHING:
				_transition_to(AIState.IDLE)  # Hacker escaped!
		
		AIState.ISOLATING:
			# Handled by countdown timer
			pass

func _transition_to(new_state: AIState):
	"""Clean state transition with enter/exit hooks."""
	if current_state == new_state:
		return  # Already in this state
	
	# Exit current state
	_exit_state(current_state)
	
	# Change state
	previous_state = current_state
	current_state = new_state
	state_enter_time = Time.get_unix_time_from_system()
	
	# Enter new state
	_enter_state(new_state)
	
	# Emit signal
	if EventBus:
		EventBus.ai_state_changed.emit(previous_state, current_state)

func _enter_state(state: AIState):
	"""State-specific enter logic."""
	match state:
		AIState.IDLE:
			print("🤖 RivalAI: IDLE - Monitoring network traffic...")
		
		AIState.SEARCHING:
			print("🤖 RivalAI: SEARCHING - Anomaly detected! Investigating...")
			if EventBus:
				EventBus.ai_searching_started.emit()
		
		AIState.LOCKDOWN:
			print("🤖 RivalAI: LOCKDOWN - Target acquired! Initiating isolation...")
			if EventBus:
				EventBus.ai_lockdown_started.emit()
		
		AIState.ISOLATING:
			print("🤖 RivalAI: ISOLATING - Connection Lost in %.0f seconds!" % ISOLATION_COUNTDOWN)
			_start_isolation_countdown()

func _exit_state(state: AIState):
	"""State-specific exit logic."""
	match state:
		AIState.SEARCHING:
			print("🤖 RivalAI: Exited SEARCHING - Trace dropped below threshold")
		
		AIState.LOCKDOWN:
			print("🤖 RivalAI: Exited LOCKDOWN - Hacker escaped or caught")

func _get_current_trace() -> float:
	"""Safely get current trace level."""
	if TraceLevelManager:
		return TraceLevelManager.get_trace_level()
	return 0.0

func _on_trace_level_changed(new_trace: float):
	"""Called when trace level changes."""
	# State machine will handle it in _process()
	pass

# === ISOLATION COUNTDOWN ===

func _start_isolation_countdown():
	"""Start the 20-second countdown to connection lost."""
	is_isolation_active = true
	isolation_timer = ISOLATION_COUNTDOWN
	
	# Show UI warning (Phase 6: actual UI)
	if TransitionManager:
		TransitionManager.show_isolation_warning(isolation_timer)
	
	# Emit signal
	if EventBus:
		EventBus.isolation_countdown_started.emit(isolation_timer)

func _update_isolation(delta: float):
	"""Update isolation countdown timer."""
	if not is_isolation_active:
		return
	
	isolation_timer -= delta
	
	if isolation_timer <= 0:
		_on_isolation_timeout()

func _on_isolation_timeout():
	"""Connection lost - game over state."""
	print("🚨 RivalAI: CONNECTION LOST - Hacker isolated!")
	is_isolation_active = false
	
	# Emit game over signal
	if EventBus:
		EventBus.connection_lost.emit()
	
	# Phase 6: Show game over UI
	# For now, just print message

# === PUBLIC API ===

func get_state() -> AIState:
	"""Returns current AI state."""
	return current_state

func get_state_name() -> String:
	"""Returns state name as string."""
	return AIState.keys()[current_state]

func is_state(state: AIState) -> bool:
	"""Check if AI is in specific state."""
	return current_state == state

func is_idle() -> bool:
	return current_state == AIState.IDLE

func is_searching() -> bool:
	return current_state == AIState.SEARCHING

func is_lockdown() -> bool:
	return current_state == AIState.LOCKDOWN

func is_isolating() -> bool:
	return current_state == AIState.ISOLATING

func get_state_duration() -> float:
	"""Returns time spent in current state (seconds)."""
	return Time.get_unix_time_from_system() - state_enter_time

func get_isolation_time_remaining() -> float:
	"""Returns isolation countdown time remaining."""
	return isolation_timer if is_isolation_active else 0.0

func reset_ai():
	"""Reset AI to IDLE state (new shift)."""
	current_state = AIState.IDLE
	previous_state = AIState.IDLE
	state_enter_time = Time.get_unix_time_from_system()
	is_isolation_active = false
	isolation_timer = 0.0
	print("🤖 RivalAI: Reset to IDLE state")

# === DEBUG COMMANDS (Hacker Campaign Only) ===

func _input(event):
	"""Debug input for testing AI states (Alt+F1-F5)."""
	# === ROLE GUARD: Only process in Hacker campaign ===
	if GameState and GameState.current_role == GameState.Role.ANALYST:
		return
	
	if not event is InputEventKey or not event.pressed:
		return
	
	# Alt+F1: Force IDLE
	if event.keycode == KEY_F1 and event.alt_pressed:
		_transition_to(AIState.IDLE)
		print("DEBUG: Alt+F1 - AI forced to IDLE")
	
	# Alt+F2: Force SEARCHING
	if event.keycode == KEY_F2 and event.alt_pressed:
		_transition_to(AIState.SEARCHING)
		print("DEBUG: Alt+F2 - AI forced to SEARCHING")
	
	# Alt+F3: Force LOCKDOWN
	if event.keycode == KEY_F3 and event.alt_pressed:
		_transition_to(AIState.LOCKDOWN)
		print("DEBUG: Alt+F3 - AI forced to LOCKDOWN")
	
	# Alt+F4: Force ISOLATING
	if event.keycode == KEY_F4 and event.alt_pressed:
		_transition_to(AIState.ISOLATING)
		print("DEBUG: Alt+F4 - AI forced to ISOLATING")
	
	# Alt+F5: Show AI state
	if event.keycode == KEY_F5 and event.alt_pressed:
		print("🤖 RivalAI: === CURRENT STATE ===")
		print("  State: %s" % get_state_name())
		print("  Duration: %.1fs" % get_state_duration())
		print("  Trace: %.0f%%" % _get_current_trace())
		if is_isolation_active:
			print("  Isolation: %.1fs remaining" % isolation_timer)
