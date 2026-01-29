# RuleSliderMinigame.gd
extends "res://scripts/ui/MinigameBase.gd"

@onready var packet_container = %PacketContainer
@onready var slider = %RuleSlider
@onready var integrity_bar = %IntegrityBar
@onready var interference_bar = %InterferenceBar

@onready var target_label = %TargetLabel

var corporate_integrity: float = 0.0
var interference_level: float = 0.0
var is_active: bool = false
var target_name: String = "UNKNOWN_NODE"

var packet_spawn_timer: float = 0.0
const SPAWN_RATE = 0.8

func set_target(node_id: String):
	target_name = node_id
	if is_instance_valid(target_label):
		target_label.text = "AUDITING: " + node_id.to_upper()

func _ready():
	minigame_name = "ACL Signal Calibration"
	slider.value_changed.connect(_on_slider_changed)
	if target_label: target_label.text = "AUDITING: " + target_name.to_upper()

func start():
	super.start()
	corporate_integrity = 20.0 # Start with base signal
	interference_level = 0.0
	is_active = true
	_update_ui()

func _process(delta):
	if not is_active: return
	
	# Spawn Packets
	packet_spawn_timer += delta
	if packet_spawn_timer >= SPAWN_RATE:
		packet_spawn_timer = 0
		_spawn_packet()
	
	# Update existing packets
	for p in packet_container.get_children():
		p.position.x += delta * 250.0 # Speed
		
		# Collision check with the slider line
		if p.position.x > 290 and p.position.x < 310:
			_check_packet_collision(p)
			continue # Already handled and queued for deletion
			
		# Cleanup if missed
		if p.position.x > 450:
			p.queue_free()

func _spawn_packet():
	var p = ColorRect.new()
	p.custom_minimum_size = Vector2(12, 12)
	p.position = Vector2(0, randf_range(50, 350))
	
	var is_malicious = randf() < 0.4
	p.color = Color.RED if is_malicious else Color.GREEN
	p.set_meta("malicious", is_malicious)
	
	packet_container.add_child(p)

func _check_packet_collision(p):
	var p_y = p.position.y
	var s_y = slider.value # Slider maps to Y height
	
	# If packet is within the "Filtered" range of the slider
	# Let's say the slider has a filter window of 60 pixels
	var in_filter = abs(p_y - s_y) < 40
	var is_malicious = p.get_meta("malicious")
	
	if in_filter:
		# Blocked!
		if is_malicious:
			corporate_integrity += 5.0
			if AudioManager: AudioManager.play_sfx(AudioManager.SFX.notification_success)
		else:
			corporate_integrity -= 10.0 # Blocked legitimate traffic!
			if AudioManager: AudioManager.play_sfx(AudioManager.SFX.notification_error)
	else:
		# Passed through
		if is_malicious:
			interference_level += 15.0
			corporate_integrity -= 5.0
		else:
			corporate_integrity += 2.0 # Good traffic received
			
	p.queue_free()
	_update_ui()
	_check_conditions()

func _update_ui():
	corporate_integrity = clamp(corporate_integrity, 0, 100)
	interference_level = clamp(interference_level, 0, 100)
	integrity_bar.value = corporate_integrity
	interference_bar.value = interference_level

func _check_conditions():
	if corporate_integrity >= 100:
		is_active = false
		_on_win({"score": 100})
	elif interference_level >= 100:
		is_active = false
		_on_lose("Signal Overrun")

func _on_slider_changed(_val):
	pass # Visual update handled by Godot slider
