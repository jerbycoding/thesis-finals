# EmailSystem.gd
# Autoload singleton that manages all emails
extends Node

signal email_added(email: EmailResource)
signal email_decision_made(email_id: String, decision: String)  # "approve", "quarantine", "escalate"
signal email_decision_processed(email: EmailResource, decision: String, inspection_state: Dictionary)

var all_emails: Array[EmailResource] = []
var active_emails: Array[EmailResource] = [] # Only these are shown in the app
var processed_emails: Array[String] = []  # Email IDs that have been processed


# Email library - preloaded .tres resources
var email_library: Array[EmailResource] = [
	preload("res://resources/emails/EmailPhishing01.tres"),
	preload("res://resources/emails/EmailLegitUrgent.tres"),
	preload("res://resources/emails/EmailSpearPhish.tres"),
	preload("res://resources/emails/EmailSocialEng.tres"),
	preload("res://resources/emails/EmailRansomNote.tres"),
	preload("res://resources/emails/EmailExfilWarning.tres"),
]

func _ready():
	print("========================================")
	print("EmailSystem initialized")
	print("========================================")
	
	# Wait a moment for other systems to initialize
	await get_tree().create_timer(0.5).timeout
	
	# Load all emails into the background library, but don't activate them yet
	_prepare_library()
	
	# Load some initial generic emails that don't need a ticket
	reveal_emails_for_ticket("") 

func _prepare_library():
	print("📧 Preparing email library...")
	for email_res in email_library:
		if email_res:
			all_emails.append(email_res.duplicate())
	print("📧 Library ready: ", all_emails.size(), " emails")

func reveal_emails_for_ticket(ticket_id: String):
	print("📧 Revealing emails for ticket: ", ticket_id if not ticket_id.is_empty() else "GENERIC")
	var count = 0
	for email in all_emails:
		if email.related_ticket == ticket_id:
			if email not in active_emails:
				active_emails.append(email)
				email_added.emit(email)
				count += 1
	
	if count > 0:
		print("📧 Revealed ", count, " new emails for ", ticket_id)

func add_email(email: EmailResource):
	if not email:
		return
	
	if email not in all_emails:
		all_emails.append(email)
	
	if email not in active_emails:
		active_emails.append(email)
		email_added.emit(email)

func get_all_emails() -> Array[EmailResource]:
	return active_emails.duplicate()

func get_emails_for_ticket(ticket_id: String) -> Array[EmailResource]:
	var filtered: Array[EmailResource] = []
	for email in active_emails:
		if email.related_ticket == ticket_id:
			filtered.append(email)
	return filtered

func get_email_by_id(email_id: String) -> EmailResource:
	for email in active_emails:
		if email.email_id == email_id:
			return email
	return null

func get_unprocessed_emails() -> Array[EmailResource]:
	var filtered: Array[EmailResource] = []
	for email in active_emails:
		if email.email_id not in processed_emails:
			filtered.append(email)
	return filtered

func make_decision(email_id: String, decision: String, inspection_state: Dictionary = {}):
	# decision: "approve", "quarantine", "escalate"
	if decision not in ["approve", "quarantine", "escalate"]:
		print("⚠ Invalid decision: ", decision)
		return
	
	var email = get_email_by_id(email_id)
	if not email:
		print("⚠ Email not found: ", email_id)
		return
	
	if email.email_id in processed_emails:
		print("⚠ Email already processed: ", email_id)
		return
	
	processed_emails.append(email.email_id)
	email_decision_made.emit(email_id, decision)
	
	print("📧 Decision made on email ", email_id, ": ", decision)
	
	# Emit a signal with all context. Other systems will listen for this.
	email_decision_processed.emit(email, decision, inspection_state)
