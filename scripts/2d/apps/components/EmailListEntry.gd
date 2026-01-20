# EmailListEntry.gd
extends PanelContainer

signal email_selected(email: EmailResource, instance: Control)

@onready var icon_label: Label = get_node_or_null("%IconLabel")
@onready var sender_label: Label = get_node_or_null("%SenderLabel")
@onready var subject_label: Label = get_node_or_null("%SubjectLabel")

var email_data: EmailResource

func set_email_data(email: EmailResource):
	email_data = email
	
	if icon_label:
		icon_label.text = "⚠️" if email.is_urgent else ""
		icon_label.visible = email.is_urgent
		
	if sender_label:
		sender_label.text = email.sender
		sender_label.add_theme_color_override("font_color", email.get_sender_color())
		
	if subject_label:
		var subject_text = email.get_formatted_subject()
		if subject_text.length() > 40:
			subject_text = subject_text.substr(0, 37) + "..."
		subject_label.text = subject_text

	# Update visual style based on sender
	var style = get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	if style:
		style.border_color = email.get_sender_color()
		add_theme_stylebox_override("panel", style)

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if email_data:
			email_selected.emit(email_data, self)
		get_viewport().set_input_as_handled()

func set_highlight(active: bool):
	var style = get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	if style:
		if active:
			style.bg_color = Color(0.2, 0.25, 0.35, 0.9)
		else:
			style.bg_color = Color(0.1, 0.12, 0.18, 0.8)
		add_theme_stylebox_override("panel", style)
