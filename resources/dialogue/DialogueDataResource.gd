# DialogueDataResource.gd
# A custom resource to hold structured dialogue data.
class_name DialogueDataResource
extends Resource

# The name of the NPC speaking.
@export var npc_name: String = "NPC"

# The character/emoji to display as a portrait.
@export var portrait: String = "👤"

## If true, the dialogue will start at a random line from the array.
@export var is_randomized: bool = false

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

func validate() -> bool:
	if lines.is_empty():
		return false
	
	for i in range(lines.size()):
		var line = lines[i]
		if not line.has("text") or line["text"].is_empty():
			return false
			
		if line.has("choices"):
			for choice in line["choices"]:
				if choice.has("next_line"):
					var target = choice["next_line"]
					if target < 0 or target >= lines.size():
						return false
	return true
