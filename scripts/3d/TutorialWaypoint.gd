# TutorialWaypoint.gd
# A 3D visual aid that only appears during specific tutorial steps.
extends Node3D

@export var visible_on_step: int = 1 # TutorialStep.ROAM_TO_OFFICE

func _ready():
	hide()
	if TutorialManager:
		TutorialManager.step_changed.connect(_on_step_changed)
		_on_step_changed(TutorialManager.current_step)

func _on_step_changed(step_id: int):
	if step_id == visible_on_step and TutorialManager.is_tutorial_active:
		show()
		_animate()
	else:
		hide()

func _animate():
	var tween = create_tween().set_loops()
	# Bounce/Pulse effect
	tween.tween_property(self, "position:y", position.y + 0.5, 1.0).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position:y", position.y, 1.0).set_trans(Tween.TRANS_SINE)
