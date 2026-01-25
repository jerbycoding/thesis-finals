# NPC_CISO.gd
# CISO (Chief Information Security Officer) NPC
extends BaseNPC

func start_dialogue(dialogue_id: String = "default"):

	# If the shift is active and it's a manual interaction, check if we can clock out

	if NarrativeDirector and NarrativeDirector.is_shift_active() and dialogue_id == "default":

		if _can_player_clock_out():

			super.start_dialogue("clockout_ready")

		else:

			super.start_dialogue("clockout_rejected")

		return

		

	super.start_dialogue(dialogue_id)



func _can_player_clock_out() -> bool:

	# Only allowed to clock out if queue is clear or it's near end of shift

	if TicketManager and TicketManager.has_active_tickets():

		return false

	

	if NarrativeDirector:

		var elapsed = NarrativeDirector.get_shift_timer()

		var duration = NarrativeDirector.get_current_shift_duration()

		# Allow early exit if 80% through the shift events

		return elapsed > (duration * 0.8)

		

	return true



func _ready():
	super._ready()
	# Dialogues are now loaded dynamically via naming convention in base NPC script.
