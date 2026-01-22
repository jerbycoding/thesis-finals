# InteractionPrompt.gd
extends Control

@onready var container: PanelContainer = %PromptContainer
@onready var label: Label = %Label

func _ready():
	hide()
	container.modulate.a = 0
	
	# Connect to EventBus for decoupled interaction handling
	if EventBus:
		EventBus.request_prompt.connect(_on_request_prompt)

func _on_request_prompt(text: String, active: bool):
	if active:
		show_prompt(text)
	else:
		hide_prompt()

func show_prompt(text: String):
	label.text = text
	show()
	
	# Fade in
	var tween = create_tween()
	tween.tween_property(container, "modulate:a", 1.0, 0.15)

func hide_prompt():
	var tween = create_tween()
	tween.tween_property(container, "modulate:a", 0.0, 0.1)
	await tween.finished
	if container.modulate.a == 0:
		hide()
