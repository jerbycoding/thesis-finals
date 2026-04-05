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

func _on_offensive_action(data: Dictionary):
	"""Check if a ransomware action completes the active contract."""
	if not active_contract or not active_contract.is_accepted or active_contract.is_completed:
		return

	if data.get("action_type") != "ransomware" or data.get("result") != "SUCCESS":
		return

	# Ransomware succeeded — check if target host matches contract
	var target = data.get("target", "")
	if active_contract.required_payload == "RANSOMWARE":
		# Contract requires ANY host to be ransomed (not specific target)
		# OR if contract has a specific target, check match
		complete_contract()

func _on_host_status_changed(hostname: String, new_status: int):
	"""Check if host becoming RANSOMED completes the active contract."""
	if not active_contract or not active_contract.is_accepted or active_contract.is_completed:
		return

	if new_status == GlobalConstants.HOST_STATUS.RANSOMED:
		complete_contract()

# === PUBLIC API ===

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
	"""Load contracts for a specific hacker shift day."""
	active_contract = null

	# Reset all contracts
	for contract in available_contracts:
		contract.clear_state()

	# Filter by shift's contract IDs
	print("💼 CONTRACTS: Loading %d contracts for Day %d" % [shift.contract_ids.size(), shift.day_number])

	# No need to reload — contracts are already loaded in _ready()
	# Just log what's available for this shift
	for contract_id in shift.contract_ids:
		var found = false
		for contract in available_contracts:
			if contract.contract_id == contract_id:
				print("  ✓ Available: %s" % contract.title)
				found = true
				break
		if not found:
			print("  ⚠ Contract not found: %s" % contract_id)

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
		EventBus.contract_accepted.emit(contract.contract_id)

	return true

func complete_contract():
	"""Mark active contract as complete and award bounty."""
	if not active_contract or not active_contract.is_accepted:
		return

	active_contract.is_completed = true

	# Award bounty
	if BountyLedger:
		BountyLedger.add_bounty(
			active_contract.contract_id,
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
		EventBus.contract_completed.emit(active_contract.contract_id)

func get_active_contract() -> ContractResource:
	return active_contract

func get_available_contracts() -> Array[ContractResource]:
	return available_contracts.duplicate()

func reset_contracts():
	"""Clear all contracts (new shift/campaign)."""
	for contract in available_contracts:
		contract.clear_state()

	active_contract = null
	print("💼 CONTRACTS: Reset")
