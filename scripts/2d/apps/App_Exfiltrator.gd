# App_Exfiltrator.gd
# Phase 4: Data theft payload with multi-stream progress.
extends Control

@onready var status_label = %StatusLabel
@onready var host_label = %HostLabel
@onready var start_button = %StartButton
@onready var stream_container = %StreamContainer
@onready var progress_summary = %ProgressSummary

var target_hostname := ""
var is_active := false
var streams: Array = []
var stream_progress: Array = []
var stream_finished: Array = []

const STREAM_SCENE = preload("res://scenes/2d/apps/components/ExfiltrationStream.tscn")

func _ready():
	start_button.pressed.connect(_on_start_pressed)
	
	# Initial eligibility check
	if not _can_launch():
		return

	target_hostname = GameState.current_foothold
	host_label.text = "Target: %s" % target_hostname
	
	# Check if we've already exfiltrated this host this shift
	# (HackerHistory should track this, or we just allow multiple runs with diminishing returns)
	
	status_label.text = "Handshake established. Ready to initiate multi-stream exfiltration."

func _can_launch() -> bool:
	if not GameState or GameState.current_role != GameState.Role.HACKER:
		status_label.text = "ERROR: System role mismatch."
		start_button.disabled = true
		return false
		
	if GameState.current_foothold.is_empty():
		status_label.text = "ERROR: No active foothold. Establish a connection first."
		start_button.disabled = true
		return false

	if RivalAI and RivalAI.is_isolation_active:
		status_label.text = "BLOCKED: AI isolation in progress. Network channels saturated."
		start_button.disabled = true
		return false
		
	return true

func _on_start_pressed():
	if not _can_launch(): return
	
	start_button.disabled = true
	start_button.text = "EXFILTRATION IN PROGRESS"
	is_active = true
	
	var host_res = NetworkState.get_host(target_hostname)
	var num_streams = host_res.data_volume if host_res else 3
	
	# Clear existing
	for child in stream_container.get_children():
		child.queue_free()
	
	streams.clear()
	stream_progress.clear()
	stream_finished.clear()
	
	# Initialize streams
	for i in range(num_streams):
		var stream_ui = STREAM_SCENE.instantiate()
		stream_container.add_child(stream_ui)
		stream_ui.set_label("Stream_%02d" % (i+1))
		streams.append(stream_ui)
		stream_progress.append(0.0)
		stream_finished.append(false)
		
	# Emit offensive action started
	EventBus.offensive_action_performed.emit({
		"action_type": "exfiltration_start",
		"target": target_hostname,
		"timestamp": ShiftClock.elapsed_seconds,
		"result": "IN_PROGRESS",
		"trace_cost": GlobalConstants.TRACE_COST.EXFILTRATION_PER_STREAM * num_streams
	})

func _process(delta: float):
	if not is_active: return
	
	# Check for LOCKDOWN interruption
	if RivalAI and RivalAI.is_isolation_active:
		_handle_interruption()
		return
		
	var host_res = NetworkState.get_host(target_hostname)
	var bandwidth = host_res.network_bandwidth if host_res else 1.0
	
	var all_done = true
	var total_progress = 0.0
	
	for i in range(streams.size()):
		if not stream_finished[i]:
			# Each stream has slightly different speed for visual variety
			var variance = 0.8 + (randf() * 0.4)
			var speed = 5.0 * bandwidth * variance # ~20 seconds base per stream
			
			stream_progress[i] += speed * delta
			streams[i].set_progress(stream_progress[i])
			
			if stream_progress[i] >= 100.0:
				stream_finished[i] = true
				streams[i].set_complete()
			else:
				all_done = false
				
		total_progress += stream_progress[i]
	
	var avg_progress = total_progress / streams.size()
	progress_summary.text = "Overall Progress: %d%%" % int(avg_progress)
	
	if all_done:
		_complete_exfiltration(1.0)

func _handle_interruption():
	is_active = false
	status_label.text = "CONNECTION TERMINATED BY AI LOCKDOWN"
	status_label.add_theme_color_override("font_color", Color(1, 0, 0, 1))
	
	var total_progress = 0.0
	for p in stream_progress:
		total_progress += p
	var avg_progress = total_progress / (stream_progress.size() * 100.0)
	
	if avg_progress >= 0.5:
		status_label.text += "\nPartial recovery successful (%d%%)." % int(avg_progress * 100)
		_complete_exfiltration(avg_progress)
	else:
		status_label.text += "\nData lost. Insufficient progress for recovery."
		_fail_exfiltration()

func _complete_exfiltration(completion_ratio: float):
	is_active = false
	var host_res = NetworkState.get_host(target_hostname)
	
	# Create IntelligenceResource
	var intel = IntelligenceResource.new()
	intel.source_hostname = target_hostname
	intel.data_type = host_res.data_type if host_res else "generic"
	intel.data_label = host_res.data_label if host_res else "Internal Data"
	intel.shift_day = NarrativeDirector.current_hacker_day if NarrativeDirector else 0
	intel.is_partial = (completion_ratio < 0.95)
	
	# Add to inventory
	if IntelligenceInventory:
		IntelligenceInventory.add_item(intel)
		
	# Add bounty
	if BountyLedger:
		var base_bounty = host_res.bounty_value if host_res else 100
		BountyLedger.add_bounty(target_hostname, int(base_bounty * completion_ratio))
		
	# Emit forensic action
	EventBus.offensive_action_performed.emit({
		"action_type": "exfiltration_complete",
		"target": target_hostname,
		"timestamp": ShiftClock.elapsed_seconds,
		"result": "SUCCESS" if not intel.is_partial else "PARTIAL",
		"trace_cost": 0.0 # Cost was paid at start
	})
	
	status_label.text = "EXFILTRATION COMPLETE\nStolen: %s\nBounty awarded: %d" % [intel.data_label, int((host_res.bounty_value if host_res else 100) * completion_ratio)]
	status_label.add_theme_color_override("font_color", Color(0, 1, 0, 1))
	
	# Close app after delay
	get_tree().create_timer(3.0).timeout.connect(_close_app)

func _fail_exfiltration():
	is_active = false
	# Emit forensic action
	EventBus.offensive_action_performed.emit({
		"action_type": "exfiltration_complete",
		"target": target_hostname,
		"timestamp": ShiftClock.elapsed_seconds,
		"result": "FAILED",
		"trace_cost": 0.0
	})
	
	start_button.disabled = false
	start_button.text = "RETRY HANDSHAKE"

func _close_app():
	if get_parent() and get_parent().has_method("close_window"):
		get_parent().close_window()
	else:
		queue_free()
