# NPC_CISO.gd
# CISO (Chief Information Security Officer) NPC
extends "res://scripts/3d/NPC.gd"

func _ready():
	super._ready()
	
	# Programmatically load dialogue resources to ensure they are available
	# without requiring manual linking in the editor. This fixes the bug
	# where dialogues would not start after the refactor.
	dialogue_resources = {
		"briefing_01": load("res://resources/dialogue/ciso_briefing_01.tres"),
		"default": load("res://resources/dialogue/ciso_default.tres"),
		"shift_end": load("res://resources/dialogue/ciso_shift_end.tres"),
		"briefing_second_shift": load("res://resources/dialogue/ciso_briefing_second_shift.tres"),
		"briefing_third_shift": load("res://resources/dialogue/ciso_briefing_third_shift.tres")
	}