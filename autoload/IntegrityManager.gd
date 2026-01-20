# IntegrityManager.gd
# Autoload singleton that manages the "HP" of the organization.
# Tracks stability (0-100%) and handles decay/penalties.
extends Node

signal integrity_changed(new_value: float, delta: float)
signal integrity_critical() # Triggered at 0%

var current_integrity: float = 100.0
var max_integrity: float = 100.0
var decay_rate_per_hour: float = 1.0 # Base decay: -1% per hour
var is_decay_active: bool = false

# Balance Constants (Defined in FULLGAME.md)
const DELTA_COMPLIANT = 5.0
const DELTA_EFFICIENT = -2.0
const DELTA_EMERGENCY = -5.0
const DELTA_TIMEOUT = -10.0
const DELTA_BREACH = -40.0

const THRESHOLD_CRITICAL = 0.0
const THRESHOLD_WARNING = 20.0

func _ready():
	# Connect to global gameplay events via EventBus
	EventBus.ticket_completed.connect(_on_ticket_completed)
	EventBus.ticket_ignored.connect(_on_ticket_ignored)
	EventBus.consequence_triggered.connect(_on_consequence_triggered)
	
	EventBus.shift_started.connect(_on_shift_started)
	EventBus.shift_ended.connect(_on_shift_ended)
	EventBus.campaign_ended.connect(func(_type): stop_decay())
	
	print("IntegrityManager initialized. Current Integrity: %.1f%%" % current_integrity)

func _process(delta):
	if is_decay_active:
		# Scaling Decay: Multiply base rate by Heat Multiplier (Week 2+)
		var multiplier = 1.0
		if HeatManager:
			multiplier = HeatManager.heat_multiplier
			
		# Convert delta (seconds) to hours for the rate calculation
		# 1 Hour of gameplay = 3600 seconds
		var hourly_decay = (decay_rate_per_hour * multiplier / 3600.0) * delta
		_apply_change(-hourly_decay, true)

func _apply_change(delta: float, silent: bool = false):
	var old_integrity = current_integrity
	current_integrity = clamp(current_integrity + delta, 0.0, max_integrity)
	
	# Only emit signals if value actually changed (optimization)
	if old_integrity != current_integrity:
		# For decay (silent), we might want to throttle signals or UI updates,
		# but for now we emit continuously for smooth UI bars.
		integrity_changed.emit(current_integrity, delta)
		
		# Check Fail State
		if current_integrity <= THRESHOLD_CRITICAL and old_integrity > THRESHOLD_CRITICAL:
			print("💀 IntegrityManager: CRITICAL FAILURE. Integrity hit 0%.")
			integrity_critical.emit()
			EventBus.campaign_ended.emit("bankrupt")
			
		# Check Warning State
		elif current_integrity <= THRESHOLD_WARNING and old_integrity > THRESHOLD_WARNING:
			print("⚠ IntegrityManager: Warning threshold reached (<20%).")
			if NotificationManager:
				NotificationManager.show_notification("WARNING: SYSTEM INTEGRITY CRITICAL", "warning", 5.0)

# --- Event Handlers ---

func _on_ticket_completed(_ticket: Resource, completion_type: String, _time_taken: float):
	var delta = 0.0
	match completion_type:
		GlobalConstants.COMPLETION_TYPE.COMPLIANT: delta = DELTA_COMPLIANT
		GlobalConstants.COMPLETION_TYPE.EFFICIENT: delta = DELTA_EFFICIENT
		GlobalConstants.COMPLETION_TYPE.EMERGENCY: delta = DELTA_EMERGENCY
		GlobalConstants.COMPLETION_TYPE.TIMEOUT: delta = DELTA_TIMEOUT
	
	if delta != 0.0:
		print("IntegrityManager: Ticket Resolved (%s) -> Delta: %+.1f" % [completion_type, delta])
		_apply_change(delta)

func _on_ticket_ignored(_ticket: Resource):
	print("IntegrityManager: Ticket Ignored -> Delta: %+.1f" % DELTA_TIMEOUT)
	_apply_change(DELTA_TIMEOUT)

func _on_consequence_triggered(type: String, _details: Dictionary):
	if type == GlobalConstants.CONSEQUENCE_ID.DATA_LOSS or type == GlobalConstants.CONSEQUENCE_ID.MAJOR_BREACH:
		print("IntegrityManager: Major Breach -> Delta: %+.1f" % DELTA_BREACH)
		_apply_change(DELTA_BREACH)

func _on_shift_started(_id):
	start_decay()

func _on_shift_ended(_results):
	stop_decay()

# --- Public Control ---

func start_decay():
	is_decay_active = true
	print("IntegrityManager: Active Decay STARTED")

func stop_decay():
	is_decay_active = false
	print("IntegrityManager: Active Decay STOPPED")

func restore_integrity(amount: float):
	print("IntegrityManager: Manual Restore -> %+.1f" % amount)
	_apply_change(amount)

# --- Persistence ---

func load_state(data: Dictionary):
	if data.has("current_integrity"):
		current_integrity = data["current_integrity"]
		integrity_changed.emit(current_integrity, 0.0)
		print("IntegrityManager state loaded: %.1f%%" % current_integrity)
