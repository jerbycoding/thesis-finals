# EmailSystem.gd
# Autoload singleton that manages all emails
extends Node

var all_emails: Array[EmailResource] = []
var active_emails: Array[EmailResource] = [] # Only these are shown in the app
var processed_emails: Array[String] = []  # Email IDs that have been processed

const EMAIL_DIR = "res://resources/emails/"

func _ready():
	print("========================================")
	print("EmailSystem initialized")
	print("========================================")
	
	_initialize_system.call_deferred()

func _initialize_system():
	# Load all emails into the background library
	_prepare_library()
	
	# Load some initial generic emails that don't need a ticket
	reveal_emails_for_ticket("") 

func _prepare_library():
	print("📧 EmailSystem: Discovering emails in %s..." % EMAIL_DIR)
	all_emails.clear()
	
	all_emails = FileUtil.load_and_validate_resources(EMAIL_DIR, "EmailResource")
	for res in all_emails:
		print("  - Discovered Email: ID=%s" % res.email_id)
			
	print("📧 EmailSystem: Library ready: ", all_emails.size(), " emails")

func reveal_emails_for_ticket(ticket_id: String):
	print("📧 EmailSystem: reveal_emails_for_ticket(%s)" % (ticket_id if not ticket_id.is_empty() else "GENERIC"))
	var count = 0
	for email in all_emails:
		# Match if:
		# 1. Exact ticket ID match
		# 2. Or ticket is GENERIC and email is GENERIC
		# 3. Or email has no ticket assigned
		var is_exact_match = email.related_ticket == ticket_id
		var is_generic_match = (ticket_id.contains("GENERIC") and email.related_ticket == "GENERIC")
		var email_is_orphaned = (email.related_ticket == "" or email.related_ticket == "NONE")
		
		if is_exact_match or is_generic_match or (ticket_id == "" and email_is_orphaned):
			if email not in active_emails:
				active_emails.append(email)
				EventBus.email_added.emit(email)
				count += 1
				print("  - Revealed Email: ID=%s | Subject=%s" % [email.email_id, email.subject])
	
	if count > 0:
		print("📧 EmailSystem: Revealed ", count, " new emails")

func add_email(email: EmailResource):
	if not email: return
	print("📧 EmailSystem: add_email() called for ID=%s" % email.email_id)
	
	if email not in all_emails:
		all_emails.append(email)
	
	if email not in active_emails:
		active_emails.append(email)
		EventBus.email_added.emit(email)

func get_all_emails() -> Array[EmailResource]:
	return active_emails.duplicate()

func get_emails_for_ticket(ticket_id: String) -> Array[EmailResource]:
	var filtered: Array[EmailResource] = []
	for email in active_emails:
		if email.related_ticket == ticket_id:
			filtered.append(email)
	return filtered

func get_email_by_id(email_id: String) -> EmailResource:
	for email in all_emails:
		if email.email_id == email_id:
			return email
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
	if decision not in [GlobalConstants.EMAIL_DECISION.APPROVE, GlobalConstants.EMAIL_DECISION.QUARANTINE, GlobalConstants.EMAIL_DECISION.ESCALATE]:
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
	
	print("📧 Decision made on email ", email_id, ": ", decision)
	
	# GLOBAL EMIT
	EventBus.email_decision_processed.emit(email, decision, inspection_state)