extends Control

@onready var start_button: Button = %StartButton
@onready var continue_button: Button = %ContinueButton

func _ready():
	# Connect signals
	start_button.pressed.connect(_on_start_button_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	
	# Check for save file and update Continue button's visibility
	if SaveSystem and SaveSystem.has_save_file():
		continue_button.visible = true
	else:
		continue_button.visible = false
	
	# When a game is loaded, we need to transition to the main scene
	if SaveSystem:
		SaveSystem.game_loaded.connect(_on_game_loaded)
	
func _on_start_button_pressed():
	if AudioManager:
		AudioManager.play_sfx(AudioManager.SFX.button_click)
	
	# When starting a new game, we could add logic here to delete an old save file.
	# For now, we just start the briefing.
	
	if NarrativeDirector:
		NarrativeDirector.start_briefing()

func _on_continue_pressed():
	if AudioManager:
		AudioManager.play_sfx(AudioManager.SFX.button_click)
	
	if SaveSystem:
		# load_game() will emit the 'game_loaded' signal on success
		SaveSystem.load_game()

func _on_game_loaded():
	# This function is called via a signal from SaveSystem after data is loaded.
	# Now we can safely transition to the main game scene.
	# We go directly to the office, bypassing the initial briefing.
	if TransitionManager:
		TransitionManager.change_scene_to("res://scenes/SOC_Office.tscn")
