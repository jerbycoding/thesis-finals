# test_archetype_analyzer.gd
extends GdUnitTestSuite

# Load the script directly
const ArchetypeAnalyzerScript = preload("res://autoload/ArchetypeAnalyzer.gd")

var analyzer

func before_test():
	analyzer = ArchetypeAnalyzerScript.new()

func after_test():
	analyzer.free()

# Test the "Negligent" Logic
func test_calculate_archetype_negligent():
	# Scenario: Ignored more than completed
	var m = {
		"tickets_completed": 1,
		"tickets_ignored": 2,
		"risks_taken": 0,
		"avg_completion_time": 100.0
	}
	
	var archetype = analyzer._calculate_archetype(m)
	assert_str(archetype).is_equal(GlobalConstants.ARCHETYPE.NEGLIGENT)

# Test the "Cowboy" Logic
func test_calculate_archetype_cowboy():
	# Scenario: Fast but risky (3+ risks)
	var m = {
		"tickets_completed": 5,
		"tickets_ignored": 0,
		"risks_taken": 3,
		"avg_completion_time": 45.0
	}
	
	var archetype = analyzer._calculate_archetype(m)
	assert_str(archetype).is_equal(GlobalConstants.ARCHETYPE.COWBOY)

# Test the "By-the-Book" Logic
func test_calculate_archetype_compliant():
	# Scenario: Zero risks, Zero ignored
	var m = {
		"tickets_completed": 5,
		"tickets_ignored": 0,
		"risks_taken": 0,
		"avg_completion_time": 120.0
	}
	
	var archetype = analyzer._calculate_archetype(m)
	assert_str(archetype).is_equal(GlobalConstants.ARCHETYPE.BY_THE_BOOK)

# Test the Default Fallback
func test_calculate_archetype_pragmatic():
	# Scenario: Balanced (1 risk, acceptable time)
	var m = {
		"tickets_completed": 5,
		"tickets_ignored": 0,
		"risks_taken": 1,
		"avg_completion_time": 90.0
	}
	
	var archetype = analyzer._calculate_archetype(m)
	assert_str(archetype).is_equal(GlobalConstants.ARCHETYPE.PRAGMATIC)
