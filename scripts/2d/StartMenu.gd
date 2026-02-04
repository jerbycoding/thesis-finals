extends PanelContainer

signal app_selected(app_id: String)

@onready var app_list = %AppList

func _ready():
	visible = false
	_populate_apps()

func toggle():
	visible = !visible
	if visible:
		# Animation: Slide Up
		var start_pos = Vector2(position.x, get_viewport_rect().size.y)
		var end_pos = Vector2(position.x, get_viewport_rect().size.y - size.y - 45) # 45 is taskbar offset
		position = start_pos
		var tween = create_tween()
		tween.tween_property(self, "position", end_pos, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _populate_apps():
	if not DesktopWindowManager: return
	
	# Clear
	for child in app_list.get_children():
		child.queue_free()
		
	# Get sorted apps
	var apps = DesktopWindowManager.app_configs.keys()
	apps.sort()
	
	for app_id in apps:
		var config = DesktopWindowManager.app_configs[app_id]
		_create_app_button(app_id, config.title)

func _create_app_button(app_id: String, title: String):
	var btn = Button.new()
	btn.text = "  " + title
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.custom_minimum_size.y = 35
	btn.flat = true
	
	# Icon logic
	var icon_name = app_id
	match app_id:
		"tickets": icon_name = "ticket"
		"decrypt": icon_name = "decryption"
		"taskmanager": icon_name = "resources"
	
	var icon_path = "res://assets/icons/" + icon_name + ".png"
	if ResourceLoader.exists(icon_path):
		btn.icon = load(icon_path)
		btn.expand_icon = true
	
	btn.pressed.connect(func():
		app_selected.emit(app_id)
		visible = false
	)
	
	app_list.add_child(btn)
