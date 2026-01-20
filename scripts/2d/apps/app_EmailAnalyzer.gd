# app_EmailAnalyzer.gd
extends Control

var email_list: VBoxContainer = null
var selected_email: EmailResource = null
var inspection_state: Dictionary = {}
var pool: UIObjectPool
var entry_scene = preload("res://scenes/2d/apps/components/EmailListEntry.tscn")

@onready var placeholder_label: Label = %PlaceholderLabel
@onready var email_detail_view: VBoxContainer = %EmailDetailView
@onready var subject_label: Label = %SubjectLabel
@onready var sender_label: Label = %SenderLabel
@onready var body_label: Label = %BodyLabel
@onready var attachments_label: Label = %AttachmentsLabel
@onready var view_headers_button: Button = %ViewHeadersButton
@onready var scan_attachments_button: Button = %ScanAttachmentsButton
@onready var check_links_button: Button = %CheckLinksButton
@onready var inspection_results_label: RichTextLabel = %InspectionResults
@onready var decision_buttons: HBoxContainer = %DecisionButtons
@onready var approve_button: Button = %ApproveButton
@onready var quarantine_button: Button = %QuarantineButton
@onready var escalate_button: Button = %EscalateButton

func _ready():
	print("======= App_EmailAnalyzer._ready() =======")
	
	# Initialize Pool
	pool = UIObjectPool.new()
	add_child(pool)

	# Force visibility
	visible = true
	modulate = Color.WHITE
	
	# Wait a frame for the scene tree to be fully set up
	await get_tree().process_frame
	
	# Get email_list node safely
	email_list = %EmailList
	if not email_list:
		print("ERROR: EmailList node not found!")
		push_error("EmailList node missing in App_EmailAnalyzer")
	else:
		print("DEBUG: EmailList found: ", email_list.name)
		email_list.visible = true
		email_list.mouse_filter = Control.MOUSE_FILTER_PASS
		email_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# Connect buttons
	if view_headers_button:
		view_headers_button.pressed.connect(_on_view_headers_pressed)
	
	if scan_attachments_button:
		scan_attachments_button.pressed.connect(_on_scan_attachments_pressed)
	
	if check_links_button:
		check_links_button.pressed.connect(_on_check_links_pressed)
	
	if approve_button:
		approve_button.pressed.connect(_on_approve_pressed)
	
	if quarantine_button:
		quarantine_button.pressed.connect(_on_quarantine_pressed)
	
	if escalate_button:
		escalate_button.pressed.connect(_on_escalate_pressed)
	
	# Connect to EventBus
	EventBus.email_added.connect(_on_email_added)
	
	# Load existing emails
	_refresh_emails()
	
	print("======= App_EmailAnalyzer Ready Complete =======")

func _refresh_emails():
	if not email_list:
		return
	
	# Release all to pool
	pool.release_all(entry_scene.resource_path)
	
	# Get all emails
	var emails_to_show: Array[EmailResource] = []
	if EmailSystem:
		emails_to_show = EmailSystem.get_unprocessed_emails()
	
	print("DEBUG: Refreshing emails - ", emails_to_show.size(), " emails")
	
	# Add emails to list
	for email in emails_to_show:
		_add_email_entry(email)

func _on_email_added(email: EmailResource):
	print("New email added: ", email.email_id)
	_refresh_emails()

func _add_email_entry(email: EmailResource):
	if not email or not email_list:
		return
	
	var entry = pool.acquire(entry_scene)
	email_list.add_child(entry)
	entry.set_email_data(email)
	
	if not entry.email_selected.is_connected(_on_email_selected):
		entry.email_selected.connect(_on_email_selected)

func _on_email_selected(email: EmailResource, instance: Control):
	selected_email = email
	print("DEBUG: Email selected: ", email.email_id)
	
	# Show detail view
	_show_email_details(email)
	
	# Highlight selected
	_highlight_selected_email(instance)

func _highlight_selected_email(selected_instance: Control):
	for child in email_list.get_children():
		if child.has_method("set_highlight"):
			child.set_highlight(child == selected_instance)

func _show_email_details(email: EmailResource):
	# Hide placeholder, show detail view
	placeholder_label.visible = false
	email_detail_view.visible = true
	
	# Reset inspection state for the new email
	inspection_state = {"headers": false, "attachments": false, "links": false}
	
	# Update decision buttons state
	_update_decision_visibility()
	
	# Update labels
	subject_label.text = "Subject: " + email.get_formatted_subject()
	sender_label.text = "From: " + email.sender
	body_label.text = email.get_formatted_body()
	
	# Show attachments if any
	if email.attachments.size() > 0:
		attachments_label.visible = true
		attachments_label.text = "Attachments: " + ", ".join(email.attachments)
	else:
		attachments_label.visible = false
	
	# Clear previous inspection results
	inspection_results_label.text = ""
	
	# Enable inspection buttons
	view_headers_button.disabled = false
	scan_attachments_button.disabled = false
	check_links_button.disabled = false

func _update_decision_visibility():
	# Check if any tool has been used
	var tools_used = ValidationManager.can_action_email(inspection_state)
	
	if decision_buttons:
		decision_buttons.visible = true # Always show them now
		
		# Update individual buttons
		for btn in [approve_button, quarantine_button, escalate_button]:
			if btn:
				btn.disabled = not tools_used
				if btn.disabled:
					btn.modulate = Color(0.5, 0.5, 0.5, 0.7) # Grayscale/Dimmed look
					btn.tooltip_text = "Investigation required: Use tools above before making a decision."
				else:
					btn.modulate = Color.WHITE
					btn.tooltip_text = "Authorize action for this email."

func _on_view_headers_pressed():
	if not selected_email:
		return
	
	inspection_state.headers = true
	
	if ArchetypeAnalyzer:
		ArchetypeAnalyzer.log_tool_used("email")
	
	view_headers_button.disabled = true
	await get_tree().create_timer(0.1).timeout
	
	var analysis = selected_email.get_header_analysis()
	inspection_results_label.text = analysis.text
	
	view_headers_button.disabled = false
	_update_decision_visibility()

func _on_scan_attachments_pressed():
	if not selected_email:
		return
		
	inspection_state.attachments = true
	
	if ArchetypeAnalyzer:
		ArchetypeAnalyzer.log_tool_used("email")
	
	scan_attachments_button.disabled = true
	await get_tree().create_timer(0.1).timeout
	
	var analysis = selected_email.get_attachment_analysis()
	inspection_results_label.text = analysis.text
	
	scan_attachments_button.disabled = false
	_update_decision_visibility()

func _on_check_links_pressed():
	if not selected_email:
		return
		
	inspection_state.links = true
	
	if ArchetypeAnalyzer:
		ArchetypeAnalyzer.log_tool_used("email")
	
	check_links_button.disabled = true
	await get_tree().create_timer(0.1).timeout
	
	var analysis = selected_email.get_link_analysis()
	inspection_results_label.text = analysis.text
	
	check_links_button.disabled = false
	_update_decision_visibility()

func _on_approve_pressed():
	if not selected_email:
		return
	if AudioManager:
		AudioManager.play_sfx(AudioManager.SFX.button_click)
	_make_decision(GlobalConstants.EMAIL_DECISION.APPROVE)

func _on_quarantine_pressed():
	if not selected_email:
		return
	if AudioManager:
		AudioManager.play_sfx(AudioManager.SFX.button_click)
	_make_decision(GlobalConstants.EMAIL_DECISION.QUARANTINE)

func _on_escalate_pressed():
	if not selected_email:
		return
	if AudioManager:
		AudioManager.play_sfx(AudioManager.SFX.button_click)
	_make_decision(GlobalConstants.EMAIL_DECISION.ESCALATE)

func _make_decision(decision: String):
	if not selected_email:
		return
	
	if ArchetypeAnalyzer:
		ArchetypeAnalyzer.log_tool_used("email")
	
	if EmailSystem:
		EmailSystem.make_decision(selected_email.email_id, decision, inspection_state)
		
		# Feedback
		var message = ""
		match decision:
			GlobalConstants.EMAIL_DECISION.APPROVE:
				message = CorporateVoice.get_notification("email_approved")
			GlobalConstants.EMAIL_DECISION.QUARANTINE:
				message = CorporateVoice.get_notification("email_quarantined")
			GlobalConstants.EMAIL_DECISION.ESCALATE:
				message = CorporateVoice.get_notification("email_escalated")
		
		if NotificationManager:
			NotificationManager.show_notification(message, "info", 3.0)
		
		# Clear selection
		selected_email = null
		placeholder_label.visible = true
		email_detail_view.visible = false
		
		# Refresh list
		_refresh_emails()
