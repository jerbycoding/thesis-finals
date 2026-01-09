extends Control

@onready var start_button: Button = %StartButton

func _ready():
	start_button.pressed.connect(_on_start_button_pressed)
	
func _on_start_button_pressed():
	if AudioManager:
		AudioManager.play_sfx(AudioManager.SFX.button_click)
	
	if NarrativeDirector:
		NarrativeDirector.start_briefing()
