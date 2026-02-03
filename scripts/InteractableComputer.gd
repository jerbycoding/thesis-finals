
extends StaticBody3D

signal player_entered_interaction
signal player_exited_interaction

@onready var monitor = $Monitor
@onready var computer_mesh = $Prop_ComputerSet

var is_highlighted: bool = false
var highlight_time: float = 0.0

func _ready():
	$InteractionArea.body_entered.connect(_on_body_entered)
	$InteractionArea.body_exited.connect(_on_body_exited)

func set_highlight(active: bool):
	is_highlighted = active
	if not active:
		if monitor and monitor.get_active_material(0):
			monitor.get_active_material(0).emission_enabled = false

func _process(delta):
	if is_highlighted and monitor:
		highlight_time += delta * 5.0
		var energy = 0.5 + (sin(highlight_time) + 1.0) * 0.5
		var mat = monitor.get_active_material(0)
		if mat is StandardMaterial3D:
			mat.emission_enabled = true
			mat.emission = Color(0.2, 1.0, 0.2) # Cyber Green
			mat.emission_energy_multiplier = energy

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
