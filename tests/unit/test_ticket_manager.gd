# test_ticket_manager.gd
extends GdUnitTestSuite

const TicketManagerScript = preload("res://autoload/TicketManager.gd")

var ticket_manager

func before_test():
	ticket_manager = TicketManagerScript.new()
	# Initialize internal libraries to empty for a clean test
	ticket_manager.active_tickets.clear()
	ticket_manager.completed_tickets.clear()
	ticket_manager.active_timers.clear()

func after_test():
	ticket_manager.free()

func test_add_ticket():
	var ticket = TicketResource.new()
	ticket.ticket_id = "T-001"
	ticket.base_time = 180.0
	
	ticket_manager.add_ticket(ticket)
	
	assert_int(ticket_manager.active_tickets.size()).is_equal(1)
	assert_bool(ticket_manager.active_timers.has("T-001")).is_true()

func test_complete_ticket_removal():
	var ticket = TicketResource.new()
	ticket.ticket_id = "T-002"
	ticket_manager.add_ticket(ticket)
	
	# Act
	ticket_manager.complete_ticket("T-002", "compliant")
	
	assert_int(ticket_manager.active_tickets.size()).is_equal(0)
	assert_int(ticket_manager.completed_tickets.size()).is_equal(1)
	assert_bool(ticket_manager.active_timers.has("T-002")).is_false()

func test_attach_log_logic():
	var ticket = TicketResource.new()
	ticket.ticket_id = "T-LOG"
	ticket_manager.add_ticket(ticket)
	
	# Act: Attach a log
	var success = ticket_manager.attach_log_to_ticket("T-LOG", "LOG-001")
	assert_bool(success).is_true()
	
	# Act: Attach same log again (should fail/return false)
	var repeat = ticket_manager.attach_log_to_ticket("T-LOG", "LOG-001")
	assert_bool(repeat).is_false()
	
	assert_int(ticket.attached_log_ids.size()).is_equal(1)

func test_detach_log_logic():
	var ticket = TicketResource.new()
	ticket.ticket_id = "T-DETACH"
	ticket_manager.add_ticket(ticket)
	ticket_manager.attach_log_to_ticket("T-DETACH", "LOG-X")
	
	# Act
	var success = ticket_manager.detach_log_from_ticket("T-DETACH", "LOG-X")
	assert_bool(success).is_true()
	assert_int(ticket.attached_log_ids.size()).is_equal(0)

func test_get_ticket_by_id():
	var t1 = TicketResource.new()
	t1.ticket_id = "ID-1"
	ticket_manager.add_ticket(t1)
	
	var found = ticket_manager.get_ticket_by_id("ID-1")
	assert_object(found).is_equal(t1)
	
	var not_found = ticket_manager.get_ticket_by_id("NON-EXISTENT")
	assert_object(not_found).is_null()

func test_clear_active_data():
	var t1 = TicketResource.new()
	t1.ticket_id = "CLEAR-ME"
	ticket_manager.add_ticket(t1)
	
	# Act
	ticket_manager.clear_active_data()
	
	assert_int(ticket_manager.active_tickets.size()).is_equal(0)
	assert_int(ticket_manager.active_timers.size()).is_equal(0)
