# ArchetypeAnalyzer.gd
# This autoload singleton tracks player metrics and determines their
# "analyst archetype" at the end of a shift.
extends Node

# Metrics to track during the shift
var metrics: Dictionary = {
	"tickets_completed": 0,
	"total_completion_time": 0.0,
	"avg_completion_time": 0.0,
	"risks_taken": 0,          # e.g., approving malicious emails, missing steps
	"consequences_triggered": 0,
	"npc_approval": 0.0,
	"tools_used": {}           # {"siem": 5, "email": 10, ...}
}

# Definitions for the archetypes
var ARCHETYPE_DEFINITIONS = {
	"By-the-Book": {
		"description": "You are a meticulous and thorough analyst. You follow procedure to the letter, ensuring every detail is checked. This results in very few mistakes, but can be slow.",
		"feedback": "Your meticulousness is a strong asset, though consider efficiency in less critical situations.",
		"condition": func(m): return m.risks_taken <= 1 and m.avg_completion_time > 150.0
	},
	"Pragmatic": {
		"description": "You are a balanced and efficient analyst. You know when to follow the rules and when to cut corners for the sake of speed, making you effective but occasionally prone to risk.",
		"feedback": "Your balanced approach is effective. Continue to refine your risk assessment skills.",
		"condition": func(m): return m.risks_taken > 1 and m.risks_taken < 4 and m.avg_completion_time <= 150.0 and m.avg_completion_time >= 90.0 # More specific condition
	},
	"Cowboy": {
		"description": "You are a fast and decisive analyst, prioritizing speed above all else. You close tickets at a record pace, but your methods often invite unnecessary risk and consequences.",
		"feedback": "Your speed is impressive, but carefully consider the long-term consequences of rapid resolutions.",
		"condition": func(m): return m.risks_taken >= 4 or m.avg_completion_time < 90.0
	}
}

func _ready():
	# Reset metrics at the start of a new game/shift
	reset_metrics()
	
	# Connect to signals from other systems to gather data
	if TicketManager:
		TicketManager.ticket_completed.connect(_on_ticket_completed)
	if ConsequenceEngine:
		ConsequenceEngine.consequence_triggered.connect(_on_consequence_triggered)

func reset_metrics():
	metrics = {
		"tickets_completed": 0,
		"total_completion_time": 0.0,
		"avg_completion_time": 0.0,
		"risks_taken": 0,
		"consequences_triggered": 0,
		"npc_approval": 0.0,
		"tools_used": {}
	}
	print("ArchetypeAnalyzer: Metrics reset.")

# --- Data Collection Functions ---

func _on_ticket_completed(ticket: TicketResource, completion_type: String, time_taken: float):
	metrics.tickets_completed += 1
	metrics.total_completion_time += time_taken
	metrics.avg_completion_time = metrics.total_completion_time / metrics.tickets_completed
	
	# Associate completion types with risk
	if completion_type in ["efficient", "emergency"]:
		metrics.risks_taken += 1
	
	print("ArchetypeAnalyzer: Logged ticket completion. Time: %.1fs, Risks: %d" % [time_taken, metrics.risks_taken])

func _on_consequence_triggered(consequence_type: String, details: Dictionary):
	metrics.consequences_triggered += 1
	print("ArchetypeAnalyzer: Logged consequence. Total: ", metrics.consequences_triggered)

func log_tool_used(tool_name: String):
	if not metrics.tools_used.has(tool_name):
		metrics.tools_used[tool_name] = 0
	metrics.tools_used[tool_name] += 1

func load_state(data: Dictionary):
	if data:
		metrics = data
		print("ArchetypeAnalyzer state loaded.")

# --- Analysis Function ---

func get_analysis_results() -> Dictionary:
	# In a real game, you'd pull final NPC approval from ConsequenceEngine
	# For now, we'll use a placeholder.
	if ConsequenceEngine and ConsequenceEngine.has_method("get_average_npc_approval"):
		metrics.npc_approval = ConsequenceEngine.get_average_npc_approval()
	
	var results = metrics.duplicate(true)
	results["archetype"] = _calculate_archetype()
	
	return results

func _calculate_archetype() -> String:
	# Pass a struct-like object to the lambda for easier access
	var m_struct = OpenStruct.new(metrics)
	
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
