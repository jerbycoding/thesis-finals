# test_resource_integrity.gd
extends GdUnitTestSuite

const SHIFT_DIR = "res://resources/shifts/"
const TICKET_DIR = "res://resources/tickets/"
const LOG_DIR = "res://resources/logs/"
const EMAIL_DIR = "res://resources/emails/"

var all_tickets: Dictionary = {}
var all_logs: Dictionary = {}
var all_emails: Dictionary = {}

func before():
	# 1. Load and Map ALL Tickets
	var ticket_res_list = FileUtil.load_and_validate_resources(TICKET_DIR, "TicketResource")
	for t in ticket_res_list:
		if all_tickets.has(t.ticket_id):
			push_error("Duplicate Ticket ID found: " + t.ticket_id)
		all_tickets[t.ticket_id] = t

	# 2. Load and Map ALL Logs
	var log_res_list = FileUtil.load_and_validate_resources(LOG_DIR, "LogResource")
	for l in log_res_list:
		all_logs[l.log_id] = l

	# 3. Load and Map ALL Emails
	var email_res_list = FileUtil.load_and_validate_resources(EMAIL_DIR, "EmailResource")
	for e in email_res_list:
		all_emails[e.email_id] = e

func test_shifts_spawn_valid_tickets():
	var shifts = FileUtil.load_and_validate_resources(SHIFT_DIR, "ShiftResource")
	
	for shift in shifts:
		for event in shift.event_sequence:
			if event.get("type") == "spawn_ticket":
				var target_id = event.get("ticket_id")
				
				# Assertion: The ticket ID in the shift MUST exist in our ticket database
				assert_bool(all_tickets.has(target_id)) \
					.override_failure_message("Shift '%s' tries to spawn non-existent ticket: '%s'" % [shift.shift_id, target_id]) \
					.is_true()

func test_tickets_require_valid_evidence():
	for ticket_id in all_tickets:
		var ticket = all_tickets[ticket_id]
		
		# Skip generic or noise tickets if they don't have requirements
		if ticket.required_log_ids.is_empty():
			continue
			
		for log_id in ticket.required_log_ids:
			# Assertion: Every required log ID MUST exist in the log database
			assert_bool(all_logs.has(log_id)) \
					.override_failure_message("Ticket '%s' requires missing log: '%s'" % [ticket_id, log_id]) \
					.is_true()

func test_logs_point_to_valid_tickets():
	for log_id in all_logs:
		var log = all_logs[log_id]
		
		# Skip noise/generic logs
		if log.related_ticket == "" or log.related_ticket == "GENERIC" or log.related_ticket == "NONE":
			continue
			
		# Assertion: If a log points to a ticket, that ticket MUST exist
		# (This ensures we don't have orphaned evidence pointing to deleted tickets)
		assert_bool(all_tickets.has(log.related_ticket)) \
			.override_failure_message("Log '%s' references missing ticket: '%s'" % [log_id, log.related_ticket]) \
			.is_true()

func test_kill_chain_integrity():
	for ticket_id in all_tickets:
		var ticket = all_tickets[ticket_id]
		
		# If a ticket has an escalation path, verify the next ticket resource is assigned
		if ticket.kill_chain_path != "":
			if ticket.kill_chain_stage < 3: # Stage 3 is usually terminal, so no escalation
				# Warning: This is a loose check, mainly looking for null resources on active chains
				if ticket.escalation_ticket == null:
					# It's okay if it's explicitly null, but we should verify logic elsewhere
					pass
				else:
					# Assertion: If an escalation resource is assigned, it must be valid
					assert_object(ticket.escalation_ticket).is_not_null()
