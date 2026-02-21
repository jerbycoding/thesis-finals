# SaveSystem.gd
# Autoload singleton for handling saving and loading game state.
# This system is responsible for collecting data from all relevant managers,
# serializing it to a JSON file, and distributing loaded data back to the managers.
extends Node

# The path to the save file in the user's data directory.
const SAVE_PATH = "user://savegame.json"

# Collects data from all managers and writes it to the save file.
func save_game():
# ... (save logic)
	# Data-driven shift progression: determine next shift from NarrativeDirector
	var next_shift = "shift_monday" # Default fallback
	
	if NarrativeDirector and NarrativeDirector.current_shift_resource:
		var current_shift = NarrativeDirector.current_shift_resource
		if not current_shift.next_shift_id.is_empty():
			next_shift = current_shift.next_shift_id
		else:
			# If no next shift is defined, we'll reload the current one
			# (or could mark game as completed)
			next_shift = current_shift.shift_id
	
	# Defensive checks for singletons
	if not is_instance_valid(ArchetypeAnalyzer):
		push_error("SaveSystem: ArchetypeAnalyzer is invalid/freed. Aborting save.")
		return
	if not is_instance_valid(ConsequenceEngine):
		push_error("SaveSystem: ConsequenceEngine is invalid/freed. Aborting save.")
		return
	if not is_instance_valid(NetworkState):
		push_error("SaveSystem: NetworkState is invalid/freed. Aborting save.")
		return
	if not is_instance_valid(TicketManager):
		push_error("SaveSystem: TicketManager is invalid/freed. Aborting save.")
		return
	if not is_instance_valid(IntegrityManager):
		push_error("SaveSystem: IntegrityManager is invalid/freed. Aborting save.")
		return

	var save_data = {
		# --- Player State ---
		"player_archetype": ArchetypeAnalyzer.get_analysis_results().get("archetype", "Pragmatic"),
		"player_metrics": ArchetypeAnalyzer.get_analysis_results(),
		
		# --- World State ---
		"next_shift_name": next_shift,
		"npc_relationships": ConsequenceEngine.npc_relationships,
		"network_state": NetworkState.host_states,
		"integrity_score": IntegrityManager.current_integrity,
		"current_week": HeatManager.current_week,
		"heat_multiplier": HeatManager.heat_multiplier,
		"vulnerability_buffer": HeatManager.vulnerability_buffer,
		
		# --- Persistence State ---
		"reviewed_logs": LogSystem.reviewed_logs,
		"processed_emails": EmailSystem.processed_emails,
		"scheduled_consequences": ConsequenceEngine.scheduled_consequences,
		
		# --- Progress State ---
		"active_tickets": _get_ticket_ids_from_array(TicketManager.get_active_tickets()),
		"completed_tickets": _get_ticket_ids_from_array(TicketManager.completed_tickets),
		"choice_log": ConsequenceEngine.get_choice_history()
	}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(save_data, "\t")
		file.store_string(json_string)
		file.close()
		print("Game state saved successfully to: ", ProjectSettings.globalize_path(SAVE_PATH))
	else:
		print("ERROR: Could not open save file for writing: ", SAVE_PATH)

# Loads the game state from the file and distributes it.
func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file found.")
		return false
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json_parser = JSON.new()
		var error = json_parser.parse(file.get_as_text())
		file.close()
		
		if error == OK:
			var save_data = json_parser.get_data()
			_distribute_loaded_data(save_data)
			print("Game state loaded successfully.")
			EventBus.game_loaded.emit()
			return true
		else:
			print("ERROR: Failed to parse save file: ", json_parser.get_error_message())
			return false
	return false

# Checks if a save file exists.
func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func new_game_setup():
	print("💾 SaveSystem: Executing master reset for New Game.")
	
	# 1. Reset Managers to resource defaults
	if IntegrityManager: IntegrityManager.reset_to_default()
	if ConsequenceEngine: ConsequenceEngine.reset_to_default()
	if NetworkState: NetworkState.reset_to_default()
	if HeatManager: HeatManager.reset_to_default()
	if NarrativeDirector: NarrativeDirector.reset_to_default()
	
	# 2. Purge active tool data
	if TicketManager: TicketManager.clear_active_data()
	if LogSystem: LogSystem.clear_active_data()
	if EmailSystem: EmailSystem.clear_active_data()
	
	# 3. Delete physical save file
	if has_save_file():
		DirAccess.remove_absolute(SAVE_PATH)
		print("💾 SaveSystem: Save file purged.")
	
	loaded_shift_id = ""

var loaded_shift_id: String = ""

# Calls the 'load_state' function on each manager with its relevant data slice.
func _distribute_loaded_data(data: Dictionary):
	# ArchetypeAnalyzer is stateless (derived from ConsequenceEngine), no load_state needed.
	
	if ConsequenceEngine and data.has("npc_relationships"):
		ConsequenceEngine.load_state(data.npc_relationships, data.get("choice_log", []), data.get("scheduled_consequences", []))
		
	if NetworkState and data.has("network_state"):
		NetworkState.load_state(data.network_state)
		
	if LogSystem and data.has("reviewed_logs"):
		LogSystem.reviewed_logs.assign(data.get("reviewed_logs", []))
		
	if EmailSystem and data.has("processed_emails"):
		EmailSystem.processed_emails.assign(data.get("processed_emails", []))
		
	if TicketManager and data.has("active_tickets"):
		TicketManager.load_state(data.active_tickets, data.get("completed_tickets", []))
	
	if IntegrityManager and data.has("integrity_score"):
		IntegrityManager.load_state({"current_integrity": data.integrity_score})
	
	if HeatManager and data.has("heat_multiplier"):
		HeatManager.load_state({
			"current_week": data.get("current_week", 1),
			"heat_multiplier": data.heat_multiplier,
			"vulnerability_buffer": data.get("vulnerability_buffer", [])
		})
	
	if data.has("next_shift_name"):
		loaded_shift_id = data.next_shift_name
	
	print("Save data distributed to all managers. Loaded Shift: ", loaded_shift_id)

# Helper function to convert an array of TicketResource objects to an array of their IDs.
func _get_ticket_ids_from_array(tickets: Array) -> Array[String]:
	var ids: Array[String] = []
	for ticket in tickets:
		if ticket is TicketResource:
			ids.append(ticket.ticket_id)
	return ids
