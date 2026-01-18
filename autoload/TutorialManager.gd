# TutorialManager.gd
# Manages the guided onboarding experience.
extends Node

var is_tutorial_active: bool = false
var tutorial_step: int = 0

func _ready():
	# Use EventBus for decoupled communication
	EventBus.shift_started.connect(_on_shift_started)
	EventBus.shift_ended.connect(_on_shift_ended)
	EventBus.ticket_added.connect(_on_ticket_added)
	EventBus.app_opened.connect(_on_app_opened)
	EventBus.log_attached_to_ticket.connect(_on_log_attached)
	EventBus.ticket_completed.connect(_on_ticket_completed)

func _on_shift_started(shift_id: String):
	if shift_id == "shift_tutorial":
		is_tutorial_active = true
		tutorial_step = 1
		print("TutorialManager: Training sequence initiated.")
		_show_instruction("TUTORIAL: Move to your desk and press [E] to use the workstation.")

func _on_shift_ended(_results: Dictionary):
	is_tutorial_active = false
	print("TutorialManager: Training sequence concluded.")

func _on_ticket_added(ticket: TicketResource):
	if not is_tutorial_active: return
	
	if tutorial_step == 1:
		_show_instruction("INSTRUCTION: A new ticket has appeared. Click on the 'TICKETS' icon to open the queue.")
		tutorial_step = 2

func _on_app_opened(app_name: String, _window_id: String):
	if not is_tutorial_active: return
	
	if tutorial_step == 2 and app_name == "tickets":
		_show_instruction("INSTRUCTION: Select the ticket to read its details. You need to find evidence in the SIEM. Click the 'SIEM' icon.")
		tutorial_step = 3
	elif tutorial_step == 3 and app_name == "siem":
		_show_instruction("INSTRUCTION: Find the log mentioned in the ticket. Click it, select the ticket from the dropdown, and click 'ATTACH TO CASE'.")
		tutorial_step = 4

func _on_log_attached(_t_id, _l_id):
	if not is_tutorial_active: return
	
	if tutorial_step == 4:
		_show_instruction("INSTRUCTION: Evidence attached. Return to the TICKET QUEUE and click 'RESOLVE INCIDENT' -> 'COMPLIANT'.")
		tutorial_step = 5

func _on_ticket_completed(_ticket, completion_type, _time):
	if not is_tutorial_active: return
	
	if tutorial_step == 5 and completion_type == "compliant":
		_show_instruction("TUTORIAL COMPLETE: You have successfully resolved your first incident. Awaiting final debrief.")
		tutorial_step = 6

func _show_instruction(text: String):
	if NotificationManager:
		NotificationManager.show_notification(text, "info", 10.0)
	print("TUTORIAL_PROMPT: ", text)
