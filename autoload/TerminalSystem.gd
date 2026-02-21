# TerminalSystem.gd
# Autoload singleton that manages terminal commands and their effects
extends Node

var is_locked: bool = false
var lock_timer: Timer
var scan_multiplier: float = 1.0 # Multiplier for scan time (affected by ZERO_DAY)
var ddos_multiplier: float = 1.0 # Multiplier for network ops (affected by DDOS_ATTACK)
var isp_multiplier: float = 1.0 # Multiplier for network latency (affected by ISP_THROTTLING)

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
	"trace": {
		"description": "Trace IP to origin host",
		"syntax": "trace [ip_address]",
		"risk_level": 1
	},
	"isolate": {
		"description": "Disconnect host from network (HIGH RISK)",
		"syntax": "isolate [hostname]",
		"risk_level": 5
	},
	"restore": {
		"description": "Reconnect an isolated host to the network",
		"syntax": "restore [hostname]",
		"risk_level": 1
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

func _ready():
	print("========================================")
	print("TerminalSystem initialized")
	print("========================================")
	lock_timer = Timer.new()
	add_child(lock_timer)
	lock_timer.one_shot = true
	lock_timer.timeout.connect(_unlock_terminal)
	
	EventBus.world_event_triggered.connect(_on_world_event)

func _on_world_event(event_id: String, active: bool, _duration: float):
	if event_id == GlobalConstants.EVENTS.ZERO_DAY:
		scan_multiplier = 1.5 if active else 1.0
		print("TerminalSystem: ZERO_DAY event ", "ACTIVE" if active else "CLEARED", ". Scan multiplier: ", scan_multiplier)
	elif event_id == GlobalConstants.EVENTS.DDOS_ATTACK:
		ddos_multiplier = 3.0 if active else 1.0
		print("TerminalSystem: DDOS_ATTACK event ", "ACTIVE" if active else "CLEARED", ". Network multiplier: ", ddos_multiplier)
	elif event_id == GlobalConstants.EVENTS.ISP_THROTTLING:
		isp_multiplier = 3.0 if active else 1.0
		print("TerminalSystem: ISP_THROTTLING event ", "ACTIVE" if active else "CLEARED", ". Latency multiplier: ", isp_multiplier)


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
	return await _execute_command_internal(command_name, args)

func _execute_command_internal(command_name: String, args: Array) -> Dictionary:
	var result: Dictionary
	match command_name:
		"help":
			result = _cmd_help()
		"scan":
			result = await _cmd_scan(args)
		"trace":
			result = await _cmd_trace(args)
		"isolate":
			result = _cmd_isolate(args)
		"restore":
			result = _cmd_restore(args)
		"status":
			result = _cmd_status()
		"logs":
			result = await _cmd_logs(args)
		"list":
			result = _cmd_list()
		_:
			result = {"success": false, "output": "Error: Command not implemented"}
			
	# GLOBAL EMIT
	if result.get("success", false):
		EventBus.terminal_command_run.emit(command_name, args)
		
	EventBus.terminal_command_executed.emit(command_name, result.get("success", false), result.get("output", ""))
		
	return result


func _cmd_help() -> Dictionary:
	var output = "[b]Available Commands:[/b]\n\n"
	for cmd_name in commands:
		var cmd = commands[cmd_name]
		output += "[color=green]" + cmd_name + "[/color] - " + cmd.description + "\n"
		output += "  Syntax: " + cmd.syntax + "\n"
		output += "  Risk Level: " + str(cmd.risk_level) + "/5\n\n"
	
	output += "[i]Tip: For detailed guides on all SOC tools, open the [color=cyan]SOC Handbook[/color] on your desktop.[/i]\n"
	return {"success": true, "output": output}

func _cmd_scan(args: Array) -> Dictionary:
	if args.is_empty():
		return {"success": false, "output": CorporateVoice.get_formatted_phrase("command_requires_hostname", {"command": "scan"})}
	
	var hostname = args[0].to_upper()
	var host_info = NetworkState.get_host_state(hostname)
	
	if host_info.is_empty():
		return {"success": false, "output": CorporateVoice.get_phrase("unknown_host")}

	# Legacy OS Check (Mechanical Variety)
	if host_info.get("os") == "Legacy":
		return {
			"success": false, 
			"output": "[color=red]ERROR: Legacy Protocol Unsupported.[/color]\nActive forensic scanning is disabled for this kernel version. Use SIEM for passive analysis."
		}

	# Calculate scan time
	var base_scan_time = 10.0
	var total_scan_time = base_scan_time * scan_multiplier * isp_multiplier
	
	# Wait for scan to complete
	await get_tree().create_timer(total_scan_time).timeout

	# Update scanned status in NetworkState
	NetworkState.update_host_state(hostname, {"scanned": true})

	var output = "[b]" + CorporateVoice.get_formatted_phrase("scanning_host", {"hostname": hostname}) + "[/b]\n"
	output += "Analysis Complete (%.1fs)...\n\n" % total_scan_time
	
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
	
	if not ValidationManager.can_isolate_host(hostname):
		return {"success": false, "output": "ERROR: Host %s must be scanned and confirmed as a threat before isolation sequence can be authorized." % hostname}

	if host_info.get("isolated", false):
		return {"success": true, "output": CorporateVoice.get_formatted_phrase("host_already_isolated", {"hostname": hostname})}

	# --- Perform Isolation ---
	NetworkState.update_host_state(hostname, {"isolated": true, "status": "ISOLATED"})
	var output = "[b]" + CorporateVoice.get_formatted_phrase("isolating_host", {"hostname": hostname}) + "[/b]\n"
	output += "Disconnecting network interfaces...\n"
	output += CorporateVoice.get_formatted_phrase("host_quarantined", {"hostname": hostname}) + "\n"

	# --- Trigger Consequences ---
	var was_scanned = host_info.get("scanned", false)
	if not was_scanned:
		EventBus.consequence_triggered.emit(GlobalConstants.CONSEQUENCE_ID.PROCEDURAL_VIOLATION, {"hostname": hostname, "reason": "unjustified_isolation"})

	# If host was critical, trigger a service outage.
	if host_info.get("critical", false):
		output += "\n[color=red]" + CorporateVoice.get_formatted_phrase("critical_server_offline", {"hostname": hostname}) + "[/color]"
		EventBus.critical_host_isolated.emit(hostname)

	
	return {"success": true, "output": output}

func _cmd_restore(args: Array) -> Dictionary:
	if args.is_empty():
		return {"success": false, "output": CorporateVoice.get_formatted_phrase("command_requires_hostname", {"command": "restore"})}
	
	var hostname = args[0].to_upper()
	var host_info = NetworkState.get_host_state(hostname)
	
	if host_info.is_empty():
		return {"success": false, "output": CorporateVoice.get_phrase("unknown_host")}
	
	if not host_info.get("isolated", false):
		return {"success": true, "output": "Host %s is already connected to the network." % hostname}

	# --- Perform Restoration ---
	NetworkState.update_host_state(hostname, {"isolated": false, "status": "CLEAN"})
	var output = "[b]" + CorporateVoice.get_formatted_phrase("restoring_host", {"hostname": hostname}) + "[/b]\n"
	output += CorporateVoice.get_formatted_phrase("host_restored", {"hostname": hostname}) + "\n"

	# Global signal for ticket verification (matches the TicketManager listener for 'isolate')
	EventBus.terminal_command_run.emit("restore", [hostname])
	
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
		
	# Simulate fetch delay
	await get_tree().create_timer(1.0 * isp_multiplier).timeout

	var output = "[b]" + CorporateVoice.get_formatted_phrase("fetching_logs_for_host", {"hostname": hostname}) + "[/b]\n\n"
	
	# Fetch actual historical logs from LogSystem
	var historical_logs: Array[LogResource] = []
	if LogSystem:
		for log in LogSystem.get_all_logs():
			if log.hostname.to_upper() == hostname:
				historical_logs.append(log)
	
	if historical_logs.is_empty():
		output += CorporateVoice.get_phrase("no_security_events")
	else:
		# Sort by timestamp descending (newest first)
		historical_logs.sort_custom(func(a, b): return a.timestamp > b.timestamp)
		
		# Show last 5 logs for brevity
		var display_count = min(5, historical_logs.size())
		for i in range(display_count):
			var log = historical_logs[i]
			var color = log.get_severity_color().to_html()
			output += "[color=#%s]%s[/color] - %s: %s\n" % [color, log.timestamp, log.source, log.message]
			
		if historical_logs.size() > 5:
			output += "\n[i](Showing 5 of %d events. Use SIEM for full forensic history.)[/i]" % historical_logs.size()
		
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

func _cmd_trace(args: Array) -> Dictionary:
	if args.is_empty():
		return {"success": false, "output": "Syntax Error: trace [ip_address] required."}
	
	var target_ip = args[0]
	var output = "Tracing route to %s...\n\n" % target_ip
	
	# Simulate hop delay (affected by DDOS and ISP throttling)
	var hop_delay = 0.8 * ddos_multiplier * isp_multiplier
	var max_hops = 4
	
	# Generate fake intermediate hops
	for i in range(1, max_hops):
		if ddos_multiplier > 1.0 or isp_multiplier > 1.0:
			output += "[color=orange][!] PACKET LOSS DETECTED... RETRYING...[/color]\n"
		await get_tree().create_timer(hop_delay).timeout
		var fake_ip = "192.168.%d.%d" % [randi()%255, randi()%255]
		output += "  %d    %d ms    %s\n" % [i, randi_range(10, 50) * ddos_multiplier * isp_multiplier, fake_ip]
		
		# If traceroute is executed via command_run/command_executed signal, we might want to update partial output
		# But since this function returns the final output, we just wait.
	
	await get_tree().create_timer(hop_delay).timeout
	
	# Resolve final hop
	var resolved_host = NetworkState.get_host_by_ip(target_ip)
	
	if resolved_host != "":
		output += "  %d    %d ms    %s [%s]\n" % [max_hops, randi_range(10, 40) * ddos_multiplier, target_ip, resolved_host]
		output += "\n[color=green]Trace complete. Origin identified: " + resolved_host + "[/color]"
	else:
		output += "  %d    %d ms    %s [EXTERNAL]\n" % [max_hops, randi_range(50, 150) * ddos_multiplier, target_ip]
		output += "\n[color=yellow]Trace complete. Origin is outside local network.[/color]"
		
	return {"success": true, "output": output}


func lock_terminal(seconds: float):
	is_locked = true
	lock_timer.start(seconds)
	EventBus.terminal_locked.emit(seconds)

func _unlock_terminal():
	is_locked = false
	EventBus.terminal_unlocked.emit()

func is_terminal_locked() -> bool:
	return is_locked
