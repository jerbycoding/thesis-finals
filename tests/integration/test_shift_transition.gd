extends GdUnitTestSuite

# Verify the full narrative chain from Monday to Friday (Updated for next_shift_id)
func test_full_shift_chain_progression():
	var shift_ids = ["shift_monday", "shift_tuesday", "shift_wednesday", "shift_thursday", "shift_friday", "shift_saturday", "shift_sunday", "shift_monday"]
	var shift_dir = "res://resources/shifts/"
	
	# Mapping of ID to assumed filenames (matching the project structure)
	var shift_map = {
		"shift_monday": "Shift1.tres",
		"shift_tuesday": "Shift2.tres",
		"shift_wednesday": "Shift3.tres",
		"shift_thursday": "Shift4.tres",
		"shift_friday": "Shift5.tres",
		"shift_saturday": "ShiftSaturday.tres",
		"shift_sunday": "ShiftSunday.tres"
	}
	
	for i in range(shift_ids.size() - 1):
		var current_id = shift_ids[i]
		var next_expected_id = shift_ids[i+1]
		
		var path = shift_dir + shift_map[current_id]
		var shift = load(path) as ShiftResource
		
		assert_object(shift).is_not_null()
		assert_str(shift.shift_id).is_equal(current_id)
		assert_str(shift.next_shift_id).is_equal(next_expected_id)

func test_briefing_ids_are_assigned():
	# Verify that each shift has a briefing dialogue assigned
	var shift_files = [
		"res://resources/shifts/Shift1.tres",
		"res://resources/shifts/Shift2.tres",
		"res://resources/shifts/Shift3.tres",
		"res://resources/shifts/Shift4.tres",
		"res://resources/shifts/Shift5.tres",
		"res://resources/shifts/ShiftSaturday.tres",
		"res://resources/shifts/ShiftSunday.tres"
	]
	
	for path in shift_files:
		var shift = load(path) as ShiftResource
		assert_str(shift.briefing_dialogue_id).is_not_empty()
