# KillChainTester.gd
# This script provides functions to verify the Kill Chain escalation logic.
# Use: Call these functions from the Godot Remote Inspector or a debug trigger.
extends Node

func run_all_tests():
	await test_malware_path_probability()
	await get_tree().create_timer(2.0).timeout
	await test_timeout_guaranteed_escalation()

## Test 1: Path A (Malware) with 50% risk (Efficient)
func test_malware_path_probability():
	print("\n[TEST] === Path A Escalation Probability (50% Risk) ===")
	if not TicketManager:
		print("[ERROR] TicketManager not found")
		return

	# 1. Spawn Stage 1
	print("[STEP 1] Spawning PHISH-001 Stage 1...")
	TicketManager.spawn_ticket_by_id("phish-001")
	await get_tree().create_timer(0.5).timeout
	
	var ticket = TicketManager.get_ticket_by_id("PHISH-001")
	if not ticket:
		print("[ERROR] PHISH-001 failed to spawn")
		return
	
	# 2. Complete as Efficient (50% risk)
	print("[STEP 2] Completing PHISH-001 as EFFICIENT (50% risk)...")
	# We manually trigger completion
	TicketManager.complete_ticket("PHISH-001", "efficient")
	
	print("[INFO] Waiting 16s for escalation roll result (ConsequenceEngine delay is 15s)...")
	await get_tree().create_timer(16.0).timeout
	
	var next_ticket = TicketManager.get_ticket_by_id("MALWARE-CONTAIN-001")
	if next_ticket:
		print("[SUCCESS] Escalation TRIGGERED. MALWARE-CONTAIN-001 is now in queue.")
		_verify_log_revelation(ticket)
	else:
		print("[INFO] No escalation. (This is expected 50% of the time).")

## Test 2: Timeout (100% Escalation)
func test_timeout_guaranteed_escalation():
	print("\n[TEST] === Timeout Guaranteed Escalation (100% Risk) ===")
	
	# Clean up queue first
	for t in TicketManager.get_active_tickets():
		TicketManager.complete_ticket(t.ticket_id, "compliant")

	print("[STEP 1] Spawning SOCIAL-001 Stage 1...")
	TicketManager.spawn_ticket_by_id("social-001")
	await get_tree().create_timer(0.5).timeout
	
	var ticket = TicketManager.get_ticket_by_id("SOCIAL-001")
	
	# Force a timeout signal
	print("[STEP 2] Forcing TIMEOUT on SOCIAL-001...")
	TicketManager._on_ticket_timeout_timer("SOCIAL-001")
	
	print("[INFO] Waiting 16s for automatic escalation...")
	await get_tree().create_timer(16.0).timeout
	
	if TicketManager.get_ticket_by_id("INSIDER-001"):
		print("[SUCCESS] Automatic escalation TRIGGERED. INSIDER-001 is active.")
		_verify_log_revelation(ticket)
	else:
		print("[FAILURE] Escalation failed to trigger on timeout.")

func _verify_log_revelation(original_ticket: TicketResource):
	print("[INFO] Verifying Evidence Flash (is_revealed flags)...")
	success = true
	for log_id in original_ticket.required_log_ids:
		var log = LogSystem.get_log_by_id(log_id)
		if log:
			if log.is_revealed:
				print("  \u2713 Log %s marked as [REVEALED]" % log_id)
			else:
				print("  \u2715 Log %s NOT marked as revealed" % log_id)
			success = false
	
	if success:
		print("[SUCCESS] Evidence Flash verification passed.")
	else:
		print("[FAILURE] Some logs were not correctly revealed.")
