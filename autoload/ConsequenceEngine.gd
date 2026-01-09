# ConsequenceEngine.gd
# Autoload singleton that tracks player choices and triggers consequences
extends Node

const CONSEQUENCE_EVAL_INTERVAL: float = 15.0 # Evaluate every 15 seconds

signal consequence_triggered(consequence_type: String, details: Dictionary)
signal followup_ticket_scheduled(ticket_id: String, delay: float)

var choice_log: Array[Dictionary] = []

var scheduled_consequences: Array[Dictionary] = []

var npc_relationships: Dictionary = {}



# Consequence types

enum ConsequenceType {

	FOLLOWUP_TICKET,

	SECURITY_BREACH,

	TOOL_DISABLED,

	REPUTATION_LOSS

}



func update_npc_relationship(npc_id: String, change: float):

	if not npc_relationships.has(npc_id):

		npc_relationships[npc_id] = 0.0

	

	npc_relationships[npc_id] += change

	print("❤️ NPC relationship updated: ", npc_id, " | New Score: ", npc_relationships[npc_id])



func trigger_consequence(consequence_id: String):

	print("🚨 CONSECUTIVE TRIGGERED by NarrativeDirector: ", consequence_id)

	match consequence_id:

		"missed_attachment_scan":

			_schedule_followup_ticket("MALWARE-CLEANUP-NARRATIVE", 30.0, "Narrative-driven malware cleanup due to missed attachment scan")

		_:

			print("⚠ Unknown consequence ID received: ", consequence_id)



func _ready():

	# Connect to the NarrativeDirector to listen for scripted consequence events

	if NarrativeDirector:

		NarrativeDirector.spawn_consequence_requested.connect(trigger_consequence)



	# Start a timer to periodically evaluate for emergent consequences

	var consequence_timer = get_tree().create_timer(CONSEQUENCE_EVAL_INTERVAL, false)

	consequence_timer.timeout.connect(_evaluate_consequences)



func _evaluate_consequences():

	# TODO: Implement logic to evaluate player choices from 'choice_log'

	# and trigger emergent consequences based on patterns of behavior.

	print("⚙️ Evaluating for emergent consequences...")

	pass



func log_ticket_completion(ticket_id: String, completion_type: String, ticket: TicketResource, time_remaining: float):

	print("📝 Logging ticket completion: ", ticket_id, " - ", completion_type)

	

	var choice_data = {

		"ticket_id": ticket_id,

		"completion_type": completion_type,

		"time_remaining": time_remaining,

		"timestamp": Time.get_ticks_msec(),

		"ticket_category": ticket.category,

		"ticket_severity": ticket.severity

	}

	

	choice_log.append(choice_data)

	

	# Check for hidden risks

	_check_hidden_risks(ticket, completion_type)

	

	# Schedule consequences based on completion type

	_schedule_consequences(ticket, completion_type, time_remaining)



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

		_schedule_followup_ticket("MALWARE-CLEANUP", 60.0, "Malware cleanup required after missed detection")

	elif "breach" in risk.to_lower() or "data" in risk.to_lower():

		# Spawn data breach report

		_schedule_followup_ticket("BREACH-REPORT", 30.0, "Data breach report required")

	else:

		# Generic followup

		_schedule_followup_ticket("FOLLOWUP-001", 90.0, "Follow-up investigation required")



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

				_schedule_followup_ticket("EFFICIENT-RISK", 60.0, "Rushed resolution may have missed critical checks")

			else:

				print("✓ Efficient completion - Moderate risk accepted")

		

		"emergency":

			# Emergency completion - high risk, immediate consequences

			print("🚨 Emergency completion - Immediate consequences")

			_schedule_followup_ticket("EMERGENCY-FOLLOWUP", 10.0, "Emergency resolution requires immediate follow-up")



func _schedule_followup_ticket(ticket_id: String, delay_seconds: float, reason: String):

	print("📅 Scheduling follow-up ticket: ", ticket_id, " in ", delay_seconds, " seconds")

	print("  Reason: ", reason)

	

	var consequence_data = {

		"ticket_id": ticket_id,

		"delay": delay_seconds,

		"reason": reason,

		"trigger_time": Time.get_ticks_msec() + (delay_seconds * 1000)

	}

	

	scheduled_consequences.append(consequence_data)

	followup_ticket_scheduled.emit(ticket_id, delay_seconds)

	

	# Start timer to spawn ticket (don't await here, use call_deferred)

	get_tree().create_timer(delay_seconds).timeout.connect(_spawn_followup_ticket.bind(ticket_id, reason))



func _spawn_followup_ticket(ticket_id: String, reason: String):

	print("🚨 Spawning follow-up ticket: ", ticket_id)

	

	# For now, create a simple follow-up ticket

	# TODO: Load from ticket library or create dynamically

	var followup_ticket = TicketResource.new()

	followup_ticket.ticket_id = ticket_id

	followup_ticket.title = "Follow-up Investigation Required"

	followup_ticket.description = reason

	followup_ticket.severity = "High"

	followup_ticket.category = "Follow-up"

	

	# Initialize arrays properly for Resource (use append to avoid type issues)

	followup_ticket.steps.clear()

	followup_ticket.steps.append("Review previous incident")

	followup_ticket.steps.append("Complete additional checks")

	followup_ticket.hidden_risks.clear()

	followup_ticket.required_log_ids.clear()

	

	followup_ticket.required_tool = "siem"

	followup_ticket.base_time = 180.0

	

	if TicketManager:

		TicketManager.add_ticket(followup_ticket)

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



func get_choice_history() -> Array[Dictionary]:

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
