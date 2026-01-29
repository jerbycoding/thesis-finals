# TutorialHUD.gd
extends Control

@onready var task_label: Label = %TaskLabel
@onready var step_counter: Label = %StepCounter
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
	hide()
	modulate.a = 0
	if TutorialManager:
		TutorialManager.step_changed.connect(_on_step_changed)

func show_hud():
	show()
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5)
	animation_player.play("slide_in")

func hide_hud():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	await tween.finished
	hide()

func _on_step_changed(step_id: int):
	if not TutorialManager or not TutorialManager.is_tutorial_active:
		hide_hud()
		return
		
	if not visible:
		show_hud()
	
	# Update Text (step_id is 1-based, need 0-based for instruction)
	var full_text = TutorialManager._get_instruction_for_step(step_id - 1)
	var task_name = full_text.split(": ")[-1]
	task_label.text = task_name
	
	# Update Counter
	var total_steps = 7
	if TutorialManager.sequence:
		total_steps = TutorialManager.sequence.steps.size()
		
	step_counter.text = "PHASE %d / %d" % [step_id, total_steps]
	
	# Update Progress
	var progress = (float(step_id) / float(total_steps)) * 100.0
	var p_tween = create_tween()
	p_tween.tween_property(progress_bar, "value", progress, 0.4).set_trans(Tween.TRANS_QUAD)
	
	# Visual Pulse on change
	animation_player.play("pulse")
