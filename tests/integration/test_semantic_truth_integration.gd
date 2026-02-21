# test_semantic_truth_integration.gd
extends GdUnitTestSuite

func test_truth_packet_propagation():
	# This test verifies that data generated for a Ticket 
	# correctly flows into related Emails and Logs.
	
	# 1. Setup
	var ticket_id = "TRUTH-TEST-001"
	
	# 2. Add a Ticket (This triggers generate_truth_packet)
	var ticket = TicketResource.new()
	ticket.ticket_id = ticket_id
	ticket.category = "Malware"
	ticket.base_time = 180.0
	
	TicketManager.add_ticket(ticket)
	
	var generated_ip = ticket.truth_packet.get("attacker_ip", "")
	assert_str(generated_ip).is_not_empty()
	
	# 3. Create a related Email and Log
	var email = EmailResource.new()
	email.email_id = "E-TRUTH"
	email.related_ticket = ticket_id
	email.body = "Attack from {attacker_ip}"
	
	var log_res = LogResource.new()
	log_res.log_id = "L-TRUTH"
	log_res.related_ticket = ticket_id
	log_res.message = "Connection from {attacker_ip} detected."
	
	# Register them in systems
	EmailSystem.all_emails.append(email)
	LogSystem.all_logs.append(log_res)
	
	# 4. Act: Trigger the reveal (This is when TicketManager passes the packet)
	# In TicketManager.gd: _reveal_evidence_for_ticket(ticket)
	TicketManager._reveal_evidence_for_ticket(ticket)
	
	# 5. Verify Propagation
	assert_str(email.truth_packet.get("attacker_ip")).is_equal(generated_ip)
	assert_str(log_res.truth_packet.get("attacker_ip")).is_equal(generated_ip)
	
	# 6. Verify String Formatting
	assert_str(email.get_formatted_body()).is_equal("Attack from " + generated_ip)
	assert_str(log_res.get_formatted_message()).is_equal("Connection from " + generated_ip + " detected.")
	
	# Cleanup
	TicketManager.clear_active_data()
	EmailSystem.clear_active_data()
	LogSystem.clear_active_data()
