# test_resource_connectivity.gd
# GdUnit4 Test Suite to verify the integrity of all data-driven resources.
# This ensures that shifts, tickets, and logs are correctly linked.

extends GdUnitTestSuite

const SHIFT_DIR = "res://resources/shifts/"
const TICKET_DIR = "res://resources/tickets/"
const LOG_DIR = "res://resources/logs/"

var ticket_ids := []
var log_ids := []

# Correct Lifecycle Method for GdUnit4
func before_all():
	# 1. Gather all valid Ticket IDs and their clean filenames
	var tickets = FileUtil.load_and_validate_resources(TICKET_DIR, "TicketResource")
	for t in tickets:
		ticket_ids.append(t.ticket_id.to_lower())
		var file_id = t.resource_path.get_file().get_basename().replace("Ticket", "").to_lower().trim_prefix("_")
		ticket_ids.append(file_id)
	
	# 2. Gather all valid Log IDs
	var logs = FileUtil.load_and_validate_resources(LOG_DIR, "LogResource")
	for l in logs:
		log_ids.append(l.log_id)
		
	# Sanity Check
	if ticket_ids.is_empty() or log_ids.is_empty():
		push_warning("TEST_CRITICAL: Resource libraries could not be loaded. Check FileUtil and paths.")

func test_shift_to_ticket_connectivity():
	var shifts = FileUtil.load_and_validate_resources(SHIFT_DIR, "ShiftResource")
	for s in shifts:
		for event in s.event_sequence:
			if event.get("type") == GlobalConstants.NARRATIVE_EVENT_TYPE.SPAWN_TICKET:
				var tid = event.get("ticket_id", "").to_lower()
				if not tid in ticket_ids:
					fail("Shift '%s' spawns non-existent Ticket ID: '%s'" % [s.shift_id, tid])

func test_ticket_to_log_connectivity():
	var tickets = FileUtil.load_and_validate_resources(TICKET_DIR, "TicketResource")
	for t in tickets:
		for rid in t.required_log_ids:
			if not rid in log_ids:
				fail("Ticket '%s' requires non-existent Log ID: '%s'" % [t.ticket_id, rid])

func test_log_to_ticket_context():
	var logs = FileUtil.load_and_validate_resources(LOG_DIR, "LogResource")
	for l in logs:
		var rel = l.related_ticket.to_lower()
		if not rel.is_empty() and rel != "generic" and rel != "none":
			if not rel in ticket_ids:
				fail("Log '%s' references invalid Ticket context: '%s'" % [l.log_id, l.related_ticket])

func test_kill_chain_integrity():
	var tickets = FileUtil.load_and_validate_resources(TICKET_DIR, "TicketResource")
	for t in tickets:
		if t.escalation_ticket != null:
			assert_bool(t.escalation_ticket is TicketResource).is_true()
			assert_str(t.kill_chain_path).is_not_empty()
			assert_int(t.kill_chain_stage).is_greater(0)
