# tests/unit/EmailSystemTest.gd
extends "res://addons/gdUnit4/src/GdUnitTestSuite.gd"

# This test suite is for the EmailSystem autoload singleton.

func reset_email_system_state():
	# The EmailSystem loads emails in its _ready() function.
	# For a clean state, we clear the arrays. A better approach for true unit testing
	# would be to prevent the initial loading, but for now, this is sufficient.
	EmailSystem.all_emails.clear()
	EmailSystem.processed_emails.clear()
	# Reload initial emails to have a consistent state for each test
	EmailSystem._load_initial_emails()

func test_get_email_by_id_found():
	reset_email_system_state()
	
	# The initial emails are loaded, so we should be able to find one.
	var email = EmailSystem.get_email_by_id("EMAIL-PHISH-001")
	assert_object(email).is_not_null()
	assert_str(email.subject).is_equal("URGENT: Verify Your Account Immediately")

func test_get_email_by_id_not_found():
	reset_email_system_state()
	
	# Search for an email that doesn't exist
	var email = EmailSystem.get_email_by_id("NON-EXISTENT-EMAIL")
	assert_object(email).is_null()

func test_make_decision():
	reset_email_system_state()
	
	# Ensure the email has not been processed
	assert_bool("EMAIL-PHISH-001" in EmailSystem.processed_emails).is_false()
	
	# Make a decision
	EmailSystem.make_decision("EMAIL-PHISH-001", "quarantine")
	
	# Verify the email is now in the processed list
	assert_bool("EMAIL-PHISH-001" in EmailSystem.processed_emails).is_true()
