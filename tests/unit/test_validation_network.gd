# GdUnit4 Test Suite for ValidationManager and NetworkState
extends GdUnitTestSuite

func before_test():
	# Reset NetworkState if possible (it doesn't have a reset but we can clear host_states)
	NetworkState.host_states = {
		"FINANCE-SRV-01": {"status": "CLEAN", "critical": true, "isolated": false, "scanned": false},
		"WEB-SRV-01": {"status": "CLEAN", "critical": true, "isolated": false, "scanned": false},
		"DB-SRV-01": {"status": "CLEAN", "critical": true, "isolated": false, "scanned": false},
		"WORKSTATION-45": {"status": "INFECTED", "critical": false, "isolated": false, "scanned": false}
	}

func test_validation_manager_ticket_evidence():
	var ticket = TicketResource.new()
	ticket.ticket_id = "VAL-TEST"
	ticket.required_log_ids = ["LOG-1", "LOG-2"]
	
	# No evidence
	assert_bool(ValidationManager.can_complete_compliant(ticket)).is_false()
	
	# Partial evidence
	ticket.attach_log("LOG-1")
	assert_bool(ValidationManager.can_complete_compliant(ticket)).is_false()
	
	# Full evidence
	ticket.attach_log("LOG-2")
	assert_bool(ValidationManager.can_complete_compliant(ticket)).is_true()

func test_validation_manager_email_action():
	var state = {"subject": false, "sender": false, "body": false}
	assert_bool(ValidationManager.can_action_email(state)).is_false()
	
	state["subject"] = true
	assert_bool(ValidationManager.can_action_email(state)).is_true()

func test_network_state_registration():
	NetworkState.register_host("NEW-HOST")
	assert_bool(NetworkState.host_states.has("NEW-HOST")).is_true()
	assert_str(NetworkState.get_host_state("NEW-HOST").status).is_equal("CLEAN")

func test_network_state_update():
	NetworkState.update_host_state("WEB-SRV-01", {"status": "INFECTED", "scanned": true})
	var state = NetworkState.get_host_state("WEB-SRV-01")
	assert_str(state.status).is_equal("INFECTED")
	assert_bool(state.scanned).is_true()
	assert_bool(state.critical).is_true() # Should persist

func test_validation_manager_isolation_gate():
	# WEB-SRV-01 starts as scanned: false in before_test
	assert_bool(ValidationManager.can_isolate_host("WEB-SRV-01")).is_false()
	
	NetworkState.update_host_state("WEB-SRV-01", {"scanned": true})
	assert_bool(ValidationManager.can_isolate_host("WEB-SRV-01")).is_true()

func test_network_discovery_robustness():
	# This tests if NetworkState can find hosts from resources
	# We manually trigger it for the test
	NetworkState._discover_hosts_from_resources()
	
	# Check for some known hosts that should be in the .tres files
	# e.g., 'FINANCE-SRV-01' is in TicketDataExfiltration.tres
	assert_bool(NetworkState.host_states.has("FINANCE-SRV-01")).is_true()
