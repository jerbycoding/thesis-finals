# NPC_ITSupport.gd
# IT Support NPC - Technical and overworked
extends BaseNPC

func start_dialogue(dialogue_id: String = "default"):
	if dialogue_id == "default":
		# Always offer favor dialogue for manual interaction
		super.start_dialogue("favor")
		return
		
	super.start_dialogue(dialogue_id)

func _ready():
	super._ready()
