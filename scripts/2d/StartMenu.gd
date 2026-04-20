extends PanelContainer

signal app_selected(app_id: String)

@onready var app_grid = %AppGrid

var app_button_scene = preload("res://scenes/2d/StartMenuAppButton.tscn")

func _ready():
	visible = false
	_populate_apps()
	
	if EventBus:
		EventBus.role_switched.connect(func(_new_role): _populate_apps())
	
	# High-Clarity: Standardize headers to white
	var headers = [get_node_or_null("Margin/VBox/PinnedSection/Label"), get_node_or_null("Margin/VBox/AllAppsSection/Label")]
	for h in headers:
		if h: h.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	
	# Profile pass
	var role_label = get_node_or_null("Margin/VBox/Footer/HBox/VBox/RoleLabel")
	if role_label: role_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.6))
	
	# Focus logic for auto-dismiss
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_exited.connect(_on_focus_lost)

func _input(event):
	if visible and event is InputEventMouseButton and event.pressed:
		# If we click outside the menu area, close it
		if not get_global_rect().has_point(event.global_position):
			visible = false

func _on_focus_lost():
	visible = false

func toggle():
	visible = !visible
	if visible:
		# Grab focus to detect when we click away
		grab_focus()
		
		# Animation: Slide Up
		var viewport_h = get_viewport_rect().size.y
		var start_pos = Vector2(position.x, viewport_h)
		var end_pos = Vector2(position.x, viewport_h - size.y - 58) # Offset for new taskbar height + gap
		position = start_pos
		var tween = create_tween()
		tween.tween_property(self, "position", end_pos, 0.25).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _populate_apps():
	if not DesktopWindowManager: return
	
	# Clear
	for child in app_grid.get_children(): child.queue_free()
		
	# Get filtered and sorted apps
	var apps = DesktopWindowManager.get_apps_for_current_role()
	apps.sort_custom(func(a, b): return a.title < b.title)
	
	for config in apps:
		# Create grid button
		var btn = _create_app_button(config.app_id, config.title)
		app_grid.add_child(btn)

func _create_app_button(app_id: String, title: String) -> Control:
	var btn = app_button_scene.instantiate()
	
	# Connect to setup AFTER instantiation
	btn.pressed.connect(func():
		app_selected.emit(app_id)
		visible = false
	)
	
	# Call setup (we can't use await here easily, so we rely on script setup)
	# Since _ready hasn't run yet, we might need to call it manually or wait a frame
	# but we'll use a safer approach in the script itself.
	btn.setup(app_id, title)
	
	return btn

func set_app_glow(app_id: String, active: bool):
	# Search in unified Grid
	for child in app_grid.get_children():
		if "app_id" in child and child.app_id == app_id:
			if child.has_method("set_glow"):
				child.set_glow(active)
				return # Found it
