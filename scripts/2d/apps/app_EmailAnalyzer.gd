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
@onready var body_label: RichTextLabel = %BodyLabel
@onready var attachments_label: Label = %AttachmentsLabel
@onready var view_headers_button: Button = %ViewHeadersButton
@onready var scan_attachments_button: Button = %ScanAttachmentsButton
@onready var check_links_button: Button = %CheckLinksButton
@onready var forensic_modal: Control = %ForensicReportModal
@onready var approve_button: Button = %ApproveButton
@onready var quarantine_button: Button = %QuarantineButton
@onready var escalate_button: Button = %EscalateButton
@onready var glow_headers: Panel = %GlowHeaders
@onready var glow_attachments: Panel = %GlowAttachments
@onready var glow_links: Panel = %GlowLinks

var _tool_glow_tweens: Dictionary = {}

func _ready():
	print("======= App_EmailAnalyzer (SaaS Redesign) Ready =======")
	
	pool = UIObjectPool.new()
	add_child(pool)

	visible = true
	modulate = Color.WHITE
	
	email_list = %EmailList
	
	# Connect buttons
	view_headers_button.pressed.connect(_on_view_headers_pressed)
	scan_attachments_button.pressed.connect(_on_scan_attachments_pressed)
	check_links_button.pressed.connect(_on_check_links_pressed)
	approve_button.pressed.connect(_on_approve_pressed)
	quarantine_button.pressed.connect(_on_quarantine_pressed)
	escalate_button.pressed.connect(_on_escalate_pressed)
	
	# Connect to EventBus
	EventBus.email_added.connect(_on_email_added)
	EventBus.emails_cleared.connect(_refresh_emails)
	
	_refresh_emails()

func _refresh_emails():
	if not email_list: return
	pool.release_all(entry_scene.resource_path)
	
	var emails_to_show = EmailSystem.get_unprocessed_emails() if EmailSystem else []
	for email in emails_to_show:
		_add_email_entry(email)

func _on_email_added(_email: EmailResource):
	_refresh_emails()

func _add_email_entry(email: EmailResource):
	var entry = pool.acquire(entry_scene)
	email_list.add_child(entry)
	entry.set_email_data(email)
	if not entry.email_selected.is_connected(_on_email_selected):
		entry.email_selected.connect(_on_email_selected)

func _on_email_selected(email: EmailResource, instance: Control):
	selected_email = email
	_show_email_details(email)
	_highlight_selected_email(instance)

func _highlight_selected_email(selected_instance: Control):
	for child in email_list.get_children():
		if child.has_method("set_highlight"):
			child.set_highlight(child == selected_instance)

func _show_email_details(email: EmailResource):
	placeholder_label.visible = false
	email_detail_view.visible = true
	inspection_state = {"headers": false, "attachments": false, "links": false}
	
	subject_label.text = email.get_formatted_subject()
	sender_label.text = email.sender + " to Corporate SOC"
	body_label.text = email.get_formatted_body()
	
	if email.attachments.size() > 0:
		attachments_label.visible = true
		attachments_label.text = "Attachments: " + ", ".join(email.attachments)
	else:
		attachments_label.visible = false
	
	_update_decision_visibility()

func _update_decision_visibility():
	var tools_used = ValidationManager.can_action_email(inspection_state) if ValidationManager else true
	approve_button.disabled = not tools_used
	quarantine_button.disabled = not tools_used
	escalate_button.disabled = not tools_used

func _on_view_headers_pressed():
	if not selected_email: return
	inspection_state.headers = true
	var analysis = selected_email.get_header_analysis()
	forensic_modal.show_report("Header Forensics", analysis.text)
	_update_decision_visibility()
	EventBus.email_inspected.emit(selected_email, "headers")

func _on_scan_attachments_pressed():
	if not selected_email: return
	inspection_state.attachments = true
	var analysis = selected_email.get_attachment_analysis()
	forensic_modal.show_report("Malware Scan Results", analysis.text)
	_update_decision_visibility()
	EventBus.email_inspected.emit(selected_email, "attachments")

func _on_check_links_pressed():
	if not selected_email: return
	inspection_state.links = true
	var analysis = selected_email.get_link_analysis()
	forensic_modal.show_report("Link Reputation Analysis", analysis.text)
	_update_decision_visibility()
	EventBus.email_inspected.emit(selected_email, "links")

func _on_approve_pressed(): _make_decision(GlobalConstants.EMAIL_DECISION.APPROVE)
func _on_quarantine_pressed(): _make_decision(GlobalConstants.EMAIL_DECISION.QUARANTINE)
func _on_escalate_pressed(): _make_decision(GlobalConstants.EMAIL_DECISION.ESCALATE)

func _make_decision(decision: String):
	if not selected_email: return
	if EmailSystem:
		EmailSystem.make_decision(selected_email.email_id, decision, inspection_state)
		selected_email = null
		placeholder_label.visible = true
		email_detail_view.visible = false
		_refresh_emails()

func set_tool_glow(tool_id: String, active: bool):
	var target_glow: Panel = null
	match tool_id:
		"headers": target_glow = glow_headers
		"attachments": target_glow = glow_attachments
		"links": target_glow = glow_links
	
	if not target_glow: return
	
	# Stop existing tween
	if _tool_glow_tweens.has(tool_id):
		_tool_glow_tweens[tool_id].kill()
		_tool_glow_tweens.erase(tool_id)
	
	if not active:
		target_glow.visible = false
		return
		
	target_glow.visible = true
	target_glow.modulate.a = 1.0
	var tween = create_tween().set_loops()
	tween.tween_property(target_glow, "modulate:a", 0.2, 0.6).set_trans(Tween.TRANS_SINE)
	tween.tween_property(target_glow, "modulate:a", 1.0, 0.6).set_trans(Tween.TRANS_SINE)
	_tool_glow_tweens[tool_id] = tween
