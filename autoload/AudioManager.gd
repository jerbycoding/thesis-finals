extends Node

# Autoload singleton for playing sound effects and managing background music.

@onready var sfx_player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var music_player: AudioStreamPlayer = AudioStreamPlayer.new()

func _ready():
	add_child(sfx_player)
	add_child(music_player)
	print("AudioManager initialized.")
	
	# Connect to EventBus for automated feedback
	EventBus.ticket_added.connect(func(_t): play_sfx(SFX.ticket_spawn))
	EventBus.ticket_completed.connect(_on_ticket_completed)
	EventBus.terminal_locked.connect(func(_s): play_alert())
	EventBus.terminal_unlocked.connect(func(): play_notification("info"))
	EventBus.terminal_command_executed.connect(_on_terminal_command_executed)
	EventBus.email_decision_processed.connect(_on_email_decision_processed)

func _on_ticket_completed(_ticket: TicketResource, completion_type: String, _time: float):
	match completion_type:
		"compliant":
			play_notification("success")
		"emergency":
			play_alert()
		"timeout":
			play_notification("error")
		"efficient":
			play_notification("warning")

func _on_email_decision_processed(email: EmailResource, decision: String, _state: Dictionary):
	if decision == "approve":
		if email.is_malicious:
			play_notification("error") # Approved malicious email
		else:
			play_notification("success") # Approved legitimate email
	elif decision == "quarantine":
		if email.is_malicious:
			play_notification("success") # Quarantined malicious email
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
		sfx_player.stream = load(sfx_path)
		sfx_player.volume_db = volume_db
		sfx_player.play()
	else:
		push_warning("AudioManager: Sound effect not found at path: %s" % sfx_path)

func play_music(music_path: String, volume_db: float = 0.0, loop: bool = true):
	if ResourceLoader.exists(music_path):
		var audio_stream = load(music_path)
		
		# In Godot 4, the 'loop' property is on the stream, not the player.
		if audio_stream.has_method("set_loop"): # For some stream types
			audio_stream.set_loop(loop)
		elif "loop" in audio_stream: # For AudioStreamOggVorbis
			audio_stream.loop = loop
			
		music_player.stream = audio_stream
		music_player.volume_db = volume_db
		music_player.play()
	else:
		push_warning("AudioManager: Music not found at path: %s" % music_path)

func stop_music():
	music_player.stop()

# --- Semantic Audio Helpers (Technical Debt Refactor) ---

func play_ui_click():
	play_sfx(SFX.button_click, -5.0)

func play_ui_hover():
	# Subtle hover
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

# Predefined SFX paths (example)
var SFX = {
	"notification_info": "res://assets/sfx/notification_info.ogg", #/
	"notification_success": "res://assets/sfx/notification_success.ogg", #/
	"notification_warning": "res://assets/sfx/notification_warning.ogg", #/
	"notification_error": "res://assets/sfx/notification_error.ogg", #/
	"button_click": "res://assets/sfx/button_click.ogg", # /
	"terminal_beep": "res://assets/sfx/terminal_beep.ogg",  #/
	"music_ambient_desktop": "res://assets/music/ambient_desktop.ogg", # /
	# Add more as needed
	"consequence_alert": "res://assets/sfx/notification_error.ogg", # Using existing error sound
	"ticket_spawn": "res://assets/sfx/newTicket.ogg", # Using existing new ticket sound
	"ui_hover": "res://assets/sfx/button_click.ogg", # Using existing button click sound
}
