# ConsequenceEngine.gd
# Autoload singleton that tracks player choices and triggers consequences
extends Node

const CONSEQUENCE_EVAL_INTERVAL: float = 15.0 # Evaluate every 15 seconds

signal consequence_triggered(consequence_type: String, details: Dictionary)
signal followup_ticket_scheduled(ticket_id: String, delay: float)
signal followup_ticket_creation_requested(ticket_data: TicketResource)

var choice_log: Array = []

var scheduled_consequences: Array[Dictionary] = []

var npc_relationships: Dictionary = {}



# Consequence types
enum ConsequenceType {
	FOLLOWUP_TICKET,
	SECURITY_BREACH,
	TOOL_DISABLED,
	REPUTATION_LOSS
}

# Kill Chain Escalation Probabilities (0.0 to 1.0)
const ESCALATION_RISKS = {
	"compliant": 0.0,
	"efficient": 0.5,
	"emergency": 0.75,
	"timeout": 1.0
}

# Standardized ID Templates to avoid Magic Strings
const CONSEQUENCE_IDS = {
	"MAJOR_BREACH": "MAJOR-BREACH-FOLLOWUP",
	"INCIDENT_ESCALATION": "INCIDENT-ESCALATION-FOLLOWUP",
	"USER_COMPLAINT": "USER-COMPLAINT-FOLLOWUP",
	"SERVICE_OUTAGE": "SERVICE-OUTAGE-FOLLOWUP",
	"MALWARE_CLEANUP": "MALWARE-CLEANUP-FOLLOWUP",
	"DATA_BREACH": "DATA-BREACH-CRITICAL"
}

func update_npc_relationship(npc_id: String, change: float):
	if not npc_relationships.has(npc_id):
		npc_relationships[npc_id] = 0.0
	
	npc_relationships[npc_id] += change
	print("❤️ NPC relationship updated: ", npc_id, " | New Score: ", npc_relationships[npc_id])

func load_state(relationships: Dictionary, choices: Array):
	if relationships:
		npc_relationships = relationships
	if choices:
		choice_log = choices
	
	# Clear any consequences that were scheduled from the previous session
	scheduled_consequences.clear()
	
	print("ConsequenceEngine state loaded.")

func trigger_consequence(consequence_id: String):
	print("🚨 CONSECUTIVE TRIGGERED by NarrativeDirector: ", consequence_id)
	match consequence_id:
		"missed_attachment_scan":
			_schedule_followup_ticket("MALWARE-CLEANUP-NARRATIVE", 30.0, "Narrative-driven malware cleanup due to missed attachment scan")
		_:
			print("⚠ Unknown consequence ID received: ", consequence_id)

func _ready():
	_initialize_engine.call_deferred()

func _initialize_engine():
	# Connect to the NarrativeDirector to listen for scripted consequence events
	if is_instance_valid(NarrativeDirector):
		NarrativeDirector.spawn_consequence_requested.connect(trigger_consequence)

	# Connect to TicketManager to listen for ticket completion events
	if is_instance_valid(TicketManager):
		TicketManager.ticket_completed.connect(_on_ticket_completed_by_manager)
		TicketManager.ticket_ignored.connect(_on_ticket_ignored)

	# Connect to EmailSystem for email decisions
	if is_instance_valid(EmailSystem):
		EmailSystem.email_decision_processed.connect(_on_email_decision_processed)

	# Connect to TerminalSystem for critical actions
	if is_instance_valid(TerminalSystem):
		TerminalSystem.critical_host_isolated.connect(_on_critical_host_isolated)

	# Start a timer to periodically evaluate for emergent consequences
	var consequence_timer = get_tree().create_timer(CONSEQUENCE_EVAL_INTERVAL, false)
	consequence_timer.timeout.connect(_evaluate_consequences)

func _on_critical_host_isolated(hostname: String):
	# This new handler creates a consequence when the terminal isolates a critical host.
	_schedule_followup_ticket(CONSEQUENCE_IDS.SERVICE_OUTAGE, 20.0, "Service outage on " + hostname + " due to network isolation.")

func _on_ticket_ignored(ticket: TicketResource):
	print("🚨 ConsequenceEngine: Ticket IGNORED (Timed out): ", ticket.ticket_id)
	
	# Log the inaction as a choice for archetype analysis
	var choice_data = {
		"type": "ticket_ignored",
		"ticket_id": ticket.ticket_id,
		"severity": ticket.severity,
		"category": ticket.category,
		"timestamp": Time.get_ticks_msec()
	}
	choice_log.append(choice_data)
	
	# Penalize NPC relationships based on severity
	match ticket.severity:
		"Critical":
			update_npc_relationship("ciso", -0.5)
			_schedule_followup_ticket(CONSEQUENCE_IDS.MAJOR_BREACH, 15.0, "Major security breach due to ignored critical alert: " + ticket.title, ticket.ticket_id)
		"High":
			update_npc_relationship("ciso", -0.3)
			update_npc_relationship("senior_analyst", -0.2)
			_schedule_followup_ticket(CONSEQUENCE_IDS.INCIDENT_ESCALATION, 30.0, "Security incident escalated due to ignored high-priority alert.", ticket.ticket_id)
		"Medium":
			update_npc_relationship("senior_analyst", -0.1)
			_schedule_followup_ticket(CONSEQUENCE_IDS.USER_COMPLAINT, 45.0, "Users reporting issues related to unaddressed alert.", ticket.ticket_id)
		_:
			# Low severity ignored might just be a small trust hit
			update_npc_relationship("it_support", -0.05)

	consequence_triggered.emit("ticket_ignored", {"ticket_id": ticket.ticket_id, "severity": ticket.severity})


func _on_email_decision_processed(email: EmailResource, decision: String, inspection_state: Dictionary):
	# This is the new handler for the decoupled signal from EmailSystem.
	log_email_decision(email.email_id, decision, email)
	
	var is_spear_phishing = _is_spear_phishing_email(email)
	
	# Wrong decisions trigger consequences
	if email.is_malicious and decision == "approve":
		# Approved malicious email - spawn malware ticket
		print("🚨 CONSEQUENCE: Approved malicious email!")
		
		# Spear phishing has more severe consequences (data breach)
		if is_spear_phishing:
			print("🚨 SPEAR PHISHING DETECTED: Approved spear phishing email!")
			_schedule_followup_ticket(CONSEQUENCE_IDS.DATA_BREACH, 120.0, "Data breach from approved spear phishing email - delayed detection")
		else:
			_schedule_followup_ticket(CONSEQUENCE_IDS.MALWARE_CLEANUP, 30.0, "Malware outbreak from approved malicious email")
	
	elif not email.is_malicious and decision == "quarantine":
		# Quarantined legitimate email - spawn user complaint
		print("⚠ CONSEQUENCE: Quarantined legitimate email!")
		_schedule_followup_ticket(CONSEQUENCE_IDS.USER_COMPLAINT, 60.0, "User complaint: legitimate email quarantined")
	
	elif email.is_malicious and decision == "quarantine":
		# Check for hidden risks on the associated ticket
		if email.related_ticket == "SPEAR-PHISH-001":
			if not inspection_state.get("attachments", false):
				print("🚨 HIDDEN RISK TRIGGERED: Player quarantined email without scanning attachments!")
				trigger_consequence("missed_attachment_scan")

func _is_spear_phishing_email(email: EmailResource) -> bool:
	# This helper is moved from EmailSystem to make ConsequenceEngine self-contained.
	if "spear" in email.email_id.to_lower():
		return true
	
	if email.related_ticket and "spear" in email.related_ticket.to_lower():
		return true
	
	# Spear phishing often spoofs executives
	if email.sender in ["CEO", "CFO", "CTO", "Executive"] and email.is_malicious:
		if email.clues.has("spoofed_sender") or email.clues.has("bad_attachment"):
			return true
	
	# Check subject for spear phishing patterns
	if "spear" in email.subject.to_lower() or "targeted" in email.subject.to_lower():
		return true
	
	return false


func _evaluate_consequences():
	# TODO: Implement logic to evaluate player choices from 'choice_log'
	# and trigger emergent consequences based on patterns of behavior.
	print("⚙️ Evaluating for emergent consequences...")
	pass

func _on_ticket_completed_by_manager(ticket: TicketResource, completion_type: String, time_taken: float):
	print("📝 ConsequenceEngine: Logged ticket completion: ", ticket.ticket_id, " - ", completion_type)

	var choice_data = {
		"ticket_id": ticket.ticket_id,
		"completion_type": completion_type,
		"time_taken": time_taken, # Changed from time_remaining to time_taken
		"timestamp": Time.get_ticks_msec(),
		"ticket_category": ticket.category,
		"ticket_severity": ticket.severity
	}
	
	choice_log.append(choice_data)
	
	# Check for hidden risks
	_check_hidden_risks(ticket, completion_type)

	# Schedule consequences based on completion type
	_schedule_consequences(ticket, completion_type, time_taken) # Pass time_taken instead of time_remaining
	
	# Kill Chain Escalation Logic
	if ticket.kill_chain_path != "":
		_evaluate_kill_chain_escalation(ticket, completion_type)

func _evaluate_kill_chain_escalation(ticket: TicketResource, completion_type: String):
	var risk = ESCALATION_RISKS.get(completion_type, 0.0)
	var roll = randf()
	
	print("⛓ Kill Chain Evaluation: %s (Path: %s, Stage: %d)" % [ticket.ticket_id, ticket.kill_chain_path, ticket.kill_chain_stage])
	print("  Risk: %.2f | Roll: %.2f" % [risk, roll])
	
	if roll < risk:
		print("  🚨 ESCALATION TRIGGERED!")
		if ticket.kill_chain_stage >= 3:
			print("  💀 Impact Stage failure. Offering Redemption (Black Ticket).")
			_spawn_black_ticket()
		else:
			_trigger_kill_chain_escalation(ticket)
	else:
		print("  ✓ Threat contained. No escalation.")
		# Check if this was the Black Ticket itself being completed correctly
		if ticket.ticket_id == "BLACK-TICKET-REDEMPTION" and completion_type == "compliant":
			if ArchetypeAnalyzer:
				ArchetypeAnalyzer.perform_career_reset()

func _spawn_black_ticket():
	var black_ticket_res = load("res://resources/tickets/TicketBlackRedemption.tres")
	if black_ticket_res:
		var black_ticket = black_ticket_res.duplicate()
		print("  🎫 Spawning Black Ticket...")
		if TicketManager:
			TicketManager.add_ticket(black_ticket)
			consequence_triggered.emit("black_ticket", {"ticket_id": black_ticket.ticket_id})
	else:
		print("  ❌ ERROR: Could not load Black Ticket resource")

func _trigger_kill_chain_escalation(ticket: TicketResource):
	if ticket.escalation_ticket == null:
		print("  ⚠ No escalation ticket defined for ", ticket.ticket_id)
		return
	
	var next_ticket = ticket.escalation_ticket.duplicate()
	var delay = 15.0 # Standard delay for escalation
	
	# Mark the original logs as revealed so the player can see what they missed
	if LogSystem:
		for log_id in ticket.required_log_ids:
			var log = LogSystem.get_log_by_id(log_id)
			if log:
				log.is_revealed = true
				print("  🔍 Log revealed: ", log_id)
	
	print("  📅 Scheduling escalation ticket: ", next_ticket.ticket_id, " in ", delay, "s")
	
	# Emit signal for NotificationManager or UI
	consequence_triggered.emit("escalation", {
		"path": ticket.kill_chain_path,
		"stage": ticket.kill_chain_stage + 1,
		"original_id": ticket.ticket_id
	})
	
	# Start timer to spawn ticket
	get_tree().create_timer(delay).timeout.connect(
		func(): 
			if TicketManager:
				TicketManager.add_ticket(next_ticket)
	)

func _check_hidden_risks(ticket: TicketResource, completion_type: String):
	# Check if player triggered any hidden risks
	if ticket.hidden_risks.is_empty():

		return

	# Check if player has sufficient evidence (all required logs attached)

	var has_sufficient = ticket.has_sufficient_evidence()


	# For efficient/emergency completion, check if they missed required logs
	if completion_type == "efficient" or completion_type == "emergency":
		if not has_sufficient:
			# Player rushed completion without all required evidence
			for risk in ticket.hidden_risks:
				print("⚠ Hidden risk detected: ", risk)
				# Schedule consequence based on risk
				_trigger_hidden_risk_consequence(ticket, risk, completion_type)
func _trigger_hidden_risk_consequence(ticket: TicketResource, risk: String, completion_type: String):
	# Parse risk description to determine consequence
	if "malware" in risk.to_lower() or "clicked" in risk.to_lower():
		# Spawn malware cleanup ticket
		_schedule_followup_ticket("MALWARE-CLEANUP", 60.0, "Malware cleanup required after missed detection", ticket.ticket_id)
	elif "breach" in risk.to_lower() or "data" in risk.to_lower():
		# Spawn data breach report
		_schedule_followup_ticket("BREACH-REPORT", 30.0, "Data breach report required", ticket.ticket_id)
	else:
		# Generic followup
		_schedule_followup_ticket("FOLLOWUP-001", 90.0, "Follow-up investigation required", ticket.ticket_id)
func _schedule_consequences(ticket: TicketResource, completion_type: String, time_remaining: float):
	match completion_type:
		"compliant":
			# Compliant completion - usually no negative consequences
			print("✓ Compliant completion - No negative consequences")
			# Could add positive consequences (bonus time, reputation gain)
		
		"efficient":
			# Efficient completion - moderate risk
			if time_remaining < ticket.base_time * 0.3:  # Used less than 30% of time
				print("⚠ Efficient completion with very little time used - High risk")
				_schedule_followup_ticket("EFFICIENT-RISK", 60.0, "Rushed resolution may have missed critical checks", ticket.ticket_id)
			else:

				print("✓ Efficient completion - Moderate risk accepted")

		"emergency":

			# Emergency completion - high risk, immediate consequences

			print("🚨 Emergency completion - Immediate consequences")

			_schedule_followup_ticket("EMERGENCY-FOLLOWUP", 10.0, "Emergency resolution requires immediate follow-up", ticket.ticket_id)



func _schedule_followup_ticket(ticket_id: String, delay_seconds: float, reason: String, original_id: String = "N/A"):
	print("📅 Scheduling follow-up ticket: ", ticket_id, " in ", delay_seconds, " seconds")
	
	var consequence_data = {
		"ticket_id": ticket_id,
		"delay": delay_seconds,
		"reason": reason,
		"original_id": original_id,
		"trigger_time": Time.get_ticks_msec() + (delay_seconds * 1000)
	}
	
	scheduled_consequences.append(consequence_data)
	followup_ticket_scheduled.emit(ticket_id, delay_seconds)

	# Start timer to spawn ticket
	get_tree().create_timer(delay_seconds).timeout.connect(_spawn_followup_ticket.bind(ticket_id, reason, original_id))

func _spawn_followup_ticket(ticket_id: String, reason: String, original_id: String = "N/A"):
	print("🚨 Spawning follow-up ticket: ", ticket_id, " related to: ", original_id)

	var followup_ticket = TicketResource.new()
	followup_ticket.ticket_id = ticket_id + "-" + str(randi() % 999) # Unique ID
	
	# IMPROVED: Dynamic context-aware information
	if original_id != "N/A":
		followup_ticket.title = "AUDIT: Re: " + original_id
		followup_ticket.description = "URGENT AUDIT REQUIRED.\n\nOriginal Incident: " + original_id + "\n\nReason: " + reason + "\n\nBecause this incident was resolved via non-standard procedures (Emergency/Efficient), we must re-verify the state of the network. Review the original logs and ensure no secondary persistence exists."
	else:
		followup_ticket.title = "Follow-up Investigation"
		followup_ticket.description = reason

	followup_ticket.severity = "High"
	followup_ticket.category = "Follow-up"
	
	followup_ticket.steps.clear()
	followup_ticket.steps.append("Re-examine original logs")
	followup_ticket.steps.append("Verify host integrity")
	
	followup_ticket.required_tool = "siem"
	followup_ticket.base_time = 120.0
	
	if TicketManager:
		# Tell TicketManager to reveal logs for the ORIGINAL ticket again
		if LogSystem and original_id != "N/A":
			LogSystem.reveal_logs_for_ticket(original_id)
			
		followup_ticket_creation_requested.emit(followup_ticket)
		consequence_triggered.emit("followup_ticket", {"ticket_id": ticket_id, "reason": reason})


func log_player_choice(choice_type: String, choice_data: Dictionary):
	# Generic choice logger
	print("📝 Logging player choice: ", choice_type)
	
	var log_entry = choice_data.duplicate()
	log_entry["type"] = choice_type
	log_entry["timestamp"] = Time.get_ticks_msec()
	
	choice_log.append(log_entry)


func log_email_decision(email_id: String, decision: String, email: EmailResource):
	# Log email decision for consequence tracking
	print("📝 Logging email decision: ", email_id, " - ", decision)
	
	var choice_data = {
		"type": "email_decision",
		"email_id": email_id,
		"decision": decision,
		"timestamp": Time.get_ticks_msec(),
		"is_malicious": email.is_malicious,
		"related_ticket": email.related_ticket
	}
	
	choice_log.append(choice_data)
	
	# Email consequences are handled in EmailSystem, but we track them here
	# for overall player archetype analysis



func get_choice_history() -> Array:
	return choice_log.duplicate()


func get_recent_choices(count: int = 5) -> Array[Dictionary]:
	var recent = []
	var start = max(0, choice_log.size() - count)
	for i in range(start, choice_log.size()):
		recent.append(choice_log[i])
	return recent



# Debug helper - print current state
func show_consequence_info():
	print("========================================")
	print("CONSEQUENCE ENGINE STATE")
	print("========================================")
	print("Choice History: ", choice_log.size(), " entries")
	print("Scheduled Consequences: ", scheduled_consequences.size())
	
	if scheduled_consequences.size() > 0:
		print("\nScheduled Consequences:")
		for i in range(scheduled_consequences.size()):
			var cons = scheduled_consequences[i]
			var time_left = (cons.trigger_time - Time.get_ticks_msec()) / 1000.0
			print("  [", i, "] ", cons.ticket_id)
			print("      Delay: ", cons.delay, "s")
			print("      Time Left: ", int(time_left), "s")
			print("      Reason: ", cons.reason)
	
	if choice_log.size() > 0:
		print("\nRecent Choices (last 3):")
		var recent = get_recent_choices(3)
		for choice in recent:
			print("  - ", choice.ticket_id, " (", choice.completion_type, ")")
	
	print("========================================")
