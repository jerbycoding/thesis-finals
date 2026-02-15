extends Button

@onready var icon_rect = %IconRect
@onready var label = %Label

var app_id: String = ""
var cached_title: String = ""

func setup(_app_id: String, title: String):
	app_id = _app_id
	cached_title = title
	if is_inside_tree():
		_apply_visuals()

func _ready():
	_apply_visuals()

func _apply_visuals():
	if label:
		label.text = cached_title
	
	# Icon logic
	var icon_name = app_id
	match app_id:
		"tickets": icon_name = "ticket"
		"decrypt": icon_name = "decryption"
		"taskmanager": icon_name = "resources"
	
	var icon_path = "res://assets/icons/" + icon_name + ".png"
	if ResourceLoader.exists(icon_path) and icon_rect:
		icon_rect.texture = load(icon_path)
