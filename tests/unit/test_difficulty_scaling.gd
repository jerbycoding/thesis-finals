# test_difficulty_scaling.gd
extends GdUnitTestSuite

func test_multiplier_calculation():
	# Mock Config for Junior
	ConfigManager.settings.gameplay.difficulty_level = GlobalConstants.DIFFICULTY.JUNIOR
	var junior_mult = HeatManager.get_effective_multiplier()
	
	# Mock Config for Lead
	ConfigManager.settings.gameplay.difficulty_level = GlobalConstants.DIFFICULTY.LEAD
	var lead_mult = HeatManager.get_effective_multiplier()
	
	assert_float(junior_mult).is_less(1.0) # Junior should be easier (<1.0 pressure)
	assert_float(lead_mult).is_greater(1.0) # Lead should be harder (>1.0 pressure)
	
	print("TEST: Junior Effective: %.2f | Lead Effective: %.2f" % [junior_mult, lead_mult])

func test_ticket_time_scaling():
	var base_time = 100.0
	
	# Test Lead Scaling
	ConfigManager.settings.gameplay.difficulty_level = GlobalConstants.DIFFICULTY.LEAD
	var lead_time = HeatManager.get_scaled_time(base_time)
	
	# With Lead time_mult = 0.7, Effective Pressure = 1.42
	# Scaled Time = 100 / 1.42 = ~70s
	assert_float(lead_time).is_between(69.0, 71.0)
	
	print("TEST: Base 100s -> Lead Scaling -> %.1fs" % lead_time)
