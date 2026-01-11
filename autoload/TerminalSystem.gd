# TerminalSystem.gd
# Autoload singleton that manages terminal commands and their effects
extends Node

signal command_run(command_name: String, args: Array) # Emitted when a command is successfully run
signal command_executed(command: String, success: bool, output: String) # For UI feedback
signal terminal_locked(seconds: float)
signal terminal_unlocked()
signal critical_host_isolated(hostname: String)

var is_locked: bool = false
var lock_timer: Timer

# Available commands
var commands: Dictionary = {
	"help": {
		"description": "Show available commands",
		"syntax": "help",
		"risk_level": 0
	},
	"scan": {
		"description": "Scan host for malware",
		"syntax": "scan [hostname]",
		"risk_level": 1
	},
	"isolate": {
		"description": "Disconnect host from network (HIGH RISK)",
		"syntax": "isolate [hostname]",
		"risk_level": 5
	},
	"status": {
		"description": "Show system status",
		"syntax": "status",
		"risk_level": 0
	},
	"logs": {
		"description": "Get recent logs from host",
		"syntax": "logs [hostname]",
		"risk_level": 2
	},
	"list": {
		"description": "List known hostnames",
		"syntax": "list",
		"risk_level": 0
	}
}

# -------------------------



func _ready():
	print("========================================")
	print("TerminalSystem initialized")
	print("========================================")
	lock_timer = Timer.new()
	add_child(lock_timer)
	lock_timer.one_shot = true
	lock_timer.timeout.connect(_unlock_terminal)


func execute_command(command_line: String) -> Dictionary:
	# Parse command
	var parts = command_line.strip_edges().split(" ", false)
	if parts.is_empty():
		return {"success": false, "output": "Error: Empty command"}
	
	var command_name = parts[0].to_lower()
	var args = parts.slice(1) if parts.size() > 1 else []
	
	# Check if terminal is locked
	if is_locked:
		var remaining = lock_timer.time_left
		return {
			"success": false,
			"output": CorporateVoice.get_formatted_phrase("terminal_locked_message", {"seconds": str(int(remaining))})
		}
	
	# Check if command exists
	if command_name not in commands:
		return {
			"success": false,
			"output": CorporateVoice.get_phrase("terminal_unknown_command")
		}
	
	# Execute command
	return _execute_command_internal(command_name, args)

func _execute_command_internal(command_name: String, args: Array) -> Dictionary:
	var result: Dictionary
	match command_name:
		"help":
			result = _cmd_help()
		"scan":
			result = _cmd_scan(args)
		"isolate":
			result = _cmd_isolate(args)
		"status":
			result = _cmd_status()
		"logs":
			result = _cmd_logs(args)
		"list":
			result = _cmd_list()
		_:
			result = {"success": false, "output": "Error: Command not implemented"}
			
	# Emit signals on successful command execution
	if result.get("success", false):
		command_run.emit(command_name, args)
		command_executed.emit(command_name, true, result.get("output", ""))
		
	return result


func _cmd_help() -> Dictionary:
	var output = "[b]Available Commands:[/b]\n\n"
	for cmd_name in commands:
		var cmd = commands[cmd_name]
		output += "[color=green]" + cmd_name + "[/color] - " + cmd.description + "\n"
		output += "  Syntax: " + cmd.syntax + "\n"
		output += "  Risk Level: " + str(cmd.risk_level) + "/5\n\n"
	return {"success": true, "output": output}

func _cmd_scan(args: Array) -> Dictionary:
	if args.is_empty():
		return {"success": false, "output": CorporateVoice.get_formatted_phrase("command_requires_hostname", {"command": "scan"})}
	
	var hostname = args[0].to_upper()
	var host_info = NetworkState.get_host_state(hostname)
	
	if host_info.is_empty():
		return {"success": false, "output": CorporateVoice.get_phrase("unknown_host")}

	var output = "[b]" + CorporateVoice.get_formatted_phrase("scanning_host", {"hostname": hostname}) + "[/b]\n"
	output += "Analyzing...\n\n"
	
	if host_info.get("status") == "INFECTED":
		output += "[color=red]⚠ " + CorporateVoice.get_phrase("malware_detected") + "[/color]\n"
		output += CorporateVoice.get_phrase("recommendation_isolate_host")
	else:
		output += "[color=green]✓ " + CorporateVoice.get_phrase("no_malware_detected") + "[/color]\n"
		output += CorporateVoice.get_formatted_phrase("host_clean", {"hostname": hostname})
	
	return {"success": true, "output": output}

func _cmd_isolate(args: Array) -> Dictionary:
	if args.is_empty():
		return {"success": false, "output": CorporateVoice.get_formatted_phrase("command_requires_hostname", {"command": "isolate"})}
	
	var hostname = args[0].to_upper()
	var host_info = NetworkState.get_host_state(hostname)
	
	if host_info.is_empty():
		return {"success": false, "output": CorporateVoice.get_phrase("unknown_host")}
	
	if host_info.get("isolated", false):
		return {"success": true, "output": CorporateVoice.get_formatted_phrase("host_already_isolated", {"hostname": hostname})}

	# --- Perform Isolation ---
	NetworkState.update_host_state(hostname, {"isolated": true})
	var output = "[b]" + CorporateVoice.get_formatted_phrase("isolating_host", {"hostname": hostname}) + "[/b]\n"
	output += "Disconnecting network interfaces...\n"
	output += CorporateVoice.get_formatted_phrase("host_quarantined", {"hostname": hostname}) + "\n"

	# --- Trigger Consequences ---
	# If host was critical, trigger a service outage.
	if host_info.get("critical", false):
		output += "\n[color=red]" + CorporateVoice.get_formatted_phrase("critical_server_offline", {"hostname": hostname}) + "[/color]"
		critical_host_isolated.emit(hostname)

	
	return {"success": true, "output": output}

func _cmd_status() -> Dictionary:
	var output = "[b]" + CorporateVoice.get_phrase("system_status") + "[/b]\n\n"
	var isolated_hosts = []
	var all_hosts = NetworkState.get_all_hostnames()
	
	for host in all_hosts:
		var host_info = NetworkState.get_host_state(host)
		if host_info and host_info.get("isolated", false):
			isolated_hosts.append(host)
	
	output += CorporateVoice.get_phrase("network_status_online") + "\n"
	if not isolated_hosts.is_empty():
		output += CorporateVoice.get_formatted_phrase("isolated_hosts_list", {"hostnames": ", ".join(isolated_hosts)}) + "\n"
	
	output += CorporateVoice.get_phrase("terminal_status_locked" if is_locked else "terminal_status_operational")
	
	return {"success": true, "output": output}

func _cmd_logs(args: Array) -> Dictionary:
	if args.is_empty():
		return {"success": false, "output": CorporateVoice.get_formatted_phrase("command_requires_hostname", {"command": "logs"})}
		
	var hostname = args[0].to_upper()
	var host_info = NetworkState.get_host_state(hostname)
	
	if host_info.is_empty():
		return {"success": false, "output": CorporateVoice.get_phrase("unknown_host")}
		
	var output = "[b]" + CorporateVoice.get_formatted_phrase("fetching_logs_for_host", {"hostname": hostname}) + "[/b]\n\n"
	
	# This is mock data. A real implementation would query LogSystem
	if host_info.get("status") == "INFECTED":
		output += "20:10:15 - WARNING: Unusual process 'svch0st.exe' started.\n"
		output += "20:10:18 - WARNING: Outbound connection to suspicious IP 145.23.1.88.\n"
		output += "20:11:05 - ERROR: Anti-virus service terminated unexpectedly."
	else:
		output += CorporateVoice.get_phrase("no_security_events")
		
	return {"success": true, "output": output}

func _cmd_list() -> Dictionary:
	var output = "[b]" + CorporateVoice.get_phrase("known_hostnames") + "[/b]\n\n"
	var hostnames = NetworkState.get_all_hostnames()
	
	if hostnames.is_empty():
		output += CorporateVoice.get_phrase("no_known_hosts")
	else:
		hostnames.sort() # Sort alphabetically for readability
		for hostname in hostnames:
			var host_info = NetworkState.get_host_state(hostname)
			var status_text = ""
			if host_info and host_info.get("isolated", false):
				status_text = " ([color=orange]ISOLATED[/color])" # Use orange for isolated status
				
			output += "- " + hostname + status_text + "\n"
			
	return {"success": true, "output": output}


func lock_terminal(seconds: float):
	is_locked = true
	lock_timer.start(seconds)
	terminal_locked.emit(seconds)

func _unlock_terminal():
	is_locked = false
	terminal_unlocked.emit()

func is_terminal_locked() -> bool:
	return is_locked
