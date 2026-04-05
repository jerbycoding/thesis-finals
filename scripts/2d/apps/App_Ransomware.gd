# App_Ransomware.gd
# Phase 4: Win condition — deploy ransomware on current foothold
# Pattern: @onready var = %NodeName (unique_name_in_owner)
extends Control

@onready var status_label = %StatusLabel
@onready var host_label = %HostLabel
@onready var start_button = %StartButton
@onready var calibration_container = %CalibrationContainer
@onready var ransom_calibration = %RansomCalibration

var target_hostname := ""

func _ready():
	start_button.pressed.connect(_on_deploy_pressed)

	# Connect calibration signals
	if ransom_calibration:
		ransom_calibration.minigame_success.connect(_on_minigame_success)
		ransom_calibration.minigame_failed.connect(_on_minigame_failed)

	# Validate eligibility
	if not _can_launch():
		status_label.text = "ERROR: No active foothold. Exploit a host first."
		status_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3, 1))
		start_button.disabled = true
		return

	# Get target from GameState
	target_hostname = GameState.current_foothold if GameState else ""
	if target_hostname.is_empty():
		status_label.text = "ERROR: Could not determine target host."
		start_button.disabled = true
		return

	host_label.text = "Target: %s" % target_hostname

	# Check if host is already RANSOMED
	var host_state = NetworkState.get_host_state(target_hostname) if NetworkState else {}
	var status = host_state.get("status", 0)
	var is_ransomed = false
	if status is int:
		is_ransomed = (status == 4)
	elif status is String:
		is_ransomed = (status == "RANSOMED")
	if is_ransomed:
		status_label.text = "ALREADY ENCRYPTED\nHost %s is already under your control.\nNo further action required." % target_hostname
		status_label.add_theme_color_override("font_color", Color(0.3, 1, 0.3, 1))
		start_button.disabled = true
		start_button.visible = true
		return

	status_label.text = "Ready to deploy ransomware payload on %s.\nTrace cost: +40.0 on success, +20.0 on failure." % target_hostname

func _can_launch() -> bool:
	# Must have a foothold
	if not GameState or GameState.current_foothold.is_empty():
		return false

	# Cannot launch during AI isolation
	if RivalAI and RivalAI.is_isolation_active:
		status_label.text = "BLOCKED: AI isolation in progress. Cannot deploy during lockdown."
		return false

	return true

func _on_deploy_pressed():
	if not _can_launch():
		return

	start_button.disabled = true
	start_button.text = "PAYLOAD ACTIVE"
	status_label.text = "Initiating calibration sequence..."

	# Show minigame
	calibration_container.visible = true
	if ransom_calibration:
		ransom_calibration.visible = true
		ransom_calibration._on_start_pressed()

func _on_minigame_success():
	# Set host to RANSOMED
	if NetworkState:
		NetworkState.update_host_state(target_hostname, {"status": "RANSOMED"})
		print("🔒 RANSOMWARE: %s is now RANSOMED" % target_hostname)

	# Emit offensive action — SUCCESS
	if EventBus:
		EventBus.offensive_action_performed.emit({
			"action_type": "ransomware",
			"target": target_hostname,
			"timestamp": 0,  # TODO: ShiftClock.elapsed_seconds
			"result": "SUCCESS",
			"trace_cost": GlobalConstants.TRACE_COST.get("RANSOMWARE", 40.0)
		})

	# Add bounty
	if BountyLedger:
		BountyLedger.add_bounty(target_hostname, 100)

	status_label.text = "PAYLOAD DEPLOYED SUCCESSFULLY\nHost %s is now encrypted." % target_hostname
	status_label.add_theme_color_override("font_color", Color(0.3, 1, 0.3, 1))

	# Close after delay
	await get_tree().create_timer(2.0).timeout
	_close_app()

func _on_minigame_failed():
	# Emit offensive action — FAILED (half trace cost)
	if EventBus:
		EventBus.offensive_action_performed.emit({
			"action_type": "ransomware",
			"target": target_hostname,
			"timestamp": 0,  # TODO: ShiftClock.elapsed_seconds
			"result": "FAILED",
			"trace_cost": GlobalConstants.TRACE_COST.get("RANSOMWARE", 40.0) * 0.5
		})

	status_label.text = "PAYLOAD DEPLOYMENT FAILED\nCalibration failed. Partial trace cost applied.\nYou may retry."
	status_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3, 1))

	# Re-enable button
	start_button.disabled = false
	start_button.text = "DEPLOY PAYLOAD"

func _close_app():
	"""Request window close via parent."""
	if get_parent() and get_parent().has_method("close_window"):
		get_parent().close_window()
	elif get_viewport() and get_viewport().gui_get_focus_owner():
		queue_free()
