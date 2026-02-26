# TutorialHUD.gd
extends Control

@onready var task_container: Control = $TaskContainer
@onready var task_label: Label = %TaskLabel
@onready var step_counter: Label = %StepCounter
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var subtitle_label: RichTextLabel = %SubtitleLabel
@onready var subtitle_container: MarginContainer = %SubtitleContainer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
	hide()
	modulate.a = 0
	subtitle_container.modulate.a = 0
	
	if TutorialManager:
		TutorialManager.step_changed.connect(_on_step_changed)
	
	EventBus.game_mode_changed.connect(_on_game_mode_changed_internal)
	_update_layout()

func show_hud():
	show()
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.0, 0.5)
	
	# Slide in TaskContainer using Tween to avoid AnimationPlayer conflicts
	task_container.position.x = -300
	tween.tween_property(task_container, "position:x", 20.0, 0.5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	
	_update_layout()

func _on_game_mode_changed_internal(_mode: int):
	if TutorialManager and TutorialManager.is_tutorial_active:
		if modulate.a < 0.1:
			show_hud()
			return # show_hud calls _update_layout
	_update_layout()

func _update_layout():
	if not task_container: return
	
	# Ensure visibility is correct based on game mode
	if GameState and GameState.is_in_2d_mode():
		# Hide the objective block because the Computer Sidebar handles it
		task_container.hide()
	else:
		# Show the objective block when roaming the 3D office
		task_container.show()

func hide_hud():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	await tween.finished
	hide()

func update_subtitle(text: String):
	if text.is_empty():
		subtitle_container.hide()
		return
		
	subtitle_container.show()
	subtitle_label.text = "[center]" + text + "[/center]"
	
	# Reset and fade in subtitle
	subtitle_container.modulate.a = 0
	var tween = create_tween()
	tween.tween_property(subtitle_container, "modulate:a", 1.0, 0.3)

func _on_step_changed(step_id: int):
	if not TutorialManager or not TutorialManager.is_tutorial_active:
		hide_hud()
		return
		
	if not visible or modulate.a < 0.1:
		show_hud()
	
	_update_layout()
	
	# Update Task Text
	var step_data = TutorialManager.sequence.get_step(step_id - 1)
	if step_data:
		var full_text = step_data.instruction_text
		var task_name = full_text
		if ": " in full_text:
			task_name = full_text.split(": ")[-1]
			
		task_label.text = task_name.to_upper()
		
		# Update Subtitle (Long narrative text)
		update_subtitle(step_data.comms_text)
	
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
	if animation_player.has_animation("pulse"):
		animation_player.play("pulse")
