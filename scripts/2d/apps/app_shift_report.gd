# app_shift_report.gd
extends Control

# Using % to get unique nodes is more robust than full paths
@onready var archetype_label: Label = %ArchetypeLabel
@onready var archetype_description: Label = %ArchetypeDescription
@onready var archetype_feedback: Label = %ArchetypeFeedback
@onready var tickets_completed_value: Label = %TicketsCompletedValue
@onready var avg_time_value: Label = %AvgTimeValue
@onready var risks_taken_value: Label = %RisksTakenValue
@onready var consequences_value: Label = %ConsequencesValue
@onready var continue_button: Button = %ContinueButton

func _ready():
	hide() # Hidden by default
	continue_button.pressed.connect(_on_continue_pressed)

func show_report(results: Dictionary):
	print("ShiftReport: Showing report with results: ", results)
	
	var archetype_name = results.get("archetype", "Unknown")
	var archetype_data = ArchetypeAnalyzer.ARCHETYPE_DEFINITIONS.get(archetype_name, {})
	
	archetype_label.text = "Archetype: " + archetype_name
	archetype_description.text = archetype_data.get("description", "No analysis available.")
	archetype_feedback.text = archetype_data.get("feedback", "No specific feedback available.")
	
	tickets_completed_value.text = str(results.get("tickets_completed", 0))
	avg_time_value.text = "%.1fs" % results.get("avg_completion_time", 0.0)
	risks_taken_value.text = str(results.get("risks_taken", 0))
	consequences_value.text = str(results.get("consequences_triggered", 0))
	
	show()
	# Bring to front to ensure it's on top of other UI
	move_to_front()

func _on_continue_pressed():
	# For now, this will just quit the game.
	# A future implementation would load the next shift or return to a main menu.
	print("ShiftReport: Continue pressed. Quitting for now.")
	get_tree().quit()
