# NPC_CISO.gd
# CISO (Chief Information Security Officer) NPC
extends "res://scripts/3d/NPC.gd"

func _ready():
	super._ready()
	
	# CISO dialogue data
	dialogue_data = {
		"briefing_01": {
			"npc_name": "CISO",
			"portrait": "👔",
			"lines": [
				{
					"text": "Welcome to the Security Operations Center. I'm the Chief Information Security Officer. We're currently monitoring an active phishing campaign targeting our organization.",
					"choices": []
				},
				{
					"text": "Your first shift will be critical. Follow protocol, but remember: time is a resource. Balance thoroughness with efficiency. The board is watching.",
					"choices": [
						{"text": "Understood. I'm ready to begin my shift.", "effect": {"change_scene": "res://scenes/SOC_Office.tscn", "start_narrative": true}}
					]
				}
			]
		},
		"default": {
			"npc_name": "CISO",
			"portrait": "👔",
			"lines": [
				{
					"text": "How is your shift progressing? Remember, we need results, not excuses.",
					"choices": []
				}
			]
		},
		"shift_end": {
			"npc_name": "CISO",
			"portrait": "👔",
			"lines": [
				{
					"text": "Shift complete. Submit your preliminary report. We'll review your performance and determine your analyst archetype.",
					"choices": []
				}
			]
		}
	}
