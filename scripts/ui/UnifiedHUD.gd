# UnifiedHUD.gd
extends Control

@onready var integrity_bar: ProgressBar = %IntegrityBar
@onready var integrity_label: Label = %IntegrityLabel
@onready var integrity_value: Label = %IntegrityValue

@onready var timer_label: Label = %TimerLabel
@onready var status_label: Label = %StatusLabel

# Hacker UI Nodes
@onready var trace_group: VBoxContainer = %TraceGroup
@onready var trace_bar: ProgressBar = %TraceBar
@onready var trace_value: Label = %TraceValue
@onready var trace_status: Label = %TraceStatus

var target_integrity: float = 100.0
var pulse_time: float = 0.0

func _ready():
	_setup_role_ui()
	
	if IntegrityManager:
		target_integrity = IntegrityManager.current_integrity
		IntegrityManager.integrity_changed.connect(_on_integrity_changed)
		_update_integrity_display(target_integrity)
	
	EventBus.ticket_completed.connect(_on_ticket_completed)
	integrity_bar.modulate = GlobalConstants.UI_COLORS.SUCCESS_FLAT

func _setup_role_ui():
	var is_hacker = GameState and GameState.current_role == GameState.Role.HACKER
	
	# Show/Hide groups based on role
	if trace_group: trace_group.visible = is_hacker
	if %IntegrityGroup: %IntegrityGroup.visible = not is_hacker
	
	if is_hacker:
		# Hacker-specific initialization
		_update_trace_display(0.0)
		# Update status for hacker mode
		status_label.text = "NETWORK_ACCESS: ACTIVE"

func _process(delta):
	# Role-Based Update
	if GameState and GameState.current_role == GameState.Role.HACKER:
		_process_hacker_ui(delta)
	else:
		_process_analyst_ui(delta)

	# Update Timer
	_process_timer()

func _process_hacker_ui(_delta):
	if not TraceLevelManager: return
	
	var current_trace = TraceLevelManager.get_trace_level()
	trace_bar.value = current_trace
	trace_value.text = "%d%%" % int(current_trace)
	
	# Update Status and Colors
	if current_trace >= 100:
		trace_status.text = "STATUS: LOCKDOWN"
		trace_status.add_theme_color_override("font_color", Color.RED)
		trace_bar.modulate = Color.RED
	elif current_trace >= 75:
		trace_status.text = "STATUS: DETECTED"
		trace_status.add_theme_color_override("font_color", Color.ORANGE)
		trace_bar.modulate = Color.ORANGE
	elif current_trace >= 40:
		trace_status.text = "STATUS: SUSPICIOUS"
		trace_status.add_theme_color_override("font_color", Color.YELLOW)
		trace_bar.modulate = Color.YELLOW
	else:
		trace_status.text = "STATUS: STEALTH"
		trace_status.add_theme_color_override("font_color", Color.GREEN)
		trace_bar.modulate = Color.GREEN

func _process_analyst_ui(delta):
	# Smooth Transition
	if integrity_bar:
		integrity_bar.value = move_toward(integrity_bar.value, target_integrity, delta * 30.0)
		
		# DYNAMIC COLOR & PULSE
		if integrity_bar.value < 25:
			integrity_bar.modulate = GlobalConstants.UI_COLORS.ERROR_FLAT
			# PULSE EFFECT: Visual Heartbeat
			pulse_time += delta * 5.0
			var pulse = (sin(pulse_time) + 1.0) / 2.0
			integrity_bar.modulate.a = lerp(0.4, 1.0, pulse)
			
			# AUDIO HEARTBEAT
			if Engine.get_frames_drawn() % 120 == 0:
				if AudioManager: AudioManager.play_terminal_beep(-10.0)
		elif integrity_bar.value < 50:
			integrity_bar.modulate = GlobalConstants.UI_COLORS.WARNING_FLAT
			integrity_bar.modulate.a = 1.0
		else:
			integrity_bar.modulate = GlobalConstants.UI_COLORS.SUCCESS_FLAT
			integrity_bar.modulate.a = 1.0

func _process_timer():
	if GameState and GameState.is_guided_mode:
		timer_label.visible = false
		status_label.text = "MODE: CERTIFICATION"
		status_label.add_theme_color_override("font_color", GlobalConstants.UI_COLORS.INFO_BLUE)
	elif NarrativeDirector and NarrativeDirector.is_shift_active():
		timer_label.visible = true
		var time_elapsed = NarrativeDirector.get_shift_timer()
		var shift_duration = NarrativeDirector.get_current_shift_duration()
		
		# Only show time if duration is valid (> 0)
		if shift_duration > 0:
			var time_remaining = max(0, shift_duration - time_elapsed)
			var m = int(time_remaining) / 60
			var s = int(time_remaining) % 60
			timer_label.text = "%02d:%02d" % [m, s]
		else:
			timer_label.text = "00:00"
			
		if GameState and GameState.current_role != GameState.Role.HACKER:
			status_label.text = "SHIFT_STATUS: ACTIVE"
			status_label.add_theme_color_override("font_color", Color.BLACK)
	else:
		timer_label.text = "00:00"
		timer_label.visible = true
		if GameState and GameState.current_role != GameState.Role.HACKER:
			status_label.text = "SHIFT_STATUS: STANDBY"
			status_label.add_theme_color_override("font_color", GlobalConstants.UI_COLORS.TEXT_SECONDARY)

func _on_integrity_changed(new_value: float, delta: float):
	target_integrity = new_value
	_update_integrity_display(new_value)
	if delta < 0:
		_flash_label(integrity_label, GlobalConstants.UI_COLORS.ERROR_FLAT)
	else:
		_flash_label(integrity_label, GlobalConstants.UI_COLORS.SUCCESS_FLAT)

func _update_trace_display(value: float):
	if trace_value:
		trace_value.text = "%d%%" % int(value)

func _update_integrity_display(value: float):
	if integrity_value:
		integrity_value.text = "%d%%" % int(value)

func _flash_label(lbl: Label, color: Color):
	var tween = create_tween()
	tween.tween_property(lbl, "modulate", color, 0.1)
	tween.tween_property(lbl, "modulate", Color.WHITE, 0.2)

func _on_ticket_completed(_t, completion_type, _time):
	match completion_type:
		"compliant": _flash_label(integrity_label, GlobalConstants.UI_COLORS.SUCCESS_FLAT)
		"emergency": _flash_label(integrity_label, GlobalConstants.UI_COLORS.WARNING_FLAT)
		"timeout": _flash_label(integrity_label, GlobalConstants.UI_COLORS.ERROR_FLAT)
