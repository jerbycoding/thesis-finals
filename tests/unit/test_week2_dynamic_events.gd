# GdUnit4 Test Suite for Week 2 Dynamic Events
extends GdUnitTestSuite

func test_ambient_spawning_toggle():
	# Verify spawning starts
	TicketManager.start_ambient_spawning()
	assert_bool(TicketManager.is_ambient_spawning_enabled).is_true()
	
	# Verify spawning stops
	TicketManager.stop_ambient_spawning()
	assert_bool(TicketManager.is_ambient_spawning_enabled).is_false()

func test_zero_day_multiplier():
	# Trigger Zero Day
	NarrativeDirector.world_event.emit("ZERO_DAY", true, 10.0)
	assert_float(TerminalSystem.scan_multiplier).is_equal(1.5)
	
	# Clear Zero Day
	NarrativeDirector.world_event.emit("ZERO_DAY", false, 0.0)
	assert_float(TerminalSystem.scan_multiplier).is_equal(1.0)

func test_false_flag_log_activation():
	# Clear active logs
	LogSystem.active_logs.clear()
	
	# Emit event
	NarrativeDirector.world_event.emit("FALSE_FLAG", true, 0.5)
	
	# Wait for first noise log to spawn
	await get_tree().process_frame
	
	# Check if any logs were added
	var noise_found = false
	for log in LogSystem.active_logs:
		if log.log_id.contains("NOISE"):
			noise_found = true
			break
	
	assert_bool(noise_found).is_true()
