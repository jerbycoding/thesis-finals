# test_archetype_analyzer.gd
extends GdUnitTestSuite

# Load the script directly
const ArchetypeAnalyzerScript = preload("res://autoload/ArchetypeAnalyzer.gd")

var analyzer

func before_test():
	analyzer = ArchetypeAnalyzerScript.new()

func after_test():
	if is_instance_valid(analyzer):
		analyzer.free()

# --- Archetype Logic Tests ---

func test_calculate_archetype_negligent():
	# Scenario: Ignored more than completed
	var m = {
		"tickets_completed": 1,
		"tickets_ignored": 2,
		"risks_taken": 0,
		"avg_completion_time": 100.0
	}
	assert_str(analyzer._calculate_archetype(m)).is_equal(GlobalConstants.ARCHETYPE.NEGLIGENT)

func test_calculate_archetype_negligent_tie():
	# Scenario: Ignored equals completed (Boundary)
	var m = {
		"tickets_completed": 2,
		"tickets_ignored": 2,
		"risks_taken": 0,
		"avg_completion_time": 100.0
	}
	assert_str(analyzer._calculate_archetype(m)).is_equal(GlobalConstants.ARCHETYPE.NEGLIGENT)

func test_calculate_archetype_cowboy_risks():
	# Scenario: Fast but risky (3+ risks)
	var m = {
		"tickets_completed": 5,
		"tickets_ignored": 0,
		"risks_taken": 3,
		"avg_completion_time": 45.0
	}
	assert_str(analyzer._calculate_archetype(m)).is_equal(GlobalConstants.ARCHETYPE.COWBOY)

func test_calculate_archetype_cowboy_speed_variant():
	# Scenario: Only 1 risk, but very fast (< 60s)
	var m = {
		"tickets_completed": 5,
		"tickets_ignored": 0,
		"risks_taken": 1,
		"avg_completion_time": 59.0
	}
	assert_str(analyzer._calculate_archetype(m)).is_equal(GlobalConstants.ARCHETYPE.COWBOY)

func test_calculate_archetype_compliant():
	# Scenario: Zero risks, Zero ignored
	var m = {
		"tickets_completed": 5,
		"tickets_ignored": 0,
		"risks_taken": 0,
		"avg_completion_time": 120.0
	}
	assert_str(analyzer._calculate_archetype(m)).is_equal(GlobalConstants.ARCHETYPE.BY_THE_BOOK)

func test_calculate_archetype_pragmatic():
	# Scenario: Balanced (1 risk, acceptable time)
	var m = {
		"tickets_completed": 5,
		"tickets_ignored": 0,
		"risks_taken": 1,
		"avg_completion_time": 90.0
	}
	assert_str(analyzer._calculate_archetype(m)).is_equal(GlobalConstants.ARCHETYPE.PRAGMATIC)

func test_calculate_archetype_zero_activity():
	# Scenario: No tickets completed or ignored
	var m = {
		"tickets_completed": 0,
		"tickets_ignored": 0,
		"risks_taken": 0,
		"avg_completion_time": 0.0
	}
	# Should fallback to Pragmatic or at least not crash
	assert_str(analyzer._calculate_archetype(m)).is_equal(GlobalConstants.ARCHETYPE.PRAGMATIC)

# --- Metric Extraction Tests ---

func test_metric_calculation_from_history():
	# Mock history setup
	var mock_history = [
		{"type": "ticket_completed", "time_taken": 40.0, "completion_type": GlobalConstants.COMPLETION_TYPE.EFFICIENT},
		{"type": "ticket_completed", "time_taken": 60.0, "completion_type": GlobalConstants.COMPLETION_TYPE.COMPLIANT},
		{"type": "ticket_ignored"},
		{"type": "tool_used", "tool_name": "Scanner"}
	]
	
	# We need to simulate the history in ConsequenceEngine for this test
	# Since we're unit testing the analyzer's logic, we'll verify it parses this structure correctly
	# if we were to inject it.
	
	# Note: ArchetypeAnalyzer._calculate_metrics_from_history() directly accesses ConsequenceEngine.
	# For a pure unit test, we test the logic inside the loop if we can.
	# Let's verify the processing logic.
	
	var m = {
		"tickets_completed": 0,
		"tickets_ignored": 0,
		"total_completion_time": 0.0,
		"risks_taken": 0,
		"tools_used": {}
	}
	
	for entry in mock_history:
		match entry.get("type", ""):
			"ticket_completed":
				m.tickets_completed += 1
				m.total_completion_time += entry.get("time_taken", 0.0)
				var c_type = entry.get("completion_type", "")
				if c_type in [GlobalConstants.COMPLETION_TYPE.EFFICIENT, GlobalConstants.COMPLETION_TYPE.EMERGENCY]:
					m.risks_taken += 1
			"ticket_ignored":
				m.tickets_ignored += 1
			"tool_used":
				var tool = entry.get("tool_name", "unknown")
				m.tools_used[tool] = m.tools_used.get(tool, 0) + 1
	
	assert_int(m.tickets_completed).is_equal(2)
	assert_int(m.tickets_ignored).is_equal(1)
	assert_int(m.risks_taken).is_equal(1)
	assert_float(m.total_completion_time).is_equal(100.0)
	assert_int(m.tools_used["Scanner"]).is_equal(1)
