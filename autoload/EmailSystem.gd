# EmailSystem.gd
# Autoload singleton that manages all emails
extends Node

signal email_added(email: EmailResource)
signal email_decision_made(email_id: String, decision: String)  # "approve", "quarantine", "escalate"
signal email_decision_processed(email: EmailResource, decision: String, inspection_state: Dictionary)

var all_emails: Array[EmailResource] = []
var processed_emails: Array[String] = []  # Email IDs that have been processed


# Email library - paths to email scripts
var email_library: Array[String] = [
	"res://resources/emails/EmailPhishing01.gd",
	"res://resources/emails/EmailLegitUrgent.gd",
	"res://resources/emails/EmailSpearPhish.gd",
]

func _ready():
	print("========================================")
	print("EmailSystem initialized")
	print("========================================")
	
	# Wait a moment for other systems to initialize
	await get_tree().create_timer(0.5).timeout
	
	# Load initial emails for testing
	_load_initial_emails()

func _load_initial_emails():
	print("📧 Loading initial emails...")
	
	for email_path in email_library:
		if ResourceLoader.exists(email_path):
			var EmailScript = load(email_path)
			if EmailScript:
				var email = EmailScript.new()
				add_email(email)
				print("  ✓ Loaded email: ", email.email_id)
			else:
				print("  ❌ ERROR: Failed to load email script: ", email_path)
		else:
			print("  ❌ ERROR: Email script not found: ", email_path)
	
	print("📧 Total emails loaded: ", all_emails.size())

func add_email(email: EmailResource):
	if not email:
		print("❌ ERROR: Trying to add null email")
		return
	
	# Check if already exists
	for existing_email in all_emails:
		if existing_email.email_id == email.email_id:
			print("⚠ Email already exists: ", email.email_id)
			return
	
	all_emails.append(email)
	email_added.emit(email)
	print("📧 Email added: ", email.email_id, " - ", email.subject)

func get_all_emails() -> Array[EmailResource]:
	return all_emails.duplicate()

func get_emails_for_ticket(ticket_id: String) -> Array[EmailResource]:
	var filtered: Array[EmailResource] = []
	for email in all_emails:
		if email.related_ticket == ticket_id:
			filtered.append(email)
	return filtered

func get_email_by_id(email_id: String) -> EmailResource:
	for email in all_emails:
		if email.email_id == email_id:
			return email
	return null

func get_unprocessed_emails() -> Array[EmailResource]:
	var filtered: Array[EmailResource] = []
	for email in all_emails:
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

