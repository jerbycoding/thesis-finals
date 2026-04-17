# IntelligenceResource.gd
# Data structure for stolen artifacts in the hacker campaign.
extends Resource
class_name IntelligenceResource

@export var source_hostname: String = ""
@export var data_type: String = "generic" # "credentials", "blueprint", "comms", etc.
@export var data_label: String = "Fragmented Data" # e.g., "CEO Email Archive"
@export var shift_day: int = 0
@export var is_partial: bool = false
@export var trace_cost_total: float = 0.0

func _to_string() -> String:
	var prefix = "[PARTIAL] " if is_partial else ""
	return "%s%s (%s from %s)" % [prefix, data_label, data_type, source_hostname]
