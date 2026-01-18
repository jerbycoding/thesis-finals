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
