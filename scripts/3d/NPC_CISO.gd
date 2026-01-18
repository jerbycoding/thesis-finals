# NPC_CISO.gd
# CISO (Chief Information Security Officer) NPC
extends "res://scripts/3d/NPC.gd"

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

	

	dialogue_resources = {

		"briefing_01": load("res://resources/dialogue/ciso_briefing_01.tres"),

		"default": load("res://resources/dialogue/ciso_default.tres"),

		"shift_end": load("res://resources/dialogue/ciso_shift_end.tres"),

		"briefing_second_shift": load("res://resources/dialogue/ciso_briefing_second_shift.tres"),

		"briefing_third_shift": load("res://resources/dialogue/ciso_briefing_third_shift.tres"),

		"clockout_ready": load("res://resources/dialogue/ciso_clockout_ready.tres"),

		"clockout_rejected": load("res://resources/dialogue/ciso_clockout_rejected.tres")

	}
