# HostResource.gd
extends Resource
class_name HostResource

@export var hostname: String = "UNKNOWN-HOST"
@export var ip_address: String = "0.0.0.0"
@export var is_critical: bool = false
@export var os_type: String = "Linux" # "Windows", "Linux", "Network"

# Potential initial state overrides
@export_enum("CLEAN", "SUSPICIOUS", "INFECTED") var initial_status: String = "CLEAN"

# === SOLO DEV PHASE 2: HACKER CAMPAIGN FIELDS ===
@export_range(0.0, 1.0, 0.05) var vulnerability_score: float = 0.5  # 0.0-1.0 exploit success chance
@export var is_honeypot: bool = false  # If true, instant LOCKDOWN in Phase 3
@export var data_volume: int = 3 # Number of exfiltration streams (Phase 4)
@export var network_bandwidth: float = 1.0 # Multiplier for exfiltration speed (Phase 4)
@export var data_type: String = "generic" # Type of intel produced: "credentials", "comms", etc.
@export var data_label: String = "Internal Data" # Visual label for stolen data
@export var bounty_value: int = 100 # Points awarded on successful exfiltration/ransom
# ================================================

func _to_string() -> String:
	return "[Host: %s (%s)]" % [hostname, ip_address]

func validate() -> bool:
	if hostname.is_empty() or hostname == "UNKNOWN-HOST":
		return false
	# === PHASE 2: Validate vulnerability_score ===
	if vulnerability_score < 0.0 or vulnerability_score > 1.0:
		push_warning("HostResource: %s has invalid vulnerability_score (%f). Must be 0.0-1.0" % [hostname, vulnerability_score])
		return false
	# ============================================
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

# === PHASE 2: Hacker Campaign Helpers ===
func get_vulnerability_percent() -> int:
	"""Returns vulnerability_score as percentage (0-100)."""
	return int(vulnerability_score * 100)

func is_vulnerable() -> bool:
	"""Returns true if host can be exploited (vulnerability_score > 0)."""
	return vulnerability_score > 0.0
