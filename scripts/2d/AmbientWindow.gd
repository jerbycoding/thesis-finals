extends PanelContainer

@onready var title_label = $VBox/Header/HBox/Title
@onready var content_area = %ContentArea

func setup(app_name: String, window_title: String):
	if title_label:
		title_label.text = window_title
	
	# LOAD ACTUAL APP UI (Visuals Only)
	if DesktopWindowManager and DesktopWindowManager.app_configs.has(app_name):
		var config = DesktopWindowManager.app_configs[app_name]
		if ResourceLoader.exists(config.scene_path):
			var app_scene = load(config.scene_path)
			var app_instance = app_scene.instantiate()
			
			# Strip logic and prevent interaction
			app_instance.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_freeze_node_recursive(app_instance)
			
			content_area.add_child(app_instance)
			
			# Ensure it fills the area
			if app_instance is Control:
				app_instance.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _freeze_node_recursive(node: Node):
	# Stop all processing and input
	node.process_mode = Node.PROCESS_MODE_DISABLED
	
	# Mute any audio nodes
	if node is AudioStreamPlayer or node is AudioStreamPlayer2D or node is AudioStreamPlayer3D:
		node.volume_db = -80
	
	# Recursively freeze children
	for child in node.get_children():
		_freeze_node_recursive(child)

