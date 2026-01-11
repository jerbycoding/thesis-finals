# tests/unit/ValidationManagerTest.gd
extends "res://addons/gdUnit4/src/GdUnitTestSuite.gd"

func test_resource_validation_ticket():
	var ticket = TicketResource.new()
	
	# Empty ID should fail
	ticket.ticket_id = ""
	assert_bool(ticket.validate()).is_false()
	
	# Valid ID and time should pass
	ticket.ticket_id = "TEST-001"
	ticket.base_time = 180.0
	assert_bool(ticket.validate()).is_true()
	
	# Too many steps should fail
	ticket.steps.assign(["Step 1", "Step 2", "Step 3", "Step 4"])
	assert_bool(ticket.validate()).is_false()
	
	# Non-positive time should fail
	ticket.steps.assign(["Step 1"])
	ticket.base_time = 0
	assert_bool(ticket.validate()).is_false()

func test_resource_validation_email():
	var email = EmailResource.new()
	
	# Empty ID should fail
	email.email_id = ""
	assert_bool(email.validate()).is_false()
	
	# Valid email should pass
	email.email_id = "EMAIL-001"
	email.sender = "CEO"
	assert_bool(email.validate()).is_true()
	
	# Missing sender should fail
	email.sender = ""
	assert_bool(email.validate()).is_false()

func test_resource_validation_log():
	var log_res = LogResource.new()
	
	# Empty ID should fail
	log_res.log_id = ""
	assert_bool(log_res.validate()).is_false()
	
	# Valid log should pass
	log_res.log_id = "LOG-001"
	log_res.severity = 3
	assert_bool(log_res.validate()).is_true()
	
	# Invalid severity should fail
	log_res.severity = 0
	assert_bool(log_res.validate()).is_false()
	log_res.severity = 6
	assert_bool(log_res.validate()).is_false()

func test_validation_manager_ticket_compliant():
	var ticket = TicketResource.new()
	ticket.required_log_ids.assign(["LOG-1", "LOG-2"])
	
	# No evidence should fail
	assert_bool(ValidationManager.can_complete_compliant(ticket)).is_false()
	
	# Partial evidence should fail
	ticket.attached_log_ids.assign(["LOG-1"])
	assert_bool(ValidationManager.can_complete_compliant(ticket)).is_false()
	
	# Full evidence should pass
	ticket.attached_log_ids.assign(["LOG-1", "LOG-2"])
	assert_bool(ValidationManager.can_complete_compliant(ticket)).is_true()

func test_validation_manager_email_action():
	var state = {"headers": false, "attachments": false, "links": false}
	
	# No tools used should fail
	assert_bool(ValidationManager.can_action_email(state)).is_false()
	
	# One tool used should pass
	state["headers"] = true
	assert_bool(ValidationManager.can_action_email(state)).is_true()

func test_validation_manager_terminal_isolate():
	var hostname = "TEST-HOST"
	NetworkState.register_host(hostname)
	
	# Not scanned should fail
	assert_bool(ValidationManager.can_isolate_host(hostname)).is_false()
	
	# Scanned should pass
	NetworkState.update_host_state(hostname, {"scanned": true})
	assert_bool(ValidationManager.can_isolate_host(hostname)).is_true()
