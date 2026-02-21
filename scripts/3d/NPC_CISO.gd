# NPC_CISO.gd
# CISO (Chief Information Security Officer) NPC
extends BaseNPC

func start_dialogue(dialogue_id: String = "default"):
	# Priority 1: Weekend Guidance (Saturday/Sunday) - ONLY trigger if shift is actually LIVE
	if NarrativeDirector and NarrativeDirector.is_shift_active() and NarrativeDirector.current_shift_resource:
		if NarrativeDirector.current_shift_resource.minigame_type != "NONE" and dialogue_id == "default":
			# Determine which guide to use
			var guide_id = "saturday_guide" if NarrativeDirector.current_shift_resource.minigame_type == "AUDIT" else "sunday_guide"
			var res = get_dialogue(guide_id)
			if res and DialogueManager:
				var hint = NarrativeDirector.get_weekend_hint()
				DialogueManager.start_dialogue(self, res, hint)
				return

	# If the shift is active and it's a manual interaction, check if we can clock out

	if NarrativeDirector and NarrativeDirector.is_shift_active() and dialogue_id == "default":
		if _can_player_clock_out():
			super.start_dialogue("clockout_ready")
		else:
			# Check for urgent performance feedback if not ready
			if ArchetypeAnalyzer:
				var results = ArchetypeAnalyzer.get_analysis_results()
				if results.get("archetype") == GlobalConstants.ARCHETYPE.NEGLIGENT:
					if get_dialogue("feedback_negligent"):
						super.start_dialogue("feedback_negligent")
						return
			
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
