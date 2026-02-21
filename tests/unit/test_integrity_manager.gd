# test_integrity_manager.gd
extends GdUnitTestSuite

# Load the script directly
const IntegrityManagerScript = preload("res://autoload/IntegrityManager.gd")

var integrity_manager

func before_test():
	# Instantiate the script
	integrity_manager = IntegrityManagerScript.new()
	# Disable _ready auto-connection to avoid singleton dependencies during unit tests
	integrity_manager.set_script(IntegrityManagerScript)
	integrity_manager.current_integrity = 100.0
	
	# ENSURE BASE MULTIPLIER (1.0) for unit tests
	if ConfigManager:
		ConfigManager.settings.gameplay.difficulty_level = GlobalConstants.DIFFICULTY.ANALYST
	
	# ENSURE BASE MULTIPLIER (1.0) for unit tests
	if ConfigManager:
		ConfigManager.settings.gameplay.difficulty_level = GlobalConstants.DIFFICULTY.ANALYST

func after_test():
	integrity_manager.free()

func test_initial_state():
	assert_float(integrity_manager.current_integrity).is_equal(100.0)
	assert_bool(integrity_manager.is_decay_active).is_false()

func test_apply_change_positive():
	integrity_manager.current_integrity = 50.0
	integrity_manager._apply_change(10.0)
	assert_float(integrity_manager.current_integrity).is_equal(60.0)

func test_apply_change_negative():
	integrity_manager.current_integrity = 100.0
	integrity_manager._apply_change(-15.0)
	assert_float(integrity_manager.current_integrity).is_equal(85.0)

func test_apply_change_clamp_max():
	integrity_manager.current_integrity = 95.0
	integrity_manager._apply_change(10.0)
	assert_float(integrity_manager.current_integrity).is_equal(100.0)

func test_apply_change_clamp_min():
	integrity_manager.current_integrity = 5.0
	integrity_manager._apply_change(-10.0)
	assert_float(integrity_manager.current_integrity).is_equal(0.0)

func test_decay_logic():
	integrity_manager.current_integrity = 100.0
	integrity_manager.is_decay_active = true
	integrity_manager.decay_rate_per_hour = 3600.0 # 1% per second for test speed
	
	# Simulate 1 second of delta
	integrity_manager._process(1.0)
	
	# With 3600/hour rate, 1 second should be exactly 1.0 delta
	assert_float(integrity_manager.current_integrity).is_equal(99.0)

func test_ticket_completion_deltas():
	# Test Compliant (+5)
	integrity_manager.current_integrity = 50.0
	integrity_manager._on_ticket_completed(null, "compliant", 0.0)
	assert_float(integrity_manager.current_integrity).is_equal(55.0)
	
	# Test Efficient (-2)
	integrity_manager._on_ticket_completed(null, "efficient", 0.0)
	assert_float(integrity_manager.current_integrity).is_equal(53.0)
	
	# Test Emergency (-5)
	integrity_manager._on_ticket_completed(null, "emergency", 0.0)
	assert_float(integrity_manager.current_integrity).is_equal(48.0)
	
	# Test Timeout (-10)
	integrity_manager._on_ticket_completed(null, "timeout", 0.0)
	assert_float(integrity_manager.current_integrity).is_equal(38.0)

func test_breach_consequence():
	integrity_manager.current_integrity = 100.0
	integrity_manager._on_consequence_triggered("data_loss", {})
	assert_float(integrity_manager.current_integrity).is_equal(60.0) # -40

func test_restore_integrity():
	integrity_manager.current_integrity = 50.0
	integrity_manager.restore_integrity(15.0)
	assert_float(integrity_manager.current_integrity).is_equal(65.0)

func test_critical_failure_signal():
	integrity_manager.current_integrity = 5.0
	
	integrity_manager._apply_change(-10.0)
	
	assert_float(integrity_manager.current_integrity).is_equal(0.0)
	assert_signal(integrity_manager).is_emitted("integrity_critical")
