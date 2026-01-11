# FPSManager.gd
# A persistent overlay to track performance.
extends CanvasLayer

var label: Label
var update_timer: float = 0.0

func _ready():
	# Ensure this draws over everything (windows are layer 10, notifications 100)
	layer = 120
	
	# Create the label programmatically to keep it simple
	label = Label.new()
	add_child(label)
	
	# Position in top-left, slightly offset
	label.position = Vector2(10, 10)
	
	# Cyber-style theme
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color(0.2, 1.0, 0.2, 0.8)) # Cyber Green
	
	# Add a small shadow/outline for readability
	label.add_theme_constant_override("outline_size", 4)
	label.add_theme_color_override("font_outline_color", Color.BLACK)

func _process(delta):
	update_timer += delta
	
	# Update text every 0.25 seconds to prevent flickering
	if update_timer >= 0.25:
		var fps = Engine.get_frames_per_second()
		label.text = "SYS_PERF: %d FPS" % fps
		
		# Color coding based on performance
		if fps >= 60:
			label.add_theme_color_override("font_color", Color(0.2, 1.0, 0.2, 0.8)) # Green
		elif fps >= 30:
			label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.2, 0.8)) # Yellow
		else:
			label.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2, 0.8)) # Red
			
		update_timer = 0.0

func toggle_visibility():
	visible = !visible
