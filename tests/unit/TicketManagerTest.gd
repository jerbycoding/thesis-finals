# tests/unit/TicketManagerTest.gd
extends "res://addons/gdUnit4/src/core/GdUnitTestSuite.gd"

# This test suite is for the TicketManager autoload singleton.
# We will access the global TicketManager instance directly.

func reset_ticket_manager_state():
	# Manually clear the arrays in the singleton to ensure a clean state for each test.
	TicketManager.active_tickets.clear()
	TicketManager.completed_tickets.clear()

# Test Cases
func test_add_ticket():
	reset_ticket_manager_state()
	
	# Preload a ticket resource for testing
	var phishing_ticket_script = load("res://resources/tickets/ticket_phishing_01.gd")
	var ticket_resource = phishing_ticket_script.new()
	
	# Initially, there should be no active tickets
	assert_int(TicketManager.get_active_tickets().size()).is_equal(0)
	
	# Add the ticket
	TicketManager.add_ticket(ticket_resource)
	
	# Verify that there is now one active ticket
	assert_int(TicketManager.get_active_tickets().size()).is_equal(1)
	# Verify that the ticket in the queue is the one we added
	assert_str(TicketManager.get_active_tickets()[0].ticket_id).is_equal("PHISH-001")

func test_complete_ticket():
	reset_ticket_manager_state()
	
	# Preload a ticket resource for testing
	var phishing_ticket_script = load("res://resources/tickets/ticket_phishing_01.gd")
	var ticket_resource = phishing_ticket_script.new()
	
	# Add the ticket first
	TicketManager.add_ticket(ticket_resource)
	assert_int(TicketManager.get_active_tickets().size()).is_equal(1)
	assert_int(TicketManager.completed_tickets.size()).is_equal(0)
	
	# Complete the ticket
	TicketManager.complete_ticket("PHISH-001", "compliant")
	
	# Verify the ticket was moved from active to completed
	assert_int(TicketManager.get_active_tickets().size()).is_equal(0)
	assert_int(TicketManager.completed_tickets.size()).is_equal(1)
	assert_str(TicketManager.completed_tickets[0].ticket_id).is_equal("PHISH-001")

func test_spawn_ticket_by_id():
	reset_ticket_manager_state()
	
	# The spawn_ticket_by_id function is connected to the NarrativeDirector singleton.
	# We can call the function directly to ensure it adds a ticket.
	
	# Ensure the map is populated (it should be by default)
	assert_true(TicketManager.ticket_id_map.has("phishing_intro"))
	
	# Call the function
	TicketManager.spawn_ticket_by_id("phishing_intro")
	
	# Verify a ticket was added
	assert_int(TicketManager.get_active_tickets().size()).is_equal(1)
	# The ID in the map 'phishing_intro' points to 'ticket_spear_phish.gd' which has the ID 'SPEAR-PHISH-001'
	assert_str(TicketManager.get_active_tickets()[0].ticket_id).is_equal("SPEAR-PHISH-001")
