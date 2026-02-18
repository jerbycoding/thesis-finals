# ArchetypeAnalyzer.gd
# This autoload singleton tracks player metrics via the ConsequenceEngine history
# to determine their "analyst archetype" at the end of a shift.
extends Node

# Definitions for the archetypes
var ARCHETYPE_DEFINITIONS = {
	GlobalConstants.ARCHETYPE.NEGLIGENT: {
		"description": "You have failed to address critical security alerts. Your lack of action has left the organization vulnerable to multiple breaches and data loss.",
		"feedback": "IMMEDIATE REVIEW REQUIRED. You are currently a liability to the SOC.",
		"condition": func(m): return m.tickets_ignored > 0 and m.tickets_completed <= m.tickets_ignored
	},
	GlobalConstants.ARCHETYPE.BY_THE_BOOK: {
		"description": "You are a meticulous and thorough analyst. You follow procedure to the letter, ensuring every detail is checked.",
		"feedback": "Your meticulousness is a strong asset, though consider efficiency in less critical situations.",
		"condition": func(m): return m.tickets_completed > 0 and m.risks_taken == 0 and m.tickets_ignored == 0
	},
	GlobalConstants.ARCHETYPE.COWBOY: {
		"description": "You are a fast and decisive analyst, prioritizing speed above all else. You close tickets at a record pace.",
		"feedback": "Your speed is impressive, but carefully consider the long-term consequences of rapid resolutions.",
		"condition": func(m): return m.tickets_completed > 0 and (m.risks_taken >= 3 or (m.risks_taken > 0 and m.avg_completion_time < 60.0))
	},
	GlobalConstants.ARCHETYPE.PRAGMATIC: {
		"description": "You are a balanced and efficient analyst. You know when to follow the rules and when to prioritize speed.",
		"feedback": "Your balanced approach is effective. Continue to refine your risk assessment skills.",
		"condition": func(m): return m.tickets_completed > 0
	}
}

# Source of Truth: All metrics are derived from ConsequenceEngine
func get_analysis_results() -> Dictionary:
	var m = _calculate_metrics_from_history()
	
	if ConsequenceEngine and ConsequenceEngine.has_method("get_average_npc_approval"):
		m.npc_approval = ConsequenceEngine.get_average_npc_approval()
	
	var results = m.duplicate(true)
	results["archetype"] = _calculate_archetype(m)
	
	return results

func _calculate_metrics_from_history() -> Dictionary:
	var m = {
		"tickets_completed": 0,
		"tickets_ignored": 0,
		"total_completion_time": 0.0,
		"avg_completion_time": 0.0,
		"risks_taken": 0,
		"consequences_triggered": 0,
		"npc_approval": 0.0,
		"tools_used": {} 
	}
	
	if not ConsequenceEngine: return m
		
	var history = ConsequenceEngine.get_choice_history()
	for entry in history:
		match entry.get("type", ""):
			"ticket_completed":
				m.tickets_completed += 1
				m.total_completion_time += entry.get("time_taken", 0.0)
				var c_type = entry.get("completion_type", "")
				if c_type in [GlobalConstants.COMPLETION_TYPE.EFFICIENT, GlobalConstants.COMPLETION_TYPE.EMERGENCY]:
					m.risks_taken += 1
			"ticket_ignored":
				m.tickets_ignored += 1
			"consequence_triggered":
				m.consequences_triggered += 1
			"tool_used":
				var tool = entry.get("tool_name", "unknown")
				m.tools_used[tool] = m.tools_used.get(tool, 0) + 1
				
	if m.tickets_completed > 0:
		m.avg_completion_time = m.total_completion_time / m.tickets_completed
		
	return m

func _calculate_archetype(m: Dictionary) -> String:
	var m_struct = OpenStruct.new(m)
	for archetype_name in ARCHETYPE_DEFINITIONS:
		var definition = ARCHETYPE_DEFINITIONS[archetype_name]
		if definition.condition.call(m_struct):
			return archetype_name
	return GlobalConstants.ARCHETYPE.PRAGMATIC

# Helper: Log tool usage via ConsequenceEngine to ensure it persists in history
func log_tool_used(tool_name: String):
	if ConsequenceEngine:
		ConsequenceEngine.log_player_choice("tool_used", {"tool_name": tool_name})

class OpenStruct:
	var _data: Dictionary
	func _init(data: Dictionary): _data = data
	func _get(property): return _data.get(property)
