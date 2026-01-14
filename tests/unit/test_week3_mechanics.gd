# GdUnit4 Test Suite for Week 3 Mechanics
extends GdUnitTestSuite

func test_response_buffer_efficient():
	# Start spawning
	TicketManager.start_ambient_spawning()
	
	# Create a dummy ticket
	var ticket = TicketResource.new()
	ticket.ticket_id = "TEST-BUFFER"
	TicketManager.active_tickets.append(ticket)
	
	# Complete as efficient
	TicketManager.complete_ticket("TEST-BUFFER", "efficient")
	
	# Verify spawning is paused (timer stopped)
	assert_bool(TicketManager.ambient_spawn_timer.is_stopped()).is_true()

func test_black_ticket_spawn_on_stage3_failure():
	# Create a stage 3 ticket
	var stage3 = TicketResource.new()
	stage3.ticket_id = "TEST-FAIL-S3"
	stage3.kill_chain_path = "Test Path"
	stage3.kill_chain_stage = 3
	
	# Trigger failure (timeout)
	ConsequenceEngine._evaluate_kill_chain_escalation(stage3, "timeout")
	
	# Verify black ticket exists in queue
	var black_ticket = TicketManager.get_ticket_by_id("BLACK-TICKET-REDEMPTION")
	assert_bool(black_ticket != null).is_true()

func test_career_reset_payoff():
	# Setup metrics
	ArchetypeAnalyzer.metrics.risks_taken = 5
	
	# Trigger reset
	ArchetypeAnalyzer.perform_career_reset()
	
	# Verify reduction (5 - 2 = 3)
	assert_int(ArchetypeAnalyzer.metrics.risks_taken).is_equal(3)
