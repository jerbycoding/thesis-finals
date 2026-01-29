# CertificationSummary.gd
extends PanelContainer

signal closed

@onready var start_button: Button = %StartButton

func _ready():
	modulate.a = 0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5)
	
	start_button.pressed.connect(_on_start_pressed)
	
	if AudioManager:
		AudioManager.play_sfx(AudioManager.SFX.notification_info)

func _on_start_pressed():
	if AudioManager:
		AudioManager.play_ui_click()
		
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	await tween.finished
	closed.emit()
	queue_free()
