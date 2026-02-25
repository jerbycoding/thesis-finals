# EmailListEntry.gd
extends PanelContainer

signal email_selected(email: EmailResource, instance: Control)

@onready var risk_bar: ColorRect = %RiskBar
@onready var subject_label: Label = %SubjectLabel
@onready var time_label: Label = %TimeLabel
@onready var sender_label: Label = %SenderLabel
@onready var preview_label: Label = %PreviewLabel
@onready var priority_badge: Label = %PriorityBadge
@onready var glow_frame: Panel = %GlowFrame

var email_data: EmailResource
var _pulse_tween: Tween = null
var _glow_tween: Tween = null

func _ready():
	mouse_entered.connect(func(): if AudioManager: AudioManager.play_ui_hover())

func set_email_data(email: EmailResource):
	email_data = email
	
	if subject_label:
		subject_label.text = email.get_formatted_subject()
		
	if sender_label:
		sender_label.text = email.sender
		
	if preview_label:
		var body = email.get_formatted_body()
		preview_label.text = body.substr(0, 80) + "..."
		
	if time_label:
		time_label.text = "Just now" # Placeholder logic
		
	if priority_badge:
		priority_badge.visible = email.is_focused
		if email.is_focused:
			_start_badge_pulse()
		else:
			_stop_badge_pulse()
			
	if risk_bar:
		if email.is_malicious:
			risk_bar.color = GlobalConstants.UI_COLORS.ERROR_FLAT
		elif email.is_urgent:
			risk_bar.color = GlobalConstants.UI_COLORS.WARNING_FLAT
		else:
			risk_bar.color = GlobalConstants.UI_COLORS.SUCCESS_FLAT

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if AudioManager: AudioManager.play_ui_click()
		if email_data:
			email_selected.emit(email_data, self)
			# Signal for Tutorial system
			EventBus.emit_signal("email_read", email_data)
		get_viewport().set_input_as_handled()

func set_highlight(active: bool):
	var style = get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	if style:
		if active:
			# Dark highlight: slight white tint with a cyber-blue border
			style.bg_color = Color(1, 1, 1, 0.08) 
			style.border_width_left = 3
			style.border_color = Color(0.2, 0.6, 1, 1) # Cyber Blue
		else:
			# Normal state: Fully transparent (let theme decide)
			style.bg_color = Color(0, 0, 0, 0)
			style.border_width_left = 0
		add_theme_stylebox_override("panel", style)

func _start_badge_pulse():
	if _pulse_tween: _pulse_tween.kill()
	_pulse_tween = create_tween().set_loops()
	_pulse_tween.tween_property(priority_badge, "modulate:a", 0.3, 0.8)
	_pulse_tween.tween_property(priority_badge, "modulate:a", 1.0, 0.8)

func _stop_badge_pulse():
	if _pulse_tween:
		_pulse_tween.kill()
		_pulse_tween = null
	if priority_badge:
		priority_badge.modulate.a = 1.0

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

func get_email_id() -> String:
	return email_data.email_id if email_data else ""
		
