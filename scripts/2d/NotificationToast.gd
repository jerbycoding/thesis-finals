# NotificationToast.gd
extends Control

signal notification_finished

var notification_text: String = ""
var notification_type: String = "info" 
var display_duration: float = 4.0

@onready var indicator: ColorRect = %Indicator
@onready var label: Label = %Label

func _ready():
	if label:
		label.text = notification_text
	
	_setup_style()
	
	var timer = get_tree().create_timer(display_duration)
	timer.timeout.connect(fade_out)
	
	fade_in()

func _setup_style():
	match notification_type:
		"success": indicator.color = GlobalConstants.UI_COLORS.SUCCESS_FLAT
		"warning": indicator.color = GlobalConstants.UI_COLORS.WARNING_FLAT
		"error": indicator.color = GlobalConstants.UI_COLORS.ERROR_FLAT
		_: indicator.color = GlobalConstants.UI_COLORS.INFO_BLUE

func fade_in():
	modulate.a = 0.0
	position.x += 20 # Slide in from right
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.0, 0.2)
	tween.tween_property(self, "position:x", position.x - 20, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func fade_out():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	await tween.finished
	notification_finished.emit()
	queue_free()

func set_notification(text: String, type: String = "info", duration: float = 4.0):
	notification_text = text
	notification_type = type
	display_duration = duration