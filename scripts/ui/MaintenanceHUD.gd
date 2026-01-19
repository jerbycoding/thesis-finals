# MaintenanceHUD.gd
extends Control

@onready var task_container: VBoxContainer = %TaskContainer

var active_tasks: Dictionary = {} # task_id: {"desc": String, "done": bool, "node": Label}

func _ready():
	hide()
	EventBus.shift_started.connect(_on_shift_started)
	EventBus.shift_ended.connect(func(_r): hide())
	EventBus.consequence_triggered.connect(_on_event)

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
	_add_task("audit_1", "Audit Floor -2 Network Router status")
	_add_task("audit_2", "Verify all patch panel connections")

func _setup_recovery_tasks():
	_clear_tasks()
	_add_task("rep_1", "Replace defective HDD in Rack 1")
	_add_task("rep_2", "Replace defective HDD in Rack 4")

func _clear_tasks():
	active_tasks.clear()
	for child in task_container.get_children():
		child.queue_free()

func _add_task(id: String, desc: String):
	var lbl = Label.new()
	lbl.text = "[ ] " + desc
	lbl.add_theme_font_size_override("font_size", 14)
	task_container.add_child(lbl)
	active_tasks[id] = {"desc": desc, "done": false, "node": lbl}

func _on_event(type: String, details: Dictionary):
	if type == "hardware_repaired":
		# Logic to mark tasks as done based on interaction
		# For this prototype, we'll mark the first undone task as complete
		for id in active_tasks:
			if not active_tasks[id].done:
				_complete_task(id)
				break

func _complete_task(id: String):
	if not active_tasks.has(id): return
	
	var task = active_tasks[id]
	task.done = true
	task.node.text = "[✔] " + task.desc
	task.node.add_theme_color_override("font_color", Color.GREEN)
	
	# If all tasks done, restore integrity
	if _all_tasks_done():
		print("MaintenanceHUD: All tasks complete. Restoring Integrity.")
		if IntegrityManager:
			IntegrityManager.restore_integrity(15.0)
		if NotificationManager:
			NotificationManager.show_notification("MAINTENANCE CYCLE COMPLETE", "success", 5.0)

func _all_tasks_done() -> bool:
	for id in active_tasks:
		if not active_tasks[id].done:
			return false
	return true
