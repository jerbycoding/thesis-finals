# GdUnit4 Test Suite for Kill Chain System
extends GdUnitTestSuite

func test_ticket_resource_kill_chain_properties():
	var ticket = TicketResource.new()
	assert_str(ticket.kill_chain_path).is_equal("")
	assert_int(ticket.kill_chain_stage).is_equal(0)
	assert_object(ticket.escalation_ticket).is_null()

func test_log_resource_revealed_property():
	var log_res = LogResource.new()
	assert_bool(log_res.is_revealed).is_false()

func test_path_a_linkage():
	# Verify Path A linkage
	var phish = load("res://resources/tickets/TicketPhishing01.tres")
	var malware = load("res://resources/tickets/TicketMalwareContainment.tres")
	var ransom = load("res://resources/tickets/TicketRansomware01.tres")
	
	assert_bool(phish != null).is_true()
	assert_object(phish.escalation_ticket).is_not_null()
	assert_str(phish.escalation_ticket.ticket_id).is_equal("MALWARE-CONTAIN-001")
	
	assert_bool(malware != null).is_true()
	assert_object(malware.escalation_ticket).is_not_null()
	assert_str(malware.escalation_ticket.ticket_id).is_equal("RANSOM-001")
