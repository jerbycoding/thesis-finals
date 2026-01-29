# CommsMessage.gd
extends PanelContainer

@onready var sender_label = %SenderLabel
@onready var text_label = %TextLabel
@onready var portrait_label = %PortraitLabel

func set_message(sender: String, text: String, portrait: String):
	sender_label.text = sender.to_upper()
	portrait_label.text = portrait
	
	# Typewriter effect
	text_label.text = ""
	var tween = create_tween()
	tween.tween_method(func(v): text_label.text = text.substr(0, v), 0, text.length(), text.length() * 0.02)
