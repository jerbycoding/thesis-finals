extends Button

var target_window: Control = null

func setup(window: Control):
	target_window = window
	%Label.text = window.window_title
	
	# Try to get app icon by convention
	var app_id = window.window_id.split("_")[0]
	var icon_name = app_id
	
	# Handle specific mappings where ID doesn't match filename
	match app_id:
		"tickets": icon_name = "ticket"
		"decrypt": icon_name = "decryption"
		"taskmanager": icon_name = "resources"
	
	var path = "res://assets/icons/" + icon_name + ".png"
	if ResourceLoader.exists(path):
		%IconRect.texture = load(path)
	
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
		# Highlight if focused
		if DesktopWindowManager.focused_window == target_window:
			modulate = Color(1.2, 1.2, 1.5) # Slight glow
		else:
			modulate = Color.WHITE
	else:
		queue_free()
