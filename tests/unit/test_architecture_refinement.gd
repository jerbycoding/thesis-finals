# GdUnit4 Suite for Sprint 2: Architecture & Tooling
extends GdUnitTestSuite

func before_test():
	# Clean slate
	if TicketManager: TicketManager.active_tickets.clear()
	if LogSystem: LogSystem.active_logs.clear()

## WEEK 4: Automated Discovery
func test_resource_auto_discovery():
	# Verify LogSystem found resources without manual path entry
	LogSystem._prepare_library()
	assert_bool(LogSystem.all_logs.size() > 0).is_true()
	
	# Verify TicketManager found resources
	TicketManager._prepare_library()
	assert_bool(TicketManager.ticket_id_map.size() > 0).is_true()

func test_global_constants_robustness():
	# Test Enum mappings
	assert_int(GlobalConstants.get_severity_from_string("critical")).is_equal(GlobalConstants.Severity.CRITICAL)
	# Verify Event string consistency
	assert_str(GlobalConstants.EVENTS.ZERO_DAY).is_equal("ZERO_DAY")

## WEEK 5: Narrative Decoupling
func test_shift_resource_loading():
	# NarrativeDirector should have populated shift_library
	NarrativeDirector._discover_shifts()
	assert_bool(NarrativeDirector.shift_library.has("first_shift")).is_true()
	
	var shift = NarrativeDirector.shift_library["first_shift"]
	assert_bool(shift != null).is_true()
	# Check for known properties instead of explicit type hint
	assert_str(shift.get("shift_id")).is_equal("first_shift")
	assert_bool(shift.get("event_sequence").size() > 0).is_true()

## WEEK 6: UI Performance & Text Data
func test_siem_row_capping():
	# Setup a mock SIEM viewer
	var siem_scene = load("res://scenes/2d/apps/App_SIEMViewer.tscn")
	var siem = siem_scene.instantiate()
	get_tree().root.add_child(siem)
	
	# Flood with logs
	for i in range(siem.MAX_VISIBLE_LOGS + 10):
		var mock_log = LogResource.new()
		mock_log.log_id = "TEST-" + str(i)
		mock_log.timestamp = "00:00:00"
		mock_log.source = "Test"
		mock_log.message = "Test log"
		siem._on_log_added(mock_log)
	
	# Verify the UI list is capped at MAX_VISIBLE_LOGS (50)
	var list_count = siem.log_list.get_child_count()
	assert_int(list_count).is_equal(siem.MAX_VISIBLE_LOGS)
	
	# Cleanup
	siem.queue_free()

func test_corporate_voice_template_integrity():
	# Verify that the new technical templates exist and return strings
	var params = {"id": "TEST", "time": "now", "color": "white", "risk": "LOW", "source": "src", "ip": "1.1", "host": "h", "message": "msg"}
	var result = CorporateVoice.get_formatted_phrase("siem_inspector_body", params)
	
	assert_bool(result != "UNKNOWN CORPORATE PHRASE").is_true()
	assert_bool(result.contains("EVENT IDENTITY")).is_true()
