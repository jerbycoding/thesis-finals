extends CanvasLayer

signal fade_finished

@onready var title_label: Label = get_node_or_null("TitleLabel")
@onready var login_container = %LoginContainer

func set_title_card(text: String):
	if title_label:
		title_label.text = text
		title_label.visible = !text.is_empty()

func fade_in():
	show()
	$AnimationPlayer.play("fade_in")
	await $AnimationPlayer.animation_finished
	
	if title_label and title_label.visible:
		await get_tree().create_timer(2.0).timeout

	fade_finished.emit()

func fade_out():
	$AnimationPlayer.play("fade_out")
	await $AnimationPlayer.animation_finished
	hide()
	fade_finished.emit()

# POLISH: Screen Shake Effect
func shake_screen(intensity: float = 10.0, duration: float = 0.2):
	var original_pos = login_container.position
	var tween = create_tween()
	
	for i in range(5):
		var offset = Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
		tween.tween_property(login_container, "position", original_pos + offset, duration / 5.0)
	
	tween.tween_property(login_container, "position", original_pos, duration / 5.0)

# POLISH: Visual Flash
func flash_green():
	var flash = ColorRect.new()
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	flash.color = Color(0, 1, 0, 0.1)
	add_child(flash)
	
	var tween = create_tween()
	tween.tween_property(flash, "modulate:a", 0.0, 0.3)
	await tween.finished
	flash.queue_free()

func flash_black(duration: float = 0.5):
	var flash = ColorRect.new()
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	flash.color = Color.BLACK
	add_child(flash)
	show() # Ensure the layer is visible
	
	var tween = create_tween()
	# Flickering effect
	for i in range(3):
		tween.tween_property(flash, "modulate:a", 0.8, duration / 6.0)
		tween.tween_property(flash, "modulate:a", 0.2, duration / 6.0)
	
	tween.tween_property(flash, "modulate:a", 0.0, 0.1)
	await tween.finished
	flash.queue_free()
	if not $AnimationPlayer.is_playing(): hide()

func play_glitch_static(duration: float = 2.0):
	"""High-entropy flickering static for breach/terminal failure."""
	if title_label:
		title_label.visible = false
		
	var static_overlay = ColorRect.new()
	static_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	static_overlay.color = Color.BLACK
	static_overlay.mouse_filter = Control.MOUSE_FILTER_STOP # Block input
	add_child(static_overlay)
	show()
	
	var label = Label.new()
	label.text = "CRITICAL_CONNECTION_FAILURE\nTERMINATED_BY_AUTHORITIES"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.add_theme_color_override("font_color", Color.RED)
	label.add_theme_font_size_override("font_size", 32)
	static_overlay.add_child(label)
	
	var timer = 0.0
	while timer < duration:
		static_overlay.modulate.a = randf_range(0.7, 1.0)
		label.modulate.v = randf_range(0.5, 2.0) # Flicker brightness
		label.position += Vector2(randf_range(-5, 5), randf_range(-5, 5))
		
		await get_tree().create_timer(0.05).timeout
		timer += 0.05
		label.position = Vector2.ZERO # Reset pos
		
	# Keep it visible but black for a moment before cleanup or scene change
	label.hide()
	static_overlay.modulate.a = 1.0
	static_overlay.color = Color.BLACK

func play_police_strobe(duration: float = 5.0):
	"""Red/Blue flashing overlay to simulate sirens."""
	var strobe = ColorRect.new()
	strobe.set_anchors_preset(Control.PRESET_FULL_RECT)
	strobe.color = Color(1, 0, 0, 0.4) # Start red
	strobe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(strobe)
	show()
	
	var timer = 0.0
	var flash_interval = 0.2
	while timer < duration:
		strobe.color = Color(0, 0, 1, 0.4) if strobe.color.r > 0 else Color(1, 0, 0, 0.4)
		await get_tree().create_timer(flash_interval).timeout
		timer += flash_interval
		
	strobe.queue_free()
func show_booking_report(day: int):
	"""Simple text-based arrest summary."""
	var report = ColorRect.new()
	report.set_anchors_preset(Control.PRESET_FULL_RECT)
	report.color = Color.BLACK
	add_child(report)
	show()

	var label = Label.new()
	# Use Full Rect with center alignment for perfect middle positioning
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 18)
	report.add_child(label)

	var charges = "UNAUTHORIZED_NETWORK_ACCESS\nDATA_EXFILTRATION\nFEDERAL_CONSPIRACY"
	var sentence = str(randi_range(10, 25)) + " YEARS"

	var text = "[ ARREST RECORD: DAY %d ]\n\n" % day
	text += "SUBJECT: OPERATOR_UNKNOWN\n"
	text += "CHARGES: %s\n" % charges
	text += "SENTENCE: %s\n\n" % sentence
	text += "[ CASE CLOSED ]"

	# Typewriter effect
	label.text = ""
	for i in range(text.length()):
		label.text += text[i]
		if i % 3 == 0:
			if AudioManager: AudioManager.play_terminal_beep(-20.0)
			await get_tree().create_timer(0.02).timeout

	await get_tree().create_timer(4.0).timeout

	# CLEANUP: Remove the report overlay before transitioning
	report.queue_free()

	# Transition back to main menu (force transition to clear all state)
	TransitionManager.change_scene_to("res://scenes/3d/MainMenu3D.tscn", "", "", true)