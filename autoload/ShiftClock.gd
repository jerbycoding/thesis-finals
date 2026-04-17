# ShiftClock.gd
# The Master Authority for time within a shift.
# All forensic correlation depends on this clock.
extends Node

## Time elapsed since the start of the current shift in seconds.
var elapsed_seconds: float = 0.0

## Whether the clock is currently ticking.
var is_active: bool = false

func _ready():
	print("🕒 ShiftClock: Unified Time Authority Initialized.")
	
	# Connect to global lifecycle events
	if EventBus:
		EventBus.shift_started.connect(_on_shift_started)
		EventBus.hacker_shift_started.connect(_on_hacker_shift_started)
		EventBus.shift_ended.connect(_on_shift_ended)
		EventBus.campaign_ended.connect(func(_type): stop_clock())

func _process(delta: float):
	if is_active:
		elapsed_seconds += delta

func _on_shift_started(_shift_id: String):
	reset_clock()
	start_clock()

func _on_hacker_shift_started(_day: int):
	reset_clock()
	start_clock()

func _on_shift_ended(_results: Dictionary):
	stop_clock()

func start_clock():
	is_active = true
	print("🕒 ShiftClock: Clock STARTED at %.2f" % elapsed_seconds)

func stop_clock():
	is_active = false
	print("🕒 ShiftClock: Clock STOPPED at %.2f" % elapsed_seconds)

func reset_clock():
	elapsed_seconds = 0.0
	print("🕒 ShiftClock: Clock RESET.")

func get_time_string() -> String:
	var minutes = int(elapsed_seconds) / 60
	var seconds = int(elapsed_seconds) % 60
	return "%02d:%02d" % [minutes, seconds]

func get_formatted_timestamp() -> String:
	# Standardized format for SIEM logs: [MM:SS]
	return "[%s]" % get_time_string()
