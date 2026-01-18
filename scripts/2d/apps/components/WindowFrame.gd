# WindowFrame.gd
extends Control

var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var window_id: String = ""
var window_title: String = "Window"
var content_scene: PackedScene = null

@onready var title_bar: HBoxContainer = $Border/VBoxContainer/TitleBar
@onready var title_label: Label = $Border/VBoxContainer/TitleBar/TitleLabel
@onready var close_button: Button = $Border/VBoxContainer/TitleBar/CloseButton
@onready var content_container: MarginContainer = $Border/VBoxContainer/ContentContainer

func _ready():
	print("DEBUG: WindowFrame _ready() called")
	
	# Check if nodes exist
	print("  - title_bar exists: ", title_bar != null)
	print("  - title_label exists: ", title_label != null)
	print("  - close_button exists: ", close_button != null)
	print("  - content_container exists: ", content_container != null)
	
	# Force visibility
	visible = true
	modulate = Color.WHITE
	
	# CRITICAL: Enable clipping to prevent content overflow
	clip_contents = true
	if content_container:
		content_container.clip_contents = true
	
	# Set title if label exists
	if title_label:
		title_label.text = window_title
		print("  - Title set to: ", window_title)
	else:
		print("ERROR: title_label is null!")
		# Try alternate path (in case structure is different)
		if has_node("Border/TitleBar/TitleLabel"):
			get_node("Border/TitleBar/TitleLabel").text = window_title
			print("  - Used alternate path for title")
	
	# Connect signals
	if close_button:
		close_button.pressed.connect(_on_close_pressed)
	else:
		print("ERROR: close_button is null!")
	
	# Make window draggable via title bar
	if title_bar:
		title_bar.gui_input.connect(_on_title_bar_gui_input)
		title_bar.mouse_filter = Control.MOUSE_FILTER_STOP
	else:
		print("ERROR: title_bar is null!")
	
	# Focus when clicked anywhere (using Border to ensure it catches input)
	var border = get_node_or_null("Border")
	if border:
		border.gui_input.connect(_on_window_gui_input)
	
	print("DEBUG: Window setup complete at position: ", position)

const SNAP_MARGIN: float = 20.0

func _on_title_bar_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# Start dragging
			is_dragging = true
			bring_to_front()
			EventBus.window_focused.emit(self)
			get_viewport().set_input_as_handled()
		else:
			# Stop dragging
			is_dragging = false
			_apply_snapping()
	elif event is InputEventMouseMotion and is_dragging:
		# Drag window using relative motion
		global_position += event.relative
		get_viewport().set_input_as_handled()

func _apply_snapping():
	var viewport_rect = get_viewport().get_visible_rect()
	var new_pos = global_position
	
	# Snap to Left
	if abs(new_pos.x) < SNAP_MARGIN:
		new_pos.x = 0
	
	# Snap to Top
	if abs(new_pos.y) < SNAP_MARGIN:
		new_pos.y = 0
		
	# Snap to Right
	if abs(new_pos.x + size.x - viewport_rect.size.x) < SNAP_MARGIN:
		new_pos.x = viewport_rect.size.x - size.x
		
	# Snap to Bottom (considering taskbar area approx 40px)
	if abs(new_pos.y + size.y - (viewport_rect.size.y - 40)) < SNAP_MARGIN:
		new_pos.y = viewport_rect.size.y - 40 - size.y
	elif abs(new_pos.y + size.y - viewport_rect.size.y) < SNAP_MARGIN:
		new_pos.y = viewport_rect.size.y - size.y
		
	if new_pos != global_position:
		var tween = create_tween()
		tween.tween_property(self, "global_position", new_pos, 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_window_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			bring_to_front()
			EventBus.window_focused.emit(self)

func _on_close_pressed():
	print("DEBUG: Closing window: ", window_id)
	EventBus.window_closed.emit(self)
	queue_free()

func load_content(scene: PackedScene):
	print("DEBUG: load_content() called with scene: ", scene)
	
	if not scene:
		print("ERROR: load_content called with null scene!")
		return
	
	if not content_container:
		print("ERROR: content_container is null! This should not happen if @onready is correct.")
		return
	
	print("DEBUG: content_container found: ", content_container.name)
	
	# Clear existing content
	for child in content_container.get_children():
		child.queue_free()
	
	# Instantiate and add new content
	print("DEBUG: Instantiating scene...")
	var content = scene.instantiate()
	if not content:
		print("ERROR: Failed to instantiate scene!")
		return
		
	print("DEBUG: Scene instantiated: ", content.name, " type: ", content.get_class())
	content_container.add_child(content)
	print("DEBUG: Content added to container")
	
	# Ensure content is visible and fills container
	content.visible = true
	content.modulate = Color.WHITE
	
	# Make sure content expands to fill the container
	if content is Control:
		content.set_anchors_preset(Control.PRESET_FULL_RECT)
		content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		content.size_flags_vertical = Control.SIZE_EXPAND_FILL
		# CRITICAL: Enable clipping on content to prevent overflow
		content.clip_contents = true
		print("DEBUG: Content anchors set to fill container")
	
	# Wait for content to be fully initialized
	await get_tree().process_frame
	
	# Force layout update
	if content is Control:
		content.reset_size()
	
	# --- Dynamically adjust WindowFrame size to fit content ---
	_resize_to_fit_content(content)

func _resize_to_fit_content(content: Node):
	"""Calculate and apply the proper window size based on content"""
	
	# Get minimum size of the loaded content
	var content_min_size = Vector2.ZERO
	if content is Control:
		content_min_size = content.custom_minimum_size
		print("DEBUG: Content custom_minimum_size: ", content_min_size)
		
		# If content doesn't have custom_minimum_size, try to get its actual size
		if content_min_size == Vector2.ZERO:
			await get_tree().process_frame
			await get_tree().process_frame
			content_min_size = content.size
			print("DEBUG: Using content.size instead: ", content_min_size)
	
	# If still no size, use a default
	if content_min_size == Vector2.ZERO:
		content_min_size = Vector2(600, 500)
		print("DEBUG: Using fallback size: ", content_min_size)
	
	# Get Border panel
	var border_panel = $Border
	
	# Calculate title bar height
	var title_bar_height = 30.0  # Default
	if title_bar and title_bar.custom_minimum_size.y > 0:
		title_bar_height = title_bar.custom_minimum_size.y
	
	# Get margins from content_container theme overrides
	var margin_left = 8.0  # Default
	var margin_right = 8.0
	var margin_top = 8.0
	var margin_bottom = 8.0
	
	# Check theme_override_constants (this is what we set in the .tscn)
	if content_container.has_theme_constant_override("margin_left"):
		margin_left = content_container.get_theme_constant("margin_left")
	if content_container.has_theme_constant_override("margin_right"):
		margin_right = content_container.get_theme_constant("margin_right")
	if content_container.has_theme_constant_override("margin_top"):
		margin_top = content_container.get_theme_constant("margin_top")
	if content_container.has_theme_constant_override("margin_bottom"):
		margin_bottom = content_container.get_theme_constant("margin_bottom")
	
	print("DEBUG: Margins - L:", margin_left, " R:", margin_right, " T:", margin_top, " B:", margin_bottom)
	
	# Get border style info
	var border_width = 2.0  # We set this to 2 in the StyleBox
	
	# Calculate total required size
	# Width = content width + margins + border widths (both sides)
	var required_width = content_min_size.x + \
						 margin_left + margin_right + \
						 (border_width * 2)
	
	# Height = content height + title bar + margins + border widths (top + bottom)
	var required_height = content_min_size.y + \
						  title_bar_height + \
						  margin_top + margin_bottom + \
						  (border_width * 2)
	
	# Ensure we don't go below WindowFrame's own minimum
	required_width = max(custom_minimum_size.x, required_width)
	required_height = max(custom_minimum_size.y, required_height)
	
	print("DEBUG: Calculated required size - W:", required_width, " H:", required_height)
	
	# Apply the size
	size = Vector2(required_width, required_height)
	custom_minimum_size = size
	
	# Force immediate layout update (Godot 4)
	reset_size()
	
	print("DEBUG: WindowFrame resized to: ", size)
	print("DEBUG: Border size: ", $Border.size)

func set_title(title: String):
	window_title = title
	# Update immediately if already ready
	if is_node_ready() and title_label:
		title_label.text = title
		print("DEBUG: Window title set to: ", title)

func set_window_id(id: String):
	window_id = id
	print("DEBUG: Window ID set: ", id)

func bring_to_front():
	# Use a higher z_index each time to ensure proper ordering
	var parent_node = get_parent()
	if parent_node:
		var max_z = 0
		for sibling in parent_node.get_children():
			if sibling is Control and sibling != self:
				max_z = max(max_z, sibling.z_index)
		z_index = max_z + 1
	else:
		z_index = 100
	print("DEBUG: Window brought to front, z_index: ", z_index)
