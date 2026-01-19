# app_EmailAnalyzer.gd
extends Control

var email_list: VBoxContainer = null
var selected_email: EmailResource = null
var inspection_state: Dictionary = {}

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
		if view_headers_button.pressed.is_connected(_on_view_headers_pressed):
			view_headers_button.pressed.disconnect(_on_view_headers_pressed)
		view_headers_button.pressed.connect(_on_view_headers_pressed)
		print("DEBUG: View Headers button connected")
	
	if scan_attachments_button:
		if scan_attachments_button.pressed.is_connected(_on_scan_attachments_pressed):
			scan_attachments_button.pressed.disconnect(_on_scan_attachments_pressed)
		scan_attachments_button.pressed.connect(_on_scan_attachments_pressed)
		print("DEBUG: Scan Attachments button connected")
	
	if check_links_button:
		if check_links_button.pressed.is_connected(_on_check_links_pressed):
			check_links_button.pressed.disconnect(_on_check_links_pressed)
		check_links_button.pressed.connect(_on_check_links_pressed)
		print("DEBUG: Check Links button connected")
	
	if approve_button:
		if approve_button.pressed.is_connected(_on_approve_pressed):
			approve_button.pressed.disconnect(_on_approve_pressed)
		approve_button.pressed.connect(_on_approve_pressed)
		print("DEBUG: Approve button connected")
	
	if quarantine_button:
		if quarantine_button.pressed.is_connected(_on_quarantine_pressed):
			quarantine_button.pressed.disconnect(_on_quarantine_pressed)
		quarantine_button.pressed.connect(_on_quarantine_pressed)
		print("DEBUG: Quarantine button connected")
	
	if escalate_button:
		if escalate_button.pressed.is_connected(_on_escalate_pressed):
			escalate_button.pressed.disconnect(_on_escalate_pressed)
		escalate_button.pressed.connect(_on_escalate_pressed)
		print("DEBUG: Escalate button connected")
	
	# Connect to EventBus
	EventBus.email_added.connect(_on_email_added)
	print("DEBUG: Connected to EventBus")
	
	# Load existing emails
	await get_tree().process_frame
	_refresh_emails()
	
	print("======= App_EmailAnalyzer Ready Complete =======")

func _refresh_emails():
	if not email_list:
		print("WARNING: Cannot refresh emails - email_list is null")
		return
	
	# Clear existing emails
	for child in email_list.get_children():
		child.queue_free()
	
	# Get all emails
	var emails_to_show: Array[EmailResource] = []
	if EmailSystem:
		emails_to_show = EmailSystem.get_unprocessed_emails()
	else:
		print("WARNING: EmailSystem not available")
	
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
	
	# Create email card UI
	var card = _create_email_card(email)
	email_list.add_child(card)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL

func _create_email_card(email: EmailResource) -> Control:
	# Create a container for the email entry
	var container = PanelContainer.new()
	container.custom_minimum_size = Vector2(200, 60)
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# Set background color based on sender
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.12, 0.18, 0.8)
	style.border_width_left = 3
	style.border_color = email.get_sender_color()
	container.add_theme_stylebox_override("panel", style)
	
	# Create horizontal layout
	var hbox = HBoxContainer.new()
	container.add_child(hbox)
	
	# Urgency icon
	if email.is_urgent:
		var urgency_label = Label.new()
		urgency_label.text = "⚠️"
		urgency_label.custom_minimum_size = Vector2(30, 0)
		hbox.add_child(urgency_label)
	
	# Sender
	var sender_label = Label.new()
	sender_label.text = email.sender
	sender_label.custom_minimum_size = Vector2(100, 0)
	sender_label.add_theme_font_size_override("font_size", 12)
	sender_label.add_theme_color_override("font_color", email.get_sender_color())
	hbox.add_child(sender_label)
	
	# Subject (truncated)
	var subject_label = Label.new()
	var subject_text = email.subject
	if subject_text.length() > 40:
		subject_text = subject_text.substr(0, 37) + "..."
	subject_label.text = subject_text
	subject_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	subject_label.add_theme_font_size_override("font_size", 12)
	subject_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	hbox.add_child(subject_label)
	
	# Make clickable
	container.mouse_filter = Control.MOUSE_FILTER_PASS
	container.gui_input.connect(_on_email_card_clicked.bind(email, container))
	
	return container

func _on_email_card_clicked(event: InputEvent, email: EmailResource, container: Control):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# Select this email
		selected_email = email
		print("DEBUG: Email selected: ", email.email_id)
		
		# Show detail view
		_show_email_details(email)
		
		# Highlight selected
		_highlight_selected_email(container)

func _highlight_selected_email(selected_container: Control):
	# Reset all entries
	for child in email_list.get_children():
		if child is PanelContainer:
			var style = child.get_theme_stylebox("panel")
			if style:
				style.bg_color = Color(0.1, 0.12, 0.18, 0.8)
	
	# Highlight selected
	if selected_container:
		var style = selected_container.get_theme_stylebox("panel")
		if style:
			style.bg_color = Color(0.2, 0.25, 0.35, 0.9)

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
	_make_decision("approve")

func _on_quarantine_pressed():
	if not selected_email:
		return
	if AudioManager:
		AudioManager.play_sfx(AudioManager.SFX.button_click)
	_make_decision("quarantine")

func _on_escalate_pressed():
	if not selected_email:
		return
	if AudioManager:
		AudioManager.play_sfx(AudioManager.SFX.button_click)
	_make_decision("escalate")

func _make_decision(decision: String):
	if not selected_email:
		return
	
	if ArchetypeAnalyzer:
		ArchetypeAnalyzer.log_tool_used("email")
	
	if EmailSystem:
		EmailSystem.make_decision(selected_email.email_id, decision, inspection_state)
		
		# Feedback (NotificationManager will also use EventBus eventually, but for now we keep it descriptive)
		var message = ""
		match decision:
			"approve":
				message = CorporateVoice.get_notification("email_approved")
			"quarantine":
				message = CorporateVoice.get_notification("email_quarantined")
			"escalate":
				message = CorporateVoice.get_notification("email_escalated")
		
		if NotificationManager:
			NotificationManager.show_notification(message, "info", 3.0)
		
		# Clear selection
		selected_email = null
		placeholder_label.visible = true
		email_detail_view.visible = false
		
		# Refresh list to show processed status
		_refresh_emails()
