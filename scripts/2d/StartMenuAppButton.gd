extends Button

@onready var icon_rect = %IconRect
@onready var label = %Label

var app_id: String = ""
var cached_title: String = ""
var greyscale_shader = preload("res://shaders/greyscale.gdshader")
var is_authorized: bool = true
var is_provisioning: bool = false

func setup(_app_id: String, title: String):
	app_id = _app_id
	cached_title = title
	if is_inside_tree():
		_apply_visuals()
		_refresh_authorization()

func _ready():
	_apply_visuals()
	_refresh_authorization()
	EventBus.permissions_updated.connect(_refresh_authorization)

func _refresh_authorization():
	if app_id == "" or not DesktopWindowManager: return
	
	var permission = DesktopWindowManager.can_open_app(app_id)
	var was_authorized = is_authorized
	is_authorized = permission.allowed
	
	if not was_authorized and is_authorized and not is_provisioning:
		_play_provisioning_sequence()
	else:
		_apply_auth_visuals()

func _apply_auth_visuals():
	if not icon_rect: return
	
	if not is_authorized:
		var mat = ShaderMaterial.new()
		mat.shader = greyscale_shader
		icon_rect.material = mat
		modulate.a = 0.6
	else:
		icon_rect.material = null
		modulate.a = 1.0

func _play_provisioning_sequence():
	is_provisioning = true
	var tween = create_tween()
	if icon_rect.material is ShaderMaterial:
		tween.tween_property(icon_rect.material, "shader_parameter/amount", 0.0, 1.0)
	tween.tween_property(self, "modulate:a", 1.0, 0.5)
	await tween.finished
	is_provisioning = false
	_apply_auth_visuals()

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
