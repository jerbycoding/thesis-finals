extends Node3D

@export var spawn_point: Node3D

func _ready():
	# Set player spawn point
	if spawn_point == null:
		spawn_point = $SpawnPoint

	print("HackerRoom loaded - Role: ", "HACKER" if GameState and GameState.current_role == GameState.Role.HACKER else "ANALYST")

	# Phase 5: Play pending Broker dialogue after transition completes
	if NarrativeDirector:
		# Give the scene a brief moment to settle, then play dialogue
		await get_tree().create_timer(0.5).timeout
		NarrativeDirector.play_pending_broker_dialogue()

func _on_floor_body_entered(_body):
	# Optional: Trigger ambient audio for hacker room
	if AudioManager:
		AudioManager.update_ambient_audio(0)  # Desktop/office ambient
