# VariableRegistry.gd
# Autoload singleton that provides procedural data for incidents.
# Ensures semantic consistency across all tools (SIEM, Email, Ticket).
extends Node

var pool: VariablePool = null

# --- Logic ---

## Generates a new Truth Packet for an incident.
## Generates a technical identity block for a hardware asset
func generate_asset_identity(node_id: String) -> Dictionary:
	seed(node_id.hash()) # Ensure the same router always has the same stats
	
	var mac = "%02X:%02X:%02X:%02X:%02X:%02X" % [randi()%256, randi()%256, randi()%256, randi()%256, randi()%256, randi()%256]
	var serial = "SN-" + str(randi_range(100000, 999999)) + "-X"
	var firmware = "OS-v" + str(randi_range(1, 4)) + "." + str(randi_range(0, 9)) + "." + str(randi_range(0, 9)) + "-STABLE"
	var model = ["NetCore-X1", "Nexus-Alpha", "Cisco-ISR-Mimic", "EdgeGateway-PRO"].pick_random()
	
	var result = {
		"node_id": node_id.to_upper(),
		"model": model,
		"serial": serial,
		"mac_address": mac,
		"firmware": firmware,
		"uptime": str(randi_range(10, 200)) + " Days"
	}
	
	randomize() # Reset to global random pool
	return result

func generate_truth_packet(ticket_id: String) -> Dictionary:
	if not pool:
		push_error("VariableRegistry: VariablePool not loaded!")
		return {}
		
	var employee = pool.employees.pick_random() if not pool.employees.is_empty() else {"name": "Test User", "dept": "IT", "role": "Admin"}
	var attacker_ip = pool.attacker_ips.pick_random() if not pool.attacker_ips.is_empty() else "1.1.1.1"
	var domain = pool.malicious_domains.pick_random() if not pool.malicious_domains.is_empty() else "evil.com"
	
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
		"victim": employee.name, # Alias
		"victim_dept": employee.dept,
		"victim_role": employee.role,
		"victim_host": victim_host,
		"host": victim_host, # Alias
		"attacker_ip": attacker_ip,
		"ip": attacker_ip, # Alias
		"malicious_url": domain,
		"timestamp": Time.get_time_string_from_system(),
		"is_vulnerable": randf() < 0.3 # 30% base chance host is actually exploitable
	}
	
	print("VariableRegistry: Generated Truth Packet for %s [%s]" % [ticket_id, packet.context_id])
	return packet

func generate_partner_packet(ticket_id: String) -> Dictionary:
	"""Generates procedural data for Supply Chain incidents involving third-party partners."""
	var base = generate_truth_packet(ticket_id)
	
	if pool and not pool.partners.is_empty():
		var p = pool.partners.pick_random()
		base["partner_name"] = p.name
		base["partner_service"] = p.service
		base["partner_contact"] = p.contact
	else:
		base["partner_name"] = "CloudServices Inc"
		base["partner_service"] = "Storage"
		base["partner_contact"] = "support@cloudserv.net"
		
	return base

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
