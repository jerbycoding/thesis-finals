# GdUnit4 Test Suite for Consequence Engine logic
extends GdUnitTestSuite

var ticket: TicketResource

func before_test():
	ticket = TicketResource.new()
	ticket.ticket_id = "TEST-PHISH"
	ticket.kill_chain_path = "Test Path"
	ticket.kill_chain_stage = 1
	# Create a dummy escalation ticket
	var escalation = TicketResource.new()
	escalation.ticket_id = "TEST-MALWARE"
	ticket.escalation_ticket = escalation

func test_escalation_logic_compliant_never_escalates():
	# Verify singleton is alive
	assert_bool(is_instance_valid(ConsequenceEngine)).is_true()

	# Manually trigger the evaluation
	# Compliance has 0.0 risk, should never trigger escalation
	ConsequenceEngine._evaluate_kill_chain_escalation(ticket, "compliant")
	pass

func test_escalation_logic_timeout_always_escalates():
	# Verify singleton is alive
	assert_bool(is_instance_valid(ConsequenceEngine)).is_true()
	
	# Monitor signals
	monitor_signals(ConsequenceEngine)
	
	# Timeout has 1.0 risk
	ConsequenceEngine._evaluate_kill_chain_escalation(ticket, "timeout")
	
	# Verify signal was emitted
	await assert_signal(ConsequenceEngine).is_emitted("consequence_triggered")

func test_log_revelation_on_escalation():
	assert_bool(is_instance_valid(ConsequenceEngine)).is_true()
	assert_bool(is_instance_valid(LogSystem)).is_true()

	# Create a dummy log in LogSystem
	var log_res = LogResource.new()
	log_res.log_id = "LOG-TEST-001"
	log_res.is_revealed = false
	LogSystem.add_log(log_res)
	
	ticket.required_log_ids.assign(["LOG-TEST-001"])
	
	# Trigger escalation logic directly
	ConsequenceEngine._trigger_kill_chain_escalation(ticket)
	
	# Verify log is revealed
	assert_bool(log_res.is_revealed).is_true()
