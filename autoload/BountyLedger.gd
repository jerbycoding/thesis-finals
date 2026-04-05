# BountyLedger.gd
# Autoload singleton that tracks bounty points from hacker contracts
# Phase 4: High-Impact Payloads
extends Node

signal bounty_added(hostname: String, amount: int, new_total: int)

# === BOUNTY TRACKING ===
var total_bounty: int = 0
var shift_bounties: Dictionary = {}  # shift_day -> { hostname -> amount }

# === SAVE PATH ===
const SAVE_PATH = "user://saves/bounty.json"

func _ready():
	print("========================================")
	print("BountyLedger initialized")
	print("  Save Path: %s" % SAVE_PATH)
	print("  Debug: Ctrl+F4 (add 100), Ctrl+F5 (reset)")
	print("========================================")

	_ensure_save_directory()
	_load_from_disk()

func _ensure_save_directory():
	var dir = DirAccess.open("user://")
	if dir and not dir.dir_exists("saves"):
		dir.make_dir("saves")

func _load_from_disk():
	if not FileAccess.file_exists(SAVE_PATH):
		print("💰 BOUNTY: No existing save (new campaign)")
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		push_warning("BountyLedger: Failed to open save file for reading!")
		return

	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		push_warning("BountyLedger: Failed to parse save file - starting fresh")
		return

	var data = json.data
	if data is Dictionary:
		total_bounty = data.get("total", 0)
		shift_bounties = data.get("shift_bounties", {})
		print("💰 BOUNTY: Loaded %d total from disk" % total_bounty)
	else:
		push_warning("BountyLedger: Save file has invalid format - starting fresh")

func _write_to_disk():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		push_warning("BountyLedger: Failed to open save file for writing!")
		return

	var data = {
		"total": total_bounty,
		"shift_bounties": shift_bounties
	}

	file.store_string(JSON.stringify(data, "  ", false))
	file.close()

# === PUBLIC API ===

func add_bounty(hostname: String, amount: int, shift_day: int = 0):
	"""
	Add bounty points from a successful contract action.
	Writes to disk immediately for crash safety.
	"""
	total_bounty += amount

	if not shift_bounties.has(shift_day):
		shift_bounties[shift_day] = {}

	var day_data = shift_bounties[shift_day]
	if day_data.has(hostname):
		day_data[hostname] += amount
	else:
		day_data[hostname] = amount

	_write_to_disk()

	print("💰 BOUNTY: +$%d from %s (Day %d) → Total: $%d" % [amount, hostname, shift_day, total_bounty])

	bounty_added.emit(hostname, amount, total_bounty)

func get_bounty() -> int:
	"""Returns total accumulated bounty."""
	return total_bounty

func get_bounty_for_day(shift_day: int) -> int:
	"""Returns bounty earned on a specific shift day."""
	if not shift_bounties.has(shift_day):
		return 0
	var day_data = shift_bounties[shift_day]
	var day_total = 0
	for hostname in day_data:
		day_total += day_data[hostname]
	return day_total

func get_bounty_breakdown() -> Dictionary:
	"""Returns { shift_day: { hostname: amount } } for Mirror Mode."""
	return shift_bounties.duplicate(true)

func reset_ledger():
	"""Clear all bounty data (new campaign)."""
	total_bounty = 0
	shift_bounties.clear()
	_write_to_disk()
	print("💰 BOUNTY: Ledger reset")

# === DEBUG COMMANDS (Hacker Campaign Only) ===

func _input(event):
	if GameState and GameState.current_role == GameState.Role.ANALYST:
		return

	if not event is InputEventKey or not event.pressed:
		return

	# Ctrl+F4: Add 100 bounty (debug)
	if event.keycode == KEY_F4 and event.ctrl_pressed:
		add_bounty("DEBUG_HOST", 100, 0)
		print("DEBUG: Ctrl+F4 - Added $100 bounty")

	# Ctrl+F5: Reset ledger
	if event.keycode == KEY_F5 and event.ctrl_pressed:
		reset_ledger()
		print("DEBUG: Ctrl+F5 - Bounty ledger reset")
