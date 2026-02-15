# TicketCard.gd
extends PanelContainer

signal card_selected(ticket: TicketResource, card_instance: Control)
signal completion_requested(ticket: TicketResource)

@onready var id_label: Label = %IDLabel
@onready var title_label: Label = %TitleLabel
@onready var time_label: Label = %TimeLabel
@onready var evidence_label: Label = %EvidenceLabel
@onready var complete_button: Button = %CompleteButton
@onready var severity_bar: ColorRect = %SeverityBar

var ticket: TicketResource
var update_timer: Timer

func _ready():
	visible = true
	modulate = Color.WHITE
	
	if complete_button:
		complete_button.pressed.connect(_on_complete_pressed)
	
	mouse_entered.connect(func(): if AudioManager: AudioManager.play_ui_hover())
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	update_timer = Timer.new()
	update_timer.wait_time = 1.0
	update_timer.timeout.connect(_on_update_timer_timeout)
	add_child(update_timer)
	update_timer.start()

func _on_update_timer_timeout():
	if ticket and is_instance_valid(ticket):
		_update_time_display()
		_update_evidence_display()

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if AudioManager: AudioManager.play_ui_click()
		if ticket:
			card_selected.emit(ticket, self)
			EventBus.ticket_selected.emit(ticket)
		get_viewport().set_input_as_handled()

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return typeof(data) == TYPE_DICTIONARY and data.get("type") == "log_evidence"

func _drop_data(_at_position: Vector2, data: Variant):
	if not ticket: return
	
	var log_id = data.get("log_id")
	if TicketManager:
		if TicketManager.attach_log_to_ticket(ticket.ticket_id, log_id):
			_play_drop_success_animation()

func _play_drop_success_animation():
	var original_color = modulate
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1.5, 1.5, 2.0), 0.1) # Flash Blue-ish
	tween.tween_property(self, "modulate", original_color, 0.2)
	
	if AudioManager:
		AudioManager.play_notification("success")

func set_ticket(t: TicketResource):
	ticket = t
	id_label.text = t.ticket_id
	title_label.text = t.get_formatted_title()
	
	_update_time_display()
	_update_evidence_display()
	
	# Set severity color bar
	match t.severity:
		"Critical": severity_bar.color = GlobalConstants.UI_COLORS.ERROR_FLAT
		"High": severity_bar.color = GlobalConstants.UI_COLORS.WARNING_FLAT
		"Medium": severity_bar.color = Color("#FFD600") # Bright Yellow
		_: severity_bar.color = GlobalConstants.UI_COLORS.SUCCESS_FLAT

func _update_time_display():
	if not ticket or not time_label: return
	var current_time = Time.get_ticks_msec()
	var remaining_msec = max(0, ticket.expiry_timestamp - current_time)
	var remaining_time = remaining_msec / 1000.0
	
	var minutes = int(remaining_time) / 60
	var seconds = int(remaining_time) % 60
	time_label.text = "%02d:%02d" % [minutes, seconds]
	
	if remaining_time < 60:
		time_label.add_theme_color_override("font_color", GlobalConstants.UI_COLORS.ERROR_FLAT)
	else:
		time_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6, 1))

func _update_evidence_display():
	if not ticket or not evidence_label: return
	var evidence = ticket.get_evidence_count()
	evidence_label.text = "Evidence: %d/%d" % [evidence.attached, evidence.required]

func _on_complete_pressed():
	if AudioManager: AudioManager.play_ui_click()
	completion_requested.emit(ticket)

func set_highlight(active: bool):
	var style = get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	if style:
		if active:
			style.bg_color = Color(1, 1, 1, 0.08)
			style.border_width_left = 3
			style.border_color = Color(0.2, 0.6, 1, 1)
		else:
			style.bg_color = Color(0, 0, 0, 0)
			style.border_width_left = 0
		add_theme_stylebox_override("panel", style)