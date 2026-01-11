# tests/unit/NetworkStateTest.gd
extends "res://addons/gdUnit4/src/GdUnitTestSuite.gd"

# This test suite is for the NetworkState autoload singleton.

func reset_network_state():
	# The NetworkState discovers hosts in its _ready() function.
	# For a clean state, we clear the dictionary and restore the defaults.
	NetworkState.host_states.clear()
	
	# Restore pre-defined critical servers
	NetworkState.host_states["FINANCE-SRV-01"] = {"status": "CLEAN", "critical": true, "isolated": false, "scanned": false}
	NetworkState.host_states["WEB-SRV-01"] = {"status": "CLEAN", "critical": true, "isolated": false, "scanned": false}
	NetworkState.host_states["DB-SRV-01"] = {"status": "CLEAN", "critical": true, "isolated": false, "scanned": false}
	# Restore initial infected host
	NetworkState.host_states["WORKSTATION-45"] = {"status": "INFECTED", "critical": false, "isolated": false, "scanned": false}
	
	NetworkState._discover_hosts_from_resources()

func test_get_host_state():
	reset_network_state()
	
	# A host discovered from resources should exist
	var host_state = NetworkState.get_host_state("FINANCE-SRV-01")
	assert_dict(host_state).is_not_empty()
	assert_bool(host_state.get("critical")).is_true()
	
	# A non-existent host should return an empty dictionary
	var non_existent_state = NetworkState.get_host_state("NON-EXISTENT-HOST")
	assert_dict(non_existent_state).is_empty()

func test_update_host_state():
	reset_network_state()
	
	var hostname = "WEB-SRV-01"
	
	# Check initial state
	var initial_state = NetworkState.get_host_state(hostname)
	assert_bool(initial_state.get("isolated")).is_false()
	
	# Update the state
	NetworkState.update_host_state(hostname, {"isolated": true, "status": "INFECTED"})
	
	# Verify the updated state
	var updated_state = NetworkState.get_host_state(hostname)
	assert_bool(updated_state.get("isolated")).is_true()
	assert_str(updated_state.get("status")).is_equal("INFECTED")
	# Ensure other properties were not overwritten
	assert_bool(updated_state.get("critical")).is_true()
