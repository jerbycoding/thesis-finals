extends Control

@onready var quit_button: Button = %QuitButton
@onready var title_label: Label = %TitleLabel
@onready var description_label: Label = %DescriptionLabel

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Animate in
	modulate.a = 0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 1.0)

func _on_quit_pressed():
	if TransitionManager:
		TransitionManager.change_scene_to("res://scenes/ui/TitleScreen.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/ui/TitleScreen.tscn")
