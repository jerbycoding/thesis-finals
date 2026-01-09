# ConsequenceTester.gd
# Debug tool to test consequence system
# Add this as a script to a node in your scene or call from console

extends Node

# How to use:
# 1. In Godot, open the Remote Inspector (Debug > Remote Inspector)
# 2. Or add this script to a node and call these functions
# 3. Or use the Godot console: get_node("/root/ConsequenceTester").test_consequence()

func test_consequence_scenario_1():
	# Test: Compliant completion with all evidence
	print("=== TEST 1: Compliant Completion (Should have NO consequences) ===")
	
	if not TicketManager or not TicketManager.has_active_tickets():
		print("ERROR: No active tickets. Make sure game is running and ticket exists.")
		return
	
	var ticket = TicketManager.get_active_tickets()[0]
	
	# Attach required logs
	for log_id in ticket.required_log_ids:
		TicketManager.attach_log_to_ticket(ticket.ticket_id, log_id)
		print("  ✓ Attached log: ", log_id)
	
	# Complete with compliant
	print("  → Completing ticket as COMPLIANT...")
	TicketManager.complete_ticket(ticket.ticket_id, "compliant")
	print("  → Expected: No consequences (all evidence provided)")

func test_consequence_scenario_2():
	# Test: Efficient completion WITHOUT evidence (should trigger hidden risk)
	print("\n=== TEST 2: Efficient Completion WITHOUT Evidence (Should trigger consequence) ===")
	
	if not TicketManager or not TicketManager.has_active_tickets():
		print("ERROR: No active tickets. Make sure game is running and ticket exists.")
		return
	
	var ticket = TicketManager.get_active_tickets()[0]
	
	# DON'T attach any logs
	print("  → NOT attaching any logs (missing evidence)")
	
	# Complete with efficient
	print("  → Completing ticket as EFFICIENT...")
	TicketManager.complete_ticket(ticket.ticket_id, "efficient")
	print("  → Expected: 'MALWARE-CLEANUP' ticket in 60 seconds")

func test_consequence_scenario_3():
	# Test: Emergency completion (always triggers immediate consequence)
	print("\n=== TEST 3: Emergency Completion (Should trigger immediate consequence) ===")
	
	if not TicketManager or not TicketManager.has_active_tickets():
		print("ERROR: No active tickets. Make sure game is running and ticket exists.")
		return
	
	var ticket = TicketManager.get_active_tickets()[0]
	
	# Complete with emergency
	print("  → Completing ticket as EMERGENCY...")
	TicketManager.complete_ticket(ticket.ticket_id, "emergency")
	print("  → Expected: 'EMERGENCY-FOLLOWUP' ticket in 10 seconds")

func test_manual_consequence():
	# Manually trigger a consequence for testing
	print("\n=== MANUAL CONSEQUENCE TEST ===")
	
	if ConsequenceEngine:
		ConsequenceEngine._schedule_followup_ticket("TEST-TICKET", 5.0, "Manual test consequence")
		print("  → Scheduled test ticket in 5 seconds")
	else:
		print("ERROR: ConsequenceEngine not found")

func show_consequence_info():
	# Show current consequence state
	print("\n=== CONSEQUENCE SYSTEM INFO ===")
	
	if ConsequenceEngine:
		print("  Choice History: ", ConsequenceEngine.choice_log.size(), " entries")
		print("  Scheduled Consequences: ", ConsequenceEngine.scheduled_consequences.size())
		
		for i in range(ConsequenceEngine.scheduled_consequences.size()):
			var cons = ConsequenceEngine.scheduled_consequences[i]
			print("    [", i, "] ", cons.ticket_id, " - ", cons.delay, "s delay")
	else:
		print("ERROR: ConsequenceEngine not found")
