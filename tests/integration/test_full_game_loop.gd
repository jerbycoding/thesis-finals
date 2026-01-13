# tests/integration/test_full_game_loop.gd
extends GdUnitTestSuite

# We use a high time scale to run the 10-minute shifts quickly.
# 600 seconds / 100 = 6 seconds real time.
const TIME_SCALE = 100.0
const WAIT_TIMEOUT = 700000 # 700 seconds (simulated) to cover the 600s shift

func before():
	# Speed up time significantly
	Engine.time_scale = TIME_SCALE
	print("Test: Engine time_scale set to ", Engine.time_scale)

func after():
	# Restore time scale
	Engine.time_scale = 1.0
	print("Test: Engine time_scale restored")

func test_first_shift_completion():
	# Verify dependencies
	assert_that(NarrativeDirector).is_not_null()
	assert_that(TicketManager).is_not_null()
	
	print("Starting First Shift Test...")
	NarrativeDirector.start_shift("first_shift")
	
	# Verify shift started
	assert_that(NarrativeDirector.is_shift_active()).is_true()
	assert_that(NarrativeDirector.current_shift_name).is_equal("first_shift")
	
	# Wait for the shift to end
	await assert_signal(NarrativeDirector).wait_until(WAIT_TIMEOUT).is_emitted("shift_ended")
	
	# Verify shift ended
	assert_that(NarrativeDirector.is_shift_active()).is_false()
	print("First Shift Test Complete.")

func test_second_shift_completion():
	print("Starting Second Shift Test...")
	NarrativeDirector.start_shift("second_shift")
	
	assert_that(NarrativeDirector.is_shift_active()).is_true()
	assert_that(NarrativeDirector.current_shift_name).is_equal("second_shift")
	
	await assert_signal(NarrativeDirector).wait_until(WAIT_TIMEOUT).is_emitted("shift_ended")
	
	assert_that(NarrativeDirector.is_shift_active()).is_false()
	print("Second Shift Test Complete.")

func test_third_shift_completion():
	print("Starting Third Shift Test...")
	NarrativeDirector.start_shift("third_shift")
	
	assert_that(NarrativeDirector.is_shift_active()).is_true()
	assert_that(NarrativeDirector.current_shift_name).is_equal("third_shift")
	
	await assert_signal(NarrativeDirector).wait_until(WAIT_TIMEOUT).is_emitted("shift_ended")
	
	assert_that(NarrativeDirector.is_shift_active()).is_false()
	print("Third Shift Test Complete.")
