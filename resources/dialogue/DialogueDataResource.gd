# DialogueDataResource.gd
# A custom resource to hold structured dialogue data.
class_name DialogueDataResource
extends Resource

# The name of the NPC speaking.
@export var npc_name: String = "NPC"

# The character/emoji to display as a portrait.
@export var portrait: String = "👤"

# An array of dialogue lines. Each line is a dictionary that must contain a "text" key.
# It can also optionally contain a "choices" key, which is an array of choice dictionaries.
#
# Example line:
# {
#   "text": "Hello, player.",
#   "choices": [
#     {"text": "Hello, NPC.", "effect": {}},
#     {"text": "Goodbye.", "next_line": 2}
#   ]
# }
@export var lines: Array[Dictionary] = []
