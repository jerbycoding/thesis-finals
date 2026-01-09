
extends StaticBody3D

signal player_entered_interaction
signal player_exited_interaction

func _ready():
	$InteractionArea.body_entered.connect(_on_body_entered)
	$InteractionArea.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "Player3D":
		player_entered_interaction.emit()
	if body.has_method("set_near_computer"):
		body.set_near_computer(self, true)

func _on_body_exited(body):
	if body.name == "Player3D":
		player_exited_interaction.emit()
	if body.has_method("set_near_computer"):
		body.set_near_computer(self, false)
