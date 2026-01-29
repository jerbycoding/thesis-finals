# TutorialTrigger.gd
# Detects player entry into specific 3D zones to advance the tutorial.
extends Area3D

## Unique ID for this objective (e.g., 'office_c')
@export var objective_id: String = ""

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player3D":
		if TutorialManager and TutorialManager.is_tutorial_active:
			print("TutorialTrigger: Player reached objective - ", objective_id)
			TutorialManager.reach_3d_objective(objective_id)
			
			# Disable after use to prevent re-triggering
			queue_free()
