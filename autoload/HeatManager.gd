# HeatManager.gd
# Autoload singleton that manages difficulty scaling and persistent vulnerabilities.
extends Node

signal heat_increased(new_multiplier: float)

var current_week: int = 1
var heat_multiplier: float = 1.0 # Increases by 1.15x per week
var vulnerability_buffer: Array[Dictionary] = [] # FIFO queue of "Efficient" closures
var week_transition_shift: String = "shift_friday"

const HEAT_INCREMENT = 0.15 # 15% increase per week
const MAX_BUFFER_SIZE = 10

func _ready():
	EventBus.shift_ended.connect(_on_shift_ended)
	EventBus.ticket_completed.connect(_on_ticket_completed)
	print("HeatManager initialized.")

func get_effective_multiplier() -> float:
	var rigor_mult = 1.0
	if ConfigManager and GlobalConstants:
		var tier = ConfigManager.settings.gameplay.difficulty_level
		var data = GlobalConstants.DIFFICULTY_DATA.get(tier, GlobalConstants.DIFFICULTY_DATA[GlobalConstants.DIFFICULTY.ANALYST])
		# Convert time_mult (where 1.5 is slower) to a pressure_mult (where >1.0 is harder)
		# analyst (1.0) -> 1.0
		# junior (1.5) -> 0.66
		# lead (0.7) -> 1.42
		rigor_mult = 1.0 / data.time_mult
		
	return heat_multiplier * rigor_mult

func get_scaled_time(base_time: float) -> float:
	# Use the effective multiplier for all time scaling
	return base_time / get_effective_multiplier()

func _on_shift_ended(_results):
	# If designated transition shift ends, increment week and heat
	if NarrativeDirector and NarrativeDirector.current_shift_name == week_transition_shift:
		current_week += 1
		heat_multiplier += HEAT_INCREMENT
		print("🔥 HEAT INCREASED: Week %d | Multiplier: %.2fx" % [current_week, heat_multiplier])
		heat_increased.emit(heat_multiplier)

func _on_ticket_completed(ticket: TicketResource, completion_type: String, _time):
	# INHERITANCE LOGIC: If a ticket is closed as 'Efficient', 
	# it's flagged as a potential future escalation point.
	if completion_type == "efficient":
		var vulnerability = {
			"original_id": ticket.ticket_id,
			"attacker_ip": ticket.truth_packet.get("attacker_ip", ""),
			"victim_host": ticket.truth_packet.get("victim_host", ""),
			"timestamp": Time.get_ticks_msec()
		}
		
		vulnerability_buffer.append(vulnerability)
		if vulnerability_buffer.size() > MAX_BUFFER_SIZE:
			vulnerability_buffer.pop_front() # FIFO
			
		print("📋 HeatManager: Vulnerability cached from %s. Buffer size: %d" % [ticket.ticket_id, vulnerability_buffer.size()])

func pop_vulnerability() -> Dictionary:
	if vulnerability_buffer.is_empty():
		return {}
	return vulnerability_buffer.pop_front()

func reset_to_default():
	print("HeatManager: Resetting difficulty scaling.")
	current_week = 1
	heat_multiplier = 1.0
	vulnerability_buffer.clear()

func load_state(data: Dictionary):
	current_week = data.get("current_week", 1)
	heat_multiplier = data.get("heat_multiplier", 1.0)
	
	if data.has("vulnerability_buffer"):
		vulnerability_buffer.assign(data["vulnerability_buffer"])
