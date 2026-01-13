extends Button

func _ready():
	pressed.connect(_on_button_pressed)

func _on_button_pressed():
	print("Exit button pressed - returning to 3D")
	TransitionManager.exit_desktop_mode()