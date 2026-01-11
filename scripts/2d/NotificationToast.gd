# NotificationToast.gd
extends Control

signal notification_finished

var notification_text: String = ""
var notification_type: String = "info"  # "info", "success", "warning", "error"
var display_duration: float = 4.0

@onready var main_panel: PanelContainer = %MainPanel
@onready var label: Label = %Label
@onready var icon_label: Label = %IconLabel

func _ready():
	# All properties have been set by NotificationManager before this point.
	# Now, apply them to the UI nodes.
	
	if label:
		label.text = notification_text
	else:
		print("ERROR in NotificationToast: The Label node was not found! Text cannot be set.")
	
	_setup_style()
	
	# Set a timer to automatically dismiss the notification.
	var timer = get_tree().create_timer(display_duration)
	timer.timeout.connect(fade_out)
	
	fade_in()

func _setup_style():
	var style = StyleBoxFlat.new()
	
	match notification_type:
		"success":
			style.bg_color = Color(0.2, 0.5, 0.2, 0.95)
			if icon_label: icon_label.text = "✓"
		"warning":
			style.bg_color = Color(0.8, 0.6, 0.1, 0.95)
			if icon_label: icon_label.text = "⚠"
		"error":
			style.bg_color = Color(0.7, 0.2, 0.2, 0.95)
			if icon_label: icon_label.text = "🚨"
		_: # "info"
			style.bg_color = Color(0.2, 0.4, 0.8, 0.95)
			if icon_label: icon_label.text = "ℹ"
	
	style.border_width_left = 3
	style.border_color = style.bg_color.lightened(0.3)
	style.corner_radius_top_left = 4
	style.corner_radius_bottom_left = 4
	
	if main_panel:
		main_panel.add_theme_stylebox_override("panel", style)

func fade_in():
	# Animate opacity for a smooth fade-in effect
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.3)
	
	# After fading in, trigger shake for warnings/errors
	tween.tween_callback(func():
		if notification_type == "warning" or notification_type == "error":
			shake_animation()
	)

func fade_out():
	# Animate opacity and then remove the notification
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	await tween.finished
	
	notification_finished.emit()
	queue_free()

func shake_animation():
	if not main_panel: return
	
	var original_panel_pos = Vector2.ZERO # Since it's anchored to fill
	var shake_strength = 5
	var shake_duration = 0.2
	var tween = create_tween()
	
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_OUT)
	
	# Shake the PANEL relative to its parent (the Control root)
	tween.tween_property(main_panel, "position", original_panel_pos + Vector2(shake_strength, 0), shake_duration / 4.0)
	tween.tween_property(main_panel, "position", original_panel_pos - Vector2(shake_strength * 0.8, 0), shake_duration / 4.0)
	tween.tween_property(main_panel, "position", original_panel_pos + Vector2(shake_strength * 0.4, 0), shake_duration / 4.0)
	tween.tween_property(main_panel, "position", original_panel_pos, shake_duration / 4.0)
	

func set_notification(text: String, type: String = "info", duration: float = 4.0):
	# This function simply stores the data. 
	# The _ready() function will handle applying it to the UI.
	notification_text = text
	notification_type = type
	display_duration = duration
