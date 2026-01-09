# completion_modal.gd
extends AcceptDialog

signal completion_selected(completion_type: String)

var current_ticket: TicketResource = null

@onready var compliant_button: Button = $VBoxContainer/ButtonContainer/CompliantButton
@onready var efficient_button: Button = $VBoxContainer/ButtonContainer/EfficientButton
@onready var emergency_button: Button = $VBoxContainer/ButtonContainer/EmergencyButton
@onready var description_label: Label = $VBoxContainer/DescriptionLabel

func _ready():
	# Connect buttons
	compliant_button.pressed.connect(_on_compliant_pressed)
	efficient_button.pressed.connect(_on_efficient_pressed)
	emergency_button.pressed.connect(_on_emergency_pressed)
	
	# Style buttons
	_style_button(compliant_button, Color(0.2, 0.8, 0.2))  # Green
	_style_button(efficient_button, Color(1.0, 0.8, 0.2))  # Yellow
	_style_button(emergency_button, Color(1.0, 0.2, 0.2))  # Red
	
	# Hide default OK button (AcceptDialog in Godot 4)
	var ok_button = get_ok_button()
	if ok_button:
		ok_button.visible = false
	
	# AcceptDialog doesn't have cancel button by default, so we don't need to hide it

func _style_button(button: Button, color: Color):
	var style = StyleBoxFlat.new()
	style.bg_color = color * 0.3
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = color
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	button.add_theme_stylebox_override("normal", style)
	
	var hover_style = style.duplicate()
	hover_style.bg_color = color * 0.5
	button.add_theme_stylebox_override("hover", hover_style)

func show_for_ticket(ticket: TicketResource):
	current_ticket = ticket
	if ticket:
		description_label.text = "Complete: " + ticket.title + "\n\nSelect completion type:"
	title = "Complete Ticket: " + ticket.ticket_id
	popup_centered()

func _on_compliant_pressed():
	print("DEBUG: Compliant completion selected")
	if AudioManager:
		AudioManager.play_sfx(AudioManager.SFX.button_click)
	completion_selected.emit("compliant")
	hide()

func _on_efficient_pressed():
	print("DEBUG: Efficient completion selected")
	if AudioManager:
		AudioManager.play_sfx(AudioManager.SFX.button_click)
	completion_selected.emit("efficient")
	hide()

func _on_emergency_pressed():
	print("DEBUG: Emergency completion selected")
	if AudioManager:
		AudioManager.play_sfx(AudioManager.SFX.button_click)
	completion_selected.emit("emergency")
	hide()
