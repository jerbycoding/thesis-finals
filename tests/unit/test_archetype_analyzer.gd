extends GdUnitTestSuite

# Load the script directly (Best practice for logic tests)
const ArchetypeAnalyzerScript = preload("res://autoload/ArchetypeAnalyzer.gd")

var analyzer

func before_test():
	# Instantiate the script as a simple Node or Object
	analyzer = ArchetypeAnalyzerScript.new()
	# Manually call _ready() or setup if needed, but here we just need access to the methods
	analyzer.reset_metrics() # Ensure metrics has the correct structure (including 'tools_used')

func after_test():
	# specific cleanup if needed (e.g. freeing nodes)
	analyzer.free()

# Helper to safely update metrics without destroying structure
func _set_metrics(updates: Dictionary):
	analyzer.metrics.merge(updates, true)

# Test the "Negligent" Logic
func test_calculate_archetype_negligent():
	# Scenario: Ignored more than completed
	_set_metrics({
		"tickets_completed": 1,
		"tickets_ignored": 2,
		"risks_taken": 0
	})
	
	var result = analyzer.get_analysis_results()
	assert_str(result["archetype"]).is_equal("Negligent")

# Test the "Cowboy" Logic
func test_calculate_archetype_cowboy():
	# Scenario: Fast but risky (3+ risks)
	_set_metrics({
		"tickets_completed": 5,
		"tickets_ignored": 0,
		"risks_taken": 3,
		"avg_completion_time": 45.0
	})
	
	var result = analyzer.get_analysis_results()
	assert_str(result["archetype"]).is_equal("Cowboy")

# Test the "By-the-Book" Logic
func test_calculate_archetype_compliant():
	# Scenario: Zero risks, Zero ignored
	_set_metrics({
		"tickets_completed": 5,
		"tickets_ignored": 0,
		"risks_taken": 0,
		"avg_completion_time": 120.0
	})
	
	var result = analyzer.get_analysis_results()
	assert_str(result["archetype"]).is_equal("By-the-Book")

# Test the Default Fallback
func test_calculate_archetype_pragmatic():
	# Scenario: Balanced (1 risk, acceptable time)
	_set_metrics({
		"tickets_completed": 5,
		"tickets_ignored": 0,
		"risks_taken": 1,
		"avg_completion_time": 90.0
	})
	
	var result = analyzer.get_analysis_results()
	assert_str(result["archetype"]).is_equal("Pragmatic")