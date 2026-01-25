# InteractableDoor.gd
# A door that toggles open/closed when interacted with.
extends BaseNPC 

@export var open_angle: float = 90.0
@export var open_speed: float = 4.0

var is_open: bool = false

func _ready():
	npc_name = "Door"
	# Connect interaction signals
	var area = get_node_or_null("InteractionArea")
	if area:
		area.body_entered.connect(_on_body_entered)
		area.body_exited.connect(_on_body_exited)

func set_highlight(_active: bool):
	# Doors don't need visual highlights for now, 
	# but the method must exist for the PlayerController.
	pass

func _on_body_entered(body):
	if body.name == "Player3D":
		body.set_near_npc(self, true)

func _on_body_exited(body):
	if body.name == "Player3D":
		body.set_near_npc(self, false)

func start_dialogue(_id: String = "default"):
	toggle()

func toggle():
	is_open = !is_open
	print("[Door] Toggled. Open: ", is_open)

func open():
	is_open = true

func close():
	is_open = false

func _process(delta):
	var target_y = deg_to_rad(open_angle) if is_open else 0.0
	rotation.y = lerp_angle(rotation.y, target_y, open_speed * delta)
