# PauseMenu.gd
extends Control

@onready var resume_button: Button = %ResumeButton
@onready var options_button: Button = %OptionsButton
@onready var settings_section: VBoxContainer = %SettingsSection
@onready var master_slider: HSlider = %MasterSlider
@onready var quit_button: Button = %QuitButton

func _ready():
	hide()
	resume_button.pressed.connect(_on_resume_pressed)
	options_button.pressed.connect(_on_options_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Setup Slider
	if ConfigManager:
		master_slider.value = ConfigManager.settings.audio.master_volume
		master_slider.value_changed.connect(_on_master_volume_changed)
	
	# Connect hover sounds
	for btn in [resume_button, options_button, quit_button]:
		btn.mouse_entered.connect(func(): if AudioManager: AudioManager.play_ui_hover())

func _on_options_pressed():
	settings_section.visible = !settings_section.visible
	if AudioManager: AudioManager.play_ui_click()

func _on_master_volume_changed(value: float):
	if ConfigManager:
		ConfigManager.set_setting("audio", "master_volume", value)

func _on_resume_pressed():
	if GameState:
		GameState.set_paused(false)

func _on_quit_pressed():
	if GameState:
		GameState.set_paused(false)
	
	# Safety: Ensure NarrativeDirector is deactivated
	if NarrativeDirector:
		NarrativeDirector.stop_shift()
	
	# Fix: Ensure mouse is visible at Title Screen
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if TransitionManager:
		TransitionManager.change_scene_to("res://scenes/3d/MainMenu3D.tscn")

func show_menu():
	show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# Animate in
	modulate.a = 0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.2)

func hide_menu():
	hide()
	if GameState and GameState.is_in_3d_mode():
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif GameState and GameState.is_in_2d_mode():
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
