# RunbookSidebar.gd
extends PanelContainer

@onready var task_container = %TaskContainer
@onready var status_label = %StatusLabel
@onready var animation_player = $AnimationPlayer

var active_tasks: Dictionary = {}

func _ready():
	# Start empty
	clear_tasks()
	_set_status("READY", Color.GREEN)

func update_task(step_id: int, instruction: String):
	# Play "Receiving" animation
	_set_status("RECEIVING_DIRECTIVE...", Color.ORANGE)
	animation_player.play("receiving")
	
	# Clear previous and add new SOP directive
	clear_tasks()
	
	var label = Label.new()
	label.text = "[ ] " + instruction.to_upper()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 11)
	label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	task_container.add_child(label)
	
	active_tasks[step_id] = label
	
	await animation_player.animation_finished
	_set_status("LIVE_SOP_ACTIVE", Color.CYAN)

func complete_task(step_id: int):
	if active_tasks.has(step_id):
		var label = active_tasks[step_id]
		label.text = "[✔] " + label.text.substr(4)
		label.add_theme_color_override("font_color", GlobalConstants.UI_COLORS.SUCCESS_FLAT)
		
		_set_status("VERIFIED", Color.GREEN)
		animation_player.play("task_complete")
		if AudioManager: AudioManager.play_notification("success")

func set_warning_mode(active: bool):
	var color = Color.ORANGE if active else Color(0.2, 0.6, 1, 1)
	$VBox/Header/Label.add_theme_color_override("font_color", color)
	_set_status("AAR_DRILL_RECOVERY" if active else "LIVE_SOP_ACTIVE", color)
	
	if active:
		if AudioManager: AudioManager.play_alert()
		# Flash effect
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color.ORANGE, 0.1)
		tween.tween_property(self, "modulate", Color.WHITE, 0.2)

func clear_tasks():
	active_tasks.clear()
	for child in task_container.get_children():
		child.queue_free()

func _set_status(text: String, color: Color):
	status_label.text = text
	status_label.modulate = color
