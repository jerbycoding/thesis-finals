extends Control

@onready var start_button: Button = %StartButton
@onready var training_button: Button = %TrainingButton
@onready var continue_button: Button = %ContinueButton
@onready var quit_button: Button = %QuitButton
@onready var main_container: VBoxContainer = %MainContainer
@onready var title_label: Label = %TitleLabel

func _ready():
	# Initial state for animation
	main_container.modulate.a = 0
	main_container.position.y += 20
	
	# Connect signals
	start_button.pressed.connect(_on_start_button_pressed)
	training_button.pressed.connect(_on_training_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Connect hover sounds
	for btn in [start_button, training_button, continue_button, quit_button]:
		btn.mouse_entered.connect(_on_button_hover)
	
	# Check for save file and update Continue button's visibility
	if SaveSystem and SaveSystem.has_save_file():
		continue_button.visible = true
	else:
		continue_button.visible = false
	
	# When a game is loaded, we need to transition to the main scene
	EventBus.game_loaded.connect(_on_game_loaded)
	
	# Start intro animation
	_animate_intro()

func _animate_intro():
	var tween = create_tween().set_parallel(true)
	tween.tween_property(main_container, "modulate:a", 1.0, 1.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(main_container, "position:y", main_container.position.y - 20, 1.0).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _on_button_hover():
	if AudioManager:
		AudioManager.play_sfx(AudioManager.SFX.button_click)

func _on_start_button_pressed():
	if AudioManager:
		AudioManager.play_sfx(AudioManager.SFX.notification_info)
	
	var tween = create_tween()
	tween.tween_property(main_container, "modulate:a", 0.0, 0.5)
	await tween.finished
	
	if NarrativeDirector:
		NarrativeDirector.start_briefing()

func _on_training_pressed():
	if AudioManager:
		AudioManager.play_sfx(AudioManager.SFX.notification_info)
	
	var tween = create_tween()
	tween.tween_property(main_container, "modulate:a", 0.0, 0.5)
	await tween.finished
	
	# Manually start the tutorial intro dialogue
	var res = load("res://resources/dialogue/tutorial_intro.tres")
	if res:
		DialogueManager.start_dialogue(null, res)

func _on_continue_pressed():
	if AudioManager:
		AudioManager.play_sfx(AudioManager.SFX.notification_success)
	
	if SaveSystem:
		SaveSystem.load_game()

func _on_quit_pressed():
	if AudioManager:
		AudioManager.play_sfx(AudioManager.SFX.button_click)
	
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	await tween.finished
	get_tree().quit()

func _on_game_loaded():
	if TransitionManager:
		TransitionManager.change_scene_to("res://scenes/SOC_Office.tscn")
