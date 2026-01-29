# TutorialSequenceResource.gd
extends Resource
class_name TutorialSequenceResource

@export var sequence_name: String = "Tier 1 Certification"
@export var steps: Array[TutorialStepResource] = []

func get_step(index: int) -> TutorialStepResource:
	if index >= 0 and index < steps.size():
		return steps[index]
	return null

func validate_all() -> bool:
	if steps.is_empty(): return false
	for step in steps:
		if not step.validate(): return false
	return true
