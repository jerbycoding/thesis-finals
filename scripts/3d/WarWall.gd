# WarWall.gd
# Reactive monitoring wall that changes color based on SOC load
extends MeshInstance3D

@export var pulse_speed: float = 1.5
@export var min_energy: float = 1.0
@export var max_energy: float = 2.5

var time: float = 0.0
var target_color: Color = Color.CYAN

func _ready():
	# Connect to EventBus signals to update color
	EventBus.ticket_added.connect(_update_status)
	EventBus.ticket_completed.connect(func(_t, _type, _time): _update_status())
	EventBus.ticket_timeout.connect(func(_id): _update_status())
	
	# Initial check
	_update_status()

func _update_status(_trash = null):
	if not TicketManager: return
	
	var count = TicketManager.get_active_tickets().size()
	
	if count <= 1:
		target_color = Color(0.0, 1.0, 1.0) # Nominal (Cyan/Green)
	elif count <= 3:
		target_color = Color(1.0, 0.8, 0.0) # Warning (Yellow)
	else:
		target_color = Color(1.0, 0.2, 0.1) # Critical (Red)

func _process(delta):
	time += delta * pulse_speed
	var energy = lerp(min_energy, max_energy, (sin(time) + 1.0) / 2.0)
	
	var mat = get_active_material(0)
	if mat is StandardMaterial3D:
		# Smoothly lerp the color for a high-tech transition
		mat.albedo_color = mat.albedo_color.lerp(target_color * 0.5, delta * 2.0)
		mat.emission = mat.emission.lerp(target_color, delta * 2.0)
		mat.emission_energy_multiplier = energy
