# VariableRegistry.gd
# Autoload singleton that provides procedural data for incidents.
# Ensures semantic consistency across all tools (SIEM, Email, Ticket).
extends Node

# --- Data Pools ---

const DEPARTMENTS = ["Finance", "Human Resources", "Engineering", "Legal", "Marketing", "Sales", "Executive"]

const EMPLOYEES = [
	{"name": "Alice Vance", "dept": "Finance", "role": "Controller"},
	{"name": "Bob Henderson", "dept": "Engineering", "role": "Lead Architect"},
	{"name": "Charlie Day", "dept": "Marketing", "role": "Manager"},
	{"name": "Diana Prince", "dept": "Legal", "role": "General Counsel"},
	{"name": "Edward Norton", "dept": "Human Resources", "role": "Specialist"},
	{"name": "Frank Castle", "dept": "Executive", "role": "CEO"},
	{"name": "Gwen Stacy", "dept": "Engineering", "role": "Researcher"},
	{"name": "Harry Osborn", "dept": "Executive", "role": "CFO"},
	{"name": "Iris West", "dept": "Marketing", "role": "Copywriter"},
	{"name": "Jack Shephard", "dept": "Finance", "role": "Analyst"}
]

const ATTACKER_IPS = [
	"203.0.113.42", "198.51.100.12", "192.0.2.88", "45.33.22.11", 
	"103.20.15.1", "185.12.44.11", "91.200.12.5", "5.101.0.44"
]

const MALICIOUS_DOMAINS = [
	"verify-update.net", "corporate-auth.biz", "secure-login.io", 
	"cloud-storage-transfer.com", "it-servicedesk.co", "bank-verify.info"
]

# --- Logic ---

## Generates a new Truth Packet for an incident.
func generate_truth_packet(ticket_id: String) -> Dictionary:
	var employee = EMPLOYEES.pick_random()
	var attacker_ip = ATTACKER_IPS.pick_random()
	var domain = MALICIOUS_DOMAINS.pick_random()
	
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
	print("VariableRegistry initialized.")
