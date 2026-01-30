# ConsequenceEngine.gd
# Autoload singleton that tracks player choices and triggers consequences
extends Node

const CONSEQUENCE_EVAL_INTERVAL: float = 15.0 # Evaluate every 15 seconds

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
	GlobalConstants.COMPLETION_TYPE.COMPLIANT: 0.0,
	GlobalConstants.COMPLETION_TYPE.EFFICIENT: 0.5,
	GlobalConstants.COMPLETION_TYPE.EMERGENCY: 0.75,
	GlobalConstants.COMPLETION_TYPE.TIMEOUT: 1.0
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
	if TimeManager:
		TimeManager.clear_all_timers()
	
	print("ConsequenceEngine state loaded.")

func reset_to_default():
	print("ConsequenceEngine: Resetting all social and choice data.")
	choice_log.clear()
	scheduled_consequences.clear()
	npc_relationships.clear()
	if TimeManager:
		# Specifically clear consequence timers
		TimeManager.clear_all_timers()

func trigger_consequence(consequence_id: String):
	print("🚨 CONSECUTIVE TRIGGERED by NarrativeDirector: ", consequence_id)
	
	choice_log.append({
		"type": "consequence_triggered",
		"consequence_type": consequence_id,
		"timestamp": Time.get_ticks_msec()
	})
	
	match consequence_id:
		GlobalConstants.CONSEQUENCE_ID.MISSED_ATTACHMENT_SCAN:
			_schedule_followup_ticket("MALWARE-CLEANUP-NARRATIVE", 30.0, "Narrative-driven malware cleanup due to missed attachment scan")
		_:
			print("⚠ Unknown consequence ID received: ", consequence_id)

func _ready():
	_initialize_engine.call_deferred()

func _initialize_engine():
	# Use EventBus for decoupled communication
	EventBus.narrative_spawn_consequence.connect(trigger_consequence)
	EventBus.ticket_completed.connect(_on_ticket_completed_by_manager)
	EventBus.ticket_ignored.connect(_on_ticket_ignored)
	EventBus.email_decision_processed.connect(_on_email_decision_processed)
	EventBus.critical_host_isolated.connect(_on_critical_host_isolated)
	EventBus.consequence_triggered.connect(_on_consequence_triggered_globally)

	# Start the periodic evaluation loop
	_start_evaluation_loop()

func _on_consequence_triggered_globally(type: String, details: Dictionary):
	if type == GlobalConstants.CONSEQUENCE_ID.PROCEDURAL_VIOLATION:
		var hostname = details.get("hostname", "Unknown")
		_schedule_followup_ticket("AUDIT-PROC-001", 10.0, "Procedural violation: Unjustified isolation of " + hostname)

func _start_evaluation_loop():
	if TimeManager:
		TimeManager.register_timer("consequence_eval", CONSEQUENCE_EVAL_INTERVAL, func():
			_evaluate_consequences()
			_start_evaluation_loop() # Restart loop
		)

func _on_critical_host_isolated(hostname: String):
	# This new handler creates a consequence when the terminal isolates a critical host.
	_schedule_followup_ticket(GlobalConstants.CONSEQUENCE_ID.SERVICE_OUTAGE, 20.0, "Service outage on " + hostname + " due to network isolation.")

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
			update_npc_relationship(GlobalConstants.NPC_ID.CISO, -0.5)
			_schedule_followup_ticket(GlobalConstants.CONSEQUENCE_ID.MAJOR_BREACH, 15.0, "Major security breach due to ignored critical alert: " + ticket.title, ticket.ticket_id)
		"High":
			update_npc_relationship(GlobalConstants.NPC_ID.CISO, -0.3)
			update_npc_relationship(GlobalConstants.NPC_ID.SENIOR_ANALYST, -0.2)
			_schedule_followup_ticket(GlobalConstants.CONSEQUENCE_ID.INCIDENT_ESCALATION, 30.0, "Security incident escalated due to ignored high-priority alert.", ticket.ticket_id)
		"Medium":
			update_npc_relationship(GlobalConstants.NPC_ID.SENIOR_ANALYST, -0.1)
			_schedule_followup_ticket(GlobalConstants.CONSEQUENCE_ID.USER_COMPLAINT, 45.0, "Users reporting issues related to unaddressed alert.", ticket.ticket_id)
		_:
			# Low severity ignored might just be a small trust hit
			update_npc_relationship(GlobalConstants.NPC_ID.IT_SUPPORT, -0.05)

	EventBus.consequence_triggered.emit("ticket_ignored", {"ticket_id": ticket.ticket_id, "severity": ticket.severity})
	
	# Log the consequence itself
	choice_log.append({
		"type": "consequence_triggered",
		"consequence_type": "ticket_ignored",
		"timestamp": Time.get_ticks_msec()
	})


func _on_email_decision_processed(email: EmailResource, decision: String, inspection_state: Dictionary):
	# This is the new handler for the decoupled signal from EmailSystem.
	log_email_decision(email.email_id, decision, email)
	
	var is_spear_phishing = _is_spear_phishing_email(email)
	
	# Wrong decisions trigger consequences
	if email.is_malicious and decision == GlobalConstants.EMAIL_DECISION.APPROVE:
		# Approved malicious email - spawn malware ticket
		print("🚨 CONSEQUENCE: Approved malicious email!")
		
		# Spear phishing has more severe consequences (data breach)
		if is_spear_phishing:
			print("🚨 SPEAR PHISHING DETECTED: Approved spear phishing email!")
			_schedule_followup_ticket(GlobalConstants.CONSEQUENCE_ID.DATA_BREACH, 120.0, "Data breach from approved spear phishing email - delayed detection")
		else:
			_schedule_followup_ticket(GlobalConstants.CONSEQUENCE_ID.MALWARE_CLEANUP, 30.0, "Malware outbreak from approved malicious email")
	
	elif not email.is_malicious and decision == GlobalConstants.EMAIL_DECISION.QUARANTINE:
		# Quarantined legitimate email - spawn user complaint
		print("⚠ CONSEQUENCE: Quarantined legitimate email!")
		_schedule_followup_ticket(GlobalConstants.CONSEQUENCE_ID.USER_COMPLAINT, 60.0, "User complaint: legitimate email quarantined")
	
	elif email.is_malicious and decision == GlobalConstants.EMAIL_DECISION.QUARANTINE:
		# Check for data-driven hidden risks defined in the EmailResource
		if not email.quarantine_hidden_risks.is_empty():
			for tool in email.quarantine_hidden_risks:
				if not inspection_state.get(tool, false):
					var consequence_id = email.quarantine_hidden_risks[tool]
					print("🚨 HIDDEN RISK TRIGGERED: Quarantined without using ", tool, " | Triggering: ", consequence_id)
					trigger_consequence(consequence_id)

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
	# Implement logic to evaluate player choices and relationships
	print("⚙️ Evaluating for emergent consequences...")
	_apply_social_consequences()

func get_relationship_rank(npc_id: String) -> String:
	var score = npc_relationships.get(npc_id, 0.0)
	if score >= GlobalConstants.RELATIONSHIP_THRESHOLD.ADMIRED: return GlobalConstants.RELATIONSHIP_RANK.ADMIRED
	if score >= GlobalConstants.RELATIONSHIP_THRESHOLD.RESPECTED: return GlobalConstants.RELATIONSHIP_RANK.RESPECTED
	if score <= GlobalConstants.RELATIONSHIP_THRESHOLD.HATED: return GlobalConstants.RELATIONSHIP_RANK.HATED
	if score <= GlobalConstants.RELATIONSHIP_THRESHOLD.DISTRUSTED: return GlobalConstants.RELATIONSHIP_RANK.DISTRUSTED
	return GlobalConstants.RELATIONSHIP_RANK.NEUTRAL

func _apply_social_consequences():
	# 1. Senior Analyst Perks (Auto-Forensics)
	var analyst_rank = get_relationship_rank(GlobalConstants.NPC_ID.SENIOR_ANALYST)
	if analyst_rank == GlobalConstants.RELATIONSHIP_RANK.ADMIRED:
		_try_auto_reveal_evidence()
	
	# 2. IT Support Penalties (Terminal Glitches)
	var it_rank = get_relationship_rank(GlobalConstants.NPC_ID.IT_SUPPORT)
	if it_rank == GlobalConstants.RELATIONSHIP_RANK.HATED:
		_try_terminal_glitch()

func _try_auto_reveal_evidence():
	if not LogSystem: return
	if randf() > 0.3: return # 30% chance per evaluation
	
	if TicketManager and TicketManager.has_active_tickets():
		var ticket = TicketManager.get_active_tickets().pick_random()
		if not ticket.required_log_ids.is_empty():
			var log_id = ticket.required_log_ids.pick_random()
			var log_res = LogSystem.get_log_by_id(log_id)
			if log_res and not log_res.is_revealed:
				log_res.is_revealed = true
				print("💡 SOCIAL PERK: Senior Analyst revealed evidence for ", ticket.ticket_id)
				if NotificationManager:
					NotificationManager.show_notification("ANALYST TIP: Evidence surfaced in SIEM.", "success")

func _try_terminal_glitch():
	if not TerminalSystem: return
	if randf() > 0.2: return # 20% chance per evaluation
	
	if not TerminalSystem.is_terminal_locked():
		print("🔌 SOCIAL PENALTY: IT Support restricted terminal access.")
		TerminalSystem.lock_terminal(10.0)
		if NotificationManager:
			NotificationManager.show_notification("TERMINAL ERROR: Network connection reset by IT.", "error")

# --- Social Favor System (Sprint 10) ---

func apply_social_favor(favor_id: String, cost: float, npc_id: String):
	var current_score = npc_relationships.get(npc_id, 0.0)
	var rank = get_relationship_rank(npc_id)
	
	# Minimum requirement: Respected
	if current_score < GlobalConstants.RELATIONSHIP_THRESHOLD.RESPECTED:
		if NotificationManager:
			NotificationManager.show_notification("FAVOR DENIED: Standing with " + npc_id + " too low.", "warning")
		return

	print("💳 Applying Social Favor: ", favor_id, " | NPC: ", npc_id, " | Cost: ", cost)
	update_npc_relationship(npc_id, -cost)
	
	match favor_id:
		"reveal_evidence":
			_reveal_guaranteed_evidence()
		"boost_bandwidth":
			_apply_bandwidth_boost()
		_:
			push_warning("ConsequenceEngine: Unknown favor ID: " + favor_id)

func _reveal_guaranteed_evidence():
	if not LogSystem or not TicketManager: return
	
	var active = TicketManager.get_active_tickets()
	if active.is_empty(): return
	
	# Filter for tickets that have unrevealed required logs
	var valid_tickets = []
	for t in active:
		for log_id in t.required_log_ids:
			var l = LogSystem.get_log_by_id(log_id)
			if l and not l.is_revealed:
				valid_tickets.append({"ticket": t, "log_id": log_id})
	
	if not valid_tickets.is_empty():
		var target = valid_tickets.pick_random()
		var log_res = LogSystem.get_log_by_id(target.log_id)
		log_res.is_revealed = true
		if NotificationManager:
			NotificationManager.show_notification("FAVOR: Analyst surfaced evidence for " + target.ticket.ticket_id, "success")
	else:
		if NotificationManager:
			NotificationManager.show_notification("FAVOR: No new evidence to surface at this time.", "info")

func _apply_bandwidth_boost():
	# Notify TerminalSystem to ignore ISP throttling for a duration
	EventBus.world_event_triggered.emit(GlobalConstants.EVENTS.ISP_THROTTLING, false, 60.0)
	if NotificationManager:
		NotificationManager.show_notification("FAVOR: IT bypassed network throttling (60s).", "success")

func _on_ticket_completed_by_manager(ticket: TicketResource, completion_type: String, time_taken: float):
	print("📝 ConsequenceEngine: Logged ticket completion: ", ticket.ticket_id, " - ", completion_type)

	var choice_data = {
		"type": "ticket_completed",
		"ticket_id": ticket.ticket_id,
		"completion_type": completion_type,
		"time_taken": time_taken, 
		"timestamp": Time.get_ticks_msec(),
		"ticket_category": ticket.category,
		"ticket_severity": ticket.severity
	}
	
	choice_log.append(choice_data)
	
	# Check for hidden risks
	_check_hidden_risks(ticket, completion_type)

	# Schedule consequences based on completion type
	_schedule_consequences(ticket, completion_type, time_taken) 
	
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
		if ticket.ticket_id == "BLACK-TICKET-REDEMPTION" and completion_type == GlobalConstants.COMPLETION_TYPE.COMPLIANT:
			if ArchetypeAnalyzer:
				ArchetypeAnalyzer.perform_career_reset()

func _spawn_black_ticket():
	var black_ticket_res = load("res://resources/tickets/TicketBlackRedemption.tres")
	if black_ticket_res:
		var black_ticket = black_ticket_res.duplicate()
		print("  🎫 Spawning Black Ticket...")
		if TicketManager:
			TicketManager.add_ticket(black_ticket)
			EventBus.consequence_triggered.emit(GlobalConstants.CONSEQUENCE_ID.BLACK_TICKET, {"ticket_id": black_ticket.ticket_id})
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
	EventBus.consequence_triggered.emit(GlobalConstants.CONSEQUENCE_ID.ESCALATION, {
		"path": ticket.kill_chain_path,
		"stage": ticket.kill_chain_stage + 1,
		"original_id": ticket.ticket_id
	})
	
	# Start timer to spawn ticket via TimeManager
	if TimeManager:
		TimeManager.register_timer("escalation_" + next_ticket.ticket_id, delay, func():
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
	if completion_type == GlobalConstants.COMPLETION_TYPE.EFFICIENT or completion_type == GlobalConstants.COMPLETION_TYPE.EMERGENCY:
		if not has_sufficient:
			# Player rushed completion without all required evidence
			for risk in ticket.hidden_risks:
				print("⚠ Hidden risk detected: ", risk)
				# Schedule consequence based on risk
				_trigger_hidden_risk_consequence(ticket, risk, completion_type)

func _trigger_hidden_risk_consequence(ticket: TicketResource, risk: String, completion_type: String):
	# Parse risk description to determine consequence
	if GlobalConstants.RISK_TYPE.MALWARE in risk.to_lower() or "clicked" in risk.to_lower():
		# Spawn malware cleanup ticket
		_schedule_followup_ticket("MALWARE-CLEANUP-FOLLOWUP", 60.0, "Malware cleanup required after missed detection", ticket.ticket_id)
	elif GlobalConstants.RISK_TYPE.DATA_BREACH in risk.to_lower() or "data" in risk.to_lower():
		# Spawn data breach report
		_schedule_followup_ticket("MAJOR-BREACH-FOLLOWUP", 30.0, "Data breach report required", ticket.ticket_id)
	else:
		# Generic followup
		_schedule_followup_ticket("FOLLOWUP-GENERIC", 90.0, "Follow-up investigation required", ticket.ticket_id)

func _schedule_consequences(ticket: TicketResource, completion_type: String, time_remaining: float):
	match completion_type:
		GlobalConstants.COMPLETION_TYPE.COMPLIANT:
			print("✓ Compliant completion - No negative consequences")
		
		GlobalConstants.COMPLETION_TYPE.EFFICIENT:
			if time_remaining < ticket.base_time * 0.3:  # Used less than 30% of time
				print("⚠ Efficient completion with very little time used - High risk")
				_schedule_followup_ticket("FOLLOWUP-GENERIC", 60.0, "Rushed resolution may have missed critical checks", ticket.ticket_id)
			else:
				print("✓ Efficient completion - Moderate risk accepted")

		GlobalConstants.COMPLETION_TYPE.EMERGENCY:
			print("🚨 Emergency completion - Immediate consequences")
			_schedule_followup_ticket("FOLLOWUP-GENERIC", 10.0, "Emergency resolution requires immediate follow-up", ticket.ticket_id)

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
	EventBus.followup_ticket_scheduled.emit(ticket_id, delay_seconds)

	# Start timer to spawn ticket via TimeManager
	if TimeManager:
		var timer_id = "followup_" + ticket_id + "_" + original_id + "_" + str(Time.get_ticks_msec())
		TimeManager.register_timer(timer_id, delay_seconds, _spawn_followup_ticket.bind(ticket_id, reason, original_id))

func _spawn_followup_ticket(ticket_id: String, reason: String, original_id: String = "N/A"):
	print("🚨 Spawning follow-up ticket: ", ticket_id, " related to: ", original_id)

	var followup_ticket: TicketResource = null
	
	# Try to load from library first (Data-Driven Priority)
	if TicketManager and TicketManager.ticket_id_map.has(ticket_id.to_lower()):
		var template = TicketManager.ticket_id_map[ticket_id.to_lower()]
		followup_ticket = template.duplicate()
		followup_ticket.ticket_id = ticket_id + "-" + str(randi() % 999) # Unique ID
		
		# Append narrative context if not present in the template's description
		if original_id != "N/A" and not original_id in followup_ticket.description:
			followup_ticket.description += "\n\n[ Technical Context ]\nRelated Incident: " + original_id + "\nDetection Reason: " + reason
	else:
		push_error("ConsequenceEngine: Could not spawn ticket. ID '%s' not found in TicketManager library." % ticket_id)
		return
	
	if TicketManager and followup_ticket:
		# Tell TicketManager to reveal logs for the ORIGINAL ticket again if applicable
		if LogSystem and original_id != "N/A":
			LogSystem.reveal_logs_for_ticket(original_id)
			
		EventBus.followup_ticket_creation_requested.emit(followup_ticket)
		EventBus.consequence_triggered.emit("followup_ticket", {"ticket_id": ticket_id, "reason": reason})


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
