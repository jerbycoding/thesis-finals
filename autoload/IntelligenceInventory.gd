# IntelligenceInventory.gd
# Autoload singleton that tracks stolen artifacts from hacker exfiltration.
# Phase 4: Shared Payload Infrastructure
extends Node

signal item_added(resource: IntelligenceResource)
signal item_consumed(item_id: String)

# === INVENTORY ===
# Dictionary: item_id -> IntelligenceResource data
var inventory: Dictionary = {}

# === SAVE PATH ===
const SAVE_PATH = "user://saves/intelligence.json"

func _ready():
	print("========================================")
	print("IntelligenceInventory initialized")
	print("  Save Path: %s" % SAVE_PATH)
	print("========================================")

	_ensure_save_directory()
	_load_from_disk()

func _ensure_save_directory():
	var dir = DirAccess.open("user://")
	if dir and not dir.dir_exists("saves"):
		dir.make_dir("saves")

func _load_from_disk():
	if not FileAccess.file_exists(SAVE_PATH):
		print("📦 INTEL: No existing inventory (new campaign)")
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return

	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		return

	var data = json.data
	if data is Dictionary:
		inventory = data
		print("📦 INTEL: Loaded %d items from disk" % inventory.size())

func _write_to_disk():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		return

	file.store_string(JSON.stringify(inventory, "  ", false))
	file.close()

# === PUBLIC API ===

func add_item(resource: IntelligenceResource):
	"""
	Add a stolen artifact to the inventory.
	Generates a unique ID and writes to disk immediately.
	"""
	var item_id = "INTEL_%s_%d" % [resource.source_hostname, Time.get_ticks_msec()]
	
	var item_data = {
		"item_id": item_id,
		"source_hostname": resource.source_hostname,
		"data_type": resource.data_type,
		"data_label": resource.data_label,
		"shift_day": resource.shift_day,
		"is_partial": resource.is_partial,
		"trace_cost_total": resource.trace_cost_total,
		"timestamp": ShiftClock.elapsed_seconds if "ShiftClock" in self else 0.0
	}
	
	inventory[item_id] = item_data
	_write_to_disk()
	
	print("📦 INTEL: Stolen artifact added: %s (%s)" % [resource.data_label, item_id])
	item_added.emit(resource)

func consume_item(item_id: String) -> bool:
	"""
	Remove an item from inventory (used for contract submission).
	"""
	if inventory.has(item_id):
		inventory.erase(item_id)
		_write_to_disk()
		print("📦 INTEL: Item consumed: %s" % item_id)
		item_consumed.emit(item_id)
		return true
	return false

func has_data_type(data_type: String) -> bool:
	"""Check if any item in inventory matches the required type."""
	for item_id in inventory:
		if inventory[item_id].get("data_type") == data_type:
			return true
	return false

func get_items_for_day(day: int) -> Array:
	"""Returns all items exfiltrated on a specific day for Mirror Mode."""
	var items = []
	for item_id in inventory:
		if inventory[item_id].get("shift_day") == day:
			items.append(inventory[item_id])
	return items

func get_all_items() -> Array:
	"""Returns all items in inventory."""
	return inventory.values()

func reset_inventory():
	"""Clear all inventory data (new campaign)."""
	inventory.clear()
	_write_to_disk()
	print("📦 INTEL: Inventory reset")
