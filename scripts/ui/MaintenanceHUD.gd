# MaintenanceHUD.gd
extends Control

@onready var task_container: VBoxContainer = %TaskContainer

var active_tasks: Dictionary = {} 
@export var recovery_config: HardwareRecoveryConfig
@export var audit_config: CalibrationMinigameConfig

func _ready():
	hide()
	EventBus.shift_started.connect(_on_shift_started)
	EventBus.shift_ended.connect(func(_r): hide())
	EventBus.consequence_triggered.connect(_on_event)
	
	if NarrativeDirector and NarrativeDirector.is_shift_active():
		_on_shift_started(NarrativeDirector.current_shift_name)

func _on_shift_started(_shift_id: String):
	if not NarrativeDirector or not NarrativeDirector.current_shift_resource: return
	var type = NarrativeDirector.current_shift_resource.minigame_type
	
	if type == "AUDIT":
		show()
		_setup_audit_tasks()
	elif type == "RECOVERY":
		show()
		_setup_recovery_tasks()
	else:
		hide()

func _setup_audit_tasks():
	_clear_tasks()
	if not audit_config:
		push_error("MaintenanceHUD: No CalibrationMinigameConfig assigned for audit tasks!")
		return
		
	for task_data in audit_config.tasks:
		_add_task(task_data.id, task_data.description)

func _setup_recovery_tasks():
	_clear_tasks()
	if not recovery_config:
		push_error("MaintenanceHUD: No HardwareRecoveryConfig assigned for recovery tasks!")
		return
	
	for task_data in recovery_config.tasks:
		_add_task(task_data.id, task_data.description)

func _clear_tasks():
	active_tasks.clear()
	for child in task_container.get_children():
		child.queue_free()

func _add_task(id: String, desc: String):
	var normalized_id = id.strip_edges().to_lower()
	var lbl = Label.new()
	lbl.text = "[ ] " + desc
	lbl.add_theme_font_size_override("font_size", 11)
	lbl.add_theme_color_override("font_color", Color.BLACK)
	task_container.add_child(lbl)
	active_tasks[normalized_id] = {"desc": desc, "done": false, "node": lbl}

func _on_event(type: String, details: Dictionary):
	if type == "audit_complete":
		var id = details.get("id", "").strip_edges().to_lower()
		_complete_task(id)
	elif type == "hardware_slotted":
		# This is emitted immediately by HardwareSocket.gd when a part is physically placed
		var socket_id = details.get("socket_id", "").strip_edges().to_upper()
		var hardware_type = details.get("type", "").strip_edges().to_lower()
		
		if not recovery_config: return
		
		for task_data in recovery_config.tasks:
			if task_data.has("completes_on_socket_id") and task_data.has("completes_on_hardware_type"):
				if task_data.completes_on_socket_id == socket_id and task_data.completes_on_hardware_type == hardware_type:
					_complete_task(task_data.id)
	elif type == "RAID_REBUILD":
		# Final signal from the minigame
		_apply_weekend_payoff()

func _complete_task(id: String):
	var normalized_id = id.strip_edges().to_lower()
	if not active_tasks.has(normalized_id): return
		
	var task = active_tasks[normalized_id]
	if task.done: return
	
	task.done = true
	task.node.text = "[✔] " + task.desc
	task.node.add_theme_color_override("font_color", GlobalConstants.UI_COLORS.SUCCESS_FLAT)
	
	# Only auto-end for AUDIT mode. RECOVERY requires the master sync.
	if _all_tasks_done():
		var type = NarrativeDirector.current_shift_resource.minigame_type
		if type == "AUDIT":
			_apply_weekend_payoff()
		else:
			if NotificationManager:
				NotificationManager.show_notification("ALL BLADES INSTALLED: Finalize RAID Sync via Tablet", "info")

func _apply_weekend_payoff():
	if not NarrativeDirector or not NarrativeDirector.current_shift_resource: return
	var type = NarrativeDirector.current_shift_resource.minigame_type
	
	if type == "AUDIT":
		IntegrityManager.stop_decay()
		NotificationManager.show_notification("AUDIT COMPLETE: INTEGRITY DECAY SUSPENDED", "success")
	elif type == "RECOVERY":
		IntegrityManager.restore_integrity(15.0)
		NotificationManager.show_notification("RECOVERY COMPLETE: OPERATIONAL INTEGRITY RESTORED", "success")
	else: return
	
	EventBus.shift_end_requested.emit()

func _all_tasks_done() -> bool:
	if active_tasks.is_empty(): return false
	for id in active_tasks:
		if not active_tasks[id].done: return false
	return true
