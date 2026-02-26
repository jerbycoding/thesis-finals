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
@onready var glow_frame: Panel = %GlowFrame

var ticket: TicketResource
var update_timer: Timer
var _glow_tween: Tween = null

func _ready():
	visible = true
	modulate = Color.WHITE
	
	if complete_button:
		complete_button.pressed.connect(_on_complete_pressed)
	
	if TutorialManager:
		TutorialManager.step_changed.connect(func(_id): _update_resolution_lock())
	
	mouse_entered.connect(func(): if AudioManager: AudioManager.play_ui_hover())
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	update_timer = Timer.new()
	update_timer.wait_time = 1.0
	update_timer.timeout.connect(_on_update_timer_timeout)
	add_child(update_timer)
	update_timer.start()
	
	# Initial state
	_update_resolution_lock()

func _update_resolution_lock():
	if not complete_button: return
	
	# RESTRICTION: In Tutorial, TRN-001 cannot be resolved until step 11
	if TutorialManager and TutorialManager.is_tutorial_active:
		if ticket and ticket.ticket_id == "TRN-001" and TutorialManager.current_step < 11:
			complete_button.disabled = true
			complete_button.tooltip_text = "RESTRICTED: FORENSIC EVIDENCE REQUIRED (SOP 1.2)"
			return
			
		# TRN-002 cannot be resolved until step 21
		if ticket and ticket.ticket_id == "TRN-002" and TutorialManager.current_step < 21:
			complete_button.disabled = true
			complete_button.tooltip_text = "RESTRICTED: CONTAINMENT PROOF REQUIRED (SOP 2.4)"
			return
			
		# TRN-003 cannot be resolved until step 26
		if ticket and ticket.ticket_id == "TRN-003" and TutorialManager.current_step < 26:
			complete_button.disabled = true
			complete_button.tooltip_text = "RESTRICTED: POLICY VERIFICATION REQUIRED (SOP 1.1)"
			return
			
		# TRN-005 cannot be resolved until step 36
		if ticket and ticket.ticket_id == "TRN-005" and TutorialManager.current_step < 36:
			complete_button.disabled = true
			complete_button.tooltip_text = "RESTRICTED: ROOT CAUSE ANALYSIS PENDING"
			return

	complete_button.disabled = false
	complete_button.tooltip_text = ""

func _on_update_timer_timeout():
	if ticket and is_instance_valid(ticket):
		_update_time_display()
		_update_evidence_display()
		_update_resolution_lock()

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
	
	# Sprint 13 Fix: Static display for tutorial
	if GameState and GameState.is_guided_mode:
		time_label.text = "--:--"
		time_label.add_theme_color_override("font_color", Color(0.4, 0.6, 1.0, 1)) # Light Blue
		return

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

func set_tutorial_glow(active: bool):
	if _glow_tween:
		_glow_tween.kill()
		_glow_tween = null
	
	if not active:
		if glow_frame: glow_frame.visible = false
		return
		
	if glow_frame:
		glow_frame.visible = true
		glow_frame.modulate.a = 1.0
		_glow_tween = create_tween().set_loops()
		_glow_tween.tween_property(glow_frame, "modulate:a", 0.2, 0.6).set_trans(Tween.TRANS_SINE)
		_glow_tween.tween_property(glow_frame, "modulate:a", 1.0, 0.6).set_trans(Tween.TRANS_SINE)

func get_ticket_id() -> String:
	return ticket.ticket_id if ticket else ""
		
