# ArchetypeAnalyzer.gd
# This autoload singleton tracks player metrics and determines their
# "analyst archetype" at the end of a shift.
extends Node

# Metrics to track during the shift
var metrics: Dictionary = {
	"tickets_completed": 0,
	"tickets_ignored": 0,
	"total_completion_time": 0.0,
	"avg_completion_time": 0.0,
	"risks_taken": 0,          # e.g., approving malicious emails, missing steps
	"consequences_triggered": 0,
	"npc_approval": 0.0,
	"tools_used": {}           # {"siem": 5, "email": 10, ...}
}

# Definitions for the archetypes
var ARCHETYPE_DEFINITIONS = {
	"Negligent": {
		"description": "You have failed to address critical security alerts. Your lack of action has left the organization vulnerable to multiple breaches and data loss. This level of passivity is unacceptable in a security environment.",
		"feedback": "IMMEDIATE REVIEW REQUIRED. You are currently a liability to the SOC. Security is a proactive role; doing nothing is a choice with consequences.",
		"condition": func(m): return m.tickets_ignored > 0 and m.tickets_completed <= m.tickets_ignored
	},
	"By-the-Book": {
		"description": "You are a meticulous and thorough analyst. You follow procedure to the letter, ensuring every detail is checked. This results in very few mistakes, but can be slow.",
		"feedback": "Your meticulousness is a strong asset, though consider efficiency in less critical situations.",
		"condition": func(m): return m.tickets_completed > 0 and m.risks_taken == 0 and m.tickets_ignored == 0
	},
	"Cowboy": {
		"description": "You are a fast and decisive analyst, prioritizing speed above all else. You close tickets at a record pace, but your methods often invite unnecessary risk and consequences.",
		"feedback": "Your speed is impressive, but carefully consider the long-term consequences of rapid resolutions.",
		"condition": func(m): return m.tickets_completed > 0 and (m.risks_taken >= 3 or (m.risks_taken > 0 and m.avg_completion_time < 60.0))
	},
	"Pragmatic": {
		"description": "You are a balanced and efficient analyst. You know when to follow the rules and when to cut corners for the sake of speed, making you effective but occasionally prone to risk.",
		"feedback": "Your balanced approach is effective. Continue to refine your risk assessment skills.",
		"condition": func(m): return m.tickets_completed > 0
	}
}

func _ready():
	# Reset metrics at the start of a new game/shift
	reset_metrics()
	
	# Use EventBus for decoupled data collection
	EventBus.ticket_completed.connect(_on_ticket_completed)
	EventBus.ticket_ignored.connect(_on_ticket_ignored)
	EventBus.consequence_triggered.connect(_on_consequence_triggered)

func reset_metrics():
	metrics = {
		"tickets_completed": 0,
		"tickets_ignored": 0,
		"total_completion_time": 0.0,
		"avg_completion_time": 0.0,
		"risks_taken": 0,
		"consequences_triggered": 0,
		"npc_approval": 0.0,
		"tools_used": {}
	}
	# Explicitly clear internal state to prevent memory ghosting
	print("ArchetypeAnalyzer: Metrics hard reset.")

# --- Data Collection Functions ---

func _on_ticket_completed(ticket: TicketResource, completion_type: String, time_taken: float):
	# Ignore timeouts - they are handled by _on_ticket_ignored
	if completion_type == "timeout":
		return

	metrics.tickets_completed += 1
	metrics.total_completion_time += time_taken
	
	if metrics.tickets_completed > 0:
		metrics.avg_completion_time = metrics.total_completion_time / metrics.tickets_completed
	else:
		metrics.avg_completion_time = 0.0
	
	# Associate completion types with risk
	if completion_type in ["efficient", "emergency"]:
		metrics.risks_taken += 1
	
	print("ArchetypeAnalyzer: Logged ticket completion. Time: %.1fs, Risks: %d" % [time_taken, metrics.risks_taken])

func _on_ticket_ignored(ticket: TicketResource):
	metrics.tickets_ignored += 1
	print("ArchetypeAnalyzer: Logged ignored ticket. Total: ", metrics.tickets_ignored)

func _on_consequence_triggered(consequence_type: String, details: Dictionary):
	metrics.consequences_triggered += 1
	print("ArchetypeAnalyzer: Logged consequence. Total: ", metrics.consequences_triggered)

func log_tool_used(tool_name: String):
	if not metrics.tools_used.has(tool_name):
		metrics.tools_used[tool_name] = 0
	metrics.tools_used[tool_name] += 1

func perform_career_reset():
	# Payoff for the Black Ticket
	print("ArchetypeAnalyzer: PERFORMING CAREER RESET.")
	metrics.risks_taken = max(0, metrics.risks_taken - 2)
	metrics.npc_approval = 0.0 # Reset to neutral
	
	if ConsequenceEngine:
		# Reset CISO relationship to neutral
		ConsequenceEngine.npc_relationships["ciso"] = 0.0
	
	print("ArchetypeAnalyzer: Career reset successful. Risks remaining: ", metrics.risks_taken)

func load_state(data: Dictionary):
	if data:
		metrics = data
		print("ArchetypeAnalyzer state loaded.")

# --- Analysis Function ---

func get_analysis_results() -> Dictionary:
	# DERIVE metrics from ConsequenceEngine rather than tracking them locally.
	# This is the "Source of Truth" refactor (Task 5).
	var source_metrics = _calculate_metrics_from_history()
	
	if ConsequenceEngine and ConsequenceEngine.has_method("get_average_npc_approval"):
		source_metrics.npc_approval = ConsequenceEngine.get_average_npc_approval()
	
	var results = source_metrics.duplicate(true)
	results["archetype"] = _calculate_archetype(source_metrics)
	
	return results

func _calculate_metrics_from_history() -> Dictionary:
	if not ConsequenceEngine:
		return metrics.duplicate(true)
		
	var history = ConsequenceEngine.get_choice_history()
	
	# If no history exists (e.g. start of game or unit test), 
	# fall back to the locally tracked metrics.
	if history.is_empty():
		return metrics.duplicate(true)
		
	var m = {
		"tickets_completed": 0,
		"tickets_ignored": 0,
		"total_completion_time": 0.0,
		"avg_completion_time": 0.0,
		"risks_taken": 0,
		"consequences_triggered": 0,
		"npc_approval": 0.0,
		"tools_used": metrics.tools_used # We still track tool usage counts locally
	}
	
	for entry in history:
		match entry.get("type", ""):
			"ticket_completed":
				m.tickets_completed += 1
				m.total_completion_time += entry.get("time_taken", 0.0)
				var c_type = entry.get("completion_type", "")
				if c_type in ["efficient", "emergency"]:
					m.risks_taken += 1
			"ticket_ignored":
				m.tickets_ignored += 1
			"consequence_triggered":
				m.consequences_triggered += 1
				
	if m.tickets_completed > 0:
		m.avg_completion_time = m.total_completion_time / m.tickets_completed
		
	return m

func _calculate_archetype(m: Dictionary) -> String:
	# Pass a struct-like object to the lambda for easier access
	var m_struct = OpenStruct.new(m)
	
	for archetype_name in ARCHETYPE_DEFINITIONS:
		var definition = ARCHETYPE_DEFINITIONS[archetype_name]
		if definition.condition.call(m_struct):
			return archetype_name
			
	return "Pragmatic" # Default fallback

# Helper class to allow dot notation access on the dictionary for cleaner conditions
class OpenStruct:
	var _data: Dictionary
	func _init(data: Dictionary):
		_data = data
	func _get(property):
		return _data.get(property)
