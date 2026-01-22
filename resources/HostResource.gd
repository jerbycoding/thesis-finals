# HostResource.gd
extends Resource
class_name HostResource

@export var hostname: String = "UNKNOWN-HOST"
@export var ip_address: String = "0.0.0.0"
@export var is_critical: bool = false
@export var os_type: String = "Linux" # "Windows", "Linux", "Network"

# Potential initial state overrides
@export_enum("CLEAN", "SUSPICIOUS", "INFECTED") var initial_status: String = "CLEAN"

func _to_string() -> String:
	return "[Host: %s (%s)]" % [hostname, ip_address]

func validate() -> bool:
	if hostname.is_empty() or hostname == "UNKNOWN-HOST":
		return false
	return true

func get_status_string() -> String:
	# Fetch dynamic status from NetworkState autoload if it exists in the tree
	var ns = Engine.get_main_loop().root.get_node_or_null("NetworkState")
	if ns:
		var state = ns.get_host_state(hostname)
		if state.has("status"):
			var s = state["status"]
			if typeof(s) == TYPE_INT:
				match s:
					0: return "CLEAN"
					1: return "SUSPICIOUS"
					2: return "INFECTED"
					3: return "ISOLATED"
			return str(s)
	return initial_status

func get_criticality_string() -> String:
	return "Critical" if is_critical else "Standard"
