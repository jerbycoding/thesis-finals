# TutorialAnchor.gd
extends Node

## The logical ID used by the Tutorial system to find this UI element.
@export var anchor_id: String = ""

func _ready():
	if anchor_id.is_empty():
		push_warning("TutorialAnchor on %s has no ID assigned." % get_parent().name)
	add_to_group("tutorial_anchors")

## Returns the parent Control node that this anchor is attached to.
func get_target() -> Control:
	var parent = get_parent()
	if parent is Control:
		return parent
	return null
