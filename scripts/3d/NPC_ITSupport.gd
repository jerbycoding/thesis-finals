# NPC_ITSupport.gd
# IT Support NPC - Technical and overworked
extends "res://scripts/3d/NPC.gd"

func _ready():
	super._ready()
	
	# IT Support dialogue data
	dialogue_data = {
		"default": {
			"npc_name": "IT Support",
			"portrait": "🔧",
			"lines": [
				{
					"text": "Yeah? What do you need? I'm swamped with tickets. If you broke something, it'll take time to fix.",
					"choices": [
						{"text": "Just checking in.", "effect": {"relationship_change": 0.0}},
						{"text": "Can you restore a disabled tool?", "effect": {"relationship_change": -0.1}},
						{"text": "Thanks for your work.", "effect": {"relationship_change": 0.1}}
					]
				}
			]
		}
	}