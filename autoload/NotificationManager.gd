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
	
	# Use EventBus for decoupled communication
	EventBus.ticket_completed.connect(_on_ticket_completed)
	EventBus.consequence_triggered.connect(_on_consequence_triggered)
	EventBus.followup_ticket_scheduled.connect(_on_followup_ticket_scheduled)
	EventBus.email_decision_processed.connect(_on_email_decision_processed)

func _on_email_decision_processed(email: EmailResource, decision: String, inspection_state: Dictionary):
	# This new handler shows notifications based on the email decision event.
	if email.is_malicious and decision == "approve":
		var is_spear_phishing = "spear" in email.email_id.to_lower() or (email.related_ticket and "spear" in email.related_ticket.to_lower())
		if is_spear_phishing:
			show_notification(CorporateVoice.get_notification("email_approved_malicious_spear_phishing"), "error", 6.0)
		else:
			show_notification(CorporateVoice.get_notification("email_approved_malicious"), "error", 5.0)

	elif not email.is_malicious and decision == "quarantine":
		show_notification(CorporateVoice.get_notification("email_quarantined_legitimate"), "warning", 4.0)

	elif email.is_malicious and decision == "quarantine":
		# Check for the hidden risk of not scanning attachments
		if email.related_ticket == "SPEAR-PHISH-001" and not inspection_state.get("attachments", false):
			show_notification(CorporateVoice.get_notification("hidden_risk_attachment_scan_missed"), "error", 6.0)
		else:
			show_notification(CorporateVoice.get_notification("email_quarantined_malicious"), "success", 3.0)
	
	elif email.is_malicious and decision == "escalate":
		show_notification(CorporateVoice.get_notification("email_escalated_malicious"), "info", 3.0)


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
			completion_text = CorporateVoice.get_notification("ticket_completed_compliant")
			show_notification(completion_text, "success", 4.0)
		"efficient":
			completion_text = CorporateVoice.get_notification("ticket_completed_efficient")
			show_notification(completion_text, "warning", 4.0)
		"emergency":
			completion_text = CorporateVoice.get_notification("ticket_completed_emergency")
			show_notification(completion_text, "error", 4.0)

func _on_consequence_triggered(consequence_type: String, details: Dictionary):
	var message = ""
	var notif_type = "warning"
	
	match consequence_type:
		"followup_ticket":
			var reason = details.get("reason", "Follow-up required")
			# For this one, the phrase might still be constructed dynamically, 
			# but we use the concise formatted getter
			message = CorporateVoice.get_formatted_notification("followup_ticket_triggered", {"reason": "Reason: " + reason.substr(0, 20) + "..."}) 
			notif_type = "warning"
		"escalation":
			var path = details.get("path", "Unknown")
			var stage = str(details.get("stage", 0))
			message = CorporateVoice.get_formatted_notification("kill_chain_escalation", {"path": path, "stage": stage})
			notif_type = "error"
		"black_ticket":
			message = "CRITICAL RECOVERY INITIATED"
			notif_type = "warning"
		"malware_outbreak":
			message = CorporateVoice.get_notification("malware_outbreak")
			notif_type = "error"
		"data_breach":
			message = CorporateVoice.get_notification("data_breach")
			notif_type = "error"
		"user_complaint":
			message = CorporateVoice.get_notification("user_complaint")
			notif_type = "warning"
		_:
			message = "⚠ Consequence: " + consequence_type
			notif_type = "error"
	
	show_notification(message, notif_type, 5.0)

func _on_followup_ticket_scheduled(ticket_id: String, delay: float):
	var message = CorporateVoice.get_formatted_notification("followup_ticket_scheduled", {"delay": str(int(delay))})
	show_notification(message, "info", 3.0)
