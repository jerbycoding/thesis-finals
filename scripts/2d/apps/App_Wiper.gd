# App_Wiper.gd
# Phase 4: Evidence destruction payload.
# Repurposes RuleSliderMinigame logic for "Log Overwriting".
extends Control

@onready var status_label = %StatusLabel
@onready var host_label = %HostLabel
@onready var start_button = %StartButton
@onready var log_cluster_container = %LogClusterContainer
@onready var slider = %SectorSlider
@onready var scrub_progress = %ScrubProgress
@onready var integrity_label = %IntegrityLabel

var target_hostname := ""
var is_active := false
var overwrite_integrity: float = 0.0
var scrub_timer: float = 0.0
const SCRUB_RATE = 0.8

func _ready():
	start_button.pressed.connect(_on_start_pressed)
	
	if not _can_launch(): return

	target_hostname = GameState.current_foothold
	host_label.text = "Target: %s" % target_hostname
	status_label.text = "Sectors mapped. Ready to initiate evidence destruction script."

func _can_launch() -> bool:
	if not GameState or GameState.current_role != GameState.Role.HACKER:
		status_label.text = "ERROR: Role mismatch."
		start_button.disabled = true
		return false
		
	if GameState.current_foothold.is_empty():
		status_label.text = "ERROR: No target sector. Establish foothold first."
		start_button.disabled = true
		return false

	if RivalAI and RivalAI.is_isolation_active:
		status_label.text = "BLOCKED: Emergency lockdown in effect. Local storage unmounted."
		start_button.disabled = true
		return false
		
	return true

func _on_start_pressed():
	if not _can_launch(): return
	
	start_button.disabled = true
	start_button.text = "WIPING SECTORS..."
	is_active = true
	overwrite_integrity = 0.0
	_update_ui()
	
	# Emit forensic action
	EventBus.offensive_action_performed.emit({
		"action_type": "wiper_start",
		"target": target_hostname,
		"timestamp": ShiftClock.elapsed_seconds,
		"result": "IN_PROGRESS",
		"trace_cost": GlobalConstants.TRACE_COST.WIPER
	})

func _process(delta: float):
	if not is_active: return
	
	# Interruption check
	if RivalAI and RivalAI.is_isolation_active:
		_handle_interruption()
		return
		
	scrub_timer += delta
	if scrub_timer >= SCRUB_RATE:
		scrub_timer = 0
		_spawn_log_cluster()
	
	# Update clusters
	for cluster in log_cluster_container.get_children():
		cluster.position.x += delta * 250.0
		
		# Collision check
		if cluster.position.x > 290 and cluster.position.x < 310:
			_check_cluster_collision(cluster)
			continue
			
		if cluster.position.x > 450:
			cluster.queue_free()

func _spawn_log_cluster():
	var c = ColorRect.new()
	c.custom_minimum_size = Vector2(16, 16)
	c.position = Vector2(0, randf_range(50, 350))
	
	# Red clusters = Evidence (GOOD to wipe), Green = System Logs (BAD to wipe, causes noise)
	var is_evidence = randf() < 0.5
	c.color = Color.RED if is_evidence else Color.GREEN
	c.set_meta("evidence", is_evidence)
	
	log_cluster_container.add_child(c)

func _check_cluster_collision(cluster):
	var c_y = cluster.position.y
	var s_y = slider.value
	
	var in_wipe_zone = abs(c_y - s_y) < 40
	var is_evidence = cluster.get_meta("evidence")
	
	if in_wipe_zone:
		# Overwritten!
		if is_evidence:
			overwrite_integrity += 10.0
			if AudioManager: AudioManager.play_terminal_beep(-5.0)
		else:
			# Wiping legitimate logs creates noise!
			overwrite_integrity -= 5.0
			if EventBus: EventBus.offensive_action_performed.emit({
				"action_type": "wiper_noise",
				"target": target_hostname,
				"timestamp": ShiftClock.elapsed_seconds,
				"result": "NOISE_GENERATED",
				"trace_cost": 2.0
			})
	else:
		# Missed evidence cluster
		if is_evidence:
			overwrite_integrity -= 2.0
			
	cluster.queue_free()
	_update_ui()
	_check_win_condition()

func _update_ui():
	overwrite_integrity = clamp(overwrite_integrity, 0, 100)
	scrub_progress.value = overwrite_integrity
	integrity_label.text = "Destruction Progress: %d%%" % int(overwrite_integrity)

func _check_win_condition():
	if overwrite_integrity >= 100:
		_complete_wipe()

func _handle_interruption():
	is_active = false
	status_label.text = "PROCESS KILLED BY SYSTEM LOCKDOWN"
	status_label.add_theme_color_override("font_color", Color(1, 0, 0, 1))
	start_button.disabled = false
	start_button.text = "RETRY WIPER"

func _complete_wipe():
	is_active = false
	status_label.text = "WIPE SUCCESSFUL. Evidence destroyed, trace reduced."
	status_label.add_theme_color_override("font_color", Color(0, 1, 0, 1))
	
	# === LOG GAP DETECTION RISK (20% cumulative per use) ===
	var host_info = NetworkState.get_host_state(target_hostname)
	var use_count = host_info.get("wiper_use_count", 0) + 1
	NetworkState.update_host_state(target_hostname, {"wiper_use_count": use_count})
	
	var alert_chance = use_count * 0.20
	if randf() < alert_chance:
		print("⚠ LOG GAP: Analyst detected forensic inconsistencies on %s!" % target_hostname)
		if EventBus: EventBus.offensive_action_performed.emit({
			"action_type": "log_integrity_violation",
			"target": target_hostname,
			"timestamp": ShiftClock.elapsed_seconds,
			"result": "ALERT_TRIGGERED",
			"trace_cost": 15.0 # Large penalty for being caught hiding
		})
		if NotificationManager:
			NotificationManager.show_notification("⚠ CRITICAL: Log Integrity Violation detected by Analyst!", "error")
	
	# EFFECT 1: Prune logs from SIEM
	if LogSystem:
		LogSystem.prune_logs_for_host(target_hostname, "OFFENSIVE")
	
	# EFFECT 2: Mark host as wiped in NetworkState
	if NetworkState:
		NetworkState.update_host_state(target_hostname, {"is_wiped": true})
		
	# EFFECT 3: Reduce Trace Level
	if TraceLevelManager:
		TraceLevelManager.add_trace(-20.0) # Reward for successful cleanup
		
	# Emit forensic action
	EventBus.offensive_action_performed.emit({
		"action_type": "wiper_complete",
		"target": target_hostname,
		"timestamp": ShiftClock.elapsed_seconds,
		"result": "SUCCESS",
		"trace_cost": 0.0
	})
	
	# Close app
	get_tree().create_timer(3.0).timeout.connect(_close_app)

func _close_app():
	if get_parent() and get_parent().has_method("close_window"):
		get_parent().close_window()
	else:
		queue_free()
