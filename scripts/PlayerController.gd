extends CharacterBody3D

@export var speed = 4.0
@export var sprint_multiplier = 1.5
@export var mouse_sensitivity = 0.002

var camera_rotation = Vector2.ZERO
var interaction_prompt = null
var near_computer = null
var near_npc = null
var movement_enabled = true

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	call_deferred("_setup_interaction_prompt")


# Connect to GameState signals
	if GameState:
		GameState.game_mode_changed.connect(_on_game_mode_changed)
func _setup_interaction_prompt():
	print("Setting up interaction prompt")
	interaction_prompt = preload("res://scenes/ui/InteractionPrompt.tscn").instantiate()
	add_child(interaction_prompt)
	interaction_prompt.hide_prompt()
	print("Prompt instantiated: ", interaction_prompt != null)

func _on_game_mode_changed(mode):
	print("Game mode changed to: ", mode)
	if mode == GameState.GameMode.MODE_2D or mode == GameState.GameMode.MODE_DIALOGUE:
		movement_enabled = false
		print("Movement disabled")
		if interaction_prompt:
			interaction_prompt.hide_prompt()
	else:
		movement_enabled = true
		print("Movement enabled")

func _input(event):
	if not movement_enabled:
		return


	if event is InputEventMouseMotion:
		camera_rotation.y -= event.relative.x * mouse_sensitivity
		camera_rotation.x = clamp(camera_rotation.x - event.relative.y * mouse_sensitivity, -1.5, 1.5)
		
		$CameraPivot.rotation.y = camera_rotation.y
		$CameraPivot/Camera3D.rotation.x = camera_rotation.x
func _physics_process(delta):
	if not movement_enabled:
		return


	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = ($CameraPivot.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	var current_speed = speed
	if Input.is_action_pressed("sprint"):
		current_speed *= sprint_multiplier

	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
func _process(delta):
	if movement_enabled and Input.is_action_just_pressed("interact"):
		if near_computer:
			print("E pressed at computer")
			if TransitionManager:
				TransitionManager.enter_desktop_mode(near_computer)
		elif near_npc:
			print("E pressed at NPC")
			if near_npc.has_method("start_dialogue"):
				near_npc.start_dialogue("default")

func set_near_computer(computer_node, is_near):
	if not movement_enabled:
		return
	
	if is_near:
		near_computer = computer_node
		interaction_prompt.show_prompt()
	else:
		if near_computer == computer_node:
			near_computer = null
		interaction_prompt.hide_prompt()

func set_near_npc(npc_node, is_near):
	if not movement_enabled:
		return
	
	if is_near:
		near_npc = npc_node
		interaction_prompt.show_prompt()
	else:
		if near_npc == npc_node:
			near_npc = null
		interaction_prompt.hide_prompt()
