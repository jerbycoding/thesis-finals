# App_TicketQueue.gd
extends Control

var selected_ticket: TicketResource = null
var pool: UIObjectPool
var card_scene = preload("res://scenes/2d/apps/components/TicketCard.tscn")

# UI Elements
@onready var ticket_list: VBoxContainer = %TicketList
@onready var detail_view: VBoxContainer = %DetailView
@onready var placeholder_view: Control = %PlaceholderView
@onready var title_label: Label = %TitleLabel
@onready var description_label: RichTextLabel = %DescriptionLabel
@onready var steps_container: VBoxContainer = %StepsContainer
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
	
	# Connect signals
	EventBus.ticket_added.connect(_on_ticket_added)
	EventBus.ticket_completed.connect(_on_ticket_completed)
	EventBus.log_attached_to_ticket.connect(_on_log_attached)
	
	_refresh_list()
	_update_detail_view(null)

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
		
		for child in steps_container.get_children():
			child.queue_free()
		
		for i in range(selected_ticket.steps.size()):
			var lbl = Label.new()
			lbl.text = "> %s" % selected_ticket.steps[i]
			lbl.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2, 1))
			lbl.add_theme_font_size_override("font_size", 12)
			steps_container.add_child(lbl)

func _on_ticket_added(ticket: TicketResource):
	var card = pool.acquire(card_scene)
	ticket_list.add_child(card)
	card.set_ticket(ticket)
	
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
		if child is PanelContainer:
			var style = child.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
			if child == selected_card:
				style.bg_color = Color(0.94, 0.94, 0.94, 1.0)
				style.border_width_left = 4
				style.border_color = GlobalConstants.UI_COLORS.HEADER_BLACK
			else:
				style.bg_color = Color(1, 1, 1, 1)
				style.border_width_left = 0
			child.add_theme_stylebox_override("panel", style)

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

func _on_log_attached(_ticket_id: String, _log_id: String):
	if ticket_list:
		for child in ticket_list.get_children():
			if child.has_method("_update_evidence_display"):
				child._update_evidence_display()
