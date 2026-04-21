# TerminalSystem.gd
# Autoload singleton that manages terminal commands and their effects
extends Node

var is_locked: bool = false
var lock_timer: Timer
var scan_multiplier: float = 1.0 # Multiplier for scan time (affected by ZERO_DAY)
var ddos_multiplier: float = 1.0 # Multiplier for network ops (affected by DDOS_ATTACK)
var isp_multiplier: float = 1.0 # Multiplier for network latency (affected by ISP_THROTTLING)

# Narrative Simulation Overrides (Used by Tutorial/Events)
var active_connections: Dictionary = {} # Hostname -> Array of strings (Remote IPs)
var trace_overrides: Dictionary = {} # IP -> String (Resolved Name)

signal command_output_received(text: String, is_partial: bool)

# Available commands
# Roles: 0 = ANALYST, 1 = HACKER, 2 = BOTH
var commands: Dictionary = {
	"help": {
		"description": "Show available commands",
		"syntax": "help",
		"risk_level": 0,
		"role": 2
	},
	"scan": {
		"description": "Scan host for technical details/malware",
		"syntax": "scan [hostname]",
		"risk_level": 1,
		"role": 2
	},
	"netstat": {
		"description": "Show active network connections",
		"syntax": "netstat [hostname]",
		"risk_level": 1,
		"role": 0
	},
	"trace": {
		"description": "Trace IP to origin host",
		"syntax": "trace [ip_address]",
		"risk_level": 1,
		"role": 0
	},
	"isolate": {
		"description": "Disconnect host from network (HIGH RISK)",
		"syntax": "isolate [hostname]",
		"risk_level": 5,
		"role": 0
	},
	"restore": {
		"description": "Reconnect an isolated host to the network",
		"syntax": "restore [hostname]",
		"risk_level": 1,
		"role": 0
	},
	"status": {
		"description": "Show system status",
		"syntax": "status",
		"risk_level": 0,
		"role": 2
	},
	"logs": {
		"description": "Get recent logs from host",
		"syntax": "logs [hostname]",
		"risk_level": 2,
		"role": 0
	},
	"list": {
		"description": "List known hostnames",
		"syntax": "list",
		"risk_level": 0,
		"role": 2
	},
	# === SOLO DEV PHASE 2: HACKER CAMPAIGN ===
	"exploit": {
		"description": "Exploit host vulnerability",
		"syntax": "exploit [hostname]",
		"risk_level": 5,
		"role": 1
	},
	"pivot": {
		"description": "Move laterally to adjacent host",
		"syntax": "pivot [hostname]",
		"risk_level": 3,
		"role": 1
	},
	"submit": {
		"description": "Submit vulnerability report to broker (advance to next day)",
		"syntax": "submit",
		"risk_level": 0,
		"role": 1
	},
	"spoof": {
		"description": "Mask network identity",
		"syntax": "spoof [mac/ip]",
		"risk_level": 2,
		"role": 1
	},
	"phish": {
		"description": "Establish foothold via social engineering (Low Trace)",
		"syntax": "phish [hostname]",
		"risk_level": 2,
		"role": 1
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

# --- Connection Management (The Forensic Bridge) ---

func register_connection(hostname: String, ip: String):
	var h = hostname.to_upper()
	if not active_connections.has(h):
		active_connections[h] = []
	
	if not ip in active_connections[h]:
		active_connections[h].append(ip)
		print("📡 Terminal: Registered malicious connection: %s -> %s" % [h, ip])

func unregister_connection(hostname: String, ip: String):
	var h = hostname.to_upper()
	if active_connections.has(h):
		active_connections[h].erase(ip)
		if active_connections[h].is_empty():
			active_connections.erase(h)
		print("📡 Terminal: Unregistered connection: %s -> %s" % [h, ip])

func clear_all_connections():
	active_connections.clear()
	trace_overrides.clear()
	print("📡 Terminal: All forensic connections cleared.")

# --------------------------------------------------

func execute_command(command_line: String) -> Dictionary:
	# Parse command
	var parts = command_line.strip_edges().split(" ", false)
	if parts.is_empty():
		return {"success": false, "output": "Error: Empty command"}
	
	var command_name = parts[0].to_lower()
	var args = parts.slice(1) if parts.size() > 1 else []
	
	# === ROLE GUARD ===
	if commands.has(command_name):
		var cmd_def = commands[command_name]
		var current_role = GameState.current_role if GameState else 0 # Default to Analyst
		
		# If command is role-restricted and doesn't match current role (and is not BOTH)
		if cmd_def.has("role") and cmd_def.role != 2:
			if cmd_def.role != current_role:
				return {
					"success": false, 
					"output": "[color=red]Error: Command '%s' not recognized.[/color]" % command_name
				}

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
		"netstat":
			result = await _cmd_netstat(args)
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
		# === SOLO DEV PHASE 2: HACKER COMMAND ===
		"exploit":
			result = _cmd_exploit(args)
		"pivot":
			result = _cmd_pivot(args)
		"submit":
			result = _cmd_submit(args)
		"spoof":
			result = _cmd_spoof(args)
		"phish":
			result = await _cmd_phish(args)
		# =======================================
		_:
			result = {"success": false, "output": "Error: Command not implemented"}

	# GLOBAL EMIT
	if result.get("success", false):
		EventBus.terminal_command_run.emit(command_name, args)

	EventBus.terminal_command_executed.emit(command_name, result.get("success", false), result.get("output", ""))

	# If we have an output but didn't stream it, emit it now as final
	if not result.get("output", "").is_empty():
		command_output_received.emit(result.output, false)
		
	return result


func _cmd_help() -> Dictionary:
	var output = "[b]AVAILABLE TERMINAL COMMANDS[/b]\n"
	output += "--------------------------------------------------\n"

	var current_role = GameState.current_role if GameState else 0

	for cmd_name in commands:
		var cmd = commands[cmd_name]

		# Filter based on role
		if cmd.has("role") and cmd.role != 2:
			if cmd.role != current_role:
				continue

		var syntax = cmd.syntax
		var padding = " ".repeat(max(1, 20 - syntax.length()))
		output += "[color=green]%s[/color]%s - %s\n" % [syntax, padding, cmd.description]

	output += "\n[i]Tip: For detailed guides, open the [color=cyan]Handbook[/color] on your desktop.[/i]\n"
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
	var base_scan_time = 6.0 # Reduced base time slightly for better feel
	var total_scan_time = base_scan_time * scan_multiplier * isp_multiplier
	
	command_output_received.emit("[b]INITIALIZING ENDPOINT SCAN: " + hostname + "[/b]\n", true)
	
	# SIMULATED PROGRESS LOOP
	var steps = [
		"Establishing secure socket...",
		"Querying process list...",
		"Analyzing PE header entropy...",
		"Checking mutex signatures...",
		"Finalizing forensic report..."
	]
	
	for i in range(steps.size()):
		var progress = (float(i+1) / steps.size()) * 100
		var bar = "["
		for j in range(10):
			if j < (i+1) * 2: bar += "#"
			else: bar += "."
		bar += "]"
		
		var line = "%s %d%% - %s\n" % [bar, int(progress), steps[i]]
		command_output_received.emit(line, true)
		
		await get_tree().create_timer(total_scan_time / steps.size()).timeout

	# Update scanned status in NetworkState
	NetworkState.update_host_state(hostname, {"scanned": true})

	var output = "\n"
	if host_info.get("status") == "INFECTED":
		output += "[color=red]⚠ " + CorporateVoice.get_phrase("malware_detected") + "[/color]\n"
		output += CorporateVoice.get_phrase("recommendation_isolate_host")
	else:
		output += "[color=green]✓ " + CorporateVoice.get_phrase("no_malware_detected") + "[/color]\n"
		output += CorporateVoice.get_formatted_phrase("host_clean", {"hostname": hostname})
	
	return {"success": true, "output": output}

func _cmd_netstat(args: Array) -> Dictionary:
	if args.is_empty():
		return {"success": false, "output": CorporateVoice.get_formatted_phrase("command_requires_hostname", {"command": "netstat"})}
	
	var hostname = args[0].to_upper()
	var host_info = NetworkState.get_host_state(hostname)
	
	if host_info.is_empty():
		return {"success": false, "output": CorporateVoice.get_phrase("unknown_host")}

	command_output_received.emit("[b]ANALYZING NETWORK INTERFACES: " + hostname + "[/b]\n", true)
	await get_tree().create_timer(1.0 * isp_multiplier).timeout
	
	var output = "[b]Proto  Local Address          Foreign Address        State[/b]\n"
	
	# Default Loopback
	output += "TCP    127.0.0.1:5354         127.0.0.1:49673        ESTABLISHED\n"
	output += "TCP    192.168.1.105:139      0.0.0.0:0              LISTENING\n"
	
	# Inject Narrative Connections (e.g. Malware C2)
	if active_connections.has(hostname):
		for remote_ip in active_connections[hostname]:
			# Randomize local port for realism
			var local_port = randi_range(49152, 65535) 
			output += "[color=red]TCP    192.168.1.105:%d      %s:443       ESTABLISHED[/color]\n" % [local_port, remote_ip]

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
	command_output_received.emit("[b]RETRIEVING REMOTE LOGS: " + hostname + "[/b]\n", true)
	command_output_received.emit("[####......] 40% - Requesting packet capture...\n", true)
	await get_tree().create_timer(0.5 * isp_multiplier).timeout
	command_output_received.emit("[#######...] 70% - Parsing event stream...\n", true)
	await get_tree().create_timer(0.5 * isp_multiplier).timeout
	command_output_received.emit("[##########] 100% - Transfer complete.\n\n", true)

	var output = ""
	
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
	var hostnames = NetworkState.get_all_hostnames()
	
	if hostnames.is_empty():
		return {"success": true, "output": "No nodes found in local segment."}
	
	hostnames.sort()
	
	var output = "[b]Hostname             Status          Details[/b]\n"
	output += "--------------------------------------------------\n"
	
	for hostname in hostnames:
		var host_info = NetworkState.get_host_state(hostname)
		var host_resource = NetworkState.get_host(hostname)
		
		var status_text = "ONLINE"
		var color = "green"
		
		if host_info and host_info.get("isolated", false):
			status_text = "ISOLATED"
			color = "orange"
		elif host_info and host_info.get("status") == "INFECTED":
			status_text = "THREAT"
			color = "red"
			
		var details = ""
		if GameState and GameState.current_role == GameState.Role.HACKER:
			# Show Effective Vulnerability (which decays after failed attempts)
			var vuln = host_info.get("effective_vulnerability", host_resource.vulnerability_score if host_resource else 0.5)
			var v_color = "green" if vuln > 0.25 else ("yellow" if vuln > 0.1 else "red")
			
			if vuln < 0.05:
				details = "[color=red][HARDENED][/color]"
			else:
				details = "[color=%s]VULN: %.0f%%[/color]" % [v_color, vuln * 100]
		else:
			details = host_resource.os_version if host_resource else "Unknown OS"
			
		# Simple manual padding for tabular look
		var padding = " ".repeat(max(1, 20 - hostname.length()))
		var status_padding = " ".repeat(max(1, 15 - status_text.length()))
		
		output += "%s%s[color=%s]%s[/color]%s%s\n" % [hostname, padding, color, status_text, status_padding, details]

	return {"success": true, "output": output}

func _cmd_trace(args: Array) -> Dictionary:
	if args.is_empty():
		return {"success": false, "output": "Syntax Error: trace [ip_address] required."}
	
	var target_ip = args[0]
	command_output_received.emit("Tracing route to " + target_ip + "...\n\n", true)
	
	# Simulate hop delay (affected by DDOS and ISP throttling)
	var hop_delay = 0.6 * ddos_multiplier * isp_multiplier
	var max_hops = 4
	
	# Generate fake intermediate hops
	for i in range(1, max_hops):
		if ddos_multiplier > 1.0 or isp_multiplier > 1.0:
			command_output_received.emit("[color=orange][!] PACKET LOSS DETECTED... RETRYING...[/color]\n", true)
		
		await get_tree().create_timer(hop_delay).timeout
		var fake_ip = "192.168.%d.%d" % [randi()%255, randi()%255]
		var line = "  %d    %d ms    %s\n" % [i, randi_range(10, 50) * ddos_multiplier * isp_multiplier, fake_ip]
		command_output_received.emit(line, true)
	
	await get_tree().create_timer(hop_delay).timeout
	
	# Resolve final hop
	var resolved_host = NetworkState.get_host_by_ip(target_ip)
	var output = ""
	
	# Check for Narrative Override (Tutorial/Events)
	if trace_overrides.has(target_ip):
		var override_name = trace_overrides[target_ip]
		output += "  %d    %d ms    %s [%s]\n" % [max_hops, randi_range(10, 40) * ddos_multiplier, target_ip, override_name]
		output += "\n[color=red]Trace complete. TARGET IDENTIFIED: " + override_name + "[/color]"
	elif resolved_host != "":
		output += "  %d    %d ms    %s [%s]\n" % [max_hops, randi_range(10, 40) * ddos_multiplier, target_ip, resolved_host]
		output += "\n[color=green]Trace complete. Origin identified: " + resolved_host + "[/color]"
	else:
		output += "  %d    %d ms    %s [EXTERNAL]\n" % [max_hops, randi_range(50, 150) * ddos_multiplier, target_ip]
		output += "\n[color=yellow]Trace complete. Origin is outside local network.[/color]"
		
	return {"success": true, "output": output}


# === SOLO DEV PHASE 2: HACKER CAMPAIGN COMMANDS ===
func _cmd_exploit(args: Array) -> Dictionary:
	"""
	Exploit host vulnerability.
	6-step execution: Null Guard → Hardening → Ownership → Honeypot → Success/Fail → Signal
	"""
	# === STEP 1: NULL GUARD ===
	if args.is_empty():
		return {"success": false, "output": "[color=red]ERROR: Missing hostname.[/color]\nSyntax: exploit [hostname]\nExample: exploit WEB-SRV-01"}
	
	var hostname = args[0].to_upper()
	var host_info = NetworkState.get_host_state(hostname)
	
	if host_info.is_empty():
		return {"success": false, "output": "[color=red]ERROR: Host not found.[/color]\nUse 'list' to see known hostnames."}
	
	# === STEP 1.5: HARDENING GUARD ===
	var attack_count = host_info.get("attack_count", 0)
	if attack_count >= 3:
		return {
			"success": false,
			"output": "[color=red]⚠ ACCESS DENIED: SYSTEM HARDENED[/color]\nMultiple failed exploit attempts detected. The target has patched the vulnerability.\n[i]Tactical Advice: Technical exploits are no longer possible. Use Phishing or Lateral Pivoting.[/i]"
		}

	# === STEP 2: OWNERSHIP GUARD ===
	if GameState.hacker_footholds.has(hostname):
		return {"success": false, "output": "[color=yellow]Host already compromised.[/color]\n%s is under your control." % hostname}
	
	# === STEP 3: HONEYPOT BRANCH ===
	var host_resource = NetworkState.get_host(hostname)
	if host_resource and host_resource.is_honeypot:
		# Honeypot detected! Instant LOCKDOWN — emit signal with max trace cost
		var result_data = _create_exploit_payload(hostname, "HONEYPOT")
		result_data["trace_cost"] = 100.0  # Instant LOCKDOWN
		EventBus.offensive_action_performed.emit(result_data)

		print("⚠ HONEYPOT: Exploited %s — instant LOCKDOWN!" % hostname)

		return {
			"success": false,
			"output": "[color=red]⚠ HONEYPOT DETECTED![/color]\nThis system was a trap!\nYour access has been logged."
		}
	
	# === STEP 4: SUCCESS/FAIL CHECK ===
	var roll = randf()  # 0.0-1.0
	var vulnerability = host_info.get("effective_vulnerability", host_resource.vulnerability_score if host_resource else 0.5)
	var success = roll < vulnerability
	
	# === STEP 5 & 6: RESULT PATH ===
	if success:
		# SUCCESS! Add to footholds
		var timestamp = ShiftClock.elapsed_seconds
		GameState.hacker_footholds[hostname] = timestamp

		# Set as current foothold for ransomware app targeting
		GameState.current_foothold = hostname

		# Emit success signal
		var result_data = _create_exploit_payload(hostname, "SUCCESS")
		EventBus.offensive_action_performed.emit(result_data)
		
		return {
			"success": true,
			"output": "[color=green]✓ EXPLOIT SUCCESSFUL![/color]\nVulnerability exploited: %s\nAccess level: ROOT\nFoothold established." % hostname
		}
	else:
		# FAILED! 
		attack_count += 1
		
		# SUCCESS CHANCE DECAY: Reduce vulnerability by 60% after every fail
		var new_vuln = vulnerability * 0.4
		NetworkState.update_host_state(hostname, {
			"attack_count": attack_count,
			"effective_vulnerability": new_vuln
		})
		
		var trace_cost = GlobalConstants.TRACE_COST.EXPLOIT
		var hardening_note = ""
		
		if attack_count == 2:
			trace_cost *= 2.0
			hardening_note = "\n[color=orange][!] ALERT: Target IDS has flagged your IP. Detection risk DOUBLED.[/color]\n[color=red]Terminal locked for 15 seconds.[/color]"
			lock_terminal(15.0)
		
		# Still emit signal (trace still increases)
		var result_data = _create_exploit_payload(hostname, "FAILED")
		result_data["trace_cost"] = trace_cost # Apply hardening multiplier
		EventBus.offensive_action_performed.emit(result_data)
		
		return {
			"success": false,
			"output": "[color=red]✗ EXPLOIT FAILED![/color]\nTarget defenses blocked the attack.\nVulnerability score: %.0f%% (Attempts: %d/3)%s" % [vulnerability * 100, attack_count, hardening_note]
		}

func _create_exploit_payload(hostname: String, result: String) -> Dictionary:
	"""Helper: Create standardized signal payload for exploit actions."""
	var shift_day = 0
	if NarrativeDirector:
		shift_day = NarrativeDirector.current_hacker_day if NarrativeDirector.has_node("NarrativeDirector") else 0

	return {
		"action_type": "exploit",
		"target": hostname,
		"timestamp": ShiftClock.elapsed_seconds,
		"result": result,  # SUCCESS, FAILED, or HONEYPOT
		"trace_cost": GlobalConstants.TRACE_COST.EXPLOIT,
		"shift_day": shift_day  # === PHASE 2: Added for HackerHistory ===
	}

func _cmd_pivot(args: Array) -> Dictionary:
	"""
	Pivot laterally to an adjacent host.
	Evades RivalAI isolation countdown during LOCKDOWN.
	Trace is NOT cleared — AI transitions to SEARCHING instead.
	"""
	# === STEP 1: NULL GUARD ===
	if args.is_empty():
		return {"success": false, "output": "[color=red]ERROR: Missing hostname.[/color]\nSyntax: pivot [hostname]\nExample: pivot DB-SRV-01"}

	var hostname = args[0].to_upper()
	var host_info = NetworkState.get_host_state(hostname)

	if host_info.is_empty():
		return {"success": false, "output": "[color=red]ERROR: Host not found.[/color]\nUse 'list' to see known hostnames."}

	# === STEP 2: OWNERSHIP GUARD — must have a foothold to pivot from ===
	if GameState.hacker_footholds.is_empty():
		return {"success": false, "output": "[color=red]ERROR: No active footholds.[/color]\nExploit a host first before pivoting."}

	# === STEP 3: PIVOT SUCCESS CHECK ===
	var host_resource = NetworkState.get_host(hostname)
	var roll = randf()
	var vulnerability = host_resource.vulnerability_score if host_resource else 0.5
	var success = roll < vulnerability

	if success:
		# Add new host as foothold, keep old ones
		var timestamp = ShiftClock.elapsed_seconds
		if not GameState.hacker_footholds.has(hostname):
			GameState.hacker_footholds[hostname] = timestamp

		# Update current foothold
		var old_foothold = GameState.current_foothold
		GameState.current_foothold = hostname

		# === PIVOT EVASION: Abort RivalAI isolation if active ===
		if RivalAI and RivalAI.is_isolation_active:
			RivalAI.abort_isolation()

		# Emit signal with evasion result
		var shift_day = 0
		if NarrativeDirector:
			shift_day = NarrativeDirector.current_hacker_day if NarrativeDirector.has_node("NarrativeDirector") else 0

		EventBus.offensive_action_performed.emit({
			"action_type": "pivot",
			"target": hostname,
			"timestamp": ShiftClock.elapsed_seconds,
			"result": "EVASION",
			"trace_cost": GlobalConstants.TRACE_COST.PIVOT,
			"shift_day": shift_day
		})

		var evasion_note = ""
		if RivalAI and RivalAI.is_isolation_active == false and old_foothold != "":
			evasion_note = "\n[color=yellow]🛡 Isolation aborted! AI returned to SEARCHING state.[/color]"

		return {
			"success": true,
			"output": "[color=green]✓ PIVOT SUCCESSFUL![/color]\nLateral movement to %s complete.\nNew foothold established.%s" % [hostname, evasion_note]
		}
	else:
		# Pivot failed — still costs trace
		var shift_day = 0
		if NarrativeDirector:
			shift_day = NarrativeDirector.current_hacker_day if NarrativeDirector.has_node("NarrativeDirector") else 0

		EventBus.offensive_action_performed.emit({
			"action_type": "pivot",
			"target": hostname,
			"timestamp": ShiftClock.elapsed_seconds,
			"result": "FAILED",
			"trace_cost": GlobalConstants.TRACE_COST.PIVOT,
			"shift_day": shift_day
		})

		return {
			"success": false,
			"output": "[color=red]✗ PIVOT FAILED![/color]\nTarget defenses blocked lateral movement.\nVulnerability score: %.0f%%" % (vulnerability * 100)
		}

# === SOLO DEV PHASE 5: HACKER DAY ADVANCEMENT ===
func _cmd_submit(_args: Array) -> Dictionary:
	"""Submit vulnerability report and advance to next day. HACKER ONLY."""
	if not GameState or GameState.current_role != GameState.Role.HACKER:
		return {"success": false, "output": "[color=red]ERROR: This command is only available in the Hacker campaign.[/color]"}

	if not NarrativeDirector or not NarrativeDirector.has_method("advance_hacker_day"):
		return {"success": false, "output": "[color=red]ERROR: Narrative system not initialized.[/color]"}

	var current_day = NarrativeDirector.current_hacker_day
	NarrativeDirector.advance_hacker_day()
	var next_day = NarrativeDirector.current_hacker_day

	if next_day > current_day:
		return {
			"success": true,
			"output": "[color=green]✓ VULNERABILITY REPORT SUBMITTED.[/color]\nPayment confirmed. Next assignment available.\nLoading Day %d..." % next_day
		}
	else:
		return {
			"success": true,
			"output": "[color=yellow]✓ VULNERABILITY REPORT SUBMITTED.[/color]\nCampaign complete. No further assignments available."
		}

func _cmd_spoof(args: Array) -> Dictionary:
	"""
	Mask network identity.
	Reduces trace_cost of subsequent actions until rotation or detection.
	"""
	if args.is_empty():
		return {"success": false, "output": "[color=red]ERROR: Identity mask required.[/color]\nSyntax: spoof [mac/ip]"}
	
	var mask = args[0]
	GameState.active_spoof_identity = {
		"mask": mask,
		"timestamp": ShiftClock.elapsed_seconds,
		"efficiency": 0.5 # 50% trace reduction
	}
	
	# Emit signal
	EventBus.offensive_action_performed.emit({
		"action_type": "spoof",
		"target": mask,
		"timestamp": ShiftClock.elapsed_seconds,
		"result": "SUCCESS",
		"trace_cost": GlobalConstants.TRACE_COST.SPOOF,
		"shift_day": NarrativeDirector.current_hacker_day if NarrativeDirector else 0
	})
	
	return {
		"success": true,
		"output": "[color=green]✓ IDENTITY MASKED.[/color]\nMAC/IP Spoof active: %s\nTrace footprint reduced by 50%%." % mask
	}

func _cmd_phish(args: Array) -> Dictionary:
	"""
	Establish foothold via social engineering.
	Low Trace, but success is dependent on Heat level and host vulnerability.
	"""
	if args.is_empty():
		return {"success": false, "output": "[color=red]ERROR: Target host required.[/color]\nSyntax: phish [hostname]"}
		
	var hostname = args[0].to_upper()
	var host_info = NetworkState.get_host_state(hostname)
	
	if host_info.is_empty():
		return {"success": false, "output": CorporateVoice.get_phrase("unknown_host")}
		
	if GameState.hacker_footholds.has(hostname):
		return {"success": false, "output": "[color=yellow]Target already compromised.[/color]"}

	command_output_received.emit("[b]PREPARING PHISHING CAMPAIGN: " + hostname + "[/b]\n", true)
	command_output_received.emit("Gathering OSINT data...\n", true)
	await get_tree().create_timer(1.0).timeout
	command_output_received.emit("Crafting spear-phish payload...\n", true)
	await get_tree().create_timer(1.5).timeout
	command_output_received.emit("Sending delivery packets...\n", true)
	await get_tree().create_timer(0.5).timeout
	
	# Success Formula: (vulnerability_score * 0.8) / HeatManager.heat_multiplier
	var host_res = NetworkState.get_host(hostname)
	var vuln = host_res.vulnerability_score if host_res else 0.5
	var heat = HeatManager.heat_multiplier if HeatManager else 1.0
	
	# Apply Security Awareness Penalty (50% reduction per failure)
	var phish_fail_count = host_info.get("phish_fail_count", 0)
	var awareness_multiplier = 1.0
	if phish_fail_count > 0:
		awareness_multiplier = pow(0.5, phish_fail_count)
		command_output_received.emit("[color=orange][!] WARNING: Target has 'Security Awareness' active. Success chance reduced.[/color]\n", true)
	
	var success_chance = (vuln * 0.8 * awareness_multiplier) / heat
	var roll = randf()
	
	if roll < success_chance:
		GameState.hacker_footholds[hostname] = ShiftClock.elapsed_seconds
		GameState.current_foothold = hostname
		
		EventBus.offensive_action_performed.emit({
			"action_type": "phish",
			"target": hostname,
			"timestamp": ShiftClock.elapsed_seconds,
			"result": "SUCCESS",
			"trace_cost": GlobalConstants.TRACE_COST.PHISH,
			"shift_day": NarrativeDirector.current_hacker_day if NarrativeDirector else 0
		})
		
		return {
			"success": true,
			"output": "[color=green]✓ PHISHING SUCCESSFUL.[/color]\nUser clicked malicious link on %s.\nReverse shell established. Access level: USER." % hostname
		}
	else:
		# Update failure count for awareness penalty
		phish_fail_count += 1
		NetworkState.update_host_state(hostname, {"phish_fail_count": phish_fail_count})
		
		EventBus.offensive_action_performed.emit({
			"action_type": "phish",
			"target": hostname,
			"timestamp": ShiftClock.elapsed_seconds,
			"result": "FAILED",
			"trace_cost": GlobalConstants.TRACE_COST.PHISH,
			"shift_day": NarrativeDirector.current_hacker_day if NarrativeDirector else 0
		})
		
		return {
			"success": false,
			"output": "[color=red]✗ PHISHING FAILED.[/color]\nPayload quarantined by end-user or gateway filters.\n[color=orange]Host security awareness increased (Attempts: %d).[/color]" % phish_fail_count
		}
# ================================================


func lock_terminal(seconds: float):
	is_locked = true
	lock_timer.start(seconds)
	EventBus.terminal_locked.emit(seconds)

func _unlock_terminal():
	is_locked = false
	EventBus.terminal_unlocked.emit()

func is_terminal_locked() -> bool:
	return is_locked

func inject_system_message(text: String):
	"""Injects a message directly into the terminal output without a command."""
	command_output_received.emit("\n" + text + "\n", false)
