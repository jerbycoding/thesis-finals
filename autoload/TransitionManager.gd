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
	if not overlay_instance or is_transitioning:
		print("Transition blocked: already transitioning or no overlay")
		return


	is_transitioning = true
	print("ENTER DESKTOP: Step 1 - Set mode")
	EventBus.transition_started.emit()

# Set mode FIRST (disables movement and shows mouse)
	GameState.set_mode(GameState.GameMode.MODE_2D)
	GameState.current_computer = computer_node

	print("ENTER DESKTOP: Step 2 - Fade in")
# Ensure overlay is on top
	overlay_instance.z_index = 1000
	overlay_instance.fade_in()

# Wait for fade
	await overlay_instance.fade_finished
	print("ENTER DESKTOP: Step 3 - Fade complete")

# Small extra delay
	await get_tree().create_timer(0.1).timeout

	print("ENTER DESKTOP: Step 4 - Create desktop")
	# Clean up any existing desktop instance first
	if GameState.desktop_instance and is_instance_valid(GameState.desktop_instance):
		print("WARNING: Existing desktop instance found, cleaning up...")
		GameState.desktop_instance.queue_free()
		await get_tree().process_frame  # Wait one frame for cleanup
		GameState.desktop_instance = null
	
	# Create desktop instance
	var desktop_scene = load("res://scenes/2d/ComputerDesktop.tscn")
	GameState.desktop_instance = desktop_scene.instantiate()
	get_tree().root.add_child(GameState.desktop_instance)

	# Show persistent windows
	DesktopWindowManager.show_all_windows()

	print("ENTER DESKTOP: Step 5 - Fade out")
	overlay_instance.fade_out()
	await overlay_instance.fade_finished

	print("ENTER DESKTOP: Complete")
	is_transitioning = false
	EventBus.transition_completed.emit()
	
	if AudioManager:
		AudioManager.play_music(AudioManager.SFX.music_standard, -10.0) # Play ambient desktop music, lower volume

func exit_desktop_mode():
	if not overlay_instance or is_transitioning:
		print("Exit blocked: already transitioning or no overlay")
		return

	if AudioManager:
		AudioManager.stop_music()


	is_transitioning = true
	print("EXIT DESKTOP: Step 1 - Fade in")
	EventBus.transition_started.emit()

# Fade to black
	overlay_instance.fade_in()
	await overlay_instance.fade_finished

	print("EXIT DESKTOP: Step 2 - Hide windows and remove desktop background")
	# Hide persistent windows instead of closing them
	DesktopWindowManager.hide_all_windows()
		
	# Remove desktop background
	if GameState.desktop_instance:
		GameState.desktop_instance.queue_free()
		GameState.desktop_instance = null

# Return to 3D mode
	GameState.set_mode(GameState.GameMode.MODE_3D)

	print("EXIT DESKTOP: Step 3 - Fade out")
	overlay_instance.fade_out()
	await overlay_instance.fade_finished

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
