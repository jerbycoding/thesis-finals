# SaveSystem.gd
# Autoload singleton for handling saving and loading game state.
# This system is responsible for collecting data from all relevant managers,
# serializing it to a JSON file, and distributing loaded data back to the managers.
extends Node

# The path to the save file in the user's data directory.
const SAVE_PATH = "user://savegame.json"
const GLOBAL_STATS_PATH = "user://global_stats.json"

var global_stats = {
	"analyst": {
		"shifts_completed": 0,
		"total_integrity_preserved": 0.0,
		"avg_integrity": 100.0,
		"tickets_resolved": 0
	},
	"hacker": {
		"days_survived": 0,
		"total_bounty": 0,
		"footholds_established": 0,
		"max_trace_level": 0.0
	},
	"meta": {
		"total_playtime": 0.0,
		"last_played": "",
		"player_name": "ANALYST_PENDING"
	}
}

func set_player_name(new_name: String):
	global_stats.meta.player_name = new_name.to_upper().replace(" ", "_")
	save_global_stats()

func _ready():
	load_global_stats()

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
		"choice_log": ConsequenceEngine.get_choice_history(),

		# --- SOLO DEV PHASE 5: HACKER CAMPAIGN ---
		"hacker_role": {
			"current_day": NarrativeDirector.current_hacker_day if NarrativeDirector else 0,
			"bounty": BountyLedger.get_bounty() if BountyLedger else 0,
			"footholds": GameState.hacker_footholds.duplicate() if GameState else {},
			"current_foothold": GameState.current_foothold if GameState else "",
			"completed_contracts": ContractManager.get_completed_ids() if ContractManager else []
		}
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

# --- GLOBAL STATS (PHASE 1) ---

func save_global_stats():
	var file = FileAccess.open(GLOBAL_STATS_PATH, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(global_stats, "\t")
		file.store_string(json_string)
		file.close()
		print("💾 SaveSystem: Global stats saved.")

func load_global_stats():
	if not FileAccess.file_exists(GLOBAL_STATS_PATH):
		save_global_stats() # Initialize file
		return
		
	var file = FileAccess.open(GLOBAL_STATS_PATH, FileAccess.READ)
	if file:
		var json_parser = JSON.new()
		var error = json_parser.parse(file.get_as_text())
		file.close()
		if error == OK:
			var data = json_parser.get_data()
			# Deep merge to ensure compatibility if we add new keys later
			for category in data:
				if global_stats.has(category):
					for key in data[category]:
						global_stats[category][key] = data[category][key]
			print("💾 SaveSystem: Global stats loaded.")

func update_global_stats(role: String, data: Dictionary):
	"""
	Call this at the end of a shift to record results.
	'role' should be "analyst" or "hacker"
	'data' should contain keys matching the global_stats sub-dictionaries.
	"""
	if not global_stats.has(role): return
	
	match role:
		"analyst":
			global_stats.analyst.shifts_completed += 1
			global_stats.analyst.tickets_resolved += data.get("tickets_resolved", 0)
			var integrity = data.get("final_integrity", 100.0)
			global_stats.analyst.total_integrity_preserved += integrity
			global_stats.analyst.avg_integrity = global_stats.analyst.total_integrity_preserved / global_stats.analyst.shifts_completed
		"hacker":
			global_stats.hacker.days_survived += 1
			global_stats.hacker.total_bounty += data.get("bounty_earned", 0)
			global_stats.hacker.footholds_established += data.get("footholds_established", 0)
			global_stats.hacker.max_trace_level = max(global_stats.hacker.max_trace_level, data.get("max_trace", 0.0))
	
	global_stats.meta.last_played = Time.get_datetime_string_from_system()
	save_global_stats()

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
	
	# 3. Purge Hacker/Forensic slates
	if HackerHistory: HackerHistory.clear_history()
	if BountyLedger: BountyLedger.reset_ledger()
	
	# 4. Preservation Logic: Do not delete physical file until a NEW save is issued.
	# This prevents accidental data loss if 'Start Game' is clicked by mistake.
	# if has_save_file():
	# 	DirAccess.remove_absolute(SAVE_PATH)
	# 	print("💾 SaveSystem: Save file purged.")
	
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

	# === SOLO DEV PHASE 5: HACKER CAMPAIGN RESTORE ===
	if data.has("hacker_role"):
		var hacker_data = data.hacker_role
		if BountyLedger:
			BountyLedger.set_bounty(hacker_data.get("bounty", 0))
		if GameState:
			GameState.hacker_footholds = hacker_data.get("footholds", {})
			GameState.current_foothold = hacker_data.get("current_foothold", "")
		# Note: Contract completion state is restored via contract IDs matching
		# ContractManager will load contracts from disk, then we'd need to re-mark
		# completed ones — but for MVHR, bounty + footholds is sufficient
		print("💾 SaveSystem: Hacker data restored (Day %d, Bounty: $%d, Footholds: %d)" % [
			hacker_data.get("current_day", 0),
			hacker_data.get("bounty", 0),
			hacker_data.get("footholds", {}).size()
		])

	print("Save data distributed to all managers. Loaded Shift: ", loaded_shift_id)

# Helper function to convert an array of TicketResource objects to an array of their IDs.
func _get_ticket_ids_from_array(tickets: Array) -> Array[String]:
	var ids: Array[String] = []
	for ticket in tickets:
		if ticket is TicketResource:
			ids.append(ticket.ticket_id)
	return ids
