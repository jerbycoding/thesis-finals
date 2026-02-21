# test_heat_inheritance.gd
extends GdUnitTestSuite

const TicketResourceScript = preload("res://resources/tickets/TicketResource.gd")
const HeatManagerScript = preload("res://autoload/HeatManager.gd")
const TicketManagerScript = preload("res://autoload/TicketManager.gd")

var heat_mgr
var ticket_mgr

func before_test():
	# We rely on the autoload instances for this integration test
	# to ensure they can talk to each other via EventBus
	heat_mgr = HeatManager
	ticket_mgr = TicketManager
	
	# Reset state
	heat_mgr.heat_multiplier = 1.0
	heat_mgr.current_week = 1
	heat_mgr.vulnerability_buffer.clear()
	ticket_mgr.active_tickets.clear()
	
	# ENSURE BASE MULTIPLIER (1.0)
	if ConfigManager:
		ConfigManager.settings.gameplay.difficulty_level = GlobalConstants.DIFFICULTY.ANALYST

func test_heat_time_scaling():
	# 1. Base Week (Heat 1.0)
	var base_time = 100.0
	var scaled = heat_mgr.get_scaled_time(base_time)
	assert_float(scaled).is_equal(100.0)
	
	# 2. Week 2 (Heat 1.15)
	heat_mgr.heat_multiplier = 1.15
	scaled = heat_mgr.get_scaled_time(base_time)
	# 100 / 1.15 = 86.95
	assert_float(scaled).is_less(100.0)
	assert_float(scaled).is_greater(80.0)

func test_inheritance_loop():
	# 1. Spawn a ticket (Ticket A)
	var ticket_a = TicketResourceScript.new()
	ticket_a.ticket_id = "TICKET-A"
	ticket_a.base_time = 100.0
	ticket_a.truth_packet = {
		"attacker_ip": "10.10.10.10", # Distinct IP
		"victim_host": "HOST-A"
	}
	ticket_mgr.add_ticket(ticket_a)
	
	# 2. Rush the ticket (Efficient Completion) -> Should trigger inheritance
	# Manually trigger the signal that HeatManager listens for
	EventBus.ticket_completed.emit(ticket_a, "efficient", 10.0)
	
	# Verify buffer has 1 entry
	assert_int(heat_mgr.vulnerability_buffer.size()).is_equal(1)
	var stored = heat_mgr.vulnerability_buffer[0]
	assert_str(stored.attacker_ip).is_equal("10.10.10.10")
	
	# 3. Spawn a new 'Malware' ticket (Ticket B) which should inherit
	var ticket_b = TicketResourceScript.new()
	ticket_b.ticket_id = "TICKET-B"
	ticket_b.category = "Malware" # Must match category check
	ticket_b.base_time = 100.0
	
	ticket_mgr.add_ticket(ticket_b)
	
	# 4. Verify Inheritance
	# Ticket B should have pulled the IP from Ticket A
	assert_str(ticket_b.truth_packet.attacker_ip).is_equal("10.10.10.10")
	assert_str(ticket_b.truth_packet.inherited_from).is_equal("TICKET-A")
	
	# Buffer should now be empty (popped)
	assert_int(heat_mgr.vulnerability_buffer.size()).is_equal(0)
