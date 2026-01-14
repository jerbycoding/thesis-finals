# GdUnit4 End-to-End Integration Test
# Simulates full shift flows from Start to End Report
extends GdUnitTestSuite

func before_test():
	# Clean singletons
	if TicketManager:
		TicketManager.active_tickets.clear()
		TicketManager.completed_tickets.clear()
		TicketManager.stop_ambient_spawning()
	
	if NarrativeDirector:
		NarrativeDirector.stop_shift()
		NarrativeDirector.is_first_ticket_completed = false
		
	if ArchetypeAnalyzer:
		ArchetypeAnalyzer.reset_metrics()

## TEST 1: Perfect Shift (By-the-Book)
func test_shift_1_perfect_compliance():
	NarrativeDirector.start_shift("first_shift")
	var arc = NarrativeDirector.shift_library["first_shift"].event_sequence
	
	# Receive tickets
	NarrativeDirector._trigger_event(arc[0]) # SPEAR-PHISH-001
	NarrativeDirector._trigger_event(arc[2]) # MALWARE-CONTAIN-001
	
	# Attach required logs
	TicketManager.attach_log_to_ticket("MALWARE-CONTAIN-001", "LOG-MALWARE-001")
	
	# Resolve as COMPLIANT
	TicketManager.complete_ticket("SPEAR-PHISH-001", "compliant")
	TicketManager.complete_ticket("MALWARE-CONTAIN-001", "compliant")
	
	# Trigger Shift End
	NarrativeDirector._trigger_event(arc.back())
	
	# Wait for shift end signal to ensure all processing (including save) is done
	await NarrativeDirector.shift_ended
	
	var results = ArchetypeAnalyzer.get_analysis_results()
	assert_str(results.archetype).is_equal("By-the-Book")
	assert_int(results.tickets_completed).is_equal(2)
	assert_int(results.risks_taken).is_equal(0)

## TEST 2: Negligent Shift (Fail all)
func test_shift_1_negligent_performance():
	NarrativeDirector.start_shift("first_shift")
	var arc = NarrativeDirector.shift_library["first_shift"].event_sequence
	
	# Receive ticket
	NarrativeDirector._trigger_event(arc[0])
	
	# TIMEOUT (Guaranteed Negligent)
	TicketManager._on_ticket_timeout_timer("SPEAR-PHISH-001")
	
	# End shift
	NarrativeDirector._trigger_event(arc.back())
	
	await NarrativeDirector.shift_ended
	
	var results = ArchetypeAnalyzer.get_analysis_results()
	assert_str(results.archetype).is_equal("Negligent")
	assert_int(results.tickets_ignored).is_greater(0)

## TEST 3: Cowboy Shift (High Risk)
func test_shift_1_cowboy_performance():
	NarrativeDirector.start_shift("first_shift")
	var arc = NarrativeDirector.shift_library["first_shift"].event_sequence
	
	# Receive tickets
	NarrativeDirector._trigger_event(arc[0])
	NarrativeDirector._trigger_event(arc[2])
	
	# Resolve all as EMERGENCY (High Risk)
	TicketManager.complete_ticket("SPEAR-PHISH-001", "emergency")
	TicketManager.complete_ticket("MALWARE-CONTAIN-001", "emergency")
	
	# End shift
	NarrativeDirector._trigger_event(arc.back())
	
	await NarrativeDirector.shift_ended
	
	var results = ArchetypeAnalyzer.get_analysis_results()
	assert_str(results.archetype).is_equal("Cowboy")
	assert_int(results.risks_taken).is_equal(2)

## TEST 4: Pragmatic Shift (Balanced)
func test_shift_1_pragmatic_performance():
	NarrativeDirector.start_shift("first_shift")
	var arc = NarrativeDirector.shift_library["first_shift"].event_sequence
	
	# Receive 3 tickets to ensure we can have Completed > Ignored
	NarrativeDirector._trigger_event(arc[0]) # SPEAR-PHISH-001
	TicketManager.spawn_ticket_by_id("AUTH-FAIL-GENERIC")
	TicketManager.spawn_ticket_by_id("SYS-MAINT-GENERIC")
	
	# Resolve 2 as Compliant, 1 as Ignored
	TicketManager.complete_ticket("SPEAR-PHISH-001", "compliant")
	TicketManager.complete_ticket("AUTH-FAIL-GENERIC", "compliant")
	TicketManager._on_ticket_timeout_timer("SYS-MAINT-GENERIC")
	
	# End shift
	NarrativeDirector._trigger_event(arc.back())
	
	# Wait for shift end signal
	await NarrativeDirector.shift_ended
	
	var results = ArchetypeAnalyzer.get_analysis_results()
	assert_str(results.archetype).is_equal("Pragmatic")

## TEST 5: Shift 2 Perfect Compliance
func test_shift_2_perfect_compliance():
	NarrativeDirector.start_shift("second_shift")
	var arc = NarrativeDirector.shift_library["second_shift"].event_sequence
	
	NarrativeDirector._trigger_event(arc[0]) # RANSOM-001
	NarrativeDirector._trigger_event(arc[2]) # INSIDER-001
	NarrativeDirector._trigger_event(arc[3]) # SOCIAL-001
	
	# Attach evidence
	TicketManager.attach_log_to_ticket("RANSOM-001", "LOG-RANSOM-FILE-ACTIVITY")
	TicketManager.attach_log_to_ticket("INSIDER-001", "LOG-JANE-DOE-ACCESS")
	TicketManager.attach_log_to_ticket("INSIDER-001", "LOG-EXFIL-JANE-DOE")
	TicketManager.attach_log_to_ticket("SOCIAL-001", "LOG-EMAIL-002")
	
	TicketManager.complete_ticket("RANSOM-001", "compliant")
	TicketManager.complete_ticket("INSIDER-001", "compliant")
	TicketManager.complete_ticket("SOCIAL-001", "compliant")
	
	NarrativeDirector._trigger_event(arc.back())
	
	await NarrativeDirector.shift_ended
	
	var results = ArchetypeAnalyzer.get_analysis_results()
	assert_str(results.archetype).is_equal("By-the-Book")

## TEST 6: Shift 3 Perfect Compliance
func test_shift_3_perfect_compliance():
	NarrativeDirector.start_shift("third_shift")
	var arc = NarrativeDirector.shift_library["third_shift"].event_sequence
	
	NarrativeDirector._trigger_event(arc[0]) # DATA-EXFIL-001
	NarrativeDirector._trigger_event(arc[1]) # PHISH-001
	
	TicketManager.attach_log_to_ticket("DATA-EXFIL-001", "LOG-EXFIL-001")
	TicketManager.attach_log_to_ticket("DATA-EXFIL-001", "LOG-NETWORK-001")
	TicketManager.attach_log_to_ticket("PHISH-001", "LOG-PHISH-001")
	TicketManager.attach_log_to_ticket("PHISH-001", "LOG-EMAIL-002")
	
	TicketManager.complete_ticket("DATA-EXFIL-001", "compliant")
	TicketManager.complete_ticket("PHISH-001", "compliant")
	
	NarrativeDirector._trigger_event(arc.back())
	
	await NarrativeDirector.shift_ended
	
	var results = ArchetypeAnalyzer.get_analysis_results()
	assert_str(results.archetype).is_equal("By-the-Book")