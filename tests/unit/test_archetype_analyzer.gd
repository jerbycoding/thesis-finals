extends GdUnitTestSuite

# Load the script directly (Best practice for logic tests)
const ArchetypeAnalyzerScript = preload("res://autoload/ArchetypeAnalyzer.gd")

var analyzer

func before_test():
	# Instantiate the script as a simple Node or Object
	analyzer = ArchetypeAnalyzerScript.new()
	# Manually call _ready() or setup if needed, but here we just need access to the methods
	analyzer.metrics = {}

func after_test():
	# specific cleanup if needed (e.g. freeing nodes)
	analyzer.free()

# Test the "Negligent" Logic
func test_calculate_archetype_negligent():
	# Scenario: Ignored more than completed
	analyzer.metrics = {
		"tickets_completed": 1,
		"tickets_ignored": 2,
		"risks_taken": 0
	}
	
	# We access the private method or logic. 
	# In GdUnit4, we can usually test public methods. 
	# Since _calculate_archetype is private, we test get_analysis_results()
	var result = analyzer.get_analysis_results()
	assert_str(result["archetype"]).is_equal("Negligent")

# Test the "Cowboy" Logic
func test_calculate_archetype_cowboy():
	# Scenario: Fast but risky (3+ risks)
	analyzer.metrics = {
		"tickets_completed": 5,
		"tickets_ignored": 0,
		"risks_taken": 3,
		"avg_completion_time": 45.0
	}
	
	var result = analyzer.get_analysis_results()
	assert_str(result["archetype"]).is_equal("Cowboy")

# Test the "By-the-Book" Logic
func test_calculate_archetype_compliant():
	# Scenario: Zero risks, Zero ignored
	analyzer.metrics = {
		"tickets_completed": 5,
		"tickets_ignored": 0,
		"risks_taken": 0,
		"avg_completion_time": 120.0
	}
	
	var result = analyzer.get_analysis_results()
	assert_str(result["archetype"]).is_equal("By-the-Book")

# Test the Default Fallback
func test_calculate_archetype_pragmatic():
	# Scenario: Balanced (1 risk, acceptable time)
	analyzer.metrics = {
		"tickets_completed": 5,
		"tickets_ignored": 0,
		"risks_taken": 1,
		"avg_completion_time": 90.0
	}
	
	var result = analyzer.get_analysis_results()
	assert_str(result["archetype"]).is_equal("Pragmatic")
