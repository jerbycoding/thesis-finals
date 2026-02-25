extends Button
class_name DesktopIcon

signal activated(action_id: String)

@export var app_id: String = ""
@export var label_text: String = "App"
@export var icon_texture: Texture2D

@onready var texture_rect = %IconTexture
@onready var label = %Label

var greyscale_shader = preload("res://shaders/greyscale.gdshader")
var is_authorized: bool = true
var is_provisioning: bool = false

func setup(_app_id: String, _label: String, _icon: Texture2D):
	app_id = _app_id
	label_text = _label
	icon_texture = _icon
	_refresh_visuals()
	_refresh_authorization()

func _ready():
	_refresh_visuals()
	_refresh_authorization()
	pressed.connect(_on_pressed)
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
	if not texture_rect: return
	
	if not is_authorized:
		var mat = ShaderMaterial.new()
		mat.shader = greyscale_shader
		texture_rect.material = mat
		modulate.a = 0.6
		tooltip_text = "PENDING_SOP_CLEARANCE"
	else:
		texture_rect.material = null
		modulate.a = 1.0
		tooltip_text = label_text

func _play_provisioning_sequence():
	is_provisioning = true
	tooltip_text = "PROVISIONING_ACCESS..."
	
	# Play digital "Unlock" sound
	if AudioManager: AudioManager.play_terminal_beep(-5.0)
	
	# Visual Pulse / Glitch
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.1)
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
	
	# Transition from greyscale to color
	if texture_rect.material is ShaderMaterial:
		var mat = texture_rect.material
		tween.tween_property(mat, "shader_parameter/amount", 0.0, 1.5).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	
	await tween.finished
	is_provisioning = false
	_apply_auth_visuals()

func _refresh_visuals():
	if texture_rect and icon_texture:
		texture_rect.texture = icon_texture
	if label:
		label.text = label_text

func _on_pressed():
	if app_id != "":
		activated.emit(app_id)
		if DesktopWindowManager:
			await DesktopWindowManager.open_app(app_id)
		if AudioManager:
			AudioManager.play_ui_click()
