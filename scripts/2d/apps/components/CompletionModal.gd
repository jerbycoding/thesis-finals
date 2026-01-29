# completion_modal.gd
extends Control

signal completion_selected(completion_type: String)

var current_ticket: TicketResource = null

@onready var compliant_button: Button = %CompliantButton
@onready var efficient_button: Button = %EfficientButton
@onready var emergency_button: Button = %EmergencyButton
@onready var cancel_button: Button = %CancelButton
@onready var description_label: Label = %DescriptionLabel
@onready var main_panel: PanelContainer = %MainPanel

func _ready():
	# Start hidden
	hide()
	modulate.a = 0
	
	# Connect buttons
	compliant_button.pressed.connect(_on_compliant_pressed)
	efficient_button.pressed.connect(_on_efficient_pressed)
	emergency_button.pressed.connect(_on_emergency_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)
	
	# Connect hover sounds
	for btn in [compliant_button, efficient_button, emergency_button, cancel_button]:
		btn.mouse_entered.connect(_on_button_hover)

func _on_button_hover():
	if AudioManager:
		AudioManager.play_sfx(AudioManager.SFX.button_click)

func show_for_ticket(ticket: TicketResource):
	current_ticket = ticket
	if ticket:
		var is_compliant_valid = ValidationManager.can_complete_compliant(ticket)
		compliant_button.disabled = not is_compliant_valid or not ValidationManager.is_resolution_allowed(ticket, "compliant")
		efficient_button.disabled = not ValidationManager.is_resolution_allowed(ticket, "efficient")
		emergency_button.disabled = not ValidationManager.is_resolution_allowed(ticket, "emergency")
		
		if is_compliant_valid:
			description_label.text = "Select resolution strategy for " + ticket.ticket_id + ". Every decision impacts organizational security posture."
			compliant_button.modulate = Color.WHITE
		else:
			description_label.text = "Insufficient evidence for Compliant resolution of " + ticket.ticket_id + "."
			compliant_button.modulate = Color(1, 1, 1, 0.4)
			
	# Reset state for animation
	show()
	modulate.a = 0
	main_panel.scale = Vector2(0.9, 0.9)
	main_panel.pivot_offset = main_panel.size / 2
	
	# Animate in
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.0, 0.2)
	tween.tween_property(main_panel, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_cancel_pressed():
	_close_modal()

func _close_modal():
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	tween.tween_property(main_panel, "scale", Vector2(0.9, 0.9), 0.2)
	await tween.finished
	hide()

func _on_compliant_pressed():
	if AudioManager:
		AudioManager.play_sfx(AudioManager.SFX.notification_success)
	completion_selected.emit("compliant")
	_close_modal()

func _on_efficient_pressed():
	if AudioManager:
		AudioManager.play_sfx(AudioManager.SFX.notification_warning)
	completion_selected.emit("efficient")
	_close_modal()

func _on_emergency_pressed():
	if AudioManager:
		AudioManager.play_sfx(AudioManager.SFX.notification_error)
	completion_selected.emit("emergency")
	_close_modal()
