# UnifiedHUD.gd
extends Control

@onready var integrity_bar: ProgressBar = %IntegrityBar
@onready var integrity_label: Label = %IntegrityLabel
@onready var integrity_value: Label = %IntegrityValue

@onready var timer_label: Label = %TimerLabel
@onready var status_label: Label = %StatusLabel

var target_integrity: float = 100.0

func _ready():
	if IntegrityManager:
		target_integrity = IntegrityManager.current_integrity
		IntegrityManager.integrity_changed.connect(_on_integrity_changed)
		_update_integrity_display(target_integrity)
	
	EventBus.ticket_completed.connect(_on_ticket_completed)
	integrity_bar.modulate = GlobalConstants.UI_COLORS.SUCCESS_FLAT

func _process(delta):
	# Smooth Transition
	if integrity_bar:
		integrity_bar.value = move_toward(integrity_bar.value, target_integrity, delta * 30.0)
		if integrity_bar.value < 25:
			integrity_bar.modulate = GlobalConstants.UI_COLORS.ERROR_FLAT
		elif integrity_bar.value < 50:
			integrity_bar.modulate = GlobalConstants.UI_COLORS.WARNING_FLAT
		else:
			integrity_bar.modulate = GlobalConstants.UI_COLORS.SUCCESS_FLAT

	# Update Timer
	if GameState and GameState.is_guided_mode:
		timer_label.visible = false
		status_label.text = "MODE: CERTIFICATION"
		status_label.add_theme_color_override("font_color", GlobalConstants.UI_COLORS.INFO_BLUE)
	elif NarrativeDirector and NarrativeDirector.is_shift_active():
		timer_label.visible = true
		var time_elapsed = NarrativeDirector.get_shift_timer()
		var shift_duration = NarrativeDirector.get_current_shift_duration()
		var time_remaining = max(0, shift_duration - time_elapsed)
		
		var m = int(time_remaining) / 60
		var s = int(time_remaining) % 60
		timer_label.text = "%02d:%02d" % [m, s]
		status_label.text = "SHIFT_STATUS: ACTIVE"
		status_label.add_theme_color_override("font_color", Color.BLACK)
	else:
		timer_label.text = "--:--"
		status_label.text = "SHIFT_STATUS: STANDBY"
		status_label.add_theme_color_override("font_color", GlobalConstants.UI_COLORS.TEXT_SECONDARY)

func _on_integrity_changed(new_value: float, delta: float):
	target_integrity = new_value
	_update_integrity_display(new_value)
	if delta < 0:
		_flash_label(integrity_label, GlobalConstants.UI_COLORS.ERROR_FLAT)
	else:
		_flash_label(integrity_label, GlobalConstants.UI_COLORS.SUCCESS_FLAT)

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
