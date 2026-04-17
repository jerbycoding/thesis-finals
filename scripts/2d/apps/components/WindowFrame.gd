# WindowFrame.gd
extends Control

var is_dragging: bool = false
var is_resizing: bool = false
var is_minimized: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var window_id: String = ""
var window_title: String = "Window"
var content_scene: PackedScene = null
var content_instance: Control = null

@onready var title_bar: HBoxContainer = $Border/VBoxContainer/TitleBarPanel/TitleBar
@onready var title_label: Label = $Border/VBoxContainer/TitleBarPanel/TitleBar/TitleLabel
@onready var minimize_button: Button = %MinimizeButton
@onready var close_button: Button = $Border/VBoxContainer/TitleBarPanel/TitleBar/CloseButton
@onready var content_container: MarginContainer = $Border/VBoxContainer/ContentContainer
@onready var resize_handle: Control = %ResizeHandle

func _ready():
	# Force visibility
	visible = true
	modulate = Color.WHITE
	
	# CRITICAL: Enable clipping to prevent content overflow
	clip_contents = true
	if content_container:
		content_container.clip_contents = true
	
	if title_label:
		title_label.text = window_title
	
	if close_button:
		close_button.pressed.connect(_on_close_pressed)
	
	if minimize_button:
		minimize_button.pressed.connect(toggle_minimize)
	
	if title_bar:
		title_bar.gui_input.connect(_on_title_bar_gui_input)
		title_bar.mouse_filter = Control.MOUSE_FILTER_STOP
	
	if resize_handle:
		resize_handle.gui_input.connect(_on_resize_handle_gui_input)
		resize_handle.mouse_filter = Control.MOUSE_FILTER_STOP
	
	var border = get_node_or_null("Border")
	if border:
		border.gui_input.connect(_on_window_gui_input)

func toggle_minimize():
	is_minimized = !is_minimized
	visible = !is_minimized
	if not is_minimized:
		bring_to_front()
		EventBus.window_focused.emit(self)

func _on_resize_handle_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_resizing = true
			bring_to_front()
			EventBus.window_focused.emit(self)
			get_viewport().set_input_as_handled()
		else:
			is_resizing = false
	elif event is InputEventMouseMotion and is_resizing:
		var parent_rect = get_viewport_rect()
		if get_parent() is Control:
			parent_rect = get_parent().get_global_rect()
			
		var min_size = custom_minimum_size
		if min_size.x < 300: min_size.x = 300
		if min_size.y < 200: min_size.y = 200
		
		# Calculate new size based on mouse delta
		var new_size = size + event.relative
		
		# Clamp size to reasonable limits
		new_size.x = clamp(new_size.x, min_size.x, parent_rect.size.x - position.x)
		new_size.y = clamp(new_size.y, min_size.y, parent_rect.size.y - position.y)
		
		size = new_size
		get_viewport().set_input_as_handled()

func _on_title_bar_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			bring_to_front()
			EventBus.window_focused.emit(self)
			get_viewport().set_input_as_handled()
		else:
			is_dragging = false
			_apply_snapping()
	elif event is InputEventMouseMotion and is_dragging:
		var parent_rect = get_viewport_rect()
		if get_parent() is Control:
			parent_rect = get_parent().get_global_rect()
			
		var new_pos = global_position + event.relative
		
		# Real-time clamping during drag
		new_pos.x = clamp(new_pos.x, parent_rect.position.x, parent_rect.position.x + parent_rect.size.x - size.x)
		new_pos.y = clamp(new_pos.y, parent_rect.position.y, parent_rect.position.y + parent_rect.size.y - size.y)
		
		global_position = new_pos
		get_viewport().set_input_as_handled()

const SNAP_MARGIN: float = 20.0

func _apply_snapping():
	# Visual snapping only (magnetic edges)
	var parent_rect = get_viewport_rect()
	if get_parent() is Control:
		parent_rect = get_parent().get_global_rect()
	
	var new_pos = global_position
	
	# Snap to Left/Right
	if abs(new_pos.x - parent_rect.position.x) < SNAP_MARGIN: new_pos.x = parent_rect.position.x
	elif abs(new_pos.x + size.x - (parent_rect.position.x + parent_rect.size.x)) < SNAP_MARGIN:
		new_pos.x = parent_rect.position.x + parent_rect.size.x - size.x
		
	# Snap to Top/Bottom
	if abs(new_pos.y - parent_rect.position.y) < SNAP_MARGIN: new_pos.y = parent_rect.position.y
	elif abs(new_pos.y + size.y - (parent_rect.position.y + parent_rect.size.y)) < SNAP_MARGIN:
		new_pos.y = parent_rect.position.y + parent_rect.size.y - size.y
		
	if new_pos != global_position:
		var tween = create_tween()
		tween.tween_property(self, "global_position", new_pos, 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_window_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			bring_to_front()
			EventBus.window_focused.emit(self)

func _on_close_pressed():
	EventBus.window_closed.emit(self)
	queue_free()

func load_content(scene: PackedScene):
	if not scene: return null
	
	for child in content_container.get_children():
		child.queue_free()
	
	content_instance = scene.instantiate()
	content_container.add_child(content_instance)
	
	content_instance.visible = true
	content_instance.modulate = Color.WHITE
	
	if content_instance is Control:
		content_instance.set_anchors_preset(Control.PRESET_FULL_RECT)
		content_instance.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		content_instance.size_flags_vertical = Control.SIZE_EXPAND_FILL
		content_instance.clip_contents = true
		
		if not content_instance.minimum_size_changed.is_connected(_on_content_minimum_size_changed):
			content_instance.minimum_size_changed.connect(_on_content_minimum_size_changed.bind(content_instance))
	
	await get_tree().process_frame
	_resize_to_fit_content(content_instance)
	return content_instance

func _on_content_minimum_size_changed(content: Control):
	_resize_to_fit_content(content)

func _resize_to_fit_content(content: Node):
	if not is_instance_valid(content) or not is_instance_valid(content_container): return
	await get_tree().process_frame
	
	var border = get_node_or_null("Border")
	if border:
		var needed_size = border.get_combined_minimum_size()
		
		# Ensure window is at least as large as the content needs
		var target_size = Vector2(
			max(size.x, needed_size.x),
			max(size.y, needed_size.y)
		)
		
		# Clamp to screen limits
		var screen_size = get_viewport().get_visible_rect().size
		target_size.x = min(target_size.x, screen_size.x * 0.95)
		target_size.y = min(target_size.y, screen_size.y * 0.85)
		
		size = target_size
		custom_minimum_size = needed_size # Only force min size to content needs

func set_title(title: String):
	window_title = title
	if is_node_ready() and title_label:
		title_label.text = title

func bring_to_front():
	var parent_node = get_parent()
	if parent_node:
		var max_z = 0
		for sibling in parent_node.get_children():
			if sibling is Control and sibling != self:
				max_z = max(max_z, sibling.z_index)
		z_index = max_z + 1
	else:
		z_index = 100
