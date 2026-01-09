
extends Control

signal fade_finished

func fade_in():
	print("DEBUG: fade_in: Showing overlay.")
	show()
	$AnimationPlayer.play("fade_in")
	print("DEBUG: fade_in: 'fade_in' animation started. Awaiting finish...")
	await $AnimationPlayer.animation_finished
	print("DEBUG: fade_in: Animation finished. Emitting signal.")
	fade_finished.emit()

func fade_out():
	$AnimationPlayer.play("fade_out")
	await $AnimationPlayer.animation_finished
	hide()
	fade_finished.emit()
