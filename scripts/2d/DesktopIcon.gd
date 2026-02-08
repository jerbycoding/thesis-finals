extends Button
class_name DesktopIcon

signal activated(action_id: String)

@export var app_id: String = ""
@export var label_text: String = "App"
@export var icon_texture: Texture2D

@onready var texture_rect = %IconTexture
@onready var label = %Label

func setup(_app_id: String, _label: String, _icon: Texture2D):
	app_id = _app_id
	label_text = _label
	icon_texture = _icon
	_refresh_visuals()

func _ready():
	_refresh_visuals()
	pressed.connect(_on_pressed)
	# Double click logic can be added later if needed

func _refresh_visuals():
	if texture_rect and icon_texture:
		texture_rect.texture = icon_texture
	if label:
		label.text = label_text

func _on_pressed():
	if app_id != "":
		activated.emit(app_id)
		if DesktopWindowManager:
			DesktopWindowManager.open_app(app_id)
		if AudioManager:
			AudioManager.play_ui_click()
