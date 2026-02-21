# test_email_system.gd
extends GdUnitTestSuite

# Load the script directly to test it in isolation
const EmailSystemScript = preload("res://autoload/EmailSystem.gd")

var email_system

func before_test():
	email_system = EmailSystemScript.new()
	# Initialize internal libraries to empty for a clean test
	email_system.all_emails.clear()
	email_system.active_emails.clear()
	email_system.processed_emails.clear()

func after_test():
	email_system.free()

func test_add_email():
	var email = EmailResource.new()
	email.email_id = "TEST-001"
	
	email_system.add_email(email)
	
	assert_int(email_system.active_emails.size()).is_equal(1)
	assert_object(email_system.get_email_by_id("TEST-001")).is_equal(email)

func test_reveal_emails_for_ticket_exact_match():
	var email = EmailResource.new()
	email.email_id = "TEST-MATCH"
	email.related_ticket = "TICKET-123"
	
	email_system.all_emails.append(email)
	
	# Act: Reveal for a specific ticket
	email_system.reveal_emails_for_ticket("TICKET-123")
	
	assert_int(email_system.active_emails.size()).is_equal(1)
	assert_str(email_system.active_emails[0].email_id).is_equal("TEST-MATCH")

func test_reveal_emails_for_ticket_generic():
	var email = EmailResource.new()
	email.email_id = "GENERIC-001"
	email.related_ticket = "GENERIC"
	
	email_system.all_emails.append(email)
	
	# Act: Reveal for ANY ticket should still show generic emails
	email_system.reveal_emails_for_ticket("SOME-OTHER-TICKET")
	
	assert_int(email_system.active_emails.size()).is_equal(1)
	assert_str(email_system.active_emails[0].email_id).is_equal("GENERIC-001")

func test_make_decision_processing_state():
	var email = EmailResource.new()
	email.email_id = "DECISION-TEST"
	email_system.add_email(email)
	
	# Act: Approve
	email_system.make_decision("DECISION-TEST", "approve")
	
	assert_int(email_system.processed_emails.size()).is_equal(1)
	assert_bool("DECISION-TEST" in email_system.processed_emails).is_true()
	
	# Verify that processing the SAME email again is blocked
	email_system.make_decision("DECISION-TEST", "quarantine")
	assert_int(email_system.processed_emails.size()).is_equal(1) # Should still be 1

func test_make_decision_invalid_input():
	var email = EmailResource.new()
	email.email_id = "INVALID-TEST"
	email_system.add_email(email)
	
	# Act: Use an undefined decision string
	email_system.make_decision("INVALID-TEST", "delete_forever")
	
	# Should NOT be in processed list
	assert_int(email_system.processed_emails.size()).is_equal(0)

func test_get_unprocessed_emails():
	var e1 = EmailResource.new()
	e1.email_id = "E1"
	var e2 = EmailResource.new()
	e2.email_id = "E2"
	
	email_system.add_email(e1)
	email_system.add_email(e2)
	
	# Process one
	email_system.make_decision("E1", "approve")
	
	var unprocessed = email_system.get_unprocessed_emails()
	assert_int(unprocessed.size()).is_equal(1)
	assert_str(unprocessed[0].email_id).is_equal("E2")
