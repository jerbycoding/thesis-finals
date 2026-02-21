# EmailSystem.gd
# Autoload singleton that manages all emails
extends Node

var all_emails: Array[EmailResource] = []
var active_emails: Array[EmailResource] = [] # Only these are shown in the app
var processed_emails: Array[String] = []  # Email IDs that have been processed

## Optional filter to restrict which emails can be revealed.
## signature: func(email: EmailResource, ticket_id: String) -> bool
var active_filter

const EMAIL_DIR = "res://resources/emails/"

func _ready():
	print("========================================")
	print("EmailSystem initialized")
	print("========================================")
	
	# Connect to EventBus for events
	EventBus.world_event_triggered.connect(_on_world_event)
	
	_initialize_system.call_deferred()

func _on_world_event(event_id: String, active: bool, _duration: float):
	if event_id == GlobalConstants.EVENTS.GOSSIP_FLOOD and active:
		_trigger_gossip_flood()

func _trigger_gossip_flood():
	print("📧 EMAIL: Internal gossip flood detected. Spawning noise.")
	reveal_emails_for_ticket("GENERIC")

func _initialize_system():
	# Load all emails into the background library
	_prepare_library()
	
	# Load some initial generic emails that don't need a ticket
	reveal_emails_for_ticket("") 

func _prepare_library():
	print("📧 EmailSystem: Discovering emails in %s..." % EMAIL_DIR)
	all_emails.clear()
	
	all_emails.assign(FileUtil.load_and_validate_resources(EMAIL_DIR, "EmailResource"))
	for res in all_emails:
		print("  - Discovered Email: ID=%s" % res.email_id)
			
	print("📧 EmailSystem: Library ready: ", all_emails.size(), " emails")

func reveal_emails_for_ticket(ticket_id: String):
	print("📧 EmailSystem: reveal_emails_for_ticket(%s)" % (ticket_id if not ticket_id.is_empty() else "GENERIC"))
	
	var count = 0
	for email in all_emails:
		var should_reveal = false
		
		if active_filter != null:
			should_reveal = active_filter.call(email, ticket_id)
		else:
			# DEFAULT REVEAL LOGIC
			var is_exact_match = not ticket_id.is_empty() and email.related_ticket == ticket_id
			var is_generic_email = email.related_ticket == "GENERIC"
			var email_is_orphaned = (email.related_ticket == "" or email.related_ticket == "NONE")
			
			if is_exact_match or is_generic_email or (ticket_id == "" and email_is_orphaned):
				should_reveal = true
		
		if should_reveal:
			if not _is_email_active(email.email_id):
				var instance = email.duplicate()
				active_emails.append(instance)
				EventBus.email_added.emit(instance)
				count += 1
				print("  - Revealed Email: ID=%s | Subject=%s" % [instance.email_id, instance.subject])
	
	if count > 0:
		print("📧 EmailSystem: Revealed ", count, " new emails")

func _is_email_active(id: String) -> bool:
	for e in active_emails:
		if e.email_id == id: return true
	return false

func clear_active_data():
	print("📧 EmailSystem: Purging all active email data.")
	active_emails.clear()
	processed_emails.clear()
	# Ensure basic corporate noise returns after purge
	reveal_emails_for_ticket("") 

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
	for email in active_emails:
		if email.email_id == email_id:
			return email
	for email in all_emails:
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