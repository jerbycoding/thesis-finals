# test_procedural_generation.gd
extends GdUnitTestSuite

const TicketResourceScript = preload("res://resources/tickets/TicketResource.gd")

func test_truth_packet_generation():
	# Verify VariableRegistry produces a full packet
	var packet = VariableRegistry.generate_truth_packet("TEST-001")
	
	assert_object(packet).is_not_null()
	assert_str(packet.ticket_id).is_equal("TEST-001")
	assert_str(packet.victim_name).is_not_empty()
	assert_str(packet.attacker_ip).is_not_empty()
	assert_str(packet.victim_host).is_not_empty()
	assert_bool(packet.has("context_id")).is_true()

func test_ticket_description_formatting():
	var ticket = TicketResourceScript.new()
	ticket.description = "User {victim_name} reported an issue from {victim_host}."
	ticket.truth_packet = {
		"victim_name": "Alice Vance",
		"victim_host": "WS-FIN-01"
	}
	
	var formatted = ticket.get_formatted_description()
	assert_str(formatted).is_equal("User Alice Vance reported an issue from WS-FIN-01.")

func test_ticket_title_formatting():
	var ticket = TicketResourceScript.new()
	ticket.title = "Alert: {attacker_ip} targeting {victim_dept}"
	ticket.truth_packet = {
		"attacker_ip": "1.2.3.4",
		"victim_dept": "Finance"
	}
	
	var formatted = ticket.get_formatted_title()
	assert_str(formatted).is_equal("Alert: 1.2.3.4 targeting Finance")

func test_manager_injects_packet_on_add():
	# Create a dummy ticket without a packet
	var ticket = TicketResourceScript.new()
	ticket.ticket_id = "PROC-TEST-99"
	ticket.base_time = 100.0
	ticket.steps.append("Step 1")
	
	# Verify packet is empty initially
	assert_bool(ticket.truth_packet.is_empty()).is_true()
	
	# Add to manager (this triggers injection)
	TicketManager.add_ticket(ticket)
	
	# Verify packet is now populated
	assert_bool(ticket.truth_packet.is_empty()).is_false()
	assert_str(ticket.truth_packet.ticket_id).is_equal("PROC-TEST-99")
	
	# Cleanup TicketManager queue
	TicketManager.active_tickets.erase(ticket)

func test_randomness_variety():
	# Ensure sequential generations aren't identical (statistically unlikely)
	var p1 = VariableRegistry.generate_truth_packet("T1")
	var p2 = VariableRegistry.generate_truth_packet("T2")
	
	# They should have different context IDs
	assert_str(p1.context_id).is_not_equal(p2.context_id)
	
	# The victim names should likely be different (10 employees in pool)
	# We don't assert strictly on random values, but checking context_id is enough
