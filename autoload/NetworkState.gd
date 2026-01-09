# NetworkState.gd
# Autoload singleton to manage the state of all hosts in the simulated network.
extends Node

# The single source of truth for host information.
var host_states: Dictionary = {
	# Pre-defined critical servers
	"FINANCE-SRV-01": {"status": "CLEAN", "critical": true, "isolated": false},
	"WEB-SRV-01": {"status": "CLEAN", "critical": true, "isolated": false},
	"DB-SRV-01": {"status": "CLEAN", "critical": true, "isolated": false},
	# Initial infected host from TerminalSystem
	"WORKSTATION-45": {"status": "INFECTED", "critical": false, "isolated": false}
}

func _ready():
	print("========================================")
	print("NetworkState initialized")
	_discover_hosts_from_resources()
	print("========================================")

func _discover_hosts_from_resources():
	print("🌐 Discovering hosts from resource files...")
	var resource_files = [
		# Tickets
		"res://resources/tickets/ticket_data_exfiltration.gd",
		"res://resources/tickets/ticket_malware_containment.gd",
		"res://resources/tickets/ticket_phishing_01.gd",
		"res://resources/tickets/ticket_spear_phish.gd",
		# Logs
		"res://resources/logs/log_auth_failure.gd",
		"res://resources/logs/log_email_blocked.gd",
		"res://resources/logs/log_exfil_001.gd",
		"res://resources/logs/log_malware_001.gd",
		"res://resources/logs/log_malware_beacon.gd",
		"res://resources/logs/log_network_001.gd",
		"res://resources/logs/log_network_scan.gd",
		"res://resources/logs/log_phishing_attempt.gd",
		"res://resources/logs/log_system_normal.gd",
		"res://resources/logs/log_user_clicked.gd"
	]
	
	var regex = RegEx.new()
	# This regex finds words that look like hostnames (e.g., WORD-WORD-123)
	regex.compile("([A-Z0-9]+-[A-Z0-9-]+)")

	for file_path in resource_files:
		if not ResourceLoader.exists(file_path):
			print("  - WARNING: Resource file not found: ", file_path)
			continue
			
		var resource_script = load(file_path)
		if not resource_script:
			continue
			
		var instance = resource_script.new()
		
		# Handle Ticket Resources
		if instance is TicketResource:
			# Search in description
			var results = regex.search_all(instance.description)
			for result in results:
				register_host(result.get_string().to_upper())
				
			# Search in steps
			for step in instance.steps:
				results = regex.search_all(step)
				for result in results:
					register_host(result.get_string().to_upper())
		
		# Handle Log Resources
		elif instance is LogResource:
			if not instance.hostname.is_empty():
				register_host(instance.hostname.to_upper())



# Registers a host if it's not already known.
func register_host(hostname: String, initial_state: Dictionary = {"status": "CLEAN", "critical": false, "isolated": false}):
	if not host_states.has(hostname):
		host_states[hostname] = initial_state
		print("  ✓ Registered new host: ", hostname)

# Returns the state dictionary for a given host.
func get_host_state(hostname: String) -> Dictionary:
	return host_states.get(hostname, {})

# Updates the state of a specific host.
func update_host_state(hostname: String, new_state: Dictionary):
	if host_states.has(hostname):
		# Merge the new state into the existing one to avoid overwriting fields.
		for key in new_state:
			host_states[hostname][key] = new_state[key]
	else:
		print("⚠ WARNING: Tried to update non-existent host: ", hostname)

# Returns all known hostnames.
func get_all_hostnames() -> Array[String]:
	var string_keys: Array[String] = []
	string_keys.assign(host_states.keys())
	return string_keys
