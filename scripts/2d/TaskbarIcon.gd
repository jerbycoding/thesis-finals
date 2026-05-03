extends Button

var target_window: Control = null
var _glow_tween: Tween = null
@onready var glow_frame: Panel = %GlowFrame

func setup(window: Control):
	target_window = window
	%Label.text = window.window_title
	
	# Get app icon from configuration
	var app_id = window.window_id.split("_")[0]
	if DesktopWindowManager and DesktopWindowManager.app_configs.has(app_id):
		var config = DesktopWindowManager.app_configs[app_id]
		if config.icon:
			%IconRect.texture = config.icon
	
	pressed.connect(_on_pressed)

func _on_pressed():
	if not is_instance_valid(target_window):
		queue_free()
		return
		
	if target_window.is_minimized:
		target_window.toggle_minimize()
	else:
		if DesktopWindowManager.focused_window == target_window:
			target_window.toggle_minimize()
		else:
			target_window.bring_to_front()
			EventBus.window_focused.emit(target_window)

func _process(_delta):
	# Keep title in sync
	if is_instance_valid(target_window):
		%Label.text = target_window.window_title
		# Highlight if focused (don't override tutorial glow if active)
		if not _glow_tween:
			if DesktopWindowManager.focused_window == target_window:
				modulate = Color(0.5, 0.8, 1.0, 1.0) # Bright technical blue for focus
			else:
				modulate = Color.WHITE
	else:
		queue_free()

func set_glow(active: bool):
	if _glow_tween:
		_glow_tween.kill()
		_glow_tween = null
	
	if not active:
		if glow_frame: glow_frame.visible = false
		return
		
	if glow_frame:
		glow_frame.visible = true
		glow_frame.modulate.a = 1.0
		_glow_tween = create_tween().set_loops()
		_glow_tween.tween_property(glow_frame, "modulate:a", 0.2, 0.6).set_trans(Tween.TRANS_SINE)
		_glow_tween.tween_property(glow_frame, "modulate:a", 1.0, 0.6).set_trans(Tween.TRANS_SINE)
