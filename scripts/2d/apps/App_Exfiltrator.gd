# App_Exfiltrator.gd
# Phase 4 Redesign: Tactical Traffic Sniffer with live oscilloscope and metrics.
extends Control

@onready var status_label = %StatusLabel
@onready var host_label = %HostLabel
@onready var start_button = %StartButton
@onready var progress_summary = %ProgressSummary
@onready var intel_feed = %IntelFeed
@onready var rate_label = %RateLabel
@onready var packet_label = %PacketLabel
@onready var graph_canvas = %GraphCanvas

var target_hostname := ""
var is_active := false
var bandwidth_timer: float = 0.0
const BANDWIDTH_ALERT_INTERVAL = 10.0
const BANDWIDTH_TRACE_PENALTY = 5.0

# --- Telemetry & Graphing ---
var _packet_count: int = 0
var _current_kbps: float = 0.0
var _graph_points: Array[float] = []
const MAX_GRAPH_POINTS = 60
var _graph_color = Color(0, 1, 0.25, 0.8) # Terminal Green
var _amplitude_multiplier = 1.0

# --- File Feed Logic ---
var _file_pool = [
	"auth.log", "config.json", "passwords.db", "blueprint_v4.pdf", 
	"root_cert.pem", "private_key.key", "payroll_Q3.xls", "email_dump.zip",
	"network_map.xml", "shadow_copy", "user_metadata.bin", "ciso_notes.docx"
]
var _feed_timer: float = 0.0

func _ready():
	start_button.pressed.connect(_on_start_pressed)
	graph_canvas.draw.connect(_on_graph_draw)
	
	# Initialize graph data
	for i in range(MAX_GRAPH_POINTS):
		_graph_points.append(0.0)

	if not _can_launch():
		return

	target_hostname = GameState.current_foothold
	host_label.text = target_hostname
	status_label.text = "Handshake established. Ready to sniff packets."
	
	_log_feed("INITIALIZING_CLANDESTINE_HANDSHAKE...", "gray")

func _can_launch() -> bool:
	if not GameState or GameState.current_role != GameState.Role.HACKER:
		status_label.text = "ERROR: System role mismatch."
		start_button.disabled = true
		return false
		
	if GameState.current_foothold.is_empty():
		status_label.text = "ERROR: No active foothold."
		start_button.disabled = true
		return false

	if RivalAI and RivalAI.is_isolation_active:
		status_label.text = "BLOCKED: AI Lockdown active."
		start_button.disabled = true
		return false
		
	return true

func _on_start_pressed():
	if not _can_launch(): return
	
	start_button.disabled = true
	start_button.text = "SNIFFING_ACTIVE"
	is_active = true
	_packet_count = 0
	_log_feed("PACKET_CAPTURE_INITIALIZED", "cyan")
	
	var host_res = NetworkState.get_host(target_hostname)
	var num_streams = host_res.data_volume if host_res else 3
	
	# Emit offensive action started
	EventBus.offensive_action_performed.emit({
		"action_type": "exfiltration_start",
		"target": target_hostname,
		"timestamp": ShiftClock.elapsed_seconds,
		"result": "IN_PROGRESS",
		"trace_cost": GlobalConstants.TRACE_COST.EXFILTRATION_PER_STREAM * num_streams
	})

# --- PROGRESS TRACKING ---
var _current_progress: float = 0.0
const TRANSFER_DURATION = 25.0 # ~25 seconds for full exfil

func _process(delta: float):
	if not is_active: 
		_update_graph(0.0) # Flatline
		return
	
	# Check for LOCKDOWN interruption
	if RivalAI and RivalAI.is_isolation_active:
		_handle_interruption()
		return
		
	# Update Progress
	var host_res = NetworkState.get_host(target_hostname)
	var bandwidth = host_res.network_bandwidth if host_res else 1.0
	_current_progress += (100.0 / TRANSFER_DURATION) * bandwidth * delta
	progress_summary.text = "OVERALL_PROGRESS: %d%%" % int(_current_progress)
	
	# Update Metrics (Jittery realism)
	_current_kbps = lerp(_current_kbps, randf_range(200, 800) * bandwidth, 0.1)
	_packet_count += int(_current_kbps * delta * 10)
	
	rate_label.text = "%.1f KB/s" % _current_kbps
	packet_label.text = str(_packet_count).pad_zeros(6)
	
	# Update Graph
	var noise = (sin(Time.get_ticks_msec() * 0.01) + randf_range(-0.5, 0.5)) * 0.5 + 0.5
	_update_graph(noise * _amplitude_multiplier)
	
	# File Feed Logic
	_feed_timer += delta
	if _feed_timer >= 1.5:
		_feed_timer = 0
		_log_feed("[+] Extracting: %s... OK" % _file_pool.pick_random(), "green")

	# === BANDWIDTH ALERT LOGIC ===
	bandwidth_timer += delta
	if bandwidth_timer >= BANDWIDTH_ALERT_INTERVAL:
		bandwidth_timer = 0.0
		_trigger_bandwidth_alert()
	
	if _current_progress >= 100.0:
		_complete_exfiltration(1.0)

func _update_graph(value: float):
	_graph_points.pop_front()
	_graph_points.push_back(value)
	graph_canvas.queue_redraw()

func _on_graph_draw():
	var size = graph_canvas.size
	var step = size.x / (MAX_GRAPH_POINTS - 1)
	
	var points = PackedVector2Array()
	for i in range(_graph_points.size()):
		var val = _graph_points[i]
		# Center vertically, apply amplitude
		var y = (size.y / 2.0) - (val * (size.y * 0.4))
		points.append(Vector2(i * step, y))
	
	if points.size() > 1:
		graph_canvas.draw_polyline(points, _graph_color, 2.0, true)

func _trigger_bandwidth_alert():
	EventBus.offensive_action_performed.emit({
		"action_type": "exfiltration_bandwidth_alert",
		"target": target_hostname,
		"timestamp": ShiftClock.elapsed_seconds,
		"result": "ALERT_TRIGGERED",
		"trace_cost": BANDWIDTH_TRACE_PENALTY
	})
	
	if NotificationManager:
		NotificationManager.show_notification("⚠ WARNING: Large outbound transfer detected.", "warning")
	
	# Visual Spike
	_amplitude_multiplier = 2.0
	_graph_color = Color.RED
	status_label.text = "⚠ ALERT: BANDWIDTH SPIKE DETECTED!"
	status_label.add_theme_color_override("font_color", Color.RED)
	
	_log_feed("[!] IDS_ALERT: UNUSUAL_OUTBOUND_TRAFFIC", "red")
	
	# Cool down after 2 seconds
	await get_tree().create_timer(2.0).timeout
	_amplitude_multiplier = 1.0
	_graph_color = Color(0, 1, 0.25, 0.8)
	status_label.text = "Exfiltration in progress..."
	status_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.4))

func _handle_interruption():
	is_active = false
	status_label.text = "CONNECTION_TERMINATED: AI_LOCKDOWN"
	status_label.add_theme_color_override("font_color", Color.RED)
	_log_feed("[!!!] CONNECTION_KILLED_BY_SOC", "red")
	
	if _current_progress >= 50.0:
		_complete_exfiltration(_current_progress / 100.0)
	else:
		_fail_exfiltration()

func _complete_exfiltration(completion_ratio: float):
	is_active = false
	var host_res = NetworkState.get_host(target_hostname)
	
	# Add intel to inventory
	var intel = IntelligenceResource.new()
	intel.source_hostname = target_hostname
	intel.data_type = host_res.data_type if host_res else "generic"
	intel.data_label = host_res.data_label if host_res else "Internal Data"
	intel.shift_day = NarrativeDirector.current_hacker_day if NarrativeDirector else 0
	intel.is_partial = (completion_ratio < 0.95)
	
	if IntelligenceInventory: IntelligenceInventory.add_item(intel)
	if BountyLedger: BountyLedger.add_bounty(target_hostname, int((host_res.bounty_value if host_res else 100) * completion_ratio))
		
	# Emit forensic action
	EventBus.offensive_action_performed.emit({
		"action_type": "exfiltration_complete",
		"target": target_hostname,
		"timestamp": ShiftClock.elapsed_seconds,
		"result": "SUCCESS" if not intel.is_partial else "PARTIAL",
		"trace_cost": 0.0
	})
	
	status_label.text = "EXFILTRATION_COMPLETE (Ratio: %.1f)" % completion_ratio
	status_label.add_theme_color_override("font_color", Color.GREEN)
	_log_feed(">> DATA_EXTRACTION_SUCCESSFUL", "green")
	_log_feed(">> DISCONNECTING_CLEANLY...", "gray")
	
	get_tree().create_timer(3.0).timeout.connect(_close_app)

func _fail_exfiltration():
	is_active = false
	EventBus.offensive_action_performed.emit({
		"action_type": "exfiltration_complete",
		"target": target_hostname,
		"timestamp": ShiftClock.elapsed_seconds,
		"result": "FAILED",
		"trace_cost": 0.0
	})
	start_button.disabled = false
	start_button.text = "RETRY_HANDSHAKE"

func _log_feed(text: String, color: String = "white"):
	intel_feed.append_text("[color=%s]%s[/color]\n" % [color, text])

func _close_app():
	if get_parent() and get_parent().has_method("close_window"):
		get_parent().close_window()
	else:
		queue_free()
