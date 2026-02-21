# test_afk_failure.gd
extends GdUnitTestSuite

func test_afk_bankrupt_failure():
	# 1. Setup - We need the real IntegrityManager and TicketManager
	# Note: In GdUnit4 integration tests, we can use the actual Autoloads if they are in the tree.
	# But for a clean test, we'll monitor the signals.
	
	var integrity_manager = IntegrityManager
	var ticket_manager = TicketManager
	
	# Reset state
	integrity_manager.reset_to_default()
	ticket_manager.clear_active_data()
	
	# 2. Simulate Shift Start
	integrity_manager.start_decay()
	
	# 3. Spawn a critical ticket that will time out
	var critical_ticket = TicketResource.new()
	critical_ticket.ticket_id = "TEST-CRIT-001"
	critical_ticket.severity = "Critical"
	critical_ticket.base_time = 0.5 # Super short for test
	
	ticket_manager.add_ticket(critical_ticket)
	
	# 4. Wait for timeout
	await get_tree().create_timer(1.0).timeout
	
	# 5. Verify Integrity dropped
	# DELTA_TIMEOUT is -10.0
	assert_float(integrity_manager.current_integrity).is_less_than(95.0) 
	
	# 6. Force rapid failure by spawning more timeouts if needed, 
	# or just manually triggering enough to hit 0.
	for i in range(10):
		integrity_manager._on_ticket_ignored(critical_ticket)
		
	# 7. Verify failure state
	assert_float(integrity_manager.current_integrity).is_equal(0.0)
	assert_signal(integrity_manager).is_emitted("integrity_critical")
	
	# Clean up
	integrity_manager.reset_to_default()
	ticket_manager.clear_active_data()

func test_negligence_firing_failure():
	# Verify that ignoring more tickets than completing leads to NEGLIGENT archetype
	var analyzer = ArchetypeAnalyzer
	
	# Manually log choices into ConsequenceEngine to simulate a shift
	if ConsequenceEngine:
		ConsequenceEngine.reset_to_default()
		
		# 1 Completed, 2 Ignored
		ConsequenceEngine.log_player_choice("ticket_completed", {"time_taken": 10.0, "completion_type": "compliant"})
		ConsequenceEngine.log_player_choice("ticket_ignored", {"severity": "High"})
		ConsequenceEngine.log_player_choice("ticket_ignored", {"severity": "High"})
		
		var results = analyzer.get_analysis_results()
		assert_str(results.archetype).is_equal(GlobalConstants.ARCHETYPE.NEGLIGENT)
		
		# Cleanup
		ConsequenceEngine.reset_to_default()
