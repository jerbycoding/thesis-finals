# App_Ransomware.gd
# Phase 4 Redesign: Crypto-Locker industrial dashboard with reactive "Kill Screen".
extends Control

@onready var status_label = %StatusLabel
@onready var host_label = %HostLabel
@onready var start_button = %StartButton
@onready var calibration_container = %CalibrationContainer
@onready var ransom_calibration = %RansomCalibration
@onready var background = %Background
@onready var encryption_counter = %EncryptionCounter

var target_hostname := ""
var _is_pulsing := false
var _pulse_time := 0.0

func _ready():
	start_button.pressed.connect(_on_deploy_pressed)

	# Connect calibration signals
	if ransom_calibration:
		ransom_calibration.minigame_success.connect(_on_minigame_success)
		ransom_calibration.minigame_failed.connect(_on_minigame_failed)

	# Validate eligibility
	if not _can_launch():
		status_label.text = "ERROR: System authorization failure. Establish foothold first."
		status_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3, 1))
		start_button.disabled = true
		return

	# Get target from GameState
	target_hostname = GameState.current_foothold if GameState else ""
	if target_hostname.is_empty():
		status_label.text = "ERROR: Target node identity missing."
		start_button.disabled = true
		return

	host_label.text = target_hostname

	# Check if host is already RANSOMED
	var host_state = NetworkState.get_host_state(target_hostname) if NetworkState else {}
	var status = host_state.get("status", 0)
	var is_ransomed = (status == 4 or status == "RANSOMED")
	
	if is_ransomed:
		status_label.text = "TARGET_ALREADY_ENCRYPTED\nControl established. No further action required."
		status_label.add_theme_color_override("font_color", Color(0.3, 1, 0.3, 1))
		start_button.disabled = true
		start_button.text = "PAYLOAD_VERIFIED"
		return

	status_label.text = "Awaiting authorization for encryption sequence..."

func _can_launch() -> bool:
	if not GameState or GameState.current_foothold.is_empty():
		return false
	if RivalAI and RivalAI.is_isolation_active:
		status_label.text = "BLOCKED: Active Lockdown detected. Handshake impossible."
		return false
	return true

func _on_deploy_pressed():
	if not _can_launch(): return

	start_button.disabled = true
	start_button.text = "PAYLOAD_ACTIVE"
	status_label.text = "Initializing calibration sequence..."

	# Show minigame
	calibration_container.visible = true
	if ransom_calibration:
		ransom_calibration.visible = true
		ransom_calibration._on_start_pressed()

func _on_minigame_success():
	# 1. Update World State
	if NetworkState:
		NetworkState.update_host_state(target_hostname, {"status": "RANSOMED"})
		print("🔒 RANSOMWARE: %s is now RANSOMED" % target_hostname)

	# 2. Trigger "Kill Screen" Sequence
	_start_kill_sequence()

	# 3. Emit offensive action with 90% Trace Jump
	if EventBus:
		var current_trace = TraceLevelManager.get_trace_level() if TraceLevelManager else 0.0
		var jump_cost = max(40.0, 90.0 - current_trace)
		
		EventBus.offensive_action_performed.emit({
			"action_type": "ransomware",
			"target": target_hostname,
			"timestamp": ShiftClock.elapsed_seconds if "ShiftClock" in self else 0,
			"result": "SUCCESS",
			"trace_cost": jump_cost
		})

	# 4. Add bounty
	if BountyLedger:
		BountyLedger.add_bounty(target_hostname, 100)

func _start_kill_sequence():
	_is_pulsing = true
	calibration_container.visible = false
	status_label.text = "ENCRYPTION_INITIALIZED: TARGET_IS_DONE"
	status_label.add_theme_color_override("font_color", Color.RED)
	
	encryption_counter.visible = true
	
	# Animate Counter: 0 -> 48,209 files
	var tween = create_tween()
	var final_count = randi_range(30000, 60000)
	tween.tween_method(func(v): encryption_counter.text = "FILES_LOCKED: %d" % int(v), 0, final_count, 2.5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	
	if AudioManager:
		AudioManager.play_notification("error") # Use error sound as a makeshift klaxon
	
	# Close after sequence
	await tween.finished
	await get_tree().create_timer(1.0).timeout
	_close_app()

func _on_minigame_failed():
	if EventBus:
		EventBus.offensive_action_performed.emit({
			"action_type": "ransomware",
			"target": target_hostname,
			"timestamp": ShiftClock.elapsed_seconds if "ShiftClock" in self else 0,
			"result": "FAILED",
			"trace_cost": 20.0
		})

	status_label.text = "PAYLOAD_FAILURE: CALIBRATION_ERROR\nYou may retry after re-authorizing."
	status_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3, 1))

	# Re-enable
	start_button.disabled = false
	start_button.text = "RE-INITIALIZE_SEQUENCE"

func _process(delta):
	if _is_pulsing:
		_pulse_time += delta * 4.0
		var pulse = (sin(_pulse_time) + 1.0) / 2.0
		background.color = lerp(Color(0.02, 0, 0), Color(0.2, 0, 0), pulse)

func _close_app():
	if get_parent() and get_parent().has_method("close_window"):
		get_parent().close_window()
	else:
		queue_free()
