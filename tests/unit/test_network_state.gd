# test_network_state.gd
extends GdUnitTestSuite

const NetworkStateScript = preload("res://autoload/NetworkState.gd")

var network_state

func before_test():
	network_state = NetworkStateScript.new()
	network_state.host_states.clear()
	network_state.host_resources.clear()

func after_test():
	network_state.free()

func test_update_host_state_new_host():
	# Setup a mock host
	network_state.host_states["WS-01"] = {"status": "CLEAN", "ip": "10.0.0.1"}
	
	# Act: Update status
	network_state.update_host_state("WS-01", {"status": "INFECTED"})
	
	assert_str(network_state.host_states["WS-01"]["status"]).is_equal("INFECTED")

func test_get_host_by_ip():
	network_state.host_states["SRV-ALPHA"] = {"ip": "192.168.1.10"}
	network_state.host_states["SRV-BETA"] = {"ip": "192.168.1.20"}
	
	assert_str(network_state.get_host_by_ip("192.168.1.10")).is_equal("SRV-ALPHA")
	assert_str(network_state.get_host_by_ip("192.168.1.20")).is_equal("SRV-BETA")
	assert_str(network_state.get_host_by_ip("0.0.0.0")).is_equal("")

func test_lateral_movement_simulation():
	# Setup: 1 Infected, 1 Clean
	network_state.host_states["INFECTED-1"] = {"status": "INFECTED", "isolated": false}
	network_state.host_states["CLEAN-1"] = {"status": "CLEAN", "isolated": false}
	
	network_state.lateral_movement_active = true
	
	# We'll force the random chance to pass by looping or just calling the internal method
	# Since it's a unit test, we can call the private-ish method directly
	for i in range(100): # Run enough times to overcome 30% chance
		network_state._process_lateral_movement()
		if network_state.host_states["CLEAN-1"]["status"] == "INFECTED":
			break
			
	assert_str(network_state.host_states["CLEAN-1"]["status"]).is_equal("INFECTED")

func test_lateral_movement_blocked_by_isolation():
	# Setup: Infected but ISOLATED
	network_state.host_states["INFECTED-ISO"] = {"status": "INFECTED", "isolated": true}
	network_state.host_states["CLEAN-2"] = {"status": "CLEAN", "isolated": false}
	
	network_state.lateral_movement_active = true
	
	for i in range(10):
		network_state._process_lateral_movement()
		
	# Should NOT spread because source is isolated
	assert_str(network_state.host_states["CLEAN-2"]["status"]).is_equal("CLEAN")
