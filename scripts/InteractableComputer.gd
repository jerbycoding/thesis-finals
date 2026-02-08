
extends StaticBody3D

signal player_entered_interaction
signal player_exited_interaction

@onready var computer_mesh = $Prop_ComputerSet

var is_highlighted: bool = false
var highlight_time: float = 0.0

func _ready():
	$InteractionArea.body_entered.connect(_on_body_entered)
	$InteractionArea.body_exited.connect(_on_body_exited)

func set_highlight(active: bool):
	is_highlighted = active

func _process(_delta):
	# Removed screen glow logic to preserve high-res wallpaper clarity
	pass

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
