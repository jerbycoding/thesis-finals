# CommsSidebar.gd
extends Control

@onready var message_container = %MessageContainer
@onready var scroll_container = %ScrollContainer

var message_scene = preload("res://scenes/ui/CommsMessage.tscn")

func _ready():
	hide()
	# Clear any editor placeholders
	for child in message_container.get_children():
		child.queue_free()

func add_message(sender: String, text: String, portrait: String = "👔"):
	# Only auto-show if we are in 2D mode. 
	# In 3D mode, the TutorialManager will show us after the transition.
	if GameState and GameState.is_in_2d_mode():
		show()
	
	var msg = message_scene.instantiate()
	message_container.add_child(msg)
	msg.set_message(sender, text, portrait)
	
	# Scroll to bottom
	await get_tree().process_frame
	scroll_container.scroll_vertical = scroll_container.get_v_scroll_bar().max_value
	
	if AudioManager:
		AudioManager.play_terminal_beep()

func clear_history():
	for child in message_container.get_children():
		child.queue_free()
