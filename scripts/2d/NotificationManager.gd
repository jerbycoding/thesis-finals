# NotificationManager.gd
# Manages notification toasts on the desktop
extends Node

var notification_queue: Array[Dictionary] = []
var active_notifications: Array[Control] = []
var notification_spacing: float = 90.0  # Space between notifications
var max_notifications: int = 5

var notification_scene = preload("res://scenes/ui/NotificationToast.tscn")
var desktop_instance: Control = null

func _ready():
	print("NotificationManager initialized")
	
	# Connect to game systems
	if TicketManager:
		TicketManager.ticket_completed.connect(_on_ticket_completed)
	
	if ConsequenceEngine:
		ConsequenceEngine.consequence_triggered.connect(_on_consequence_triggered)
		ConsequenceEngine.followup_ticket_scheduled.connect(_on_followup_ticket_scheduled)

func set_desktop(desktop: Control):
	desktop_instance = desktop
	print("NotificationManager: Desktop instance set")

func show_notification(text: String, type: String = "info", duration: float = 4.0):
	if not is_instance_valid(desktop_instance):
		print("WARNING: Cannot show notification - no valid desktop instance")
		return
	
	# Play sound effect based on type
	if AudioManager:
		match type:
			"success":
				AudioManager.play_sfx(AudioManager.SFX.notification_success)
			"warning":
				AudioManager.play_sfx(AudioManager.SFX.notification_warning)
			"error":
				AudioManager.play_sfx(AudioManager.SFX.notification_error)
			_: # "info"
				AudioManager.play_sfx(AudioManager.SFX.notification_info)
	
	# Create notification
	var notification = notification_scene.instantiate()
	if not notification:
		print("ERROR: Failed to instantiate notification")
		return
	
	# Set notification properties BEFORE adding to scene tree
	notification.set_notification(text, type, duration)
	notification.notification_finished.connect(_on_notification_finished.bind(notification))
	
	# Add to desktop (top-right corner)
	desktop_instance.add_child(notification)
	
	# Position notification (stack from top-right)
	# Wait a frame for size to be calculated
	await get_tree().process_frame
	
	var viewport_size = get_viewport().get_visible_rect().size
	var y_offset = active_notifications.size() * notification_spacing
	notification.position = Vector2(
		viewport_size.x - notification.size.x - 20,
		20 + y_offset
	)
	
	# Set z-index to appear above windows
	notification.z_index = 100
	
	active_notifications.append(notification)
	
	# Limit active notifications
	if active_notifications.size() > max_notifications:
		var oldest = active_notifications.pop_front() # Safely remove from the front
		if is_instance_valid(oldest):
			oldest.fade_out() # Tell it to fade out, it will free itself.
	
	print("📢 Notification shown: ", text)

func _on_notification_finished(notification: Control):
	if notification in active_notifications:
		active_notifications.erase(notification)
	
	# Reposition remaining notifications
	_update_notification_positions()

func _update_notification_positions():
	var viewport_size = get_viewport().get_visible_rect().size
	for i in range(active_notifications.size()):
		var notif = active_notifications[i]
		if is_instance_valid(notif):
			var y_offset = i * notification_spacing
			var target_pos = Vector2(
				viewport_size.x - notif.size.x - 20,
				20 + y_offset
			)
			# Smoothly move to new position
			var tween = create_tween()
			tween.tween_property(notif, "position", target_pos, 0.2)

func _on_ticket_completed(ticket: TicketResource, completion_type: String, time_taken: float):
	var completion_text = ""
	match completion_type:
		"compliant":
			completion_text = CorporateVoice.get_phrase("ticket_completed_compliant")
			show_notification(completion_text, "success", 4.0)
		"efficient":
			completion_text = CorporateVoice.get_phrase("ticket_completed_efficient")
			show_notification(completion_text, "warning", 4.0)
		"emergency":
			completion_text = CorporateVoice.get_phrase("ticket_completed_emergency")
			show_notification(completion_text, "error", 4.0)

func _on_consequence_triggered(consequence_type: String, details: Dictionary):
	var message = ""
	var notif_type = "warning"
	
	match consequence_type:
		"followup_ticket":
			var reason = details.get("reason", "Follow-up required")
			message = CorporateVoice.get_formatted_phrase("followup_ticket_triggered", {"reason": reason}) # Assuming a new phrase for this
			notif_type = "warning"
		"malware_outbreak":
			message = CorporateVoice.get_phrase("malware_outbreak")
			notif_type = "error"
		"data_breach":
			message = CorporateVoice.get_phrase("data_breach")
			notif_type = "error"
		"user_complaint":
			message = CorporateVoice.get_phrase("user_complaint")
			notif_type = "warning"
		_:
			message = "⚠ Consequence Triggered\n" + consequence_type # Fallback for unhandled types
			notif_type = "error"
	
	show_notification(message, notif_type, 5.0)

func _on_followup_ticket_scheduled(ticket_id: String, delay: float):
	var message = CorporateVoice.get_formatted_phrase("followup_ticket_scheduled", {"delay": str(int(delay))})
	show_notification(message, "info", 3.0)
