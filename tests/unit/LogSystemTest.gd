# tests/unit/LogSystemTest.gd
extends "res://addons/gdUnit4/src/GdUnitTestSuite.gd"

# This test suite is for the LogSystem autoload singleton.

func reset_log_system_state():
	# The LogSystem loads logs in its _ready() function.
	# For a clean state, we clear the arrays and reload.
	LogSystem.all_logs.clear()
	LogSystem.reviewed_logs.clear()
	LogSystem._load_initial_logs()

func test_get_log_by_id_found():
	reset_log_system_state()
	
	# The initial logs are loaded, so we should be able to find one.
	var log = LogSystem.get_log_by_id("LOG-PHISH-001")
	assert_object(log).is_not_null()
	assert_str(log.source).is_equal("Email Gateway")

func test_get_log_by_id_not_found():
	reset_log_system_state()
	
	# Search for a log that doesn't exist
	var log = LogSystem.get_log_by_id("NON-EXISTENT-LOG")
	assert_object(log).is_null()

func test_mark_log_reviewed():
	reset_log_system_state()
	
	# Ensure the log has not been reviewed
	assert_bool(LogSystem.is_log_reviewed("LOG-PHISH-001")).is_false()
	
	# Mark the log as reviewed
	LogSystem.mark_log_reviewed("LOG-PHISH-001")
	
	# Verify the log is now marked as reviewed
	assert_bool(LogSystem.is_log_reviewed("LOG-PHISH-001")).is_true()
