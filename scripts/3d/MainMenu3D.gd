extends Node3D

@onready var camera: Camera3D = $Camera3D
@onready var computer_set: Node3D = $Prop_ComputerSet
@onready var monitor: Node3D = $Prop_ComputerSet/Prop_Monitor
@onready var input_bridge: MonitorInputBridge = $Prop_ComputerSet/Prop_Monitor/InputBridge

var terminal_menu: Control
var breathing_tween: Tween

# PARALLAX CONFIG
@export var parallax_intensity: float = 0.05
@export var smooth_speed: float = 2.0
var base_camera_pos: Vector3
var base_camera_rot: Vector3
var is_transitioning: bool = false

func _ready():
	# Enforce UI mode for menu interaction
	if GameState:
		GameState.set_mode(GameState.GameMode.MODE_UI_ONLY)
	
	# Store base transform for parallax
	base_camera_pos = camera.position
	base_camera_rot = camera.rotation
	
	# Activate the monitor screen
	if monitor.has_method("set_screen_active"):
		monitor.set_screen_active(true)
	
	# SETUP TERMINAL: Instance it and add it to the monitor's viewport
	var viewport = monitor.get_node("SubViewport")
	if viewport:
		# Hide default desktop if it exists
		for child in viewport.get_children():
			if child.name == "AmbientDesktop":
				child.visible = false
		
		# Instance the Terminal
		var terminal_scene = load("res://scenes/ui/TerminalMenu2D.tscn")
		if terminal_scene:
			terminal_menu = terminal_scene.instantiate()
			viewport.add_child(terminal_menu)
			terminal_menu.action_selected.connect(_on_terminal_action)
	
	# Activate Input Bridge for mouse interaction
	if input_bridge:
		input_bridge.activate()
	
	# Connect to save system feedback
	EventBus.game_loaded.connect(_on_game_loaded)

func _on_game_loaded():
	if is_transitioning: return
	is_transitioning = true
	
	if TransitionManager:
		var shift_to_load = SaveSystem.loaded_shift_id if SaveSystem else ""
		TransitionManager.play_secure_login("res://scenes/SOC_Office.tscn", shift_to_load)

func _input(event):
	# Forward mouse clicks to the input bridge
	if input_bridge and (event is InputEventMouseButton or event is InputEventMouseMotion):
		if event is InputEventMouseButton:
			input_bridge.handle_mouse_button(event)
		# Motion is handled by the bridge's _process if active
	
	# Forward keys as well
	if input_bridge and event is InputEventKey:
		input_bridge.handle_key(event)

func _process(delta):
	if is_transitioning: return
	
	# INTERACTIVE PARALLAX LOGIC
	var mouse_pos = get_viewport().get_mouse_position()
	var screen_size = get_viewport().get_visible_rect().size
	
	# Calculate normalized mouse offset (-0.5 to 0.5)
	var offset = Vector2(
		(mouse_pos.x / screen_size.x) - 0.5,
		(mouse_pos.y / screen_size.y) - 0.5
	)
	
	# Target position/rotation based on mouse
	var target_pos = base_camera_pos + Vector3(offset.x * 0.1, -offset.y * 0.05, 0)
	var target_rot = base_camera_rot + Vector3(-offset.y * parallax_intensity, -offset.x * parallax_intensity, 0)
	
	# Smoothly interpolate
	camera.position = camera.position.lerp(target_pos, delta * smooth_speed)
	camera.rotation = camera.rotation.lerp(target_rot, delta * smooth_speed)

func _on_terminal_action(action_id: String):
	match action_id:
		"start":
			_start_shift_sequence()
		"continue":
			if SaveSystem:
				SaveSystem.load_game()
		"training":
			_start_training_sequence()
		"quit":
			_start_quit_sequence()

func _start_shift_sequence():
	if is_transitioning: return
	is_transitioning = true
	
	# 1. Start the Parallel Transition
	if SaveSystem:
		SaveSystem.new_game_setup()
	
	if TransitionManager:
		TransitionManager.play_secure_login("res://scenes/3d/BriefingRoom.tscn", "shift_monday")
	
	# 2. "LAZY LEAN" Animation
	# Subtle move forward, keeping props visible
	var lean_pos = camera.global_position + (camera.global_transform.basis.z * -0.2)
	var target_rot = Vector3(0, 0, 0) # Center the view
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(camera, "global_position", lean_pos, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(camera, "global_rotation", target_rot, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(camera, "fov", 65.0, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	# Subtle background blur (less intense than full zoom)
	var env = $WorldEnvironment.environment
	if env:
		env.set("dof_blur_far_enabled", true)
		tween.tween_method(func(val): env.set("dof_blur_far_distance", val), 10.0, 2.0, 1.5)

func _start_training_sequence():
	if is_transitioning: return
	is_transitioning = true
	
	if SaveSystem:
		SaveSystem.new_game_setup()
	
	if TransitionManager:
		TransitionManager.play_secure_login("res://scenes/3d/BriefingRoom.tscn", "shift_tutorial")
	
	# 2. "LAZY LEAN" Animation
	var lean_pos = camera.global_position + (camera.global_transform.basis.z * -0.2)
	var target_rot = Vector3(0, 0, 0)
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(camera, "global_position", lean_pos, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(camera, "global_rotation", target_rot, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(camera, "fov", 65.0, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _start_quit_sequence():
	is_transitioning = true
	
	# Phase 1: Lights Out & Power Surge
	var tween = create_tween().set_parallel(true)
	
	var monitor_light = get_node_or_null("OmniLight3D")
	var bezel_light = get_node_or_null("MonitorBezelLight")
	var desk_lamp = get_node_or_null("Prop_DeskLamp/SpotLight3D")
	
	if monitor_light: tween.tween_property(monitor_light, "light_energy", 0.0, 0.4)
	if bezel_light: tween.tween_property(bezel_light, "light_energy", 0.0, 0.4)
	if desk_lamp: tween.tween_property(desk_lamp, "light_energy", 0.0, 0.4)
	
	# Intense screen flicker surge
	if monitor and monitor.has_node("Screen_Mesh"):
		var mesh = monitor.get_node("Screen_Mesh")
		var mat = mesh.material_override
		if mat is ShaderMaterial:
			tween.tween_method(func(val): mat.set_shader_parameter("screen_flicker", val), 0.01, 0.8, 0.4)

	await tween.finished
	
	# Phase 2: Screen Collapse
	if monitor and monitor.has_node("Screen_Mesh"):
		var mesh = monitor.get_node("Screen_Mesh")
		mesh.visible = false
	
	if AudioManager:
		AudioManager.play_terminal_beep(-5.0)
	
	# Phase 3: Fade to Black and Exit
	if TransitionManager and TransitionManager.overlay_instance:
		TransitionManager.overlay_instance.fade_in()
		await TransitionManager.overlay_instance.fade_finished
	
	await get_tree().create_timer(0.5).timeout
	get_tree().quit()
