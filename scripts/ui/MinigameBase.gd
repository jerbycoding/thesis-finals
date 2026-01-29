# MinigameBase.gd
# Abstract base class for all 2D tablet minigames.
extends Control

signal completed(results: Dictionary)
signal failed(reason: String)

@export var minigame_name: String = "Generic Minigame"

func start():
	print("[Minigame] Starting: ", minigame_name)
	show()

func stop():
	print("[Minigame] Stopping: ", minigame_name)
	hide()

func _on_win(results: Dictionary = {}):
	completed.emit(results)

func _on_lose(reason: String = "Timeout"):
	failed.emit(reason)
