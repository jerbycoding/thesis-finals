extends Node

var transition_overlay = preload("res://scenes/ui/TransitionOverlay.tscn")
var overlay_instance = null
var is_transitioning = false

func _ready():
	overlay_instance = transition_overlay.instantiate()
	get_tree().root.call_deferred("add_child", overlay_instance)
	overlay_instance.hide()
	print("TransitionManager ready")

func enter_desktop_mode(computer_node):
	if is_transitioning:
		print("Transition blocked: already transitioning")
		return

	is_transitioning = true
	print("ENTER DESKTOP: Step 1 - Trigger Camera Sit")
	EventBus.transition_started.emit()

	# Trigger Player Camera Animation
	var player = get_tree().root.find_child("Player3D", true, false)
	if player and player.has_method("sit_down"):
		var anchor = computer_node.get_node_or_null("ViewAnchor")
		if anchor:
			player.sit_down(anchor)
		else:
			push_warning("TransitionManager: No ViewAnchor found on computer!")
	
	# Wait for sit animation (0.8s)
	await get_tree().create_timer(0.8).timeout

	# Set mode (enables mouse)
	GameState.set_mode(GameState.GameMode.MODE_2D)
	GameState.current_computer = computer_node

	print("ENTER DESKTOP: Step 2 - Activate desktop")
	
	# Check for existing instance
	if GameState.desktop_instance and is_instance_valid(GameState.desktop_instance):
		print("Resuming existing desktop session...")
		GameState.desktop_instance.visible = true
		GameState.desktop_instance.process_mode = Node.PROCESS_MODE_INHERIT
		
		# Optional: Play wakeup sound or effect?
	else:
		# Create new instance if none exists
		print("Initializing new desktop session...")
		var desktop_scene = load("res://scenes/2d/ComputerDesktop.tscn")
		GameState.desktop_instance = desktop_scene.instantiate()
		get_tree().root.add_child(GameState.desktop_instance)

	print("ENTER DESKTOP: Complete")
	is_transitioning = false
	EventBus.transition_completed.emit()
	
	if AudioManager:
		AudioManager.play_music(AudioManager.SFX.music_standard, -10.0) 

func exit_desktop_mode():
	if is_transitioning:
		print("Exit blocked: already transitioning")
		return

	if AudioManager:
		AudioManager.stop_music()

	is_transitioning = true
	print("EXIT DESKTOP: Step 1 - Hide Windows")
	EventBus.transition_started.emit()

	# Hide desktop instead of destroying it to preserve state (windows, text, etc.)
	if GameState.desktop_instance and is_instance_valid(GameState.desktop_instance):
		GameState.desktop_instance.visible = false
		GameState.desktop_instance.process_mode = Node.PROCESS_MODE_DISABLED
	else:
		GameState.desktop_instance = null

	# Return to 3D mode (Triggers Player stand_up() via signal)
	GameState.set_mode(GameState.GameMode.MODE_3D)

	# Wait for stand animation (0.8s)
	await get_tree().create_timer(0.8).timeout

	print("EXIT DESKTOP: Complete")
	is_transitioning = false
	EventBus.transition_completed.emit()

func change_scene_to(path: String, narrative_to_start_after: String = "", title_card: String = ""):
	if not overlay_instance:
		print(">>> TRANSITION ERROR: Overlay instance is null!")
		return
	if is_transitioning:
		print(">>> TRANSITION BLOCKED: A transition is already in progress. New request for '", path, "' was ignored.")
		return
	
	print(">>> TRANSITION START: To '", path, "'")
	is_transitioning = true
	EventBus.transition_started.emit()
	
	# CLEANUP: Explicitly destroy the persistent desktop before changing scenes
	if GameState.desktop_instance and is_instance_valid(GameState.desktop_instance):
		print(">>> TRANSITION CLEANUP: Destroying persistent desktop session.")
		GameState.desktop_instance.queue_free()
		GameState.desktop_instance = null
	
	# CLEANUP SIGNAL: Let persistent UIs (like Desktop) kill themselves
	EventBus.prepare_for_scene_change.emit()
	
	# Force mode reset to 3D for the next scene
	GameState.set_mode(GameState.GameMode.MODE_3D)

	# TITLE CARD LOGIC
	if not title_card.is_empty():
		overlay_instance.set_title_card(title_card)
	else:
		overlay_instance.set_title_card("")

	overlay_instance.fade_in()
	print(">>> TRANSITION FADE_IN: Waiting for fade-in to complete...")
	await overlay_instance.fade_finished
	print(">>> TRANSITION FADE_IN: Complete.")
	
	print(">>> TRANSITION SCENE_CHANGE: Changing scene in tree to '", path, "'...")
	get_tree().change_scene_to_file(path)
	
	await get_tree().create_timer(0.1).timeout
	print(">>> TRANSITION SCENE_CHANGE: Scene tree changed.")
	
	overlay_instance.fade_out()
	print(">>> TRANSITION FADE_OUT: Waiting for fade-out to complete...")
	await overlay_instance.fade_finished
	print(">>> TRANSITION FADE_OUT: Complete.")
	
	is_transitioning = false
	EventBus.transition_completed.emit()
	print(">>> TRANSITION END: To '", path, "'")
	
	# After everything is done, check if there's a follow-up narrative action
	if not narrative_to_start_after.is_empty():
		if NarrativeDirector:
			print(">>> TRANSITION ACTION: Starting narrative '", narrative_to_start_after, "' after scene change.")
			NarrativeDirector.start_shift(narrative_to_start_after)
		else:
			push_error("TransitionManager: Cannot start narrative, NarrativeDirector not found!")

func play_secure_login(target_path: String, narrative: String = ""):
	if is_transitioning: return
	is_transitioning = true
	
	overlay_instance.show()
	var login_ui = overlay_instance.get_node("%LoginContainer")
	var auth_label = overlay_instance.get_node("%AuthLabel")
	var progress = overlay_instance.get_node("%InitProgressBar")
	
	login_ui.visible = true
	progress.value = 0
	overlay_instance.fade_in()
	await overlay_instance.fade_finished
	
	# HEAVY LOADING SEQUENCE
	var steps = [
		{"text": "INITIALIZING SECURE KERNEL...", "val": 15.0, "wait": 0.8},
		{"text": "MOUNTING ENCRYPTED VOLUMES...", "val": 45.0, "wait": 0.5},
		{"text": "ESTABLISHING SECURE VPN TUNNEL...", "val": 52.0, "wait": 1.2}, # Long pause for 'network' feel
		{"text": "SYNCING SIEM LOG DATABASE...", "val": 85.0, "wait": 0.7},
		{"text": "ENFORCING ZERO-TRUST PROTOCOLS...", "val": 98.0, "wait": 0.4},
		{"text": "BIOMETRIC MATCH CONFIRMED. ACCESS GRANTED.", "val": 100.0, "wait": 0.8}
	]
	
	for step in steps:
		auth_label.text = step.text
		auth_label.modulate = Color.WHITE
		
		# Rapid snap for the bar
		var tween = create_tween()
		tween.tween_property(progress, "value", step.val, 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		
		await get_tree().create_timer(step.wait).timeout
		
		# Feedback: Flash text green to show step is done
		auth_label.text = step.text + " [ OK ]"
		auth_label.modulate = Color.GREEN
		if AudioManager: AudioManager.play_terminal_beep(-10.0)
		await get_tree().create_timer(0.15).timeout
	
	# Scene Change
	get_tree().change_scene_to_file(target_path)
	await get_tree().create_timer(0.3).timeout
	
	login_ui.visible = false
	overlay_instance.fade_out()
	await overlay_instance.fade_finished
	
	is_transitioning = false
	
	# Let NarrativeDirector handle what happens next (Debt #5 Fix)
	if not narrative.is_empty():
		if NarrativeDirector:
			NarrativeDirector.prepare_shift(narrative)
