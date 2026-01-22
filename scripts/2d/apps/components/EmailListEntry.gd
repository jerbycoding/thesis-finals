# EmailListEntry.gd
extends PanelContainer

signal email_selected(email: EmailResource, instance: Control)

@onready var risk_bar: ColorRect = %RiskBar
@onready var subject_label: Label = %SubjectLabel
@onready var time_label: Label = %TimeLabel
@onready var sender_label: Label = %SenderLabel
@onready var preview_label: Label = %PreviewLabel

var email_data: EmailResource

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
		get_viewport().set_input_as_handled()

func set_highlight(active: bool):
	var style = get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	if style:
		if active:
			style.bg_color = Color(0.95, 0.95, 0.95, 1.0)
			style.border_width_left = 2
			style.border_color = GlobalConstants.UI_COLORS.INFO_BLUE
		else:
			style.bg_color = Color(1, 1, 1, 1)
			style.border_width_left = 0
		add_theme_stylebox_override("panel", style)