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

var next_shift_id: String = ""

func _ready():
	hide() # Hidden by default
	continue_button.pressed.connect(_on_continue_pressed)

func set_next_shift(shift_id: String):
	next_shift_id = shift_id

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
	
	if not next_shift_id.is_empty():
		print("ShiftReport: Moving to next shift: ", next_shift_id)
		if NarrativeDirector:
			NarrativeDirector.trigger_briefing(next_shift_id)
	else:
		print("ShiftReport: Final shift completed or no next shift defined. Returning to title.")
		TransitionManager.change_scene_to("res://scenes/ui/TitleScreen.tscn")