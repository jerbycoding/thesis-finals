# tests/unit/ConsequenceEngineTest.gd
extends "res://addons/gdUnit4/src/GdUnitTestSuite.gd"

# This test suite is for the ConsequenceEngine autoload singleton.

func reset_consequence_engine_state():
	# Manually clear the state of the singleton for each test.
	ConsequenceEngine.choice_log.clear()
	ConsequenceEngine.scheduled_consequences.clear()
	ConsequenceEngine.npc_relationships.clear()

func test_log_player_choice():
	reset_consequence_engine_state()
	
	# Initially, the choice log should be empty
	assert_int(ConsequenceEngine.get_choice_history().size()).is_equal(0)
	
	# Log a player choice
	ConsequenceEngine.log_player_choice("test_choice", {"data": "test_data"})
	
	# Verify that the choice log now contains one entry
	var history = ConsequenceEngine.get_choice_history()
	assert_int(history.size()).is_equal(1)
	
	# Verify the content of the logged choice
	var logged_choice = history[0]
	assert_str(logged_choice["type"]).is_equal("test_choice")
	assert_str(logged_choice["data"]).is_equal("test_data")
	assert_bool(logged_choice.has("timestamp")).is_true()

func test_update_npc_relationship():
	reset_consequence_engine_state()
	
	# Initially, there should be no relationships
	assert_dict(ConsequenceEngine.npc_relationships).is_empty()
	
	# Update a relationship
	ConsequenceEngine.update_npc_relationship("ciso", 0.5)
	
	# Verify the relationship score
	assert_dict(ConsequenceEngine.npc_relationships).has_size(1)
	assert_float(ConsequenceEngine.npc_relationships["ciso"]).is_equal(0.5)
	
	# Update the relationship again
	ConsequenceEngine.update_npc_relationship("ciso", -0.2)
	assert_float(ConsequenceEngine.npc_relationships["ciso"]).is_equal_approx(0.3, 0.001)
