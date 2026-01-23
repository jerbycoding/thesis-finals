# VariableRegistry.gd
# Autoload singleton that provides procedural data for incidents.
# Ensures semantic consistency across all tools (SIEM, Email, Ticket).
extends Node

var pool: VariablePool = null

# --- Logic ---

## Generates a new Truth Packet for an incident.
func generate_truth_packet(ticket_id: String) -> Dictionary:
	if not pool:
		push_error("VariableRegistry: VariablePool not loaded!")
		return {}
		
	var employee = pool.employees.pick_random()
	var attacker_ip = pool.attacker_ips.pick_random()
	var domain = pool.malicious_domains.pick_random()
	
	# Try to get a random host from NetworkState if available
	var victim_host = "WS-UNKNOWN"
	if NetworkState:
		var hostnames = NetworkState.get_all_hostnames()
		if not hostnames.is_empty():
			# Prefer non-critical hosts for random phishing
			var workstations = []
			for h in hostnames:
				if not NetworkState.get_host_state(h).get("critical", false):
					workstations.append(h)
			
			if not workstations.is_empty():
				victim_host = workstations.pick_random()
			else:
				victim_host = hostnames.pick_random()

	var packet = {
		"context_id": "UID_" + str(randi() % 100000),
		"ticket_id": ticket_id,
		"victim_name": employee.name,
		"victim_dept": employee.dept,
		"victim_role": employee.role,
		"victim_host": victim_host,
		"attacker_ip": attacker_ip,
		"malicious_url": domain,
		"timestamp": Time.get_time_string_from_system(),
		"is_vulnerable": randf() < 0.3 # 30% base chance host is actually exploitable
	}
	
	print("VariableRegistry: Generated Truth Packet for %s [%s]" % [ticket_id, packet.context_id])
	return packet

func _ready():
	_load_pool()
	print("VariableRegistry initialized.")

func _load_pool():
	var path = "res://resources/VariablePool.tres"
	if ResourceLoader.exists(path):
		pool = load(path)
		print("VariableRegistry: Data pool loaded from %s" % path)
	else:
		push_error("VariableRegistry: Could not find VariablePool.tres at %s" % path)
