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

func get_scaled_time(base_time: float) -> float:
	# Scaling: T_scaled = base_time / (1.0 + (heat - 1.0))
	# Higher heat = less time
	return base_time / heat_multiplier

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
	vulnerability_buffer = data.get("vulnerability_buffer", [])
