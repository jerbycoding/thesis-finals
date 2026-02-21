extends Control

@onready var credits_label = %CreditsLabel

var credits_text = [
	"VERIFY.EXE :: PROJECT_ATTRIBUTION",
	"===========================================================",
	" ",
	"CORE_DEVELOPMENT:",
	"-----------------------------------------------------------",
	"HANS JERBY DE LANA",
	"  > LEAD_PROGRAMMER",
	"  > SYSTEMS_ARCHITECT",
	"  > TECHNICAL_ENGINEER",
	" ",
	"NARRATIVE_&_DESIGN:",
	"-----------------------------------------------------------",
	"MARK LANDER DURIAS",
	"  > CREATIVE_DIRECTOR",
	"  > LEAD_DESIGNER",
	"  > SCENARIO_WRITER",
	" ",
	" ",
	"SPECIAL_THANKS:",
	"-----------------------------------------------------------",
	"GODOT_ENGINE_COMMUNITY",
	"IR_SECURITY_PROFESSIONALS",
	" ",
	"===========================================================",
	"VERSION: 1.0.0-FINAL (GOLD_MASTER)",
	"LICENSE: ACADEMIC_THESIS_PROTOTYPE",
	" ",
	" ",
	"  [ESC] RETURN_TO_TERMINAL"
]

func _ready():
	credits_label.text = ""
	_play_credits()

func _play_credits():
	for line in credits_text:
		credits_label.text += line + "
"
		if AudioManager: AudioManager.play_terminal_beep(-15.0)
		await get_tree().create_timer(0.08).timeout

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if AudioManager: AudioManager.play_ui_click()
		get_parent().queue_free() # This will be in a CanvasLayer
