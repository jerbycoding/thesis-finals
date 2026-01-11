# NPC_SeniorAnalyst.gd
# Senior Analyst NPC - Jaded but helpful
extends "res://scripts/3d/NPC.gd"

func _ready():
	super._ready()
	
	dialogue_resources = {
		"checkin_01": load("res://resources/dialogue/senior_analyst_checkin_01.tres"),
		"default": load("res://resources/dialogue/senior_analyst_default.tres")
	}
