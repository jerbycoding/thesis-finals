# ConsequenceEngine.gd
# Autoload singleton that tracks player choices and triggers consequences
extends Node

const CONSEQUENCE_EVAL_INTERVAL: float = 15.0 # Evaluate every 15 seconds

var choice_log: Array = []
var scheduled_consequences: Array[Dictionary] = []
var npc_relationships: Dictionary = {}
var ignored_tickets_in_shift: int = 0

# Kill Chain Escalation Probabilities (0.0 to 1.0)
const ESCALATION_RISKS = {
	GlobalConstants.COMPLETION_TYPE.COMPLIANT: 0.0,
	GlobalConstants.COMPLETION_TYPE.EFFICIENT: 0.5,
	GlobalConstants.COMPLETION_TYPE.EMERGENCY: 0.75,
	GlobalConstants.COMPLETION_TYPE.TIMEOUT: 1.0
}

# Severity-based penalties for ignored tickets
const IGNORE_PENALTIES = {
	"Critical": {
		"npc": GlobalConstants.NPC_ID.CISO, 
		"hit": -0.5, 
		"cons": GlobalConstants.CONSEQUENCE_ID.MAJOR_BREACH, 
		"delay": 15.0
	},
	"High": {
		"npc": GlobalConstants.NPC_ID.CISO, 
		"hit": -0.3, 
		"cons": GlobalConstants.CONSEQUENCE_ID.INCIDENT_ESCALATION, 
		"delay": 30.0
	},
	"Medium": {
		"npc": GlobalConstants.NPC_ID.SENIOR_ANALYST, 
		"hit": -0.1, 
		"cons": GlobalConstants.CONSEQUENCE_ID.USER_COMPLAINT, 
		"delay": 45.0
	}
}

func _ready():
	_initialize_engine.call_deferred()

func _initialize_engine():
	# Use EventBus for decoupled communication
	EventBus.narrative_spawn_consequence.connect(trigger_consequence)
	EventBus.ticket_ignored.connect(_on_ticket_ignored)
	EventBus.ticket_completed.connect(_on_ticket_completed)
	EventBus.email_decision_processed.connect(_on_email_decision_processed)
	EventBus.critical_host_isolated.connect(_on_critical_host_isolated)
	EventBus.consequence_triggered.connect(_on_consequence_triggered_globally)
	EventBus.shift_started.connect(func(_id): ignored_tickets_in_shift = 0)
	EventBus.shift_ended.connect(func(_r): ignored_tickets_in_shift = 0)
	EventBus.campaign_ended.connect(func(_type): reset_to_default())

	# Start the periodic evaluation loop
	_start_evaluation_loop()

func _start_evaluation_loop():
	if TimeManager:
		TimeManager.register_timer("consequence_eval", CONSEQUENCE_EVAL_INTERVAL, func():
			_evaluate_consequences()
			_start_evaluation_loop() # Restart loop
		)

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
		GlobalConstants.CONSEQUENCE_ID.MALWARE_CLEANUP:
			_schedule_followup_ticket(GlobalConstants.CONSEQUENCE_ID.MALWARE_CLEANUP, 30.0, "Delayed malware outbreak from unverified quarantine")
		_:
			print("⚠ Unknown consequence ID received: ", consequence_id)

func _on_consequence_triggered_globally(type: String, details: Dictionary):
	if type == GlobalConstants.CONSEQUENCE_ID.PROCEDURAL_VIOLATION:
		var hostname = details.get("hostname", "Unknown")
		_schedule_followup_ticket("AUDIT-PROC-001", 10.0, "Procedural violation: Unjustified isolation of " + hostname, "N/A", hostname)

func _on_critical_host_isolated(hostname: String):
	_schedule_followup_ticket(GlobalConstants.CONSEQUENCE_ID.SERVICE_OUTAGE, 20.0, "Service outage on " + hostname + " due to network isolation.", "N/A", hostname)

func _on_ticket_ignored(ticket: TicketResource):
	print("🚨 ConsequenceEngine: Ticket IGNORED (Timed out): ", ticket.ticket_id)
	ignored_tickets_in_shift += 1
	
	log_player_choice("ticket_ignored", {
		"ticket_id": ticket.ticket_id,
		"severity": ticket.severity,
		"category": ticket.category
	})
	
	# CRITICAL NEGLIGENCE CHECK
	if ticket.severity == "Critical":
		print("💀 CRITICAL NEGLIGENCE: Immediate termination required.")
		EventBus.campaign_ended.emit("fired")
		return
		
	if ignored_tickets_in_shift >= 4:
		print("💀 CUMULATIVE NEGLIGENCE: Too many ignored alerts.")
		EventBus.campaign_ended.emit("fired")
		return

	if IGNORE_PENALTIES.has(ticket.severity):
		var p = IGNORE_PENALTIES[ticket.severity]
		update_npc_relationship(p.npc, p.hit)
		_schedule_followup_ticket(p.cons, p.delay, "Ignored " + ticket.severity + " alert: " + ticket.title, ticket.ticket_id)
	else:
		update_npc_relationship(GlobalConstants.NPC_ID.IT_SUPPORT, -0.05)

	EventBus.consequence_triggered.emit("ticket_ignored", {"ticket_id": ticket.ticket_id, "severity": ticket.severity})

func _on_ticket_completed(ticket: TicketResource, completion_type: String, time_taken: float):
	print("🚨 ConsequenceEngine: Ticket COMPLETED: ", ticket.ticket_id, " as ", completion_type)
	
	log_player_choice("ticket_completed", {
		"ticket_id": ticket.ticket_id,
		"completion_type": completion_type,
		"time_taken": time_taken,
		"severity": ticket.severity
	})
	
	_evaluate_kill_chain_escalation(ticket, completion_type)

func _on_email_decision_processed(email: EmailResource, decision: String, inspection_state: Dictionary):
	log_email_decision(email.email_id, decision, email)
	
	if decision == GlobalConstants.EMAIL_DECISION.APPROVE:
		_handle_email_approval(email)
	elif decision == GlobalConstants.EMAIL_DECISION.QUARANTINE:
		_handle_email_quarantine(email, inspection_state)

func _handle_email_approval(email: EmailResource):
	if not email.is_malicious: 
		return 
		
	print("🚨 CONSEQUENCE: Approved malicious email!")
	
	if email.is_spear_phishing():
		print("🚨 SPEAR PHISHING DETECTED: Critical data breach risk.")
		_schedule_followup_ticket(GlobalConstants.CONSEQUENCE_ID.DATA_BREACH, 120.0, "Data breach from approved spear phishing email")
	else:
		_schedule_followup_ticket(GlobalConstants.CONSEQUENCE_ID.MALWARE_CLEANUP, 30.0, "Malware outbreak from approved malicious email")

func _handle_email_quarantine(email: EmailResource, inspection_state: Dictionary):
	if not email.is_malicious:
		print("⚠ CONSEQUENCE: Quarantined legitimate email!")
		_schedule_followup_ticket(GlobalConstants.CONSEQUENCE_ID.USER_COMPLAINT, 60.0, "User complaint: legitimate email quarantined")
		return

	for tool in email.quarantine_hidden_risks:
		if not inspection_state.get(tool, false):
			var consequence_id = email.quarantine_hidden_risks[tool]
			print("🚨 HIDDEN RISK: Quarantined without using ", tool, " | Triggering: ", consequence_id)
			trigger_consequence(consequence_id)

func update_npc_relationship(npc_id: String, change: float):
	if not npc_relationships.has(npc_id):
		npc_relationships[npc_id] = 0.0
	
	npc_relationships[npc_id] += change
	print("❤️ NPC relationship updated: ", npc_id, " | New Score: ", npc_relationships[npc_id])

func _evaluate_consequences():
	print("⚙️ Evaluating for emergent consequences...")
	_apply_social_consequences()

func _apply_social_consequences():
	var analyst_rank = get_relationship_rank(GlobalConstants.NPC_ID.SENIOR_ANALYST)
	if analyst_rank == GlobalConstants.RELATIONSHIP_RANK.ADMIRED:
		_try_auto_reveal_evidence()
	
	var it_rank = get_relationship_rank(GlobalConstants.NPC_ID.IT_SUPPORT)
	if it_rank == GlobalConstants.RELATIONSHIP_RANK.HATED:
		_try_terminal_glitch()

func get_relationship_rank(npc_id: String) -> String:
	var score = npc_relationships.get(npc_id, 0.0)
	if score >= GlobalConstants.RELATIONSHIP_THRESHOLD.ADMIRED: return GlobalConstants.RELATIONSHIP_RANK.ADMIRED
	if score >= GlobalConstants.RELATIONSHIP_THRESHOLD.RESPECTED: return GlobalConstants.RELATIONSHIP_RANK.RESPECTED
	if score <= GlobalConstants.RELATIONSHIP_THRESHOLD.HATED: return GlobalConstants.RELATIONSHIP_RANK.HATED
	if score <= GlobalConstants.RELATIONSHIP_THRESHOLD.DISTRUSTED: return GlobalConstants.RELATIONSHIP_RANK.DISTRUSTED
	return GlobalConstants.RELATIONSHIP_RANK.NEUTRAL

func _try_auto_reveal_evidence():
	if not LogSystem: return
	if randf() > 0.3: return 
	
	if TicketManager and TicketManager.has_active_tickets():
		var ticket = TicketManager.get_active_tickets().pick_random()
		if not ticket.required_log_ids.is_empty():
			var log_id = ticket.required_log_ids.pick_random()
			var log_res = LogSystem.get_log_by_id(log_id)
			if log_res and not log_res.is_revealed:
				log_res.is_revealed = true
				if NotificationManager:
					NotificationManager.show_notification("ANALYST TIP: Evidence surfaced in SIEM.", "success")

func _try_terminal_glitch():
	if not TerminalSystem: return
	if randf() > 0.2: return 
	
	if not TerminalSystem.is_terminal_locked():
		TerminalSystem.lock_terminal(10.0)
		if NotificationManager:
			NotificationManager.show_notification("TERMINAL ERROR: Network connection reset by IT.", "error")

func apply_social_favor(favor_id: String, cost: float, npc_id: String):
	var current_score = npc_relationships.get(npc_id, 0.0)
	if current_score < GlobalConstants.RELATIONSHIP_THRESHOLD.RESPECTED:
		if NotificationManager:
			NotificationManager.show_notification("FAVOR DENIED: Standing too low.", "warning")
		return

	update_npc_relationship(npc_id, -cost)
	match favor_id:
		"reveal_evidence": _reveal_guaranteed_evidence()
		"boost_bandwidth": _apply_bandwidth_boost()

func _reveal_guaranteed_evidence():
	if not LogSystem or not TicketManager: return
	var active = TicketManager.get_active_tickets()
	if active.is_empty(): return
	
	var valid_targets = []
	for t in active:
		for log_id in t.required_log_ids:
			var l = LogSystem.get_log_by_id(log_id)
			if l and not l.is_revealed:
				valid_targets.append({"ticket": t, "log_id": log_id})
	
	if not valid_targets.is_empty():
		var target = valid_targets.pick_random()
		var log_res = LogSystem.get_log_by_id(target.log_id)
		log_res.is_revealed = true
		if NotificationManager:
			NotificationManager.show_notification("FAVOR: Evidence surfaced for " + target.ticket.ticket_id, "success")

func _apply_bandwidth_boost():
	EventBus.world_event_triggered.emit(GlobalConstants.EVENTS.ISP_THROTTLING, false, 60.0)
	if NotificationManager:
		NotificationManager.show_notification("FAVOR: IT bypassed network throttling.", "success")

func _evaluate_kill_chain_escalation(ticket: TicketResource, completion_type: String):
	var risk = ESCALATION_RISKS.get(completion_type, 0.0)
	if randf() < risk:
		if ticket.kill_chain_stage >= 3:
			_spawn_black_ticket()
		else:
			_trigger_kill_chain_escalation(ticket)

func _spawn_black_ticket():
	var black_ticket_res = load("res://resources/tickets/TicketBlackRedemption.tres")
	if black_ticket_res:
		var black_ticket = black_ticket_res.duplicate()
		if TicketManager:
			TicketManager.add_ticket(black_ticket)
			EventBus.consequence_triggered.emit(GlobalConstants.CONSEQUENCE_ID.BLACK_TICKET, {"ticket_id": black_ticket.ticket_id})

func _trigger_kill_chain_escalation(ticket: TicketResource):
	if ticket.escalation_ticket == null: return
	
	var next_ticket = ticket.escalation_ticket.duplicate()
	var delay = 15.0 
	
	if LogSystem:
		for log_id in ticket.required_log_ids:
			var log = LogSystem.get_log_by_id(log_id)
			if log: log.is_revealed = true
	
	EventBus.consequence_triggered.emit(GlobalConstants.CONSEQUENCE_ID.ESCALATION, {
		"path": ticket.kill_chain_path,
		"stage": ticket.kill_chain_stage + 1,
		"original_id": ticket.ticket_id
	})
	
	if TimeManager:
		TimeManager.register_timer("escalation_" + next_ticket.ticket_id, delay, func():
			if TicketManager: TicketManager.add_ticket(next_ticket)
		)

func _schedule_followup_ticket(ticket_id: String, delay_seconds: float, reason: String, original_id: String = "N/A", target_host: String = ""):
	var consequence_data = {
		"ticket_id": ticket_id,
		"delay": delay_seconds,
		"reason": reason,
		"original_id": original_id,
		"target_host": target_host,
		"trigger_time": Time.get_ticks_msec() + (delay_seconds * 1000)
	}
	
	scheduled_consequences.append(consequence_data)
	EventBus.followup_ticket_scheduled.emit(ticket_id, delay_seconds)

	if TimeManager:
		var timer_id = "followup_" + ticket_id + "_" + original_id + "_" + str(Time.get_ticks_msec())
		TimeManager.register_timer(timer_id, delay_seconds, _spawn_followup_ticket.bind(ticket_id, reason, original_id, target_host))

func _spawn_followup_ticket(ticket_id: String, reason: String, original_id: String = "N/A", target_host: String = ""):
	if not TicketManager: return
	
	var template = TicketManager.ticket_id_map.get(ticket_id.to_lower())
	if template:
		var followup_ticket = template.duplicate()
		followup_ticket.ticket_id = ticket_id + "-" + str(randi() % 999)
		
		# Set technical fulfillment target (Sprint 13 Fix)
		if target_host != "":
			if "AUDIT" in ticket_id:
				followup_ticket.required_host_isolation = target_host
			else:
				followup_ticket.required_host_restoration = target_host
		
		if original_id != "N/A" and not original_id in followup_ticket.description:
			followup_ticket.description += "\n\n[ Context ]\nRelated: " + original_id + "\nReason: " + reason
			
		if LogSystem and original_id != "N/A":
			LogSystem.reveal_logs_for_ticket(original_id)
			
		EventBus.followup_ticket_creation_requested.emit(followup_ticket)
		EventBus.consequence_triggered.emit("followup_ticket", {"ticket_id": ticket_id, "reason": reason})

func log_player_choice(choice_type: String, choice_data: Dictionary):
	var log_entry = choice_data.duplicate()
	log_entry["type"] = choice_type
	log_entry["timestamp"] = Time.get_ticks_msec()
	choice_log.append(log_entry)

func log_email_decision(email_id: String, decision: String, email: EmailResource):
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
	return choice_log

func get_average_npc_approval() -> float:
	if npc_relationships.is_empty():
		return 0.0
	var total = 0.0
	for npc_id in npc_relationships:
		total += npc_relationships[npc_id]
	return total / npc_relationships.size()

func load_state(relationships: Dictionary, choices: Array, scheduled: Array = []):
	if relationships: npc_relationships = relationships
	if choices: choice_log = choices
	
	scheduled_consequences.clear()
	if TimeManager: TimeManager.clear_all_timers()
	
	# Re-register pending consequences
	var current_time = Time.get_ticks_msec()
	for cons in scheduled:
		var delay = (cons.trigger_time - current_time) / 1000.0
		# Clamp to minimum 0.5s to ensure timer actually fires if it was just about to
		if delay > -5.0: # Even if slightly in the past, trigger it shortly after load
			_schedule_followup_ticket(cons.ticket_id, max(0.5, delay), cons.reason, cons.original_id)

func reset_to_default():
	choice_log.clear()
	scheduled_consequences.clear()
	npc_relationships.clear()
	if TimeManager: TimeManager.clear_all_timers()
