# NPC_ITSupport.gd
# IT Support NPC - Technical and overworked
extends "res://scripts/3d/NPC.gd"

func _ready():
	super._ready()
	
	dialogue_resources = {
		"default": load("res://resources/dialogue/it_support_default.tres")
	}