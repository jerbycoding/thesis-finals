# NetworkState.gd
# Autoload singleton to manage the state of all hosts in the simulated network.
extends Node

# Centralized constants for critical system hosts (used for code logic)
const HOSTS = {
	"FINANCE": "FINANCE-SRV-01",
	"WEB": "WEB-SRV-01",
	"DATABASE": "DB-SRV-01"
}

# The single source of truth for host information.
var host_states: Dictionary = {}
var host_resources: Dictionary = {} # hostname -> HostResource

const HOST_DIR = "res://resources/hosts/"

func _ready():
	print("========================================")
	print("NetworkState initialized")
	
	_register_hosts_from_folder.call_deferred()
	
	# Use EventBus for world events
	EventBus.world_event_triggered.connect(_on_world_event)
		
	# Start simulation timer
	var timer = Timer.new()
	timer.wait_time = 10.0
	timer.timeout.connect(_on_simulation_tick)
	add_child(timer)
	timer.start()
	
	print("========================================")

func _register_hosts_from_folder():
	print("🌐 NetworkState: Discovering hosts from %s..." % HOST_DIR)
	host_states.clear()
	
	var loaded_hosts = FileUtil.load_and_validate_resources(HOST_DIR, "HostResource")
	
	for res in loaded_hosts:
		# Register host using resource data
		var initial_state = {
			"status": res.initial_status,
			"critical": res.is_critical,
			"isolated": false,
			"scanned": false,
			"ip": res.ip_address,
			"os": res.os_type
		}
		host_states[res.hostname] = initial_state
		host_resources[res.hostname] = res
		print("  ✓ Registered Host: %s [%s]" % [res.hostname, res.ip_address])
	
	print("🌐 NetworkState: Library ready: %d hosts." % host_states.size())

var lateral_movement_active: bool = false

func _on_world_event(event_id: String, active: bool, _duration: float):
	if event_id == "LATERAL_MOVEMENT":
		lateral_movement_active = active
		if active: print("NetworkState: Lateral movement simulation STARTED")

func _on_simulation_tick():
	if lateral_movement_active:
		_process_lateral_movement()

func _process_lateral_movement():
	# Find infected hosts
	var infected_hosts = []
	var clean_hosts = []
	
	for hostname in host_states:
		var state = host_states[hostname]
		if state.get("status") == "INFECTED" and not state.get("isolated", false):
			infected_hosts.append(hostname)
		elif state.get("status") == "CLEAN":
			clean_hosts.append(hostname)
	
	# If we have infected hosts, try to spread to a random clean host
	if not infected_hosts.is_empty() and not clean_hosts.is_empty():
		# 30% chance to spread per tick
		if randf() < 0.3:
			var target = clean_hosts.pick_random()
			update_host_state(target, {"status": "INFECTED"})
			print("NetworkState: ALERT! Infection spread to ", target)
			
			if NotificationManager:
				NotificationManager.show_notification("CRITICAL ALERT: Lateral Movement Detected on " + target, "error", 6.0)
			
			if AudioManager:
				AudioManager.play_sfx(AudioManager.SFX.consequence_alert)

# Returns the hostname for a given IP, or empty string if not found.
func get_host_by_ip(ip: String) -> String:
	for hostname in host_states:
		if host_states[hostname].get("ip") == ip:
			return hostname
	return ""

# Returns the state dictionary for a given host.
func get_host_state(hostname: String) -> Dictionary:
	return host_states.get(hostname, {})

# Returns the HostResource for a given hostname.
func get_host(hostname: String) -> HostResource:
	return host_resources.get(hostname)

# Returns all HostResource objects.
func get_all_hosts() -> Array:
	return host_resources.values()

func load_state(data: Dictionary):
	if data:
		host_states = data
		print("NetworkState state loaded.")

# Updates the state of a specific host.
func update_host_state(hostname: String, new_state: Dictionary):
	if host_states.has(hostname):
		# Merge the new state into the existing one to avoid overwriting fields.
		for key in new_state:
			host_states[hostname][key] = new_state[key]
		
		# Emit signals via EventBus
		if new_state.has("status"):
			var status_val = new_state["status"]
			# Convert string status to int if necessary
			var status_int = 0
			if typeof(status_val) == TYPE_STRING:
				match status_val:
					"CLEAN": status_int = GlobalConstants.HOST_STATUS.CLEAN
					"SUSPICIOUS": status_int = GlobalConstants.HOST_STATUS.SUSPICIOUS
					"INFECTED": status_int = GlobalConstants.HOST_STATUS.INFECTED
					"ISOLATED": status_int = GlobalConstants.HOST_STATUS.ISOLATED
			else:
				status_int = status_val
				
			EventBus.host_status_changed.emit(hostname, status_int)
		
		EventBus.host_state_changed.emit(hostname, host_states[hostname])
	else:
		print("⚠ WARNING: Tried to update non-existent host: ", hostname)

# Returns all known hostnames.
func get_all_hostnames() -> Array[String]:
	var string_keys: Array[String] = []
	string_keys.assign(host_states.keys())
	return string_keys
