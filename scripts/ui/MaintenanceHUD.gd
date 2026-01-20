# MaintenanceHUD.gd
extends Control

@onready var task_container: VBoxContainer = %TaskContainer

var active_tasks: Dictionary = {} # task_id: {"desc": String, "done": bool, "node": Label}

func _ready():
	hide()
	EventBus.shift_started.connect(_on_shift_started)
	EventBus.shift_ended.connect(func(_r): hide())
	EventBus.consequence_triggered.connect(_on_event)
	
	# Check if shift is already active (e.g. after floor transition)
	if NarrativeDirector and NarrativeDirector.is_shift_active():
		_on_shift_started(NarrativeDirector.current_shift_name)

func _on_shift_started(shift_id: String):
	if shift_id == "shift_saturday":
		show()
		_setup_audit_tasks()
	elif shift_id == "shift_sunday":
		show()
		_setup_recovery_tasks()
	else:
		hide()

func _setup_audit_tasks():
	_clear_tasks()
	_add_task("audit_1", "Audit Router A")
	_add_task("audit_2", "Audit Router B")
	_add_task("audit_3", "Audit Router C")
	_add_task("audit_4", "Audit Router D")
	_add_task("audit_5", "Audit Router E")
	_add_task("audit_6", "Audit Router F")

func _setup_recovery_tasks():
	_clear_tasks()
	_add_task("rep_1", "Repair Rack 1 (NVMe)")
	_add_task("rep_2", "Repair Rack 2 (NVMe)")
	_add_task("rep_3", "Repair Rack 4 (SATA)")
	_add_task("rep_4", "Repair Rack 5 (SATA)")

func _clear_tasks():
	active_tasks.clear()
	for child in task_container.get_children():
		child.queue_free()

func _add_task(id: String, desc: String):
	var normalized_id = id.strip_edges().to_lower()
	var lbl = Label.new()
	lbl.text = "[ ] " + desc
	lbl.add_theme_font_size_override("font_size", 14)
	task_container.add_child(lbl)
	active_tasks[normalized_id] = {"desc": desc, "done": false, "node": lbl}
	print("MaintenanceHUD: Registered task: ", normalized_id)

func _on_event(type: String, details: Dictionary):
	print("MaintenanceHUD: Received Event - ", type, " | Details: ", details)
	
	if type == "audit_complete":
		var id = details.get("id", "").strip_edges().to_lower()
		_complete_task(id)
			
	elif type == "hardware_repaired":
		# Map physical Rack ID to the checklist IDs
		var rack = details.get("rack", "").strip_edges().to_upper()
		print("MaintenanceHUD: Processing repair for: ", rack)
		if rack == "RACK_1": _complete_task("rep_1")
		elif rack == "RACK_2": _complete_task("rep_2")
		elif rack == "RACK_4": _complete_task("rep_3")
		elif rack == "RACK_5": _complete_task("rep_4")

func _complete_task(id: String):
	var normalized_id = id.strip_edges().to_lower()
	if not active_tasks.has(normalized_id): 
		print("MaintenanceHUD: ID mismatch - ", normalized_id, " not in ", active_tasks.keys())
		return
		
	var task = active_tasks[normalized_id]
	if task.done: return
	
	task.done = true
	task.node.text = "[✔] " + task.desc
	task.node.add_theme_color_override("font_color", Color.GREEN)
	print("MaintenanceHUD: Task UI updated: ", normalized_id)
	
	if _all_tasks_done():
		print("MaintenanceHUD: All objectives met. Applying payoff.")
		_apply_weekend_payoff()

func _apply_weekend_payoff():
	var shift = NarrativeDirector.current_shift_name
	
	if shift == "shift_saturday":
		IntegrityManager.stop_decay()
		NotificationManager.show_notification("AUDIT COMPLETE: DECAY PAUSED", "success")
	elif shift == "shift_sunday":
		IntegrityManager.restore_integrity(15.0)
		NotificationManager.show_notification("RECOVERY COMPLETE: +15% INTEGRITY", "success")
	else:
		return
	
	# Win Logic: End shift immediately (Weekend Only)
	EventBus.shift_end_requested.emit()

func _all_tasks_done() -> bool:
	if active_tasks.is_empty(): return false
	for id in active_tasks:
		if not active_tasks[id].done: return false
	return true
