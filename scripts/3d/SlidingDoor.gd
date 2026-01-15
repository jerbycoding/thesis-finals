# SlidingDoor.gd
extends Node3D

@export var open_distance: float = 1.8
@export var open_speed: float = 2.0
@export_enum("X", "Y", "Z") var slide_axis: String = "X"

@onready var left_panel = $LeftPanel
@onready var right_panel = $RightPanel

var is_open: bool = false
var start_pos_left: float = 0.0
var start_pos_right: float = 0.0

func _ready():
	if left_panel: start_pos_left = _get_axis_pos(left_panel)
	if right_panel: start_pos_right = _get_axis_pos(right_panel)

func _process(delta):
	var target_left = start_pos_left - (open_distance if is_open else 0.0)
	var target_right = start_pos_right + (open_distance if is_open else 0.0)
	
	if left_panel:
		var current = _get_axis_pos(left_panel)
		var new_val = move_toward(current, target_left, open_speed * delta)
		_set_axis_pos(left_panel, new_val)
		
	if right_panel:
		var current = _get_axis_pos(right_panel)
		var new_val = move_toward(current, target_right, open_speed * delta)
		_set_axis_pos(right_panel, new_val)

func _get_axis_pos(node: Node3D) -> float:
	match slide_axis:
		"X": return node.position.x
		"Y": return node.position.y
		"Z": return node.position.z
	return 0.0

func _set_axis_pos(node: Node3D, val: float):
	match slide_axis:
		"X": node.position.x = val
		"Y": node.position.y = val
		"Z": node.position.z = val

func open():
	is_open = true

func close():
	is_open = false
