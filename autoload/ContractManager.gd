# ContractManager.gd
# Autoload singleton that manages the hacker campaign contracts
# Phase 4: High-Impact Payloads — Minimal scope (ONE contract type)
extends Node

signal contract_accepted(contract_id: String)
signal contract_completed(contract_id: String)

# Preload to ensure class_name is registered
const ContractResource = preload("res://scripts/resources/ContractResource.gd")
const HackerShiftResource = preload("res://scripts/resources/HackerShiftResource.gd")

# === CONTRACT TRACKING ===
var active_contract: ContractResource = null
var available_contracts: Array[ContractResource] = []
var current_shift_contracts: Array[ContractResource] = [] # FILTERED list for the current day

# === LOAD PATH ===
const CONTRACT_DIR = "res://resources/contracts/"

func _ready():
	print("========================================")
	print("ContractManager initialized")
	print("  Contract Dir: %s" % CONTRACT_DIR)
	print("========================================")

	# Load available contracts from disk using FileUtil
	load_contracts()

	# Listen for ransomware actions to check contract completion
	if EventBus:
		EventBus.offensive_action_performed.connect(_on_offensive_action)
		EventBus.host_status_changed.connect(_on_host_status_changed)

func _on_offensive_action(_data: Dictionary):
	"""
	Hacker performed an offensive action.
	In the new system, we don't auto-complete. The player must use the 
	Contract Board app to SUBMIT their work once technical requirements are met.
	"""
	pass

func _on_host_status_changed(_hostname: String, _new_status: int):
	"""Check if host status change makes active contract ready to submit."""
	# In the new system, we don't auto-complete. The player must SUBMIT.
	pass

# === PUBLIC API ===

func is_contract_ready(contract: ContractResource) -> bool:
	"""Checks if all technical requirements for a contract are met."""
	if not contract: return false
	
	# 1. Check Ransomware Requirement
	if contract.required_payload == ContractResource.PayloadType.RANSOMWARE or \
	   contract.required_payload == ContractResource.PayloadType.BOTH:
		if contract.target_hostname == "":
			# ANY host case: check if any host is ransomed
			var found_ransomed = false
			var all_hosts = NetworkState.get_all_hostnames()
			for h in all_hosts:
				var host_state = NetworkState.get_host_state(h)
				var status = str(host_state.get("status", ""))
				if status == "4" or status == "RANSOMED":
					found_ransomed = true
					break
			if not found_ransomed:
				return false
		else:
			# Specific target case
			var host_state = NetworkState.get_host_state(contract.target_hostname)
			var status = str(host_state.get("status", ""))
			if not (status == "4" or status == "RANSOMED"):
				return false
			
	# 2. Check Exfiltration Requirement
	if contract.required_payload == ContractResource.PayloadType.EXFILTRATION or \
	   contract.required_payload == ContractResource.PayloadType.BOTH:
		if not IntelligenceInventory or not IntelligenceInventory.has_data_type(contract.required_data_type):
			return false
			
	# 3. Check Wiper Requirement
	if contract.required_payload == ContractResource.PayloadType.WIPER:
		var host_state = NetworkState.get_host_state(contract.target_hostname)
		if not host_state.get("is_wiped", false):
			return false
			
	return true

func submit_contract(contract: ContractResource) -> bool:
	"""
	Executes the 7-step verification sequence for contract submission.
	"""
	if not contract or not contract.is_accepted or contract.is_completed:
		return false
		
	if not is_contract_ready(contract):
		return false
		
	# --- START 7-STEP VERIFICATION ---
	
	# 1 & 2. (Checked in is_contract_ready)
	
	# 3. Consume Item (if exfiltration was required)
	if contract.required_payload in [ContractResource.PayloadType.EXFILTRATION, ContractResource.PayloadType.BOTH]:
		# Find and consume the item
		var items = IntelligenceInventory.get_all_items()
		for item in items:
			if item.get("data_type") == contract.required_data_type:
				IntelligenceInventory.consume_item(item.get("item_id"))
				break
	
	# 4. Award Bounty
	if BountyLedger:
		var day = NarrativeDirector.current_hacker_day if NarrativeDirector else 0
		BountyLedger.add_bounty(contract.target_hostname, contract.bounty_reward, day)
		
	# 5. Mark Completed & Emit
	contract.is_completed = true
	EventBus.contract_completed.emit(contract.ticket_id)
	
	if contract.ticket_id == "final_intel":
		print("🏆 CONTRACT: Final objective reached. Campaign complete.")
		if EventBus.has_signal("hacker_campaign_complete"):
			EventBus.hacker_campaign_complete.emit()
		elif EventBus.has_signal("campaign_ended"):
			EventBus.campaign_ended.emit("victory")
	
	# 6. Trigger Narrative
	if not contract.completion_dialogue_id.is_empty() and NarrativeDirector:
		NarrativeDirector.start_broker_dialogue(contract.completion_dialogue_id)
		
	# 7. Forensic Record
	if HackerHistory:
		HackerHistory.add_entry({
			"action_type": "contract_submitted",
			"target": contract.ticket_id,
			"timestamp": ShiftClock.elapsed_seconds if "ShiftClock" in self else 0.0,
			"result": "SUCCESS",
			"note": "Contract '%s' verified and payout processed." % contract.title
		})
		
	print("💼 CONTRACT SUBMITTED: %s" % contract.title)
	
	# Auto-save
	if SaveSystem:
		SaveSystem.save_game()
		
	return true

func load_contracts():
	"""Load all ContractResource files from CONTRACT_DIR using FileUtil."""
	available_contracts.clear()

	var loaded = FileUtil.load_and_validate_resources(CONTRACT_DIR, "ContractResource")
	for res in loaded:
		if res is ContractResource:
			available_contracts.append(res)
			print("  ✓ Contract loaded: %s" % res.title)

	print("💼 CONTRACTS: %d available" % available_contracts.size())

func load_shift_contracts(shift: HackerShiftResource):
	"""Load and filter contracts for a specific hacker shift day."""
	active_contract = null
	current_shift_contracts.clear()

	# Reset state of all known contracts
	for contract in available_contracts:
		contract.clear_state()

	print("💼 CONTRACTS: Filtering %d contracts for Day %d" % [shift.contract_ids.size(), shift.day_number])

	for contract_id in shift.contract_ids:
		var found = false
		for contract in available_contracts:
			if contract.ticket_id == contract_id:
				current_shift_contracts.append(contract)
				print("  ✓ Added to Shift: %s" % contract.title)
				found = true
				break
		if not found:
			print("  ⚠ Contract resource not found in library: %s" % contract_id)
	
	print("💼 CONTRACTS: Shift library ready with %d items." % current_shift_contracts.size())

func accept_contract(contract: ContractResource) -> bool:
	"""Accept a contract from the available list."""
	if not contract or not contract.validate():
		push_warning("ContractManager: Invalid contract")
		return false

	if contract.is_accepted:
		push_warning("ContractManager: Contract already accepted")
		return false

	# Reset any existing contract
	if active_contract:
		print("⚠ ContractManager: Replacing active contract: %s" % active_contract.title)

	active_contract = contract
	active_contract.is_accepted = true

	print("💼 CONTRACT ACCEPTED: %s (Bounty: $%d)" % [contract.title, contract.bounty_reward])

	if EventBus:
		EventBus.contract_accepted.emit(contract.ticket_id)

	return true

func complete_contract():
	"""Mark active contract as complete and award bounty."""
	if not active_contract or not active_contract.is_accepted:
		return

	active_contract.is_completed = true

	# Award bounty
	if BountyLedger:
		BountyLedger.add_bounty(
			active_contract.ticket_id,
			active_contract.bounty_reward,
			0  # TODO: pass actual shift_day
		)

	print("💼 CONTRACT COMPLETE: %s → Bounty: $%d" % [active_contract.title, active_contract.bounty_reward])

	if NotificationManager:
		NotificationManager.show_notification(
			"Contract Complete! Bounty: $%d" % active_contract.bounty_reward,
			"success",
			5.0
		)

	if EventBus:
		EventBus.contract_completed.emit(active_contract.ticket_id)

	# PHASE 5: Auto-save on contract completion (hacker campaign persistence)
	if SaveSystem:
		SaveSystem.save_game()

func get_active_contract() -> ContractResource:
	return active_contract

func get_available_contracts() -> Array[ContractResource]:
	return current_shift_contracts.duplicate()

func get_completed_ids() -> Array[String]:
	"""Returns array of completed contract IDs (for save system)."""
	var ids: Array[String] = []
	for contract in available_contracts:
		if contract.is_completed:
			ids.append(contract.ticket_id)
	return ids

func reset_contracts():
	"""Clear all contracts (new shift/campaign)."""
	for contract in available_contracts:
		contract.clear_state()

	active_contract = null
	print("💼 CONTRACTS: Reset")
