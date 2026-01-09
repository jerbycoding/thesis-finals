# NPC_SeniorAnalyst.gd
# Senior Analyst NPC - Jaded but helpful
extends "res://scripts/3d/NPC.gd"

func _ready():
	super._ready()
	
	# Senior Analyst dialogue data
	dialogue_data = {
		"checkin_01": {
			"npc_name": "Senior Analyst",
			"portrait": "👨‍💻",
			"lines": [
				{
					"text": "Hey, how's your first ticket going? Don't rush it - I've seen too many analysts skip steps and create bigger problems.",
					"choices": [
						{"text": "I'm being thorough, checking everything.", "effect": {"relationship_change": 0.2, "npc": "senior_analyst"}},
						{"text": "Trying to move fast. Time is tight.", "effect": {"relationship_change": -0.1, "npc": "senior_analyst"}},
						{"text": "Any tips?", "effect": {"relationship_change": 0.1, "npc": "senior_analyst"}}
					]
				},
				{
					"text": "Remember: Email headers tell you everything. And always scan attachments. Always.",
					"choices": []
				}
			]
		},
		"default": {
			"npc_name": "Senior Analyst",
			"portrait": "👨‍💻",
			"lines": [
				{
					"text": "Need something? I'm busy, but I can help if it's quick.",
					"choices": []
				}
			]
		}
	}

