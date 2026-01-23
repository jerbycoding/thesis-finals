extends Node


# This autoload singleton provides corporate-toned versions of common phrases
# to maintain a consistent in-game narrative style.

static var corporate_phrases = {
	"new_ticket_received": "A new security incident has been logged. Prioritize and address promptly.",
	"ticket_completed_compliant": "Incident resolution process completed in adherence to established protocols. Exemplary compliance noted.",
	"ticket_completed_efficient": "Incident mitigated with expedited efficiency. Potential procedural deviations have been noted for review.",
	"ticket_completed_emergency": "Critical incident contained. Emergency protocols engaged. Post-incident analysis is mandatory.",
	"log_attached": "Evidence package updated. Log entry cross-referenced with incident report.",
	"email_approved": "Communication release authorized. Delivery initiated.",
	"email_quarantined": "Potential threat neutralized. Communication placed in isolation for further analysis.",
	"email_escalated": "Elevated threat assessment initiated. Incident escalated to Tier 2 response team.",
	"terminal_locked": "Command interface temporarily restricted. System integrity protocols engaged.",
	"terminal_unlocked": "Command interface operational. Access restored.",
	"malware_outbreak": "Systemic compromise detected. Malware containment protocols active.",
	"data_breach": "Data exfiltration confirmed. Critical information security incident declared.",
	"user_complaint": "Stakeholder dissatisfaction report filed. Incident review pending.",
	"followup_ticket_triggered": "Follow-up incident report initiated. Reason: {reason}.",
	"followup_ticket_scheduled": "Follow-up incident scheduled for deployment in {delay} seconds.",
	"email_approved_malicious_spear_phishing": "CRITICAL INCIDENT: Spear phishing attack successfully executed. Significant data breach anticipated.",
	"email_approved_malicious": "WARNING: Malicious email approved. Potential malware outbreak imminent.",
	"email_quarantined_legitimate": "USER COMPLAINT: Legitimate communication quarantined. Review required.",
	"email_quarantined_malicious": "SECURITY INCIDENT: Malicious communication successfully neutralized. Threat contained.",
	"email_escalated_malicious": "INCIDENT ESCALATION: Malicious communication referred for senior analyst review.",
	"hidden_risk_attachment_scan_missed": "CRITICAL VULNERABILITY DETECTED: Attachment analysis bypassed during incident resolution. Internal review initiated.",
	"terminal_locked_message": "Command interface restricted. Please await system availability in {seconds} seconds.",
	"terminal_unknown_command": "Command syntax error. Refer to 'help' for authorized commands.",
	"command_requires_hostname": "Parameter missing: Hostname required. Syntax: {command} [hostname]",
	"unknown_host": "Host not recognized. Verify hostname and retry.",
	"scanning_host": "Host {hostname} under active analysis.",
	"malware_detected": "CRITICAL THREAT: Malware signature detected. Immediate isolation recommended.",
	"recommendation_isolate_host": "Recommendation: Initiate immediate host isolation procedures.",
	"no_malware_detected": "Threat assessment: No active malware detected. System integrity confirmed.",
	"host_clean": "Host {hostname} status: Clean.",
	"host_already_isolated": "Host {hostname} already in isolated status. No further action required.",
	"isolating_host": "Host {hostname} isolation sequence initiated. Network interfaces decoupling.",
	"host_quarantined": "Host {hostname} successfully quarantined.",
	"critical_server_offline": "CRITICAL ALERT: Production server {hostname} has been taken offline due to network isolation. Service impact high.",
	"system_status": "System Operational Status:",
	"network_status_online": "Network Connectivity: Online",
	"isolated_hosts_list": "Isolated Hosts: {hostnames}",
	"terminal_status_locked": "Terminal Interface: Locked",
	"terminal_status_operational": "Terminal Interface: Operational",
	"fetching_logs_for_host": "Retrieving log data for host: {hostname}.",
	"no_security_events": "No anomalous security events recorded.",
	"known_hostnames": "Authorized Hostname Directory:",
	"no_known_hosts": "No hosts currently registered within the network.",
	"terminal_locked_print_debug": "Terminal access temporarily suspended for {seconds} seconds.",
	"terminal_unlocked_print_debug": "Terminal access restored.",
	"ticket_id_not_found_map": "ERROR: Incident identifier not found in mapping directory. ID: {ticket_id}",
	"ticket_script_load_failed": "ERROR: Failed to load incident script. Path: {path}",
	"ticket_script_not_found": "ERROR: Incident script not located. Path: {path}",
	"adding_null_ticket_error": "ERROR: Attempted to add null incident report. Operation aborted.",
	"ticket_already_in_queue_warning": "WARNING: Incident report {ticket_id} already present in active queue.",
	"new_ticket_added_header": "NEW INCIDENT REPORT FILED",
	"ticket_completed_header": "INCIDENT RESOLUTION CONFIRMED",
	"invalid_completion_type_warning": "WARNING: Invalid completion type specified. Defaulting to 'compliant'.",
	"ticket_not_found_for_completion_warning": "WARNING: Incident report {ticket_id} not found for completion.",
	"getting_active_tickets_count": "Retrieving active incident reports. Count: {count}",
	"ticket_not_found_by_id": "WARNING: Incident report {ticket_id} not found by ID.",
	"no_tickets_in_library_warning": "WARNING: Incident library empty. No new reports can be generated.",
	"cannot_attach_log_ticket_not_found": "WARNING: Log attachment failed. Incident report {ticket_id} not found.",
	"log_attached_success": "CONFIRMATION: Log {log_id} successfully appended to incident report {ticket_id}.",
	"log_already_attached_warning": "WARNING: Log {log_id} is already associated with incident report {ticket_id}.",
	"ticket_timeout": "INCIDENT TIMEOUT: Report {ticket_id} exceeded allocated resolution time.",
	"ticket_update_host_isolated": "INCIDENT UPDATE: Target host isolation for malware containment confirmed. Initiating incident closure procedure.",
	"kill_chain_escalation": "CRITICAL ALERT: Threat escalation detected in path: {path}. Transitioning to Stage {stage}.",
	
	# --- SIEM Templates ---
	"siem_inspector_header": "[color=#006CFF][b]EVENT IDENTITY[/b][/color]\n",
	"siem_inspector_metadata": "\n[color=#006CFF][b]NETWORK METADATA[/b][/color]\n",
	"siem_inspector_technical": "\n[color=#006CFF][b]TECHNICAL MESSAGE[/b][/color]\n",
	"siem_inspector_body": "[b]EVENT IDENTITY[/b]\n[code]ID: {id}[/code]\n[code]TIME: {time}[/code]\nRISK: [color={color}]{risk}[/color]\n\n[b]NETWORK METADATA[/b]\nSOURCE: {source}\n[code]IP ADDR: {ip}[/code]\n[code]HOST: {host}[/code]\n\n[b]TECHNICAL MESSAGE[/b]\n[font_size=12][i]{message}[/i][/font_size]\n",
	
	# --- Terminal Templates ---
	"terminal_welcome": "[color=green]SOC Terminal v2.1[/color]\n[color=green]Type 'help' for available commands[/color]\n\n",
	"terminal_prompt": "soc@terminal:~$ ",
	"terminal_command_echo": "[color=#006CFF]$ {command}[/color]\n"
}

# Concise phrases specifically for NotificationToast (max 40 chars)
static var notifications = {
	"ticket_completed_compliant": "Ticket Closed: COMPLIANT",
	"ticket_completed_efficient": "Ticket Closed: EFFICIENT (Risk Accepted)",
	"ticket_completed_emergency": "Ticket Closed: EMERGENCY PROTOCOL",
	"log_attached": "Evidence Attached",
	"email_approved": "Email Approved",
	"email_quarantined": "Email Quarantined",
	"email_escalated": "Email Escalated to Tier 2",
	"terminal_locked": "TERMINAL LOCKED",
	"terminal_unlocked": "Terminal Access Restored",
	"malware_outbreak": "ALERT: Malware Outbreak Detected",
	"data_breach": "CRITICAL: Data Exfiltration Active",
	"user_complaint": "Feedback: User Complaint Received",
	"email_approved_malicious": "FAILURE: Malware Approved!",
	"email_approved_malicious_spear_phishing": "CRITICAL FAILURE: CEO Compromised!",
	"email_quarantined_legitimate": "Warning: Legitimate Email Blocked",
	"email_quarantined_malicious": "Success: Threat Neutralized",
	"email_escalated_malicious": "Success: Threat Escalated",
	"hidden_risk_attachment_scan_missed": "FAILURE: Attachment Scan Skipped",
	"kill_chain_escalation": "ESCALATION: {path} -> Stage {stage}",
	"followup_ticket_triggered": "Follow-up Investigation Opened",
	"followup_ticket_scheduled": "Follow-up scheduled in {delay}s"
}

static func get_phrase(key: String) -> String:
	if corporate_phrases.has(key):
		return corporate_phrases[key]
	push_warning("CorporateVoice: Phrase key '%s' not found." % key)
	return "UNKNOWN CORPORATE PHRASE"

static func get_notification(key: String) -> String:
	if notifications.has(key):
		return notifications[key]
	# Fallback to verbose phrase if no short version exists
	if corporate_phrases.has(key):
		return corporate_phrases[key]
	return "NOTIFICATION: " + key

static func get_formatted_notification(key: String, params: Dictionary = {}) -> String:
	var phrase = get_notification(key)
	for p_key in params:
		phrase = phrase.replace("{" + p_key + "}", str(params[p_key]))
	return phrase

static func get_formatted_phrase(key: String, params: Dictionary = {}) -> String:
	var phrase = get_phrase(key)
	for p_key in params:
		phrase = phrase.replace("{" + p_key + "}", str(params[p_key]))
	return phrase
