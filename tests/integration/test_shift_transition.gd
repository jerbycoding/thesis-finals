extends GdUnitTestSuite

# Verify the full narrative chain from Monday to Friday
func test_full_shift_chain_progression():
	var current_shift_path = "res://resources/shifts/Shift1.tres"
	var expected_ids = ["shift_monday", "shift_tuesday", "shift_wednesday", "shift_thursday", "shift_friday"]
	
	for i in range(expected_ids.size()):
		var shift = load(current_shift_path) as ShiftResource
		
		# 1. Ensure this link in the chain exists
		assert_object(shift).is_not_null()
		assert_str(shift.shift_id).is_equal(expected_ids[i])
		
		# 2. If it's not the final shift, check if it points to the correct next one
		if i < expected_ids.size() - 1:
			assert_object(shift.next_shift).is_not_null()
			current_shift_path = shift.next_shift.resource_path
		else:
			# Friday should be the end (null next_shift)
			assert_object(shift.next_shift).is_null()

func test_briefing_ids_are_assigned():
	# Verify that each shift has a briefing dialogue assigned (Sprint 3 requirement)
	var shifts = [
		"res://resources/shifts/Shift1.tres",
		"res://resources/shifts/Shift2.tres",
		"res://resources/shifts/Shift3.tres",
		"res://resources/shifts/Shift4.tres",
		"res://resources/shifts/Shift5.tres"
	]
	
	for path in shifts:
		var shift = load(path) as ShiftResource
		assert_str(shift.briefing_dialogue_id).is_not_empty()