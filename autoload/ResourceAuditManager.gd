# ResourceAuditManager.gd
# Performs a one-time connectivity audit on game resources at startup.
# Reports missing links between Shifts, Tickets, and Logs.
extends Node

const SHIFT_DIR = "res://resources/shifts/"
const TICKET_DIR = "res://resources/tickets/"
const LOG_DIR = "res://resources/logs/"

func _ready():
	# Wait for other managers to prepare their libraries
	await get_tree().create_timer(2.0).timeout
	run_audit()

func run_audit():
	print("\n--- 🔍 RESOURCE CONNECTIVITY AUDIT START ---")
	
	var shifts = FileUtil.load_and_validate_resources(SHIFT_DIR, "ShiftResource")
	var tickets = FileUtil.load_and_validate_resources(TICKET_DIR, "TicketResource")
	var logs = FileUtil.load_and_validate_resources(LOG_DIR, "LogResource")
	
	var total_errors = 0
	
	# 1. Map all existing IDs and Clean Filenames (matching TicketManager logic)
	var ticket_valid_keys = []
	for t in tickets: 
		ticket_valid_keys.append(t.ticket_id.to_lower())
		var file_id = t.resource_path.get_file().get_basename().replace("Ticket", "").to_lower().trim_prefix("_")
		ticket_valid_keys.append(file_id)
	
	var log_ids = []
	for l in logs: log_ids.append(l.log_id)
	
	# 2. Audit Shifts (Shift -> Ticket)
	print("\n[Step 1: Shift Connectivity]")
	for s in shifts:
		for event in s.event_sequence:
			if event.get("type") == GlobalConstants.NARRATIVE_EVENT_TYPE.SPAWN_TICKET:
				var tid = event.get("ticket_id", "").to_lower()
				if tid not in ticket_valid_keys:
					print("  ❌ ERROR: Shift '%s' spawns non-existent Ticket '%s'" % [s.shift_name, tid])
					total_errors += 1
					
	# 3. Audit Tickets (Ticket -> Log)
	print("\n[Step 2: Ticket Evidence Connectivity]")
	for t in tickets:
		for rid in t.required_log_ids:
			if rid not in log_ids:
				print("  ❌ ERROR: Ticket '%s' (%s) requires non-existent Log '%s'" % [t.ticket_id, t.title, rid])
				total_errors += 1
				
	# 4. Audit Log Relationships (Log -> Ticket)
	print("\n[Step 3: Log Context Verification]")
	for l in logs:
		if not l.related_ticket.is_empty() and l.related_ticket != "GENERIC" and l.related_ticket != "NONE":
			if l.related_ticket.to_lower() not in ticket_valid_keys:
				print("  ⚠️ WARNING: Log '%s' points to dead Ticket ID '%s'" % [l.log_id, l.related_ticket])
	
	print("\n--- 🏁 AUDIT COMPLETE: %d CRITICAL ERRORS FOUND ---" % total_errors)
	if total_errors == 0:
		print("✅ All systems go. The game is mathematically winnable.")
	print("-------------------------------------------\n")
