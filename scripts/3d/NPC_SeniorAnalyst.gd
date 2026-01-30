# NPC_SeniorAnalyst.gd
# Senior Analyst NPC - Jaded but helpful
extends BaseNPC

func start_dialogue(dialogue_id: String = "default"):
	# Priority 0: Weekend Guidance (Sunday)
	if NarrativeDirector and NarrativeDirector.current_shift_resource:
		if NarrativeDirector.current_shift_resource.minigame_type == "RECOVERY":
			var hint = NarrativeDirector.get_weekend_hint()
			var res = get_dialogue("sunday_guide")
			if res and DialogueManager:
				DialogueManager.start_dialogue(self, res, hint)
				return

	if dialogue_id == "default":
		# Priority 1: If there's an active ticket, offer technical favor
		if TicketManager and TicketManager.has_active_tickets():
			super.start_dialogue("favor")
			return
			
		# Priority 2: Archetype-specific feedback
		if ArchetypeAnalyzer:
			var results = ArchetypeAnalyzer.get_analysis_results()
			var archetype = results.get("archetype", "Pragmatic").to_lower().replace("-", "_")
			
			# Check if a specific feedback dialogue exists for this archetype
			# res://resources/dialogue/senior_analyst_feedback_[archetype].tres
			var feedback_id = "feedback_" + archetype
			if get_dialogue(feedback_id):
				super.start_dialogue(feedback_id)
				return

	super.start_dialogue(dialogue_id)

func _ready():
	super._ready()
