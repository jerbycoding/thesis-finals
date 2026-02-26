# RunbookSidebar.gd
extends PanelContainer

@onready var task_label = %TaskLabel
@onready var context_label = %ContextLabel
@onready var progress_bar = %ProgressBar
@onready var system_status_label = %SystemStatusLabel
@onready var step_counter = %StepCounter
@onready var animation_player = $AnimationPlayer
@onready var action_zone = %ActionZone

var current_step_id: int = -1

func _ready():
	# Start in standby
	task_label.text = "AWAITING_DIRECTIVE"
	context_label.text = "Establish secure link to mission control..."
	_set_status("STANDBY", Color.GRAY)

func update_task(step_id: int, instruction: String, mentor: String = "RIVERA", tip: String = ""):
	current_step_id = step_id
	
	# 1. Update Content
	task_label.text = instruction.to_upper()
	context_label.text = tip
	
	# Update Counter
	var total_steps = 36
	if TutorialManager and TutorialManager.sequence:
		total_steps = TutorialManager.sequence.steps.size()
	step_counter.text = "PHASE %02d/%02d" % [step_id, total_steps]
	
	# 2. Glitchy Arrival Animation
	_set_status("RECEIVING...", Color.ORANGE)
	animation_player.play("receiving")
	
	if AudioManager:
		AudioManager.play_terminal_beep()
	
	await animation_player.animation_finished
	_set_status("DIRECTIVE_ACTIVE", Color.CYAN)

func complete_task(step_id: int):
	if step_id == current_step_id:
		_set_status("VERIFIED", Color.GREEN)
		animation_player.play("task_complete")
		if AudioManager: 
			AudioManager.play_notification("success")

func set_warning_mode(active: bool):
	var color = Color.ORANGE if active else Color(0, 1, 0, 1)
	_set_status("REMEDIATION_REQUIRED" if active else "DIRECTIVE_ACTIVE", color)
	
	if active:
		if AudioManager: AudioManager.play_alert()
		# Visual Glitch
		var tween = create_tween()
		tween.tween_property(action_zone, "modulate", Color.ORANGE, 0.1)
		tween.tween_property(action_zone, "modulate", Color.WHITE, 0.1)

func _set_status(text: String, color: Color):
	system_status_label.text = text
	system_status_label.modulate = color
