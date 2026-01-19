
extends Control

signal fade_finished

@onready var title_label: Label = get_node_or_null("TitleLabel")

func set_title_card(text: String):
	if title_label:
		title_label.text = text
		title_label.visible = !text.is_empty()

func fade_in():
	print("DEBUG: fade_in: Showing overlay.")
	show()
	$AnimationPlayer.play("fade_in")
	print("DEBUG: fade_in: 'fade_in' animation started. Awaiting finish...")
	await $AnimationPlayer.animation_finished
	
	# If we have a title card, wait extra time for it to be read
	if title_label and title_label.visible:
		await get_tree().create_timer(2.0).timeout

	print("DEBUG: fade_in: Animation finished. Emitting signal.")
	fade_finished.emit()

func fade_out():
	$AnimationPlayer.play("fade_out")
	await $AnimationPlayer.animation_finished
	hide()
	fade_finished.emit()
