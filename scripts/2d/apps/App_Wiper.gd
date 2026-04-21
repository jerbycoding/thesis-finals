# App_Wiper.gd
# Phase 4 Redesign: Sector Zero-Fill (Hex Scrubber)
extends Control

@onready var status_label = %StatusLabel
@onready var host_label = %HostLabel
@onready var start_button = %StartButton
@onready var hex_grid = %HexGrid
@onready var scrub_progress = %ScrubProgress
@onready var integrity_label = %IntegrityLabel

var target_hostname := ""
var is_active := false
var overwrite_integrity: float = 0.0
var _grid_cells: Array[Label] = []
var _evidence_spawn_timer: float = 0.0
const EVIDENCE_SPAWN_RATE = 0.6

# --- Mouse State ---
var _is_mouse_down: bool = false

func _ready():
	start_button.pressed.connect(_on_start_pressed)
	
	if not _can_launch(): return

	target_hostname = GameState.current_foothold
	host_label.text = target_hostname
	
	_initialize_grid()
	status_label.text = "Sectors mapped. Ready to initiate evidence destruction script."

func _can_launch() -> bool:
	if not GameState or GameState.current_role != GameState.Role.HACKER:
		status_label.text = "ERROR: System role mismatch."
		start_button.disabled = true
		return false
		
	if GameState.current_foothold.is_empty():
		status_label.text = "ERROR: No target sector. Establish foothold first."
		start_button.disabled = true
		return false

	if RivalAI and RivalAI.is_isolation_active:
		status_label.text = "BLOCKED: Lockdown in effect. Local storage unmounted."
		start_button.disabled = true
		return false
		
	return true

func _initialize_grid():
	# Clear existing
	for child in hex_grid.get_children(): child.queue_free()
	_grid_cells.clear()
	
	# Increase to 256 cells (16x16) to fill space
	for i in range(256):
		var lbl = Label.new()
		lbl.text = _get_random_hex()
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 14) # Increased font size
		lbl.add_theme_color_override("font_color", Color(1, 1, 1, 0.15))
		
		# Ensure each cell takes up meaningful space
		lbl.custom_minimum_size = Vector2(24, 24)
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lbl.size_flags_vertical = Control.SIZE_EXPAND_FILL
		
		lbl.mouse_filter = Control.MOUSE_FILTER_PASS
		
		# Connect mouse events for scrubbing
		lbl.mouse_entered.connect(_on_cell_scrubbed.bind(lbl))
		
		hex_grid.add_child(lbl)
		_grid_cells.append(lbl)

func _get_random_hex() -> String:
	var chars = "0123456789ABCDEF"
	return chars[randi() % 16] + chars[randi() % 16]

func _on_start_pressed():
	if not _can_launch(): return
	
	start_button.disabled = true
	start_button.text = "WIPE_ACTIVE"
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

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_is_mouse_down = event.pressed

func _process(delta: float):
	if not is_active: return
	
	# Interruption check
	if RivalAI and RivalAI.is_isolation_active:
		_handle_interruption()
		return
		
	_evidence_spawn_timer += delta
	if _evidence_spawn_timer >= EVIDENCE_SPAWN_RATE:
		_evidence_spawn_timer = 0
		_spawn_evidence()

func _spawn_evidence():
	# Pick a random cell and turn it RED (Evidence)
	var cell = _grid_cells.pick_random()
	if not cell.get_meta("is_evidence", false) and cell.text != "00":
		cell.add_theme_color_override("font_color", Color.RED)
		cell.set_meta("is_evidence", true)

func _on_cell_scrubbed(cell: Label):
	if not is_active or not _is_mouse_down: return
	
	if cell.get_meta("is_evidence", false):
		# SUCCESS: Wiped evidence
		cell.text = "00"
		cell.add_theme_color_override("font_color", Color.GREEN)
		cell.set_meta("is_evidence", false)
		overwrite_integrity += 5.0
		if AudioManager: AudioManager.play_terminal_beep(-15.0)
		_update_ui()
		_check_win_condition()
	elif cell.text != "00":
		# NOISE: Wiping healthy system data
		cell.modulate = Color.ORANGE
		var t = create_tween()
		t.tween_property(cell, "modulate", Color.WHITE, 0.2)
		
		overwrite_integrity -= 1.0 # Cleanup penalty
		_update_ui()

func _update_ui():
	overwrite_integrity = clamp(overwrite_integrity, 0, 100)
	scrub_progress.value = overwrite_integrity
	integrity_label.text = "DESTRUCTION: %d%%" % int(overwrite_integrity)

func _check_win_condition():
	if overwrite_integrity >= 100:
		_complete_wipe()

func _handle_interruption():
	is_active = false
	status_label.text = "PROCESS_KILLED: AI_LOCKDOWN"
	status_label.add_theme_color_override("font_color", Color.RED)
	start_button.disabled = false
	start_button.text = "RETRY_WIPE"

func _complete_wipe():
	is_active = false
	status_label.text = "WIPE SUCCESSFUL. Forensics sanitized."
	status_label.add_theme_color_override("font_color", Color.GREEN)
	
	# === LOG GAP DETECTION RISK (20% cumulative per use) ===
	var host_info = NetworkState.get_host_state(target_hostname)
	var use_count = host_info.get("wiper_use_count", 0) + 1
	NetworkState.update_host_state(target_hostname, {"wiper_use_count": use_count})
	
	var alert_chance = use_count * 0.20
	if randf() < alert_chance:
		if EventBus: EventBus.offensive_action_performed.emit({
			"action_type": "log_integrity_violation",
			"target": target_hostname,
			"timestamp": ShiftClock.elapsed_seconds,
			"result": "ALERT_TRIGGERED",
			"trace_cost": 15.0
		})
		if NotificationManager:
			NotificationManager.show_notification("⚠ CRITICAL: Log Integrity Violation detected!", "error")
	
	# EFFECT 1: Prune logs from SIEM
	if LogSystem: LogSystem.prune_logs_for_host(target_hostname, "OFFENSIVE")
	
	# EFFECT 2: Mark host as wiped
	if NetworkState: NetworkState.update_host_state(target_hostname, {"is_wiped": true})
		
	# EFFECT 3: Reduce Trace Level
	if TraceLevelManager: TraceLevelManager.add_trace(-20.0)
		
	# Emit forensic action
	EventBus.offensive_action_performed.emit({
		"action_type": "wiper_complete",
		"target": target_hostname,
		"timestamp": ShiftClock.elapsed_seconds,
		"result": "SUCCESS",
		"trace_cost": 0.0
	})
	
	get_tree().create_timer(3.0).timeout.connect(_close_app)

func _close_app():
	if get_parent() and get_parent().has_method("close_window"):
		get_parent().close_window()
	else:
		queue_free()
