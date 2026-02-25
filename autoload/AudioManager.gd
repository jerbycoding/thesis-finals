extends Node

# Autoload singleton for playing sound effects and managing background music.

@onready var sfx_player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var music_player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var ambient_player: AudioStreamPlayer = AudioStreamPlayer.new() # For environment loops
@onready var footstep_player: AudioStreamPlayer = AudioStreamPlayer.new() # Dedicated for movement

# Dynamic Typing Cache
var typing_stream: AudioStream = null

var ambient_bus_index: int = -1
var lpf_effect: AudioEffectLowPassFilter = null

func _ready():
	add_child(sfx_player)
	add_child(music_player)
	add_child(ambient_player)
	add_child(footstep_player)
	
	_setup_ambient_bus()
	
	print("AudioManager initialized.")
	
	# Load typing stream for sampling
	if ResourceLoader.exists(SFX.keyboard_typing):
		typing_stream = load(SFX.keyboard_typing)
	
	# Connect to EventBus for automated feedback
	EventBus.ticket_added.connect(func(_t): play_sfx(SFX.ticket_spawn))
	EventBus.ticket_completed.connect(_on_ticket_completed)
	EventBus.terminal_locked.connect(func(_s): play_alert())
	EventBus.terminal_unlocked.connect(func(): play_notification("info"))
	EventBus.terminal_command_executed.connect(_on_terminal_command_executed)
	EventBus.email_decision_processed.connect(_on_email_decision_processed)
	EventBus.app_opened.connect(func(_a, _w): play_sfx(SFX.ui_window_open, -5.0))
	
	# Start initial atmosphere (SOC Office)
	update_ambient_audio(1)

func _setup_ambient_bus():
	ambient_bus_index = AudioServer.get_bus_index("Ambient")
	
	# Fallback: If no Ambient bus, use Master or create one if possible (though creating is complex at runtime)
	if ambient_bus_index == -1:
		ambient_bus_index = AudioServer.get_bus_index("Master")
	
	ambient_player.bus = AudioServer.get_bus_name(ambient_bus_index)
	
	# Check for existing LPF or add one
	for i in range(AudioServer.get_bus_effect_count(ambient_bus_index)):
		if AudioServer.get_bus_effect(ambient_bus_index, i) is AudioEffectLowPassFilter:
			lpf_effect = AudioServer.get_bus_effect(ambient_bus_index, i)
			break
	
	if not lpf_effect:
		lpf_effect = AudioEffectLowPassFilter.new()
		lpf_effect.cutoff_hz = 20000.0 # Effectively off
		AudioServer.add_bus_effect(ambient_bus_index, lpf_effect)

func set_focus_mode(active: bool):
	if not lpf_effect: return
	
	var target_hz = 600.0 if active else 20000.0
	var target_db = -20.0 if active else -15.0
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(lpf_effect, "cutoff_hz", target_hz, 0.8).set_trans(Tween.TRANS_SINE)
	tween.tween_property(ambient_player, "volume_db", target_db, 0.8)
	
	print("AudioManager: Focus Mode ", "ACTIVE" if active else "INACTIVE")

func _on_ticket_completed(_ticket: TicketResource, completion_type: String, _time: float):
	match completion_type:
		"compliant":
			play_success_sound()
		"emergency":
			play_alert()
		"timeout":
			play_notification("error")
		"efficient":
			play_notification("warning")

func play_success_sound():
	# Alternate between success sounds for variety
	var sound = SFX.notification_success if randf() > 0.5 else SFX.success_variant
	play_sfx(sound)

func _on_email_decision_processed(email: EmailResource, decision: String, _state: Dictionary):
	if decision == "approve":
		if email.is_malicious:
			play_notification("error") # Approved malicious email
		else:
			play_success_sound() # Approved legitimate email
	elif decision == "quarantine":
		if email.is_malicious:
			play_success_sound() # Quarantined malicious email
		else:
			play_notification("warning") # Quarantined legitimate email
	elif decision == "escalate":
		play_notification("info")

func _on_terminal_command_executed(_cmd, success, _out):
	if success:
		play_terminal_beep()
	else:
		play_notification("error")

func play_sfx(sfx_path: String, volume_db: float = 0.0):
	if ResourceLoader.exists(sfx_path):
		var p = AudioStreamPlayer.new() # Use temporary players for overlapping SFX
		add_child(p)
		p.stream = load(sfx_path)
		p.volume_db = volume_db
		p.play()
		p.finished.connect(p.queue_free)
	else:
		push_warning("AudioManager: Sound effect not found at path: %s" % sfx_path)

func play_music(music_path: String, volume_db: float = -10.0, loop: bool = true):
	if music_player.playing and music_player.stream and music_player.stream.resource_path == music_path:
		return # Already playing
		
	if ResourceLoader.exists(music_path):
		var audio_stream = load(music_path)
		if audio_stream.has_method("set_loop"): audio_stream.set_loop(loop)
		elif "loop" in audio_stream: audio_stream.loop = loop
			
		music_player.stream = audio_stream
		music_player.volume_db = volume_db
		music_player.play()
	else:
		push_warning("AudioManager: Music not found at path: %s" % music_path)

func stop_music():
	music_player.stop()

# --- Dynamic Audio logic (Sprint 12) ---

func play_dynamic_typing():
	if not typing_stream: return
	
	var p = AudioStreamPlayer.new()
	add_child(p)
	p.stream = typing_stream
	p.volume_db = randf_range(-15.0, -10.0)
	p.pitch_scale = randf_range(0.9, 1.1)
	
	# Randomly sample from the 19s file
	var start_pos = randf_range(0.0, typing_stream.get_length() - 0.2)
	p.play(start_pos)
	
	# Kill the sound after a short burst (simulating a key press)
	get_tree().create_timer(randf_range(0.05, 0.12)).timeout.connect(func():
		p.stop()
		p.queue_free()
	)

func update_ambient_audio(floor_num: int):
	var target_path = ""
	match floor_num:
		1: target_path = SFX.ambient_office
		0: target_path = SFX.ambient_desktop
		-1: target_path = SFX.ambient_vault
		-2: target_path = SFX.ambient_hub
		
	if target_path == "" or not ResourceLoader.exists(target_path):
		ambient_player.stop()
		return
		
	if ambient_player.playing and ambient_player.stream and ambient_player.stream.resource_path == target_path:
		return

	# Fade out and switch
	var tween = create_tween()
	tween.tween_property(ambient_player, "volume_db", -40.0, 0.5)
	tween.tween_callback(func():
		ambient_player.stream = load(target_path)
		if "loop" in ambient_player.stream: ambient_player.stream.loop = true
		ambient_player.play()
	)
	tween.tween_property(ambient_player, "volume_db", -15.0, 1.0)

func update_music_intensity(is_emergency: bool):
	var track = SFX.music_emergency if is_emergency else SFX.music_standard
	play_music(track)

# --- Semantic Audio Helpers ---

func play_ui_click():
	play_sfx(SFX.button_click, -5.0)

func play_ui_hover():
	play_sfx(SFX.button_click, -15.0)

func play_notification(type: String = "info"):
	match type:
		"success": play_sfx(SFX.notification_success)
		"warning": play_sfx(SFX.notification_warning)
		"error": play_sfx(SFX.notification_error)
		_: play_sfx(SFX.notification_info)

func play_alert():
	play_sfx(SFX.consequence_alert)

func play_terminal_beep(volume_db: float = 0.0):
	play_sfx(SFX.terminal_beep, volume_db)

func play_footstep():
	if ResourceLoader.exists(SFX.footsteps_tile):
		footstep_player.stream = load(SFX.footsteps_tile)
		footstep_player.volume_db = -15.0
		footstep_player.play()

func stop_footstep():
	footstep_player.stop()

func play_hardware_slot():
	play_sfx(SFX.hardware_slot, -5.0)

# Predefined SFX paths
var SFX = {
	"notification_info": "res://assets/sfx/notification_info.ogg",
	"notification_success": "res://assets/sfx/notification_success.ogg",
	"success_variant": "res://assets/sfx/success2.ogg",
	"notification_warning": "res://assets/sfx/notification_warning.ogg",
	"notification_error": "res://assets/sfx/notification_error.ogg",
	"button_click": "res://assets/sfx/button_click.ogg",
	"terminal_beep": "res://assets/sfx/terminal_beep.ogg",
	"keyboard_typing": "res://assets/sfx/keyboard_typing.ogg",
	"ui_window_open": "res://assets/sfx/ui_window_open.ogg",
	"ui_data_processing": "res://assets/sfx/ui_data_processing.ogg",
	"footsteps_tile": "res://assets/sfx/footstep-tile.ogg",
	"hardware_slot": "res://assets/sfx/hardware-slot.ogg",
	"ambient_office": "res://assets/sfx/ambient_office.ogg",
	"ambient_desktop": "res://assets/sfx/ambient_desktop.ogg",
	"ambient_vault": "res://assets/sfx/ambient_vault.ogg",
	"ambient_hub": "res://assets/sfx/ambient_hub.ogg",
	"electrical_crackle": "res://assets/sfx/electrical_crackle.ogg",
	"ticket_spawn": "res://assets/sfx/newTicket.ogg",
	"consequence_alert": "res://assets/sfx/notification_error.ogg",
	"music_standard": "res://assets/music/theme-standard.ogg",
	"music_emergency": "res://assets/music/theme-emergency.ogg"
}
