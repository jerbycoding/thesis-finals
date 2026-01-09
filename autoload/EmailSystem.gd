# EmailSystem.gd
# Autoload singleton that manages all emails
extends Node

signal email_added(email: EmailResource)
signal email_decision_made(email_id: String, decision: String)  # "approve", "quarantine", "escalate"

var all_emails: Array[EmailResource] = []
var processed_emails: Array[String] = []  # Email IDs that have been processed

# Email library - paths to email scripts
var email_library: Array[String] = [
	"res://resources/emails/email_phishing_01.gd",
	"res://resources/emails/email_legit_urgent.gd",
	"res://resources/emails/email_spear_phish.gd",
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
	
	# Trigger consequences based on decision
	_trigger_email_consequences(email, decision, inspection_state)

func _trigger_email_consequences(email: EmailResource, decision: String, inspection_state: Dictionary):
	# Check if this is a spear phishing email
	var is_spear_phishing = _is_spear_phishing_email(email)
	
	# Wrong decisions trigger consequences
	if email.is_malicious and decision == "approve":
		# Approved malicious email - spawn malware ticket
		print("🚨 CONSEQUENCE: Approved malicious email!")
		if ConsequenceEngine:
			ConsequenceEngine.log_email_decision(email.email_id, decision, email)
			
			# Spear phishing has more severe consequences (data breach)
			if is_spear_phishing:
				print("🚨 SPEAR PHISHING DETECTED: Approved spear phishing email!")
				ConsequenceEngine._schedule_followup_ticket("DATA-BREACH", 120.0, "Data breach from approved spear phishing email - delayed detection")
				if NotificationManager:
					NotificationManager.show_notification(CorporateVoice.get_phrase("email_approved_malicious_spear_phishing"), "error", 6.0)
			else:
				ConsequenceEngine._schedule_followup_ticket("MALWARE-OUTBREAK", 30.0, "Malware outbreak from approved malicious email")
				if NotificationManager:
					NotificationManager.show_notification(CorporateVoice.get_phrase("email_approved_malicious"), "error", 5.0)
	
	elif not email.is_malicious and decision == "quarantine":
		# Quarantined legitimate email - spawn user complaint
		print("⚠ CONSEQUENCE: Quarantined legitimate email!")
		if ConsequenceEngine:
			ConsequenceEngine.log_email_decision(email.email_id, decision, email)
			ConsequenceEngine._schedule_followup_ticket("USER-COMPLAINT", 60.0, "User complaint: legitimate email quarantined")
		if NotificationManager:
			NotificationManager.show_notification(CorporateVoice.get_phrase("email_quarantined_legitimate"), "warning", 4.0)
	
	elif email.is_malicious and decision == "quarantine":
		# Correctly quarantined malicious email - positive outcome
		print("✓ Correctly quarantined malicious email")
		var completion_type = "compliant"

		# Check for hidden risks on the associated ticket
		if TicketManager and email.related_ticket == "SPEAR-PHISH-001":
			var ticket = TicketManager.get_ticket_by_id(email.related_ticket)
			if ticket and ticket.hidden_risks.has("missed_attachment_scan"):
				if not inspection_state.get("attachments", false):
					print("🚨 HIDDEN RISK TRIGGERED: Player quarantined email without scanning attachments!")
					# We still pass 'compliant' to complete_ticket, but trigger the specific consequence
					if ConsequenceEngine:
						ConsequenceEngine.trigger_consequence("missed_attachment_scan")
					if NotificationManager:
						NotificationManager.show_notification(CorporateVoice.get_phrase("hidden_risk_attachment_scan_missed"), "error", 6.0)
		
		# Complete the associated ticket if it exists
		if TicketManager and not email.related_ticket.is_empty():
			TicketManager.complete_ticket(email.related_ticket, completion_type)
		
		if NotificationManager:
			NotificationManager.show_notification(CorporateVoice.get_phrase("email_quarantined_malicious"), "success", 3.0)
	
	elif email.is_malicious and decision == "escalate":
		# Escalated malicious email - good decision, but takes time
		print("✓ Escalated malicious email for review")
		if NotificationManager:
			NotificationManager.show_notification(CorporateVoice.get_phrase("email_escalated_malicious"), "info", 3.0)

func _is_spear_phishing_email(email: EmailResource) -> bool:
	# Check if email is spear phishing based on:
	# 1. Email ID contains "SPEAR" or "spear"
	# 2. Related ticket is spear phishing ticket
	# 3. Subject contains spear phishing indicators
	# 4. Has spoofed sender but appears legitimate (CEO, executive, etc.)
	
	if "spear" in email.email_id.to_lower():
		return true
	
	if email.related_ticket and "spear" in email.related_ticket.to_lower():
		return true
	
	# Spear phishing often spoofs executives
	if email.sender in ["CEO", "CFO", "CTO", "Executive"] and email.is_malicious:
		# Check if it has suspicious elements despite appearing legitimate
		if email.clues.has("spoofed_sender") or email.clues.has("bad_attachment"):
			return true
	
	# Check subject for spear phishing patterns
	if "spear" in email.subject.to_lower() or "targeted" in email.subject.to_lower():
		return true
	
	return false


