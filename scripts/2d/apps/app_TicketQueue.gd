# App_TicketQueue.gd
extends Control

var selected_ticket: TicketResource = null
var pool: UIObjectPool
var card_scene = preload("res://scenes/2d/apps/components/TicketCard.tscn")
var artifact_tag_scene = preload("res://scenes/2d/apps/components/TicketArtifactTag.tscn")

# UI Elements
@onready var ticket_list: VBoxContainer = %TicketList
@onready var detail_view: VBoxContainer = %DetailView
@onready var placeholder_view: Control = %PlaceholderView
@onready var title_label: Label = %TitleLabel
@onready var description_label: RichTextLabel = %DescriptionLabel
@onready var steps_container: VBoxContainer = %StepsContainer
@onready var evidence_box: VBoxContainer = %EvidenceBox
@onready var artifact_container: HFlowContainer = %ArtifactContainer
@onready var root_cause_box: VBoxContainer = %RootCauseBox
@onready var root_cause_edit: LineEdit = %RootCauseEdit
@onready var root_cause_status: Label = %RootCauseStatus
@onready var completion_modal: Control = %CompletionModal
@onready var required_tool_label: Label = %RequiredToolLabel

func _ready():
	print("======= App_TicketQueue (Redesign) Ready =======")
	
	pool = UIObjectPool.new()
	add_child(pool)
	
	visible = true
	modulate = Color.WHITE

	if completion_modal:
		completion_modal.completion_selected.connect(_on_completion_selected)
	
	if root_cause_edit:
		root_cause_edit.text_changed.connect(_on_root_cause_text_changed)
	
	# Connect signals
	EventBus.ticket_added.connect(_on_ticket_added)
	EventBus.ticket_completed.connect(_on_ticket_completed)
	EventBus.log_attached_to_ticket.connect(_on_log_attached)
	EventBus.log_detached_from_ticket.connect(_on_log_detached)
	EventBus.ticket_state_updated.connect(_on_ticket_state_updated)
	
	_refresh_list()
	_update_detail_view(null)

func _on_root_cause_text_changed(new_text: String):
	if selected_ticket and TicketManager:
		TicketManager.submit_root_cause(selected_ticket.ticket_id, new_text)

func _on_ticket_state_updated(ticket: TicketResource):
	if selected_ticket and selected_ticket.ticket_id == ticket.ticket_id:
		_update_root_cause_status()

func _update_detail_view(ticket: TicketResource):
	selected_ticket = ticket
	
	if not selected_ticket:
		placeholder_view.visible = true
		detail_view.visible = false
	else:
		placeholder_view.visible = false
		detail_view.visible = true
		
		if required_tool_label:
			required_tool_label.text = "ANALYSIS TOOL: " + selected_ticket.required_tool.to_upper()
		
		title_label.text = selected_ticket.get_formatted_title()
		description_label.text = selected_ticket.get_formatted_description()
		
		# Steps
		for child in steps_container.get_children():
			child.queue_free()
		
		for i in range(selected_ticket.steps.size()):
			var lbl = Label.new()
			lbl.text = "> %s" % selected_ticket.steps[i]
			# Technical Off-White for steps
			lbl.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0, 1))
			lbl.add_theme_font_size_override("font_size", 12)
			steps_container.add_child(lbl)
			
		# Root Cause View
		if root_cause_box:
			root_cause_box.visible = not selected_ticket.required_root_cause.is_empty()
			if root_cause_box.visible:
				root_cause_edit.text = selected_ticket.input_root_cause
				_update_root_cause_status()
			
		# Evidence Artifacts
		_update_artifact_list()

func _update_root_cause_status():
	if not selected_ticket: return
	
	var is_valid = selected_ticket.has_sufficient_evidence() # This now includes root cause check
	
	# Actually, let's check root cause specifically for the status label
	var target = selected_ticket.required_root_cause
	if target.begins_with("{") and not selected_ticket.truth_packet.is_empty():
		target = target.format(selected_ticket.truth_packet)
	
	var root_cause_met = selected_ticket.input_root_cause.strip_edges().to_lower() == target.strip_edges().to_lower()
	
	if root_cause_met:
		root_cause_status.text = "VERIFIED"
		root_cause_status.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3, 1))
	else:
		root_cause_status.text = "REQUIRED"
		root_cause_status.add_theme_color_override("font_color", Color(1, 0.3, 0.3, 1))

func _update_artifact_list():
	if not selected_ticket: return
	
	# Clear existing
	for child in artifact_container.get_children():
		child.queue_free()
		
	# Visibility
	evidence_box.visible = not selected_ticket.attached_log_ids.is_empty()
	
	# Populate
	for log_id in selected_ticket.attached_log_ids:
		var tag = artifact_tag_scene.instantiate()
		artifact_container.add_child(tag)
		tag.setup(log_id)
		tag.removal_requested.connect(_on_artifact_removal_requested)

func _on_artifact_removal_requested(log_id: String):
	if selected_ticket and TicketManager:
		TicketManager.detach_log_from_ticket(selected_ticket.ticket_id, log_id)

func _on_log_detached(ticket_id: String, _log_id: String):
	if selected_ticket and selected_ticket.ticket_id == ticket_id:
		_update_artifact_list()
	
	# Update the counts on the list cards
	if ticket_list:
		for child in ticket_list.get_children():
			if child.has_method("_update_evidence_display"):
				child._update_evidence_display()

func _on_ticket_added(ticket: TicketResource):
	var card = pool.acquire(card_scene)
	ticket_list.add_child(card)
	card.set_ticket(ticket)
	
	# Initial highlight check
	if card.has_method("set_highlight"):
		card.set_highlight(selected_ticket == ticket)
	
	if not card.card_selected.is_connected(_on_ticket_card_selected):
		card.card_selected.connect(_on_ticket_card_selected)
	if not card.completion_requested.is_connected(_on_ticket_completion_requested):
		card.completion_requested.connect(_on_ticket_completion_requested)

func _on_ticket_card_selected(ticket: TicketResource, card_instance: Control):
	_update_detail_view(ticket)
	_highlight_card(card_instance)

func _on_ticket_completion_requested(ticket: TicketResource):
	if completion_modal:
		completion_modal.show_for_ticket(ticket)

func _on_completion_selected(completion_type: String):
	if completion_modal and completion_modal.current_ticket:
		var ticket_id = completion_modal.current_ticket.ticket_id
		if TicketManager:
			TicketManager.complete_ticket(ticket_id, completion_type)

func _highlight_card(selected_card: Control):
	for child in ticket_list.get_children():
		if child.has_method("set_highlight"):
			child.set_highlight(child == selected_card)

func _refresh_list():
	if not ticket_list: return
	selected_ticket = null
	_update_detail_view(null)
	pool.release_all(card_scene.resource_path)
	
	if TicketManager:
		for ticket in TicketManager.get_active_tickets():
			_on_ticket_added(ticket)

func _on_ticket_completed(_ticket: TicketResource, _completion_type: String, _time_taken: float):
	_refresh_list()

func _on_log_attached(ticket_id: String, _log_id: String):
	if selected_ticket and selected_ticket.ticket_id == ticket_id:
		_update_artifact_list()
		
	if ticket_list:
		for child in ticket_list.get_children():
			if child.has_method("_update_evidence_display"):
				child._update_evidence_display()

func set_modal_glow(active: bool):
	if completion_modal and completion_modal.has_method("set_glow"):
		completion_modal.set_glow(active)
