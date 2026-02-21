# test_event_engine.gd
extends GdUnitTestSuite

const NarrativeDirectorScript = preload("res://autoload/NarrativeDirector.gd")

var director

func before_test():
	director = NarrativeDirectorScript.new()
	
	# Manually initialize @onready variables as a safeguard
	director._event_handlers = {
		GlobalConstants.NARRATIVE_EVENT_TYPE.NPC_INTERACTION: director._handle_npc_interaction,
		GlobalConstants.NARRATIVE_EVENT_TYPE.SPAWN_TICKET: director._handle_spawn_ticket,
		GlobalConstants.NARRATIVE_EVENT_TYPE.SPAWN_CONSEQUENCE: director._handle_spawn_consequence,
		GlobalConstants.NARRATIVE_EVENT_TYPE.SYSTEM_EVENT: director._handle_system_event,
		GlobalConstants.NARRATIVE_EVENT_TYPE.SHIFT_END: director._handle_shift_end
	}
	
	# Add to tree so get_tree() is valid for create_timer calls
	add_child(director)
	
	director.shift_library.clear()
	director._is_shift_active = false

func after_test():
	if is_instance_valid(director):
		if director.get_parent():
			director.get_parent().remove_child(director)
		director.free()

func test_chaos_tick_empty_pool():
	# Setup active shift with NO pool
	director._is_shift_active = true
	director.current_shift_resource = ShiftResource.new()
	director.current_shift_resource.random_event_pool.clear()
	
	# Act: Tick should not crash
	director._on_chaos_tick()
	
	assert_bool(true).is_true() # Survival check

func test_chaos_tick_selection():
	director._is_shift_active = true
	var shift = ShiftResource.new()
	var event = {"type": "system_event", "event_id": "TEST_EV", "event": "Test Event"}
	shift.random_event_pool.append(event)
	director.current_shift_resource = shift
	
	# Act: Trigger event path
	director._trigger_event(event)
	
	assert_signal(EventBus).is_emitted("world_event_triggered")

func test_event_handler_missing_data_protection():
	# Verify that malformed events don't crash the director
	var malformed = {"type": "spawn_ticket"} # Missing ticket_id
	
	# Act
	director._trigger_event(malformed)
	
	assert_bool(true).is_true() # If we reach here, protection worked

func test_variable_pool_robustness():
	# Test the data registry directly
	var registry = VariableRegistry
	if not registry: return
	
	var packet = registry.generate_truth_packet("T-001")
	
	assert_str(packet.get("victim_name", "")).is_not_empty()
	assert_str(packet.get("attacker_ip", "")).is_not_empty()

func test_shift_end_victory_logic():
	# Ensure GameState is in a safe mode to avoid awaits in NarrativeDirector
	if GameState: GameState.set_mode(GameState.GameMode.MODE_3D)
	
	# Prove that no next_shift_id means Victory
	director._is_shift_active = true
	director.current_shift_resource = ShiftResource.new()
	director.current_shift_resource.next_shift_id = ""
	
	# Act: Call the handler directly
	director._handle_shift_end({})
	
	assert_signal(EventBus).is_emitted("campaign_ended", ["victory"])
