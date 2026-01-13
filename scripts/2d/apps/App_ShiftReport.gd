# app_shift_report.gd
extends Control

# Using % to get unique nodes is more robust than full paths
@onready var archetype_label: Label = %ArchetypeLabel
@onready var archetype_description: Label = %ArchetypeDescription
@onready var archetype_feedback: Label = %ArchetypeFeedback
@onready var tickets_completed_value: Label = %TicketsCompletedValue
@onready var tickets_ignored_value: Label = %TicketsIgnoredValue
@onready var avg_time_value: Label = %AvgTimeValue
@onready var risks_taken_value: Label = %RisksTakenValue
@onready var consequences_value: Label = %ConsequencesValue
@onready var continue_button: Button = %ContinueButton

func _ready():
	hide() # Hidden by default
	continue_button.pressed.connect(_on_continue_pressed)

func show_report(results: Dictionary):
	print("ShiftReport: Showing report with results: ", results)
	
	# Ensure mouse is visible for UI interaction
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	var archetype_name = results.get("archetype", "Unknown")
	var archetype_data = ArchetypeAnalyzer.ARCHETYPE_DEFINITIONS.get(archetype_name, {})
	
	archetype_label.text = "Archetype: " + archetype_name
	archetype_description.text = archetype_data.get("description", "No analysis available.")
	archetype_feedback.text = archetype_data.get("feedback", "No specific feedback available.")
	
	tickets_completed_value.text = str(results.get("tickets_completed", 0))
	tickets_ignored_value.text = str(results.get("tickets_ignored", 0))
	avg_time_value.text = "%.1fs" % results.get("avg_completion_time", 0.0)
	risks_taken_value.text = str(results.get("risks_taken", 0))
	consequences_value.text = str(results.get("consequences_triggered", 0))
	
	# Auto-save progress at the end of the shift
	if SaveSystem:
		SaveSystem.save_game()
	
	show()
	# Bring to front to ensure it's on top of other UI
	move_to_front()

func _on_continue_pressed():
	print("ShiftReport: Continue pressed.")
	hide() # Hide the report itself
	
	if NarrativeDirector:
		match NarrativeDirector.current_shift_name:
			"first_shift":
				print("ShiftReport: Transitioning from first to second shift.")
				NarrativeDirector.start_second_shift_briefing()
			"second_shift":
				print("ShiftReport: Transitioning from second to third shift.")
				NarrativeDirector.start_third_shift_briefing()
			"third_shift":
				print("ShiftReport: Final shift completed. Returning to title.")
				TransitionManager.change_scene_to("res://scenes/ui/TitleScreen.tscn")
			_:
				print("ShiftReport: Unknown shift state. Returning to title.")
				TransitionManager.change_scene_to("res://scenes/ui/TitleScreen.tscn")
